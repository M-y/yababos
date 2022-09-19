import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    DateTime? lastDate;
    List<ExpansionTile> expansionTiles = List.empty(growable: true);
    List<Widget> children = List.empty(growable: true);
    double balance = 0;

    for (Transaction transaction in transactions) {
      DateTime date = DateTime(
          transaction.when.year, transaction.when.month, transaction.when.day);

      if (date != lastDate) {
        if (lastDate != null) {
          expansionTiles
              .add(expansionTile(lastDate, context, balance, children));
          children = List.empty(growable: true);
          balance = 0;
        }
        lastDate = date;
      }

      children.add(TransactionWidget(
        transaction: transaction,
        wallets: wallets,
        wallet: selectedWallet,
        showDate: false,
      ));
      if (_isExpense(transaction, selectedWallet))
        balance -= transaction.amount;
      else
        balance += transaction.amount;
    }
    expansionTiles.add(expansionTile(lastDate!, context, balance, children));

    return ListView.builder(
      itemCount: expansionTiles.length,
      itemBuilder: (context, index) {
        return Card(child: expansionTiles[index]);
      },
    );
  }

  ExpansionTile expansionTile(DateTime date, BuildContext context,
      double balance, List<Widget> children) {
    return ExpansionTile(
      key: Key("tile" + date.toString()),
      title: Align(
        child: Text(DateFormat.MMMMEEEEd().format(date),
            style: Theme.of(context).textTheme.caption),
        alignment: Alignment.centerRight,
      ),
      subtitle: _balance(balance),
      children: children,
    );
  }

  bool _isExpense(Transaction transaction, Wallet wallet) {
    if (transaction.from == wallet.id) return true;
    return false;
  }

  Widget _balance(double balance) {
    if (balance > 0) {
      return Text(
        balance.toString(),
        style: TextStyle(color: Colors.green),
      );
    }

    return Text(balance.toString());
  }
}
