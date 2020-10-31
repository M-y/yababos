import 'package:flutter/material.dart';
import 'package:yababos/models/transaction.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem(this.transaction);

  bool _isExpense() {
    if (transaction.to == null) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _isExpense() ? Colors.white : Colors.lightGreenAccent,
      child: InkWell(
        onTap: () {
          print(1);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Icon(Icons.category),
              ),
              Center(child: Text(transaction.description ?? '')),
              Align(
                alignment: Alignment.topRight,
                child: Text(
                    (_isExpense() ? '-' : '') + transaction.amount.toString()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
