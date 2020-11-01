import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/transaction_repository.dart';

class TransactionInmemory extends TransactionRepository {
  List<Transaction> _transactions = [];

  @override
  Future add(Transaction transaction) {
    return Future(() {
      transaction.id = _transactions.length + 1;
      _transactions.add(transaction);
    });
  }

  @override
  Future<List<Transaction>> getAll() {
    return Future.delayed(Duration(seconds: 3), () => _transactions);
  }

  @override
  Future delete(int id) {
    return Future(() async {
      Transaction transaction = await get(id);
      _transactions.remove(transaction);
    });
  }

  @override
  Future<Transaction> get(int id) {
    return Future(() {
      return _transactions.firstWhere((element) => element.id == id);
    });
  }

  @override
  Future update(Transaction transaction) {
    return Future(() {
      _transactions[_transactions
          .indexWhere((element) => element.id == transaction.id)] = transaction;
    });
  }
}
