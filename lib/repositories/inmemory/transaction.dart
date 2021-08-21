import 'package:yababos/models/transaction.dart';
import 'package:yababos/repositories/transaction_repository.dart';

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

  @override
  Future<double> balance(int wallet) {
    return Future(() async {
      List<Transaction> transactions = await walletTransactions(wallet);
      double balance = 0;
      for (Transaction transaction in transactions) {
        if (transaction.from == wallet) balance -= transaction.amount;
        if (transaction.to == wallet) balance += transaction.amount;
      }

      return balance;
    });
  }

  @override
  Future<List<Transaction>> walletTransactions(int wallet) {
    return Future(() {
      List<Transaction> transactions = _transactions.toList();
      transactions.retainWhere((t) => t.from == wallet || t.to == wallet);
      transactions.sort((a, b) => a.when.compareTo(b.when));
      return transactions;
    });
  }
}
