import 'package:yababos/repositories/settings_repository.dart';
import 'package:yababos/repositories/sqlite/settings.dart';
import 'package:yababos/repositories/sqlite/tag.dart';
import 'package:yababos/repositories/sqlite/transaction.dart';
import 'package:yababos/repositories/sqlite/wallet.dart';
import 'package:yababos/repositories/tag_repository.dart';
import 'package:yababos/repositories/transaction_repository.dart';
import 'package:yababos/repositories/wallet_repository.dart';

class RepositorySelections {
  static SettingsRepository settingsRepository = SettingsSqlite();
  static WalletRepository walletRepository = WalletSqlite();
  static TagRepository tagRepository = TagSqlite();
  static TransactionRepository transactionRepository =
      TransactionSqlite(tagRepository);
}
