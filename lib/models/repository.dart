import 'package:yababos/models/inmemory/tag.dart';
import 'package:yababos/models/inmemory/transaction.dart';
import 'package:yababos/models/tag_repository.dart';
import 'package:yababos/models/transaction_repository.dart';

class RepositorySelections {
  static TransactionRepository transactionRepository = TransactionInmemory();
  static TagRepository tagRepository = TagInmemory();
}
