import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/views/transaction_editor.dart';

class TransactionWidget extends StatelessWidget {
  final Transaction transaction;

  const TransactionWidget(this.transaction);

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (econtext) => TransactionEditor(
                transaction: transaction,
                onSave: (transaction) {
                  BlocProvider.of<TagBloc>(context)
                      .add(TagsAdd(transaction.tags));
                  BlocProvider.of<TransactionBloc>(context)
                      .add(TransactionUpdate(transaction));
                },
                onDelete: (transaction) =>
                    BlocProvider.of<TransactionBloc>(context)
                        .add(TransactionDelete(transaction.id)),
              ),
            ),
          );
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
