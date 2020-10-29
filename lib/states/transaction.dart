abstract class TransactionState {
  const TransactionState();
}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {}
