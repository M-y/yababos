import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
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

import 'sample_database.dart';

void main() {
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    sqflite.databaseFactory = databaseFactoryFfi;
    YababosSqlite.path = ':memory:';
  });

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
        expect: () => <SettingState>[SettingChanged(sampleSetting)],
      );

      blocTest(
        'add same setting $settingsRepository',
        build: () => SettingsBloc(settingsRepository),
        act: (bloc) => bloc.add(SettingAdd(sampleSetting)),
        expect: () => <SettingState>[SettingLoaded(sampleSetting)],
      );

      blocTest(
        'update setting $settingsRepository',
        build: () => SettingsBloc(settingsRepository),
        act: (bloc) => bloc.add(SettingAdd(sampleSettingChanged)),
        expect: () => <SettingState>[SettingChanged(sampleSettingChanged)],
      );

      blocTest(
        'get setting $settingsRepository',
        build: () => SettingsBloc(settingsRepository),
        act: (bloc) => bloc.add(SettingGet('sample')),
        expect: () => <SettingState>[SettingLoaded(sampleSettingChanged)],
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
      TransactionBloc transactionBloc = TransactionBloc(transactionRepository);

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
        expect: () => <WalletState>[
          WalletsLoaded(wallets: sampleWalletList, selectedWallet: sampleWallet)
        ],
      );

      blocTest(
        'WalletGetAll $walletRepository',
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) => bloc.add(WalletGetAll()),
        expect: () => <WalletState>[WalletsLoaded(wallets: sampleWalletList)],
      );

      blocTest(
        'WalletGet $walletRepository',
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) => bloc.add(WalletGet(1)),
        expect: () => <WalletState>[WalletLoaded(sampleWallet)],
      );

      blocTest(
        'WalletUpdate $walletRepository',
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) => bloc.add(WalletUpdate(updatedWallet)),
        expect: () => <WalletState>[WalletsLoaded(wallets: updatedWalletList)],
      );

      blocTest(
        'WalletDelete $walletRepository',
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) => bloc.add(WalletDelete(1)),
        expect: () => <WalletState>[WalletsLoaded(wallets: List<Wallet>())],
      );

      blocTest(
        "selected wallet $walletRepository",
        build: () {
          sampleWallet.id = 2;
          updatedWallet.id = 3;
          walletRepository.add(sampleWallet);
          walletRepository.add(updatedWallet);
          return WalletBloc(walletRepository, settingsBloc, transactionBloc);
        },
        act: (bloc) {
          settingsBloc.add(SettingAdd(Setting(name: 'wallet', value: 3)));
        },
        wait: Duration(seconds: 10),
        expect: () => <WalletState>[
          WalletsLoaded(
            wallets: List<Wallet>.from([sampleWallet, updatedWallet]),
            selectedWallet: updatedWallet,
          )
        ],
      );

      blocTest(
        'set as selected wallet when first one added $walletRepository',
        setUp: () => walletRepository = WalletInmemory(),
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) {
          bloc.add(WalletAdd(sampleWallet));
        },
        expect: () => <WalletState>[
          WalletsLoaded(
            wallets: List<Wallet>.from([sampleWallet]),
            selectedWallet: sampleWallet,
          )
        ],
      );

      blocTest(
        'set as selected wallet when last one stands $walletRepository',
        setUp: () => walletRepository = WalletInmemory(),
        build: () =>
            WalletBloc(walletRepository, settingsBloc, transactionBloc),
        act: (bloc) {
          bloc.add(WalletAdd(sampleWallet));
          bloc.add(WalletAdd(updatedWallet));
          bloc.add(WalletDelete(1));
        },
        skip: 1,
        expect: () => <WalletState>[
          WalletsLoaded(
            wallets: List<Wallet>.from([updatedWallet]),
            selectedWallet: updatedWallet,
          )
        ],
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
        to: null,
        amount: 100,
        when: DateTime.now(),
        description: 'sample expense',
      );
      Transaction updatedTransaction = Transaction(
        id: 1,
        from: 1,
        to: null,
        amount: 150,
        when: DateTime.now(),
        description: 'updated expense',
      );
      Transaction walletTransaction = Transaction(
        id: 2,
        from: null,
        to: 2,
        amount: 100,
        when: DateTime.now(),
        description: null,
      );

      blocTest(
        'TransactionAdd $transactionRepository',
        build: () => TransactionBloc(transactionRepository),
        act: (bloc) => bloc.add(TransactionAdd(sampleTransaction)),
        expect: () => <TransactionState>[
          WalletTransactionsLoaded(
              List<Transaction>.from([sampleTransaction]), 100)
        ],
      );

      blocTest(
        'TransactionGetAll $transactionRepository',
        build: () => TransactionBloc(transactionRepository),
        act: (bloc) => bloc.add(TransactionGetAll()),
        expect: () => <TransactionState>[
          TransactionLoaded.many(List<Transaction>.from([sampleTransaction]))
        ],
      );

      blocTest(
        'TransactionGet $transactionRepository',
        build: () => TransactionBloc(transactionRepository),
        act: (bloc) => bloc.add(TransactionGet(1)),
        expect: () =>
            <TransactionState>[TransactionLoaded.one(sampleTransaction)],
      );

      blocTest(
        'TransactionUpdate $transactionRepository',
        build: () => TransactionBloc(transactionRepository),
        act: (bloc) => bloc.add(TransactionUpdate(updatedTransaction)),
        expect: () => <TransactionState>[
          WalletTransactionsLoaded(
              List<Transaction>.from([updatedTransaction]), 150)
        ],
      );

      blocTest(
        'TransactionDelete $transactionRepository',
        build: () => TransactionBloc(transactionRepository),
        act: (bloc) => bloc.add(TransactionDelete(1)),
        expect: () => <TransactionState>[
          WalletTransactionsLoaded(List<Transaction>(), 0)
        ],
      );

      blocTest(
        'Wallet\'s Transactions and balance $transactionRepository',
        build: () => TransactionBloc(transactionRepository)
          ..add(TransactionAdd(sampleTransaction))
          ..add(TransactionAdd(walletTransaction)),
        act: (bloc) {
          walletTransaction.id = 3;
          bloc.add(TransactionGetWallet(walletTransaction.to));
        },
        skip: 2,
        expect: () => <TransactionState>[
          WalletTransactionsLoaded(
              List<Transaction>.from([walletTransaction]), 100)
        ],
        tearDown: () => TransactionBloc(transactionRepository)
          ..add(TransactionDelete(2))
          ..add(TransactionDelete(3)),
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
        expect: () => <TagState>[TagLoaded(sampleTagList)],
      );

      blocTest(
        'TagUpdate $tagRepository',
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagUpdate(sampleTag.name, newTag)),
        expect: () => <TagState>[TagLoaded(newTagList)],
      );

      blocTest(
        'TagDelete $tagRepository',
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagDelete(newTag)),
        expect: () => <TagState>[TagLoaded([])],
      );

      blocTest(
        'TagsAdd $tagRepository',
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagsAdd(allTags)),
        expect: () => <TagState>[TagLoaded(allTags)],
      );

      blocTest(
        'TagFind $tagRepository',
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagFind(Tag(name: 'sample'))),
        expect: () => <TagState>[TagLoaded(sampleTagList)],
      );

      blocTest(
        'TagGetAll $tagRepository',
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagGetAll()),
        expect: () => <TagState>[TagLoaded(allTags)],
      );

      blocTest(
        'duplicate add $tagRepository',
        build: () => TagBloc(tagRepository),
        act: (bloc) => bloc.add(TagAdd(sampleTag)),
        expect: () => <TagState>[TagLoaded(allTags)],
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
        id: 4,
        from: 1,
        to: null,
        amount: 100,
        when: null,
        description: 'transaction with tags',
        tags: [Tag(name: 't1'), Tag(name: 't2')],
      );

      blocTest(
        'Transaction tags $tagRepository',
        build: () {
          TagBloc(tagRepository)..add(TagsAdd(transactionWithTags.tags));
          return TransactionBloc(transactionRepository)
            ..add(TransactionAdd(transactionWithTags));
        },
        act: (bloc) {
          bloc.add(TransactionGetAll());
        },
        skip: 1,
        expect: () => <TransactionState>[
          TransactionLoaded.many(List<Transaction>.from([transactionWithTags]))
        ],
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

      String csv = '1,Wallet 1,null,100.0,2021-11-20 14:08:46.000,"[[t1, 4294967295], [t2, 4294967295]]",transaction with tags\r\n' +
          '2,Wallet 2,Wallet 1,10.0,2021-11-20 03:09:03.000,null,transaction from wallet2 to wallet1\r\n' +
          'null,null,Wallet 1,1.0,1970-01-01 02:00:00.000,null,Wallet initial balance\r\n' +
          'null,null,Wallet 2,10.0,1970-01-01 02:00:00.000,null,Wallet initial balance';

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
        expect: () => <BackupState>[BackupLoaded(4)],
      );
    }
  });
}
