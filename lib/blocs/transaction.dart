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

  TransactionBloc(this._transactionRepository) : super(TransactionLoading()) {
    on<TransactionAdd>(_mapAddtoState);
    on<TransactionDelete>(_mapDeletetoState);
    on<TransactionUpdate>(_mapUpdatetoState);
    on<TransactionGet>(_mapGettoState);
    on<TransactionGetAll>(_mapGetAlltoState);
    on<TransactionGetWallet>(_mapGetWallettoState);
    on<TransactionSearch>(_mapSearchtoState);
  }

  Future<void> _mapAddtoState(
      TransactionAdd event, Emitter<TransactionState> emit) async {
    await _transactionRepository.add(event.transaction);
    return emit(await _selectedWalletTransactions());
  }

  Future<void> _mapDeletetoState(
      TransactionDelete event, Emitter<TransactionState> emit) async {
    await _transactionRepository.delete(event.id);
    return emit(await _selectedWalletTransactions());
  }

  Future<void> _mapUpdatetoState(
      TransactionUpdate event, Emitter<TransactionState> emit) async {
    await _transactionRepository.update(event.transaction);
    return emit(await _selectedWalletTransactions());
  }

  Future<void> _mapGettoState(
      TransactionGet event, Emitter<TransactionState> emit) async {
    return emit(
        TransactionLoaded.one(await _transactionRepository.get(event.id)));
  }

  Future<void> _mapGetAlltoState(
      TransactionGetAll event, Emitter<TransactionState> emit) async {
    return emit(TransactionLoaded.many(await _transactionRepository.getAll()));
  }

  Future<void> _mapGetWallettoState(
      TransactionGetWallet event, Emitter<TransactionState> emit) async {
    _selectedWallet = event.wallet;
    _year = event.year;
    _month = event.month;

    return emit(await _selectedWalletTransactions());
  }

  Future<WalletTransactionsLoaded> _selectedWalletTransactions() async {
    return WalletTransactionsLoaded(
        await _transactionRepository.walletTransactions(
            _selectedWallet, _year, _month),
        await _transactionRepository.balance(_selectedWallet));
  }

  Future<void> _mapSearchtoState(
      TransactionSearch event, Emitter<TransactionState> emit) async {
    List<Transaction> transactions = await _transactionRepository.search(
        event.transaction, event.transactionEnd);

    double balance = 0;
    for (Transaction transaction in transactions) {
      if (transaction.from == null)
        balance += transaction.amount;
      else
        balance -= transaction.amount;
    }

    return emit(TransactionsFound(transactions, balance));
  }
}
