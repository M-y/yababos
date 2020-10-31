import 'package:yababos/models/transaction.dart';

abstract class TransactionState {
  const TransactionState();
}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  Transaction transaction;
  List<Transaction> transactions;

  TransactionLoaded();
  TransactionLoaded.one(this.transaction);
  TransactionLoaded.all(this.transactions);
}
