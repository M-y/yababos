import 'package:collection/collection.dart' show IterableExtension;
import 'package:yababos/models/tag.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/transaction_search.dart';
import 'package:yababos/repositories/transaction.dart';

class TransactionInmemory extends TransactionRepository {
  List<Transaction> _transactions = [];
  int _lastId = 0;

  @override
  Future add(Transaction transaction) {
    return Future(() {
      _lastId = _lastId + 1;
      transaction.id = _lastId;
      _transactions.add(transaction);
    });
  }

  @override
  Future<List<Transaction>> getAll({bool isUtc = false}) {
    return Future(() => _transactions);
  }

  @override
  Future delete(int id) {
    return Future(() async {
      Transaction? transaction = await get(id);
      _transactions.remove(transaction);
    });
  }

  @override
  Future<Transaction?> get(int id) {
    return Future(() {
      return _transactions.firstWhereOrNull(
        (element) => element.id == id,
      );
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
      List<Transaction> transactions = _transactions.toList();
      transactions.retainWhere((t) => t.from == wallet || t.to == wallet);
      double balance = 0;
      for (Transaction transaction in transactions) {
        if (transaction.from == wallet) balance -= transaction.amount;
        if (transaction.to == wallet) balance += transaction.amount;
      }

      return balance;
    });
  }

  @override
  Future<List<Transaction>> walletTransactions(
      int wallet, int year, int month) {
    return Future(() {
      DateTime start = DateTime(year, month);
      DateTime end = DateTime(year, month + 1);
      if (month == 12) end = DateTime(year + 1, 1);

      List<Transaction> transactions = _transactions.toList();
      transactions.retainWhere((t) =>
          (t.from == wallet || t.to == wallet) &&
          t.when.compareTo(start) >= 0 &&
          t.when.compareTo(end) < 0);
      transactions.sort((a, b) => b.when.compareTo(a.when));
      return transactions;
    });
  }

  @override
  Future clear() {
    return Future(() {
      _transactions.clear();
      _lastId = 0;
    });
  }

  @override
  Future<List<Transaction>> search(TransactionSearch transaction,
      [TransactionSearch? transactionEnd]) {
    return Future(() {
      DateTime? start;
      DateTime? end;
      if (transaction.when != null) {
        start = transaction.when;
        end = DateTime(transaction.when!.year, transaction.when!.month,
            transaction.when!.day + 1);
        if (transactionEnd != null) end = transactionEnd.when;
      }

      List<Transaction> transactions = _transactions.toList();
      transactions.retainWhere((t) {
        bool test = true;

        if (transaction.from != null) test = test && t.from == transaction.from;

        if (transaction.to != null) test = test && t.to == transaction.to;

        if (transaction.amount != null)
          test = test && t.amount == transaction.amount;

        if (transaction.description != null)
          test = test && t.description!.contains(transaction.description!);

        if (transaction.tags != null) {
          bool tagTest = false;
          if (t.tags != null) {
            for (Tag tag in transaction.tags!)
              tagTest = tagTest || t.tags!.contains(tag);
          }

          test = test && tagTest;
        }

        if (start != null)
          test = test &&
              (t.when.isAtSameMomentAs(start) || t.when.isAfter(start)) &&
              t.when.isBefore(end!);

        return test;
      });

      transactions.sort((a, b) => b.when.compareTo(a.when));
      return transactions;
    });
  }
}
