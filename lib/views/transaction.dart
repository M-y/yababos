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
                  if (transaction.tags != null)
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
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Wrap(
                  children: (transaction.tags == null)
                      ? []
                      : transaction.tags
                          .map((tag) => Container(
                                color: tag.color,
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.all(.5),
                                child: Text(tag.name),
                              ))
                          .toList(),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(transaction.description ?? ''),
              ),
              Expanded(
                  flex: 1,
                  child: Text((_isExpense() ? '-' : '') +
                      transaction.amount.toString()))
            ],
          ),
        ),
      ),
    );
  }
}
