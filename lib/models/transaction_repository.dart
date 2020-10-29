import 'package:yababos/models/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAll();
  Future<Transaction> get(int id);

  Future add(Transaction transaction);
  Future update(Transaction transaction);
  Future delete(int id);
}
