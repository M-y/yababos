import 'package:yababos/models/setting.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/repositories/csv.dart';
import 'package:yababos/repositories/inmemory/settings.dart';
import 'package:yababos/repositories/inmemory/tag.dart';
import 'package:yababos/repositories/inmemory/transaction.dart';
import 'package:yababos/repositories/inmemory/wallet.dart';
import 'package:yababos/repositories/settings.dart';
import 'package:yababos/repositories/tag.dart';
import 'package:yababos/repositories/transaction.dart';
import 'package:yababos/repositories/wallet.dart';

import '../models/transaction.dart';
import '../models/wallet.dart';

class RepositorySelections {
  static SettingsRepository settingsRepository = SettingsInmemory();
  static WalletRepository walletRepository = WalletInmemory();
  static TagRepository tagRepository = TagInmemory();
  static TransactionRepository transactionRepository = TransactionInmemory();

  static CsvRepository csvRepository = CsvRepository();

  static initalize() async {
    await sampleDatabase(walletRepository, tagRepository, transactionRepository,
        settingsRepository);
  }

  static sampleDatabase(
      WalletRepository walletRepository,
      TagRepository tagRepository,
      TransactionRepository transactionRepository,
      SettingsRepository settingsRepository) async {
    await tagRepository.clear();
    await transactionRepository.clear();
    await walletRepository.clear();
    await settingsRepository.clear();

    Wallet wallet1 = Wallet(id: 1, name: 'Wallet 1', curreny: 'TRY', amount: 1);
    Wallet wallet2 =
        Wallet(id: 2, name: 'Wallet 2', curreny: 'TRY', amount: 10);
    await walletRepository.add(wallet1);
    await walletRepository.add(wallet2);

    List<Transaction> transactions = List.from([
      Transaction(
        id: 1,
        from: 1,
        to: 0,
        amount: 100,
        when: DateTime.now(),
        description: 'transaction with tags',
        tags: [Tag(name: 't1'), Tag(name: 't2')],
      ),
      Transaction(
        id: 2,
        from: 1,
        to: 0,
        amount: 50,
        when: DateTime.now(),
        description: 'expense',
      ),
      Transaction(
        id: 3,
        from: 2,
        to: 1,
        amount: 1000,
        when: DateTime.now().subtract(Duration(days: 1)),
        description: 'transaction from wallet2 to wallet1',
      ),
      Transaction(
        id: 4,
        from: 1,
        to: 0,
        amount: 100,
        when: DateTime.now().subtract(Duration(days: 1)),
        description: 'expense',
      ),
    ]);

    for (Transaction transaction in transactions) {
      if (transaction.tags != null)
        for (Tag tag in transaction.tags!) {
          if (await tagRepository.get(tag.name) == null)
            await tagRepository.add(tag);
        }
      await transactionRepository.add(transaction);
    }

    settingsRepository.add(Setting(name: 'wallet', value: 1));
  }
}
