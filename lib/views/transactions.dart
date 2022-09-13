import 'package:flutter/material.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/views/transaction.dart';

class TransactionsWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Wallet> wallets;
  final Wallet selectedWallet;

  const TransactionsWidget(
      {required this.transactions,
      required this.wallets,
      required this.selectedWallet});

  @override
  Widget build(BuildContext context) {
    int? lastDate;

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        Transaction transaction = transactions[index];
        int date = transaction.when.year +
            transaction.when.month +
            transaction.when.day;
        bool showDate = false;
        if (lastDate != date) {
          showDate = true;
          lastDate = date;
        }
        return TransactionWidget(
          transaction: transaction,
          wallets: wallets,
          wallet: selectedWallet,
          showDate: showDate,
        );
      },
    );
  }
}
