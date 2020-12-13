import 'package:flutter_test/flutter_test.dart';
import 'package:yababos/models/inmemory/settings.dart';
import 'package:yababos/models/inmemory/tag.dart';
import 'package:yababos/models/inmemory/transaction.dart';
import 'package:yababos/models/inmemory/wallet.dart';
import 'package:yababos/models/setting.dart';
import 'package:yababos/models/settings_repository.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/models/tag_repository.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/transaction_repository.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/models/wallet_repository.dart';

void main() {
  group('Settings', () {
    SettingsRepository settingsRepository = SettingsInmemory();

    test('add', () async {
      Setting sampleSetting = Setting(name: 'test', value: 1);
      await settingsRepository.add(sampleSetting);
    });

    test('get', () async {
      expect((await settingsRepository.get('test')).value, 1);
      expect(await settingsRepository.get('not available'), null);
    });
    test('update', () async {
      Setting tobeUpdateSetting = Setting(name: 'test', value: 2);
      await settingsRepository.add(tobeUpdateSetting);

      expect((await settingsRepository.get('test')).value, 2);
    });
  });

  group('Wallet', () {
    WalletRepository walletRepository = WalletInmemory();

    test('add', () async {
      Wallet sampleWallet = Wallet(
        id: null,
        name: 'Sample',
        amount: 1000,
        curreny: 'TRY',
      );

      await walletRepository.add(sampleWallet);
      expect((await walletRepository.getAll()).first.name, 'Sample');
    });

    test('update/get', () async {
      Wallet wallet = (await walletRepository.getAll()).first;
      wallet.curreny = 'USD';

      await walletRepository.update(wallet);
      expect((await walletRepository.get(wallet.id)).curreny, 'USD');
    });

    test('getAll/delete', () async {
      int id = (await walletRepository.getAll()).first.id;
      await walletRepository.delete(id);

      expect((await walletRepository.getAll()).length, 0);
    });
  });

  group('Transaction', () {
    TransactionRepository transactionRepository = TransactionInmemory();

    test('add', () async {
      Transaction sampleTransaction = Transaction(
        id: null,
        from: 0,
        to: null,
        amount: 100,
        description: 'sample',
      );

      await transactionRepository.add(sampleTransaction);
      expect((await transactionRepository.getAll()).first.amount, 100);
    });

    test('update/get', () async {
      Transaction transaction = (await transactionRepository.getAll()).first;
      transaction.amount = 150;

      await transactionRepository.update(transaction);
      expect((await transactionRepository.get(transaction.id)).amount, 150);
    });

    test('getAll/delete', () async {
      int id = (await transactionRepository.getAll()).first.id;
      await transactionRepository.delete(id);

      expect((await transactionRepository.getAll()).length, 0);
    });
  });

  group('Tag', () {
    TagRepository tagRepository = TagInmemory();

    test('add', () async {
      Tag sampleTag = Tag(name: 'test');
      await tagRepository.add(sampleTag);

      expect(await tagRepository.get(sampleTag.name), sampleTag);
    });

    test('get', () async {
      expect((await tagRepository.get('test')).name, 'test');
      expect(await tagRepository.get('not available'), null);
    });

    test('getAll', () async {
      expect(await tagRepository.getAll(), isInstanceOf<List<Tag>>());
    });

    test('update', () async {
      Tag updateTag = Tag(name: 'updated');
      await tagRepository.update('test', updateTag);

      expect(await tagRepository.get('test'), null);
      expect(tagRepository.update('test', updateTag), throwsException);
      expect(await tagRepository.get('updated'), updateTag);
    });

    test('find', () async {
      Tag find = Tag(name: 'updated');
      Tag toNotFind = Tag(name: 'not available');

      expect(await tagRepository.find(find), isInstanceOf<List<Tag>>());
      expect((await tagRepository.find(find)).length, 1);
      expect(await tagRepository.find(toNotFind), isInstanceOf<List<Tag>>());
      expect((await tagRepository.find(toNotFind)).length, 0);
    });

    test('delete', () async {
      await tagRepository.delete('updated');

      expect(await tagRepository.get('updated'), null);
    });
  });
}
