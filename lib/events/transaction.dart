import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/transaction_search.dart' as model;

abstract class TransactionEvent {
  const TransactionEvent();
}

class TransactionAdd extends TransactionEvent {
  final Transaction transaction;

  const TransactionAdd(this.transaction);
}

class TransactionUpdate extends TransactionEvent {
  final Transaction transaction;

  const TransactionUpdate(this.transaction);
}

class TransactionGet extends TransactionEvent {
  final int id;

  const TransactionGet(this.id);
}

class TransactionGetAll extends TransactionEvent {}

class TransactionGetWallet extends TransactionEvent {
  final int wallet;
  final int year;
  final int month;

  const TransactionGetWallet(this.wallet, this.year, this.month);
}

class TransactionDelete extends TransactionEvent {
  final int id;

  const TransactionDelete(this.id);
}

class TransactionSearch extends TransactionEvent {
  final model.TransactionSearch transaction;
  final model.TransactionSearch? transactionEnd;

  TransactionSearch(this.transaction, [this.transactionEnd]);
}

class TransactionSearchOr extends TransactionEvent {
  final model.TransactionSearch transaction;

  TransactionSearchOr(this.transaction);
}
