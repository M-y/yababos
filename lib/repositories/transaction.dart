import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/transaction_search.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAll({bool isUtc = false});
  Future<Transaction?> get(int id);

  Future add(Transaction transaction);
  Future update(Transaction transaction);
  Future delete(int id);

  Future<double > balance(int wallet);
  Future<List<Transaction>> walletTransactions(
      int wallet, int year, int month);
  Future<List<Transaction>> search(TransactionSearch transaction,
      [TransactionSearch? transactionEnd]);

  Future clear();
}
