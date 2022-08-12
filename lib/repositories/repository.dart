import 'package:yababos/repositories/csv.dart';
import 'package:yababos/repositories/settings.dart';
import 'package:yababos/repositories/sqlite/settings.dart';
import 'package:yababos/repositories/sqlite/tag.dart';
import 'package:yababos/repositories/sqlite/transaction.dart';
import 'package:yababos/repositories/sqlite/wallet.dart';
import 'package:yababos/repositories/tag.dart';
import 'package:yababos/repositories/transaction.dart';
import 'package:yababos/repositories/wallet.dart';

class RepositorySelections {
  static SettingsRepository settingsRepository = SettingsSqlite();
  static WalletRepository walletRepository = WalletSqlite();
  static TagRepository tagRepository = TagSqlite();
  static TransactionRepository transactionRepository =
      TransactionSqlite(tagRepository as TagSqlite);

  static CsvRepository csvRepository = CsvRepository();
}
