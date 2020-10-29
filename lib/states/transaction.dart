import 'package:yababos/models/transaction.dart';

abstract class TransactionState {
  const TransactionState();
}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  Transaction transaction;

  TransactionLoaded();
  TransactionLoaded.one(this.transaction);
}
