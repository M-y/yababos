import 'package:yababos/models/tag.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/repositories/sqlite/tag.dart';
import 'package:yababos/repositories/sqlite/yababos.dart';
import 'package:yababos/repositories/transaction.dart';

class TransactionSqlite extends TransactionRepository {
  TagSqlite _tagRepository;

  TransactionSqlite(this._tagRepository);

  @override
  Future add(Transaction transaction) {
    return Future(() async {
      transaction.id = await (await YababosSqlite.getDatabase()).rawInsert('''
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

      if (transaction.tags != null)
        await _addTransactionTags(transaction.id, transaction.tags);
    });
  }

  @override
  Future<List<Transaction>> getAll({bool isUtc = false}) {
    return Future(() async {
      List<Transaction> transactions = List<Transaction>();
      List<Map<String, Object>> records =
          await (await YababosSqlite.getDatabase())
              .rawQuery('SELECT * FROM transactions');
      for (var record in records) {
        transactions.add(await _mapRecord(record, isUtc: isUtc));
      }
      return transactions;
    });
  }

  @override
  Future delete(int id) {
    return Future(() async {
      await _deleteTransactionTags(id);
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

      await _deleteTransactionTags(transaction.id);
      if (transaction.tags != null)
        await _addTransactionTags(transaction.id, transaction.tags);
    });
  }

  @override
  Future<double> balance(int wallet) {
    return Future(() async {
      List<Map<String, Object>> record;
      if (wallet == null)
        record = await (await YababosSqlite.getDatabase()).rawQuery('''
          select 
            IFNULL((SELECT SUM(amount) FROM transactions WHERE toWallet IS NULL),0.0)
            -
            IFNULL((SELECT SUM(amount) FROM transactions WHERE fromWallet IS NULL),0.0)
          as balance
          ''');
      else
        record = await (await YababosSqlite.getDatabase()).rawQuery('''
          select 
            IFNULL((SELECT SUM(amount) FROM transactions WHERE toWallet = ?),0.0)
            -
            IFNULL((SELECT SUM(amount) FROM transactions WHERE fromWallet = ?),0.0)
          as balance
          ''', [wallet, wallet]);
      return record[0]['balance'];
    });
  }

  @override
  Future<List<Transaction>> walletTransactions(int wallet) {
    return Future(() async {
      List<Transaction> transactions = List<Transaction>();
      List<Map<String, Object>> records;
      if (wallet == null)
        records = await (await YababosSqlite.getDatabase()).rawQuery(
            'SELECT * FROM transactions WHERE fromWallet IS NULL OR toWallet IS NULL ORDER BY date DESC');
      else
        records = await (await YababosSqlite.getDatabase()).rawQuery(
            'SELECT * FROM transactions WHERE fromWallet = ? OR toWallet = ? ORDER BY date DESC',
            [wallet, wallet]);

      for (var record in records) {
        transactions.add(await _mapRecord(record));
      }
      return transactions;
    });
  }

  Future<Transaction> _mapRecord(Map<String, Object> record,
      {bool isUtc = false}) async {
    return Transaction(
      id: record['id'],
      from: record['fromWallet'],
      to: record['toWallet'],
      amount: record['amount'],
      when: record['date'] != null
          ? (isUtc)
              ? DateTime.fromMicrosecondsSinceEpoch(record['date'], isUtc: true)
              : DateTime.fromMicrosecondsSinceEpoch(record['date'], isUtc: true)
                  .toLocal()
          : null,
      description: record['description'],
      tags: await _transactionTags(record['id']),
    );
  }

  Future<List<Tag>> _transactionTags(int transactionId) {
    return Future(() async {
      List<Tag> tags = List<Tag>();

      List<Map<String, Object>> records =
          await (await YababosSqlite.getDatabase()).rawQuery(
              'SELECT * FROM transaction_tags WHERE transactionId = ?',
              [transactionId]);
      for (var record in records) {
        tags.add(await _tagRepository.get(record['tag']));
      }

      if (tags.isEmpty) return null;
      return tags;
    });
  }

  Future _deleteTransactionTags(int transactionId) {
    return Future(() async {
      await (await YababosSqlite.getDatabase()).rawDelete(
          'DELETE FROM transaction_tags WHERE transactionId = ?',
          [transactionId]);
    });
  }

  Future _addTransactionTags(int transactionId, List<Tag> tags) {
    return Future(() async {
      for (Tag tag in tags) {
        await (await YababosSqlite.getDatabase()).rawInsert('''
        INSERT INTO transaction_tags
        (
          transactionId,
          tag
        )
        VALUES
        (
          ?,
          ?
        )
        ''', [
          transactionId,
          tag.name,
        ]);
      }
    });
  }

  @override
  Future clear() {
    return Future(() async {
      await (await YababosSqlite.getDatabase())
          .rawDelete('DELETE FROM transactions');
      await (await YababosSqlite.getDatabase())
          .rawDelete("DELETE FROM sqlite_sequence WHERE name='transactions'");
    });
  }
}
