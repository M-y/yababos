import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/repositories/transaction_repository.dart';
import 'package:yababos/states/transaction.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionBloc(this._transactionRepository) : super(TransactionLoading());

  @override
  Stream<TransactionState> mapEventToState(TransactionEvent event) async* {
    if (event is TransactionAdd) {
      yield await _mapAddtoState(event);
    } else if (event is TransactionDelete) {
      yield await _mapDeletetoState(event);
    } else if (event is TransactionUpdate) {
      yield await _mapUpdatetoState(event);
    } else if (event is TransactionGet) {
      yield await _mapGettoState(event);
    } else if (event is TransactionGetAll) {
      yield await _mapGetAlltoState(event);
    }
  }

  Future<TransactionState> _mapAddtoState(TransactionAdd event) async {
    await _transactionRepository.add(event.transaction);
    return TransactionLoaded.all(await _transactionRepository.getAll());
  }

  Future<TransactionState> _mapDeletetoState(TransactionDelete event) async {
    await _transactionRepository.delete(event.id);
    return TransactionLoaded.all(await _transactionRepository.getAll());
  }

  Future<TransactionState> _mapUpdatetoState(TransactionUpdate event) async {
    await _transactionRepository.update(event.transaction);
    return TransactionLoaded.all(await _transactionRepository.getAll());
  }

  Future<TransactionState> _mapGettoState(TransactionGet event) async {
    return TransactionLoaded.one(await _transactionRepository.get(event.id));
  }

  _mapGetAlltoState(TransactionGetAll event) async {
    return TransactionLoaded.all(await _transactionRepository.getAll());
  }
}
