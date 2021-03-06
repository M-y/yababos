import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:yababos/blocs/settings.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/blocs/wallet.dart';
import 'package:yababos/events/settings.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/events/wallet.dart';
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
import 'package:yababos/states/settings.dart';
import 'package:yababos/states/tag.dart';
import 'package:yababos/states/transaction.dart';
import 'package:yababos/states/wallet.dart';

void main() {
  group('Settings', () {
    SettingsRepository settingsRepository = SettingsInmemory();
    Setting sampleSetting = Setting(name: 'sample', value: 1);
    Setting sampleSettingChanged = Setting(name: 'sample', value: 2);

    blocTest(
      'add setting',
      build: () => SettingsBloc(settingsRepository),
      act: (bloc) => bloc.add(SettingAdd(sampleSetting)),
      expect: <SettingState>[SettingChanged(sampleSetting)],
    );

    blocTest(
      'add same setting',
      build: () => SettingsBloc(settingsRepository),
      act: (bloc) => bloc.add(SettingAdd(sampleSetting)),
      expect: <SettingState>[SettingLoaded(sampleSetting)],
    );

    blocTest(
      'update setting',
      build: () => SettingsBloc(settingsRepository),
      act: (bloc) => bloc.add(SettingAdd(sampleSettingChanged)),
      expect: <SettingState>[SettingChanged(sampleSettingChanged)],
    );

    blocTest(
      'get setting',
      build: () => SettingsBloc(settingsRepository),
      act: (bloc) => bloc.add(SettingGet('sample')),
      expect: <SettingState>[SettingLoaded(sampleSettingChanged)],
    );
  });

  group('Wallet', () {
    WalletRepository walletRepository = WalletInmemory();
    SettingsRepository settingsRepository = SettingsInmemory();
    SettingsBloc settingsBloc = SettingsBloc(settingsRepository);
    Wallet sampleWallet = Wallet(
      id: null,
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
      'WalletAdd',
      build: () => WalletBloc(walletRepository, settingsBloc),
      act: (bloc) => bloc.add(WalletAdd(sampleWallet)),
      expect: <WalletState>[WalletLoaded(wallets: sampleWalletList)],
    );

    blocTest(
      'WalletGetAll',
      build: () => WalletBloc(walletRepository, settingsBloc),
      act: (bloc) => bloc.add(WalletGetAll()),
      expect: <WalletState>[WalletLoaded(wallets: sampleWalletList)],
    );

    blocTest(
      'WalletGet',
      build: () => WalletBloc(walletRepository, settingsBloc),
      act: (bloc) => bloc.add(WalletGet(1)),
      expect: <WalletState>[WalletLoaded.one(sampleWallet)],
    );

    blocTest(
      'WalletUpdate',
      build: () => WalletBloc(walletRepository, settingsBloc),
      act: (bloc) => bloc.add(WalletUpdate(updatedWallet)),
      expect: <WalletState>[WalletLoaded(wallets: updatedWalletList)],
    );

    blocTest(
      'WalletDelete',
      build: () => WalletBloc(walletRepository, settingsBloc),
      act: (bloc) => bloc.add(WalletDelete(1)),
      expect: <WalletState>[WalletLoaded(wallets: List<Wallet>())],
    );

    blocTest(
      'selected wallet',
      build: () => WalletBloc(walletRepository, settingsBloc),
      act: (bloc) {
        bloc.add(WalletAdd(sampleWallet));
        bloc.add(WalletAdd(updatedWallet));
        settingsBloc.add(SettingAdd(Setting(name: 'wallet', value: 1)));
      },
      expect: <WalletState>[
        WalletLoaded(
          wallets: List<Wallet>.from([sampleWallet, updatedWallet]),
          selectedWallet: sampleWallet,
        )
      ],
    );
  });

  group('Transaction', () {
    TransactionRepository transactionRepository = TransactionInmemory();
    Transaction sampleTransaction = Transaction(
      id: null,
      from: 1,
      to: null,
      amount: 100,
      description: 'sample expense',
    );
    Transaction updatedTransaction = Transaction(
      id: 1,
      from: 1,
      to: null,
      amount: 150,
      description: 'updated expense',
    );

    blocTest(
      'TransactionAdd',
      build: () => TransactionBloc(transactionRepository),
      act: (bloc) => bloc.add(TransactionAdd(sampleTransaction)),
      expect: <TransactionState>[
        TransactionLoaded.all(List<Transaction>.from([sampleTransaction]))
      ],
    );

    blocTest(
      'TransactionGetAll',
      build: () => TransactionBloc(transactionRepository),
      act: (bloc) => bloc.add(TransactionGetAll()),
      expect: <TransactionState>[
        TransactionLoaded.all(List<Transaction>.from([sampleTransaction]))
      ],
    );

    blocTest(
      'TransactionGet',
      build: () => TransactionBloc(transactionRepository),
      act: (bloc) => bloc.add(TransactionGet(1)),
      expect: <TransactionState>[TransactionLoaded.one(sampleTransaction)],
    );

    blocTest(
      'TransactionUpdate',
      build: () => TransactionBloc(transactionRepository),
      act: (bloc) => bloc.add(TransactionUpdate(updatedTransaction)),
      expect: <TransactionState>[
        TransactionLoaded.all(List<Transaction>.from([updatedTransaction]))
      ],
    );

    blocTest(
      'TransactionDelete',
      build: () => TransactionBloc(transactionRepository),
      act: (bloc) => bloc.add(TransactionDelete(1)),
      expect: <TransactionState>[TransactionLoaded.all(List<Transaction>())],
    );
  });

  group('Tag', () {
    TagRepository tagRepository = TagInmemory();
    Tag sampleTag = Tag(name: 'sample');
    List<Tag> sampleTagList = [sampleTag];
    Tag newTag = Tag(name: 'new');
    List<Tag> newTagList = [newTag];
    List<Tag> allTags = [sampleTag, newTag];

    blocTest(
      'TagAdd',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagAdd(sampleTag)),
      expect: <TagState>[TagLoaded(sampleTagList)],
    );

    blocTest(
      'TagUpdate',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagUpdate(sampleTag.name, newTag)),
      expect: <TagState>[TagLoaded(newTagList)],
    );

    blocTest(
      'TagDelete',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagDelete(newTag)),
      expect: <TagState>[TagLoaded([])],
    );

    blocTest(
      'TagsAdd',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagsAdd(allTags)),
      expect: <TagState>[TagLoaded(allTags)],
    );

    blocTest(
      'TagFind',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagFind(Tag(name: 'sample'))),
      expect: <TagState>[TagLoaded(sampleTagList)],
    );

    blocTest(
      'TagGetAll',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagGetAll()),
      expect: <TagState>[TagLoaded(allTags)],
    );

    blocTest(
      'duplicate add',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagAdd(sampleTag)),
      expect: <TagState>[TagLoaded(allTags)],
    );
  });
}
