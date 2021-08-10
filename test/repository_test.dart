import 'package:flutter_test/flutter_test.dart';
import 'package:yababos/repositories/inmemory/settings.dart';
import 'package:yababos/repositories/inmemory/tag.dart';
import 'package:yababos/repositories/inmemory/transaction.dart';
import 'package:yababos/repositories/inmemory/wallet.dart';
import 'package:yababos/models/setting.dart';
import 'package:yababos/repositories/settings_repository.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/repositories/tag_repository.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/repositories/transaction_repository.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/repositories/wallet_repository.dart';

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

  group('Transaction', () {
    TransactionRepository transactionRepository = TransactionInmemory();

    test('add', () async {
      Transaction sampleTransaction = Transaction(id: null, from: null, to: 1);
      await transactionRepository.add(sampleTransaction);

      expect(await transactionRepository.get(1), sampleTransaction);
    });

    test('update', () async {
      await transactionRepository
          .update(Transaction(id: 1, from: null, to: 1, description: "test"));

      expect((await transactionRepository.get(1)).description, "test");
    });

    test('delete & getAll', () async {
      expect((await transactionRepository.getAll()).length, 1);
      await transactionRepository.delete(1);
      expect((await transactionRepository.getAll()).length, 0);
    });
  });
}
