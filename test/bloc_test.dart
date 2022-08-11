import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:yababos/blocs/backup.dart';
import 'package:yababos/blocs/settings.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/blocs/wallet.dart';
import 'package:yababos/events/backup.dart';
import 'package:yababos/events/settings.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/events/wallet.dart';
import 'package:yababos/repositories/csv.dart';
import 'package:yababos/repositories/inmemory/settings.dart';
import 'package:yababos/repositories/inmemory/tag.dart';
import 'package:yababos/repositories/inmemory/transaction.dart';
import 'package:yababos/repositories/inmemory/wallet.dart';
import 'package:yababos/models/setting.dart';
import 'package:yababos/repositories/settings.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/repositories/sqlite/settings.dart';
import 'package:yababos/repositories/sqlite/tag.dart';
import 'package:yababos/repositories/sqlite/transaction.dart';
import 'package:yababos/repositories/sqlite/wallet.dart';
import 'package:yababos/repositories/sqlite/yababos.dart';
import 'package:yababos/repositories/tag.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/repositories/transaction.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/repositories/wallet.dart';
import 'package:yababos/states/backup.dart';
import 'package:yababos/states/settings.dart';
import 'package:yababos/states/tag.dart';
import 'package:yababos/states/transaction.dart';
import 'package:yababos/states/wallet.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'bloc_test.mocks.dart';
import 'sample_database.dart';

