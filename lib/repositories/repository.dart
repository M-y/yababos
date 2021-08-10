import 'package:yababos/repositories/inmemory/settings.dart';
import 'package:yababos/repositories/inmemory/tag.dart';
import 'package:yababos/repositories/inmemory/transaction.dart';
import 'package:yababos/repositories/inmemory/wallet.dart';
import 'package:yababos/repositories/settings_repository.dart';
import 'package:yababos/repositories/tag_repository.dart';
import 'package:yababos/repositories/transaction_repository.dart';
import 'package:yababos/repositories/wallet_repository.dart';

class RepositorySelections {
  static SettingsRepository settingsRepository = SettingsInmemory();
  static WalletRepository walletRepository = WalletInmemory();
  static TransactionRepository transactionRepository = TransactionInmemory();
  static TagRepository tagRepository = TagInmemory();
}
