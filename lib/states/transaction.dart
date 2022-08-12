import 'package:equatable/equatable.dart';
import 'package:yababos/models/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  Transaction? transaction;
  List<Transaction>? transactions;

  TransactionLoaded();
  TransactionLoaded.one(this.transaction);
  TransactionLoaded.many(this.transactions);

  @override
  List<Object?> get props => [transaction, transactions];
}

class WalletTransactionsLoaded extends TransactionState {
  List<Transaction> transactions;
  double balance;

  WalletTransactionsLoaded(this.transactions, this.balance);

  @override
  List<Object> get props => [transactions, balance];
}

class TransactionsFound extends TransactionState {
  final List<Transaction> transactions;
  final double balance;

  const TransactionsFound(this.transactions, this.balance);

  @override
  List<Object> get props => [transactions, balance];
}
