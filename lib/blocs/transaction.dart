import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/repositories/transaction.dart';
import 'package:yababos/states/transaction.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;
  int _selectedWallet;
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;

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
    } else if (event is TransactionGetWallet) {
      yield await _mapGetWallettoState(event);
    } else if (event is TransactionSearch) {
      yield await _mapSearchtoState(event);
    }
  }

  Future<TransactionState> _mapAddtoState(TransactionAdd event) async {
    await _transactionRepository.add(event.transaction);
    return await _selectedWalletTransactions();
  }

  Future<TransactionState> _mapDeletetoState(TransactionDelete event) async {
    await _transactionRepository.delete(event.id);
    return await _selectedWalletTransactions();
  }

  Future<TransactionState> _mapUpdatetoState(TransactionUpdate event) async {
    await _transactionRepository.update(event.transaction);
    return await _selectedWalletTransactions();
  }

  Future<TransactionState> _mapGettoState(TransactionGet event) async {
    return TransactionLoaded.one(await _transactionRepository.get(event.id));
  }

  _mapGetAlltoState(TransactionGetAll event) async {
    return TransactionLoaded.many(await _transactionRepository.getAll());
  }

  _mapGetWallettoState(TransactionGetWallet event) async {
    _selectedWallet = event.wallet;
    _year = event.year;
    _month = event.month;

    return await _selectedWalletTransactions();
  }

  Future<WalletTransactionsLoaded> _selectedWalletTransactions() async {
    return WalletTransactionsLoaded(
        await _transactionRepository.walletTransactions(
            _selectedWallet, _year, _month),
        await _transactionRepository.balance(_selectedWallet));
  }

  Future<TransactionsFound> _mapSearchtoState(TransactionSearch event) async {
    List<Transaction> transactions = await _transactionRepository.search(
        event.transaction, event.transactionEnd);

    double balance = 0;
    for (Transaction transaction in transactions) {
      if (transaction.from == null)
        balance += transaction.amount;
      else
        balance -= transaction.amount;
    }

    return TransactionsFound(transactions, balance);
  }
}
