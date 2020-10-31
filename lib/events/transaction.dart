import 'package:yababos/models/transaction.dart';

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

class TransactionDelete extends TransactionEvent {
  final int id;

  const TransactionDelete(this.id);
}
