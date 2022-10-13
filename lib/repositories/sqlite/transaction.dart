import 'package:yababos/models/tag.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/transaction_search.dart';
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
        transaction.when.microsecondsSinceEpoch,
        transaction.description,
      ]);

      if (transaction.tags != null)
        await _addTransactionTags(transaction.id, transaction.tags!);
    });
  }

  @override
  Future<List<Transaction>> getAll({bool isUtc = false}) {
    return Future(() async {
      List<Transaction> transactions = <Transaction>[];
      List<Map<String, Object?>> records =
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
  Future<Transaction?> get(int id) {
    return Future(() async {
      List<Map<String, Object?>> record =
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
        transaction.when.microsecondsSinceEpoch,
        transaction.description,
        transaction.id,
      ]);

      await _deleteTransactionTags(transaction.id);
      if (transaction.tags != null)
        await _addTransactionTags(transaction.id, transaction.tags!);
    });
  }

  @override
  Future<double> balance(int wallet) {
    return Future(() async {
      List<Map<String, Object?>> record;

      record = await (await YababosSqlite.getDatabase()).rawQuery('''
          select 
            IFNULL((SELECT SUM(amount) FROM transactions WHERE toWallet = ?),0.0)
            -
            IFNULL((SELECT SUM(amount) FROM transactions WHERE fromWallet = ?),0.0)
          as balance
          ''', [wallet, wallet]);
      return record[0]['balance'] as double;
    });
  }

  @override
  Future<List<Transaction>> walletTransactions(
      int wallet, int year, int month) {
    return Future(() async {
      List<Transaction> transactions = <Transaction>[];
      List<Map<String, Object?>> records;

      DateTime start = DateTime(year, month);
      DateTime end = DateTime(year, month + 1);
      if (month == 12) end = DateTime(year + 1, 1);
      String dateWhere =
          'date >= ${start.microsecondsSinceEpoch} AND date < ${end.microsecondsSinceEpoch}';

      records = await (await YababosSqlite.getDatabase()).rawQuery(
          'SELECT * FROM transactions WHERE $dateWhere AND (fromWallet = ? OR toWallet = ?) ORDER BY date DESC',
          [wallet, wallet]);

      for (var record in records) {
        transactions.add(await _mapRecord(record));
      }
      return transactions;
    });
  }

  Future<Transaction> _mapRecord(Map<String, Object?> record,
      {bool isUtc = false}) async {
    return Transaction(
      id: record['id'] as int,
      from: record['fromWallet'] as int,
      to: record['toWallet'] as int,
      amount: record['amount'] as double,
      when: (isUtc)
          ? DateTime.fromMicrosecondsSinceEpoch(record['date'] as int,
              isUtc: true)
          : DateTime.fromMicrosecondsSinceEpoch(record['date'] as int,
                  isUtc: true)
              .toLocal(),
      description: record['description'] as String?,
      tags: await _transactionTags(record['id'] as int),
    );
  }

  Future<List<Tag>?> _transactionTags(int transactionId) {
    return Future(() async {
      List<Tag> tags = <Tag>[];

      List<Map<String, Object?>> records =
          await (await YababosSqlite.getDatabase()).rawQuery(
              'SELECT * FROM transaction_tags WHERE transactionId = ?',
              [transactionId]);
      for (var record in records) {
        tags.add(await (_tagRepository.get(record['tag'] as String)) as Tag);
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

  @override
  Future<List<Transaction>> search(TransactionSearch transaction,
      [TransactionSearch? transactionEnd]) {
    return Future(() async {
      List<Transaction> transactions = <Transaction>[];
      List<Map<String, Object?>> records;
      List<String> where = List.empty(growable: true);
      String join = '';

      DateTime? start;
      DateTime? end;
      if (transaction.when != null) {
        start = transaction.when;
        end = DateTime(transaction.when!.year, transaction.when!.month,
            transaction.when!.day + 1);
        if (transactionEnd != null) end = transactionEnd.when;

        where.add(
            'date >= ${start!.microsecondsSinceEpoch} AND date < ${end!.microsecondsSinceEpoch}');
      }

      if (transaction.from != null)
        where.add('fromWallet = ${transaction.from}');
      if (transaction.to != null) where.add('toWallet = ${transaction.to}');

      if (transaction.amount != null)
        where.add('amount == ${transaction.amount}');

      if (transaction.description != null)
        where.add("description LIKE '%${transaction.description}%'");

      if (transaction.tags != null) {
        join = 'JOIN transaction_tags ON(transactionId = id)';
        List<String> tagWhere = List.empty(growable: true);
        for (Tag tag in transaction.tags!) tagWhere.add("tag = '${tag.name}'");

        where.add('(${tagWhere.join(" OR ")})');
      }

      records = await (await YababosSqlite.getDatabase()).rawQuery(
          'SELECT * FROM transactions $join WHERE ${where.join(" AND ")} ORDER BY date DESC');

      for (var record in records) {
        transactions.add(await _mapRecord(record));
      }

      return transactions;
    });
  }
}
