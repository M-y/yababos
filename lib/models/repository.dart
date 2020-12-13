import 'package:yababos/models/inmemory/settings.dart';
import 'package:yababos/models/inmemory/tag.dart';
import 'package:yababos/models/inmemory/transaction.dart';
import 'package:yababos/models/inmemory/wallet.dart';
import 'package:yababos/models/settings_repository.dart';
import 'package:yababos/models/tag_repository.dart';
import 'package:yababos/models/transaction_repository.dart';
import 'package:yababos/models/wallet_repository.dart';

class RepositorySelections {
  static SettingsRepository settingsRepository = SettingsInmemory();
  static WalletRepository walletRepository = WalletInmemory();
  static TransactionRepository transactionRepository = TransactionInmemory();
  static TagRepository tagRepository = TagInmemory();
}
