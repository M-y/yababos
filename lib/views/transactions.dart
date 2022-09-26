import 'dart:collection';

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
    List<ExpansionTile> expansionTiles = _buildExpansionTiles(context);

    return ListView.builder(
      itemCount: expansionTiles.length,
      itemBuilder: (context, index) {
        return Card(child: expansionTiles[index]);
      },
    );
  }

  List<ExpansionTile> _buildExpansionTiles(BuildContext context) {
    List<ExpansionTile> expansionTiles = List.empty(growable: true);

    _getDayMaps().forEach((day, dayTransactions) {
      double dayBalance = 0;
      List<Widget> children = List.empty(growable: true);

      for (Transaction transaction in dayTransactions) {
        children.add(TransactionWidget(
          transaction: transaction,
          wallets: wallets,
          wallet: selectedWallet,
          showDate: false,
        ));

        if (_isExpense(transaction, selectedWallet))
          dayBalance -= transaction.amount;
        else
          dayBalance += transaction.amount;
      }

      expansionTiles
          .add(_buildExpansionTile(context, day, dayBalance, children));
    });

    return expansionTiles;
  }

  HashMap<DateTime, List<Transaction>> _getDayMaps() {
    HashMap<DateTime, List<Transaction>> map =
        HashMap<DateTime, List<Transaction>>();

    for (Transaction transaction in transactions) {
      DateTime date = DateTime(
          transaction.when.year, transaction.when.month, transaction.when.day);

      if (!map.containsKey(date))
        map[date] = List<Transaction>.empty(growable: true);
      (map[date] as List).add(transaction);
    }

    return map;
  }

  ExpansionTile _buildExpansionTile(BuildContext context, DateTime date,
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
