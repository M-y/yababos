import 'package:yababos/models/wallet.dart';
import 'package:yababos/repositories/sqlite/yababos.dart';
import 'package:yababos/repositories/wallet.dart';

class WalletSqlite extends WalletRepository {
  @override
  Future<int> add(Wallet wallet) {
    return Future(() async {
      return await (await YababosSqlite.getDatabase()).rawInsert('''
        INSERT INTO wallets
        (
          name,
          curreny,
          amount
        )
        VALUES
        (
          ?,
          ?,
          ?
        )
        ''', [
        wallet.name,
        wallet.curreny,
        wallet.amount,
      ]);
    });
  }

  @override
  Future delete(int id) {
    return Future(() async {
      await (await YababosSqlite.getDatabase())
          .rawDelete('DELETE FROM wallets WHERE id = ?', [id]);
    });
  }

  @override
  Future<Wallet?> get(int id) {
    return Future(() async {
      List<Map<String, Object?>> record =
          await (await YababosSqlite.getDatabase())
              .rawQuery('SELECT * FROM wallets WHERE id = ?', [id]);
      if (record.isEmpty) return null;
      return _mapRecord(record[0]);
    });
  }

  @override
  Future<List<Wallet>> getAll() {
    return Future(() async {
      List<Wallet> wallets = <Wallet>[];
      List<Map<String, Object?>> records =
          await (await YababosSqlite.getDatabase())
              .rawQuery('SELECT * FROM wallets');
      for (var record in records) {
        wallets.add(_mapRecord(record));
      }
      return wallets;
    });
  }

  @override
  Future update(Wallet wallet) {
    return Future(() async {
      await (await YababosSqlite.getDatabase()).rawUpdate('''
        UPDATE wallets SET
          name = ?,
          curreny = ?,
          amount = ?
        WHERE id = ?
        ''', [
        wallet.name,
        wallet.curreny,
        wallet.amount,
        wallet.id,
      ]);
    });
  }

  Wallet _mapRecord(Map<String, Object?> record) {
    return Wallet(
      id: record['id'] as int,
      name: record['name'] as String?,
      amount: record['amount'] as double?,
      curreny: record['curreny'] as String?,
    );
  }

  @override
  Future clear() {
    return Future(() async {
      await (await YababosSqlite.getDatabase())
          .rawDelete('DELETE FROM wallets');
      await (await YababosSqlite.getDatabase())
          .rawDelete("DELETE FROM sqlite_sequence WHERE name='wallets'");
    });
  }
}
