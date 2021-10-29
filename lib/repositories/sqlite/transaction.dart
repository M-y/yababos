import 'package:yababos/models/transaction.dart';
import 'package:yababos/repositories/sqlite/yababos.dart';
import 'package:yababos/repositories/transaction_repository.dart';

class TransactionSqlite extends TransactionRepository {
  @override
  Future add(Transaction transaction) {
    return Future(() async {
      await (await YababosSqlite.getDatabase()).rawInsert('''
        INSERT INTO transactions
        (
          fromWallet,
          toWallet,
          amount,
          date,
          description
        )
        VALUES
        (
          ?,
          ?,
          ?,
          ?,
          ?
        )
        ''', [
        transaction.from,
        transaction.to,
        transaction.amount,
        transaction.when != null
            ? transaction.when.microsecondsSinceEpoch
            : null,
        transaction.description,
      ]);
    });
  }

  @override
  Future<List<Transaction>> getAll() {
    return Future(() async {
      List<Transaction> transactions = List<Transaction>();
      List<Map<String, Object>> records =
          await (await YababosSqlite.getDatabase())
              .rawQuery('SELECT * FROM transactions');
      for (var record in records) {
        transactions.add(_mapRecord(record));
      }
      return transactions;
    });
  }

  @override
  Future delete(int id) {
    return Future(() async {
      await (await YababosSqlite.getDatabase())
          .rawDelete('DELETE FROM transactions WHERE id = ?', [id]);
    });
  }

  @override
  Future<Transaction> get(int id) {
    return Future(() async {
      List<Map<String, Object>> record =
          await (await YababosSqlite.getDatabase())
              .rawQuery('SELECT * FROM transactions WHERE id = ?', [id]);
      if (record.isEmpty) return null;
      return _mapRecord(record[0]);
    });
  }

  @override
  Future update(Transaction transaction) {
    return Future(() async {
      await (await YababosSqlite.getDatabase()).rawUpdate('''
        UPDATE transactions SET
          fromWallet = ?,
          toWallet = ?,
          amount = ?,
          date = ?,
          description = ?
        WHERE id = ?
        ''', [
        transaction.from,
        transaction.to,
        transaction.amount,
        transaction.when != null
            ? transaction.when.microsecondsSinceEpoch
            : null,
        transaction.description,
        transaction.id,
      ]);
    });
  }

  @override
  Future<double> balance(int wallet) {
    return Future(() async {
      List<Map<String, Object>> record =
          await (await YababosSqlite.getDatabase()).rawQuery('''
          select 
            (SELECT SUM(amount) FROM transactions WHERE toWallet = ?)
            -
            (SELECT SUM(amount) FROM transactions WHERE fromWallet = ?)
          as balance
          ''', [wallet, wallet]);

      return record[0]['balance'];
    });
  }

  @override
  Future<List<Transaction>> walletTransactions(int wallet) {
    return Future(() async {
      List<Transaction> transactions = List<Transaction>();
      List<Map<String, Object>> records =
          await (await YababosSqlite.getDatabase()).rawQuery(
              'SELECT * FROM transactions WHERE fromWallet = ? OR toWallet = ? ORDER BY date',
              [wallet, wallet]);
      for (var record in records) {
        transactions.add(_mapRecord(record));
      }
      return transactions;
    });
  }

  Transaction _mapRecord(Map<String, Object> record) {
    return Transaction(
      id: record['id'],
      from: record['fromWallet'],
      to: record['toWallet'],
      amount: record['amount'],
      when: record['date'] != null
          ? DateTime.fromMicrosecondsSinceEpoch(record['date'])
          : null,
      description: record['description'],
    );
  }
}
