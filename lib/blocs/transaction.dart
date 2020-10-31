import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/transaction_repository.dart';
import 'package:yababos/states/transaction.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository db;

  TransactionBloc({@required this.db}) : super(TransactionLoading());

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
    db.add(event.transaction);
    return TransactionLoaded.all(await db.getAll());
  }

  Future<TransactionState> _mapDeletetoState(TransactionDelete event) async {
    db.delete(event.id);
    return TransactionLoaded();
  }

  Future<TransactionState> _mapUpdatetoState(TransactionUpdate event) async {
    db.update(event.transaction);
    return TransactionLoaded();
  }

  Future<TransactionState> _mapGettoState(TransactionGet event) async {
    return TransactionLoaded.one(await db.get(event.id));
  }

  _mapGetAlltoState(TransactionGetAll event) async {
    return TransactionLoaded.all(await db.getAll());
  }
}
