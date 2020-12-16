import 'package:equatable/equatable.dart';
import 'package:yababos/models/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  Transaction transaction;
  List<Transaction> transactions;

  TransactionLoaded();
  TransactionLoaded.one(this.transaction);
  TransactionLoaded.all(this.transactions);

  @override
  List<Object> get props => [transaction, transactions];
}
