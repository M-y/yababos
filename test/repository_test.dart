import 'package:flutter_test/flutter_test.dart';
import 'package:yababos/repositories/inmemory/settings.dart';
import 'package:yababos/repositories/inmemory/tag.dart';
import 'package:yababos/repositories/inmemory/transaction.dart';
import 'package:yababos/repositories/inmemory/wallet.dart';
import 'package:yababos/models/setting.dart';
import 'package:yababos/repositories/settings_repository.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/repositories/sqlite/settings.dart';
import 'package:yababos/repositories/sqlite/tag.dart';
import 'package:yababos/repositories/sqlite/transaction.dart';
import 'package:yababos/repositories/sqlite/wallet.dart';
import 'package:yababos/repositories/sqlite/yababos.dart';
import 'package:yababos/repositories/tag_repository.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/repositories/transaction_repository.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/repositories/wallet_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

void main() {
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    sqflite.databaseFactory = databaseFactoryFfi;
    YababosSqlite.path = ':memory:';
  });

  group('Settings', () {
    List<SettingsRepository> repositories = List.from([
      SettingsInmemory(),
      SettingsSqlite(),
    ]);

    for (SettingsRepository settingsRepository in repositories) {
      test('add $settingsRepository', () async {
        Setting sampleSetting = Setting(name: 'test', value: 1);
        await settingsRepository.add(sampleSetting);
      });

      test('get $settingsRepository', () async {
        expect((await settingsRepository.get('test')).value, 1);
        expect(await settingsRepository.get('not available'), null);
      });
      test('update $settingsRepository', () async {
        Setting tobeUpdateSetting = Setting(name: 'test', value: 2);
        await settingsRepository.add(tobeUpdateSetting);

        expect((await settingsRepository.get('test')).value, 2);
      });
    }
  });

  group('Tag', () {
    List<TagRepository> repositories = List.from([
      TagInmemory(),
      TagSqlite(),
    ]);

    for (TagRepository tagRepository in repositories) {
      test('add $tagRepository', () async {
        Tag sampleTag = Tag(name: 'test');
        await tagRepository.add(sampleTag);

        expect(await tagRepository.get(sampleTag.name), sampleTag);
      });

      test('get $tagRepository', () async {
        expect((await tagRepository.get('test')).name, 'test');
        expect(await tagRepository.get('not available'), null);
      });

      test('getAll $tagRepository', () async {
        expect(await tagRepository.getAll(), isInstanceOf<List<Tag>>());
      });

      test('update $tagRepository', () async {
        Tag updateTag = Tag(name: 'updated');
        await tagRepository.update('test', updateTag);

        expect(await tagRepository.get('test'), null);
        expect(tagRepository.update('test', updateTag), throwsException);
        expect(await tagRepository.get('updated'), updateTag);
      });

      test('find $tagRepository', () async {
        Tag find = Tag(name: 'up');
        Tag toNotFind = Tag(name: 'not available');

        expect(await tagRepository.find(find), isInstanceOf<List<Tag>>());
        expect((await tagRepository.find(find)).length, 1);
        expect(await tagRepository.find(toNotFind), isInstanceOf<List<Tag>>());
        expect((await tagRepository.find(toNotFind)).length, 0);
      });

      test('delete $tagRepository', () async {
        await tagRepository.delete('updated');

        expect(await tagRepository.get('updated'), null);
      });
    }
  });

  group('Transaction', () {
    List<TransactionRepository> repositories = List.from([
      TransactionInmemory(),
      TransactionSqlite(TagSqlite()),
    ]);

    for (TransactionRepository transactionRepository in repositories) {
      test('add $transactionRepository', () async {
        Transaction sampleTransaction =
            Transaction(id: 1, from: null, to: 1, amount: 0, when: null);
        await transactionRepository.add(sampleTransaction);

        expect(await transactionRepository.get(1), sampleTransaction);
      });

      test('update $transactionRepository', () async {
        await transactionRepository.update(Transaction(
            id: 1,
            from: null,
            to: 1,
            description: "test",
            amount: 0,
            when: null));

        expect((await transactionRepository.get(1)).description, "test");
      });

      test('delete & getAll $transactionRepository', () async {
        expect((await transactionRepository.getAll()).length, 1);
        await transactionRepository.delete(1);
        expect((await transactionRepository.getAll()).length, 0);
      });

      test('wallet\'s transactions $transactionRepository', () async {
        Transaction yesterday = Transaction(
          id: 2,
          from: null,
          to: 1,
          amount: 0,
          when: DateTime.now().subtract(new Duration(days: 1)),
        );
        Transaction today = Transaction(
          id: 3,
          from: 1,
          to: null,
          amount: 0,
          when: DateTime.now(),
        );
        Transaction otherWalletTransaction = Transaction(
          id: 4,
          from: null,
          to: 2,
          amount: 0,
          when: DateTime.now(),
        );
        await transactionRepository.add(yesterday);
        await transactionRepository.add(today);
        await transactionRepository.add(otherWalletTransaction);
        List<Transaction> walletTransactions =
            await transactionRepository.walletTransactions(1);

        expect(walletTransactions.length, 2);
        expect(walletTransactions[0], yesterday);
        expect(walletTransactions[1], today);
      });

      test('balance $transactionRepository', () async {
        Transaction income = Transaction(
            id: null, from: null, to: 1, amount: 150.5, when: DateTime.now());
        Transaction expense = Transaction(
            id: null, from: 1, to: null, amount: 50, when: DateTime.now());
        await transactionRepository.add(income);
        await transactionRepository.add(expense);

        expect(await transactionRepository.balance(1), 100.5);
      });
    }
  });

  group('Wallet', () {
    List<WalletRepository> repositories = List.from([
      WalletInmemory(),
      WalletSqlite(),
    ]);

    for (WalletRepository walletRepository in repositories) {
      test('add $walletRepository', () async {
        Wallet sampleWallet =
            Wallet(id: 1, name: 'sample', amount: 0, curreny: 'TRY');
        await walletRepository.add(sampleWallet);

        expect(await walletRepository.get(1), sampleWallet);
      });

      test('update $walletRepository', () async {
        await walletRepository
            .update(Wallet(id: 1, name: 'test', amount: 10, curreny: 'TRY'));

        expect((await walletRepository.get(1)).name, 'test');
        expect((await walletRepository.get(1)).amount, 10);
      });

      test('delete & getAll $walletRepository', () async {
        expect((await walletRepository.getAll()).length, 1);
        await walletRepository.delete(1);
        expect((await walletRepository.getAll()).length, 0);
      });
    }
  });
}