@GenerateMocks([TagRepository])
void main() {
  // Initialize FFI
  sqfliteFfiInit();
  // Change the default factory
  sqflite.databaseFactory = databaseFactoryFfi;
  YababosSqlite.path = ':memory:';

  group('Settings', () {
    Setting sampleSetting = Setting(name: 'sample', value: 1);
    Setting sampleSettingChanged = Setting(name: 'sample', value: 2);

    List<SettingsRepository> repositories = List.from([
      SettingsInmemory(),
      SettingsSqlite(),
    ]);

    for (SettingsRepository settingsRepository in repositories) {
      blocTest(
        'add setting $settingsRepository',
        build: () => SettingsBloc(settingsRepository),
        act: (bloc) => bloc.add(SettingAdd(sampleSetting)),
        wait: Duration(milliseconds: 500),
        expect: () => <SettingState>[SettingChanged(sampleSetting)],
        tearDown: () async => settingsRepository.clear(),
      );

      blocTest(
        'add same setting $settingsRepository',
        setUp: () async => await settingsRepository.add(sampleSetting),
        build: () => SettingsBloc(settingsRepository),
        act: (bloc) => bloc.add(SettingAdd(sampleSetting)),
        wait: Duration(milliseconds: 500),
        expect: () => <SettingState>[SettingLoaded(sampleSetting)],
        tearDown: () async => settingsRepository.clear(),
      );

      blocTest(
        'update setting $settingsRepository',
        setUp: () async => await settingsRepository.add(sampleSetting),
        build: () => SettingsBloc(settingsRepository),
        act: (bloc) => bloc.add(SettingAdd(sampleSettingChanged)),
        wait: Duration(milliseconds: 500),
        expect: () => <SettingState>[SettingChanged(sampleSettingChanged)],
        tearDown: () async => settingsRepository.clear(),
      );

      blocTest(
        'get setting $settingsRepository',
        setUp: () async => await settingsRepository.add(sampleSettingChanged),
        build: () => SettingsBloc(settingsRepository),
        act: (bloc) => bloc.add(SettingGet('sample')),
        wait: Duration(milliseconds: 500),
        expect: () => <SettingState>[SettingLoaded(sampleSettingChanged)],
        tearDown: () async => settingsRepository.clear(),
      );
    }
  });

  group('Wallet', () {
    var repositories = [
      [WalletInmemory(), SettingsInmemory(), TransactionInmemory()],
      [WalletSqlite(), SettingsSqlite(), TransactionSqlite(TagSqlite())],
    ];
    for (var repository in repositories) {
      WalletRepository walletRepository = repository[0];
      SettingsRepository settingsRepository = repository[1];
      TransactionRepository transactionRepository = repository[2];

      SettingsBloc settingsBloc = SettingsBloc(settingsRepository);
      TransactionBloc transactionBloc =
          TransactionBloc(transactionRepository, MockTagRepository());

      Wallet sampleWallet = Wallet(
        id: 1,
        name: 'Sample',
        amount: 1000,
        curreny: 'TRY',
      );
      List<Wallet> sampleWalletList = [sampleWallet];
      Wallet updatedWallet = Wallet(
        id: 1,
        name: 'New',
        amount: 2000,
        curreny: 'USD',
      );
      List<Wallet> updatedWalletList = [updatedWallet];

      blocTest(
        'WalletAdd $walletRepository',
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) => bloc.add(WalletAdd(sampleWallet)),
        wait: Duration(milliseconds: 500),
        expect: () => <WalletState>[
          WalletsLoaded(wallets: sampleWalletList, selectedWallet: sampleWallet)
        ],
        tearDown: () async => await walletRepository.clear(),
      );

      blocTest(
        'WalletGetAll $walletRepository',
        setUp: () async => await walletRepository.add(sampleWallet),
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) => bloc.add(WalletGetAll()),
        wait: Duration(milliseconds: 500),
        expect: () => <WalletState>[WalletsLoaded(wallets: sampleWalletList)],
        tearDown: () async => await walletRepository.clear(),
      );

      blocTest(
        'WalletGet $walletRepository',
        setUp: () async => await walletRepository.add(sampleWallet),
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) => bloc.add(WalletGet(1)),
        wait: Duration(milliseconds: 500),
        expect: () => <WalletState>[WalletLoaded(sampleWallet)],
        tearDown: () async => await walletRepository.clear(),
      );

      blocTest(
        'WalletUpdate $walletRepository',
        setUp: () async => await walletRepository.add(sampleWallet),
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) => bloc.add(WalletUpdate(updatedWallet)),
        wait: Duration(milliseconds: 500),
        expect: () => <WalletState>[WalletsLoaded(wallets: updatedWalletList)],
        tearDown: () async => await walletRepository.clear(),
      );

      blocTest(
        'WalletDelete $walletRepository',
        setUp: () async => await walletRepository.add(updatedWallet),
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) => bloc.add(WalletDelete(1)),
        wait: Duration(milliseconds: 500),
        expect: () => <WalletState>[WalletsLoaded(wallets: <Wallet>[])],
        tearDown: () async => await walletRepository.clear(),
      );

      blocTest(
        "selected wallet $walletRepository",
        setUp: () async {
          sampleWallet.id = 1;
          updatedWallet.id = 2;
          await walletRepository.add(sampleWallet);
          await walletRepository.add(updatedWallet);
        },
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) =>
            settingsBloc.add(SettingAdd(Setting(name: 'wallet', value: 2))),
        wait: Duration(milliseconds: 500),
        expect: () => <WalletState>[
          WalletsLoaded(
            wallets: List<Wallet>.from([sampleWallet, updatedWallet]),
            selectedWallet: updatedWallet,
          )
        ],
        tearDown: () async {
          await walletRepository.clear();
          await settingsRepository.clear();
        },
      );

      blocTest(
        'set as selected wallet when first one added $walletRepository',
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) {
          bloc.add(WalletAdd(sampleWallet));
        },
        wait: Duration(milliseconds: 500),
        expect: () => <WalletState>[
          WalletsLoaded(
            wallets: List<Wallet>.from([sampleWallet]),
            selectedWallet: sampleWallet,
          )
        ],
        tearDown: () async {
          await walletRepository.clear();
          await settingsRepository.clear();
        },
      );

      blocTest(
        'set as selected wallet when last one stands $walletRepository',
        setUp: () async {
          await walletRepository.add(sampleWallet);
          await settingsRepository.add(Setting(name: "wallet", value: 1));
          updatedWallet.id = 2;
          await walletRepository.add(updatedWallet);
        },
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) => bloc.add(WalletDelete(1)),
        wait: Duration(milliseconds: 500),
        expect: () => <WalletState>[
          WalletsLoaded(
            wallets: List<Wallet>.from([updatedWallet]),
            selectedWallet: updatedWallet,
          )
        ],
        tearDown: () async {
          await walletRepository.clear();
          await settingsRepository.clear();
        },
      );
    }
  });

  group('Transaction', () {
    List<TransactionRepository> repositories = List.from([
      TransactionInmemory(),
      TransactionSqlite(TagSqlite()),
    ]);

    for (TransactionRepository transactionRepository in repositories) {
      Transaction sampleTransaction = Transaction(
        id: 1,
        from: 1,
        to: 0,
        amount: 100,
        when: DateTime.now(),
        description: 'sample expense',
      );
      Transaction updatedTransaction = Transaction(
        id: 1,
        from: 1,
        to: 0,
        amount: 150,
        when: DateTime.now(),
        description: 'updated expense',
      );
      Transaction walletTransaction = Transaction(
        id: 2,
        from: 0,
        to: 2,
        amount: 100,
        when: DateTime.now(),
        description: null,
      );

      blocTest(
        'TransactionAdd $transactionRepository',
        build: () =>
            TransactionBloc(transactionRepository, MockTagRepository()),
        act: (bloc) => bloc.add(TransactionAdd(sampleTransaction)),
        wait: Duration(milliseconds: 500),
        expect: () => <TransactionState>[
          WalletTransactionsLoaded(
              List<Transaction>.from([sampleTransaction]), 100)
        ],
        tearDown: () async => await transactionRepository.clear(),
      );

      blocTest(
        'TransactionGetAll $transactionRepository',
        setUp: () async => await transactionRepository.add(sampleTransaction),
        build: () =>
            TransactionBloc(transactionRepository, MockTagRepository()),
        act: (bloc) => bloc.add(TransactionGetAll()),
        wait: Duration(milliseconds: 500),
        expect: () => <TransactionState>[
          TransactionLoaded.many(List<Transaction>.from([sampleTransaction]))
        ],
        tearDown: () async => await transactionRepository.clear(),
      );

      blocTest(
        'TransactionGet $transactionRepository',
        setUp: () async => await transactionRepository.add(sampleTransaction),
        build: () =>
            TransactionBloc(transactionRepository, MockTagRepository()),
        act: (bloc) => bloc.add(TransactionGet(1)),
        wait: Duration(milliseconds: 500),
        expect: () =>
            <TransactionState>[TransactionLoaded.one(sampleTransaction)],
        tearDown: () async => await transactionRepository.clear(),
      );

      blocTest(
        'TransactionUpdate $transactionRepository',
        setUp: () async => await transactionRepository.add(sampleTransaction),
        build: () =>
            TransactionBloc(transactionRepository, MockTagRepository()),
        act: (bloc) => bloc.add(TransactionUpdate(updatedTransaction)),
        wait: Duration(milliseconds: 500),
        expect: () => <TransactionState>[
          WalletTransactionsLoaded(
              List<Transaction>.from([updatedTransaction]), 150)
        ],
        tearDown: () async => await transactionRepository.clear(),
      );

      blocTest(
        'TransactionDelete $transactionRepository',
        setUp: () async => await transactionRepository.add(sampleTransaction),
        build: () =>
            TransactionBloc(transactionRepository, MockTagRepository()),
        act: (bloc) => bloc.add(TransactionDelete(1)),
        wait: Duration(milliseconds: 500),
        expect: () =>
            <TransactionState>[WalletTransactionsLoaded(<Transaction>[], 0)],
        tearDown: () async => await transactionRepository.clear(),
      );

      blocTest(
        'Wallet\'s Transactions and balance $transactionRepository',
        setUp: () async {
          await transactionRepository.add(sampleTransaction);
          await transactionRepository.add(walletTransaction);
        },
        build: () =>
            TransactionBloc(transactionRepository, MockTagRepository()),
        act: (bloc) => bloc.add(TransactionGetWallet(
            walletTransaction.to, DateTime.now().year, DateTime.now().month)),
        wait: Duration(milliseconds: 500),
        expect: () => <TransactionState>[
          WalletTransactionsLoaded(
              List<Transaction>.from([walletTransaction]), 100)
        ],
        tearDown: () async => await transactionRepository.clear(),
      );

      blocTest(
        'TransactionSearch $transactionRepository',
        setUp: () async => await transactionRepository.add(sampleTransaction),
        build: () =>
            TransactionBloc(transactionRepository, MockTagRepository()),
        act: (bloc) => bloc.add(TransactionSearch(Transaction(
          id: null,
          from: null,
          to: null,
          amount: null,
          when: null,
          description: 'sample expense',
        ))),
        wait: Duration(milliseconds: 500),
        expect: () => <TransactionState>[
          TransactionsFound(List<Transaction>.from([sampleTransaction]), -100)
        ],
        tearDown: () async => await transactionRepository.clear(),
      );
    }
  });

  group('Tag', () {
    Tag sampleTag = Tag(name: 'sample');
    List<Tag> sampleTagList = [sampleTag];
    Tag newTag = Tag(name: 'new');
    List<Tag> newTagList = [newTag];
    List<Tag> allTags = [sampleTag, newTag];

    List<TagRepository> repositories = List.from([
      TagInmemory(),
      TagSqlite(),
    ]);

    for (TagRepository tagRepository in repositories) {
      blocTest(
        'TagAdd $tagRepository',
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagAdd(sampleTag)),
        wait: Duration(milliseconds: 500),
        expect: () => <TagState>[TagLoaded(sampleTagList)],
        tearDown: () async => await tagRepository.clear(),
      );

      blocTest(
        'TagUpdate $tagRepository',
        setUp: () async => await tagRepository.add(sampleTag),
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagUpdate(sampleTag.name, newTag)),
        wait: Duration(milliseconds: 500),
        expect: () => <TagState>[TagLoaded(newTagList)],
        tearDown: () async => await tagRepository.clear(),
      );

      blocTest(
        'TagDelete $tagRepository',
        setUp: () async => await tagRepository.add(newTag),
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagDelete(newTag)),
        wait: Duration(milliseconds: 500),
        expect: () => <TagState>[TagLoaded([])],
        tearDown: () async => await tagRepository.clear(),
      );

      blocTest(
        'TagsAdd $tagRepository',
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagsAdd(allTags)),
        wait: Duration(milliseconds: 500),
        expect: () => <TagState>[TagLoaded(allTags)],
        tearDown: () async => await tagRepository.clear(),
      );

      blocTest(
        'TagFind $tagRepository',
        setUp: () async {
          await tagRepository.add(sampleTag);
          await tagRepository.add(newTag);
        },
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagFind(Tag(name: 'sample'))),
        wait: Duration(milliseconds: 500),
        expect: () => <TagState>[TagLoaded(sampleTagList)],
        tearDown: () async => await tagRepository.clear(),
      );

      blocTest(
        'TagGetAll $tagRepository',
        setUp: () async {
          await tagRepository.add(sampleTag);
          await tagRepository.add(newTag);
        },
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagGetAll()),
        wait: Duration(milliseconds: 500),
        expect: () => <TagState>[TagLoaded(allTags)],
        tearDown: () async => await tagRepository.clear(),
      );

      blocTest(
        'duplicate add $tagRepository',
        setUp: () async {
          await tagRepository.add(sampleTag);
          await tagRepository.add(newTag);
        },
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagAdd(sampleTag)),
        wait: Duration(milliseconds: 500),
        expect: () => <TagState>[TagLoaded(allTags)],
        tearDown: () async => await tagRepository.clear(),
      );
    }
  });

  group('Transaction & Tag', () {
    var repositories = [
      [TagInmemory(), TransactionInmemory()],
      [TagSqlite(), TransactionSqlite(TagSqlite())]
    ];

    for (var repository in repositories) {
      TagRepository tagRepository = repository[0];
      TransactionRepository transactionRepository = repository[1];
      Transaction transactionWithTags = Transaction(
        id: 1,
        from: 1,
        to: 0,
        amount: 100,
        when: DateTime.now(),
        description: 'transaction with tags',
        tags: [Tag(name: 't1'), Tag(name: 't2')],
      );

      blocTest(
        'Transaction tags $tagRepository',
        setUp: () async {
          TransactionBloc(transactionRepository, tagRepository)
            ..add(TransactionAdd(transactionWithTags));
          await Future.delayed(Duration(seconds: 3));
        },
        build: () => TransactionBloc(transactionRepository, tagRepository),
        act: (bloc) => bloc.add(TransactionGetAll()),
        wait: Duration(milliseconds: 500),
        expect: () => <TransactionState>[
          TransactionLoaded.many(List<Transaction>.from([transactionWithTags]))
        ],
        tearDown: () async {
          await transactionRepository.clear();
          await tagRepository.clear();
        },
      );
    }
  });

  group('Backup', () {
    var repositories = [
      [TagInmemory(), TransactionInmemory(), WalletInmemory()],
      [TagSqlite(), TransactionSqlite(TagSqlite()), WalletSqlite()]
    ];

    for (var repository in repositories) {
      TagRepository tagRepository = repository[0];
      TransactionRepository transactionRepository = repository[1];
      WalletRepository walletRepository = repository[2];

      String csv = '1,Wallet 1,null,100.0,2021-11-20 11:08:46.000Z,"[[t1, 4294967295], [t2, 4294967295]]",transaction with tags\r\n' +
          '2,Wallet 2,Wallet 1,10.0,2021-11-20 00:09:03.000Z,null,transaction from wallet2 to wallet1\r\n' +
          'null,null,Wallet 1,1.0,1970-01-01 00:00:00.000Z,null,Wallet initial balance\r\n' +
          'null,null,Wallet 2,10.0,1970-01-01 00:00:00.000Z,null,Wallet initial balance';

      blocTest(
        'Create Backup $tagRepository',
        setUp: () async => await sampleDatabase(
            walletRepository, tagRepository, transactionRepository),
        build: () {
          return BackupBloc(CsvRepository(), tagRepository,
              transactionRepository, walletRepository);
        },
        act: (bloc) {
          bloc.add(BackupCreate());
        },
        wait: Duration(milliseconds: 500),
        expect: () => <BackupState>[BackupComplete(csv)],
      );

      blocTest(
        'Load Backup $tagRepository',
        build: () {
          return BackupBloc(CsvRepository(), tagRepository,
              transactionRepository, walletRepository);
        },
        act: (bloc) {
          bloc.add(BackupLoad(csv));
        },
        wait: Duration(milliseconds: 500),
        expect: () => <BackupState>[BackupLoaded(4)],
      );
    }
  });
}
