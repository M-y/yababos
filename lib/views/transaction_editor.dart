import 'package:flutter/material.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/generated/l10n.dart';

typedef OnSave = Function(Transaction transaction);

class TransactionEditor extends StatelessWidget {
  final Transaction transaction;
  final OnSave onSave;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  const TransactionEditor({
    @required this.transaction,
    @required this.onSave,
  });

  bool _isEdit() {
    if (transaction.id != null) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit()
            ? S.of(context).editTransaction
            : S.of(context).newTransaction),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: S.of(context).amount),
              initialValue: _isEdit() ? transaction.amount.toString() : null,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true, signed: false),
              onSaved: (newValue) =>
                  transaction.amount = double.parse(newValue),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: S.of(context).description),
              initialValue: _isEdit() ? transaction.description : null,
              onSaved: (newValue) => transaction.description = newValue,
              maxLines: 100,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          _formKey.currentState.save();
          onSave(transaction);
          Navigator.pop(context);
        },
      ),
    );
  }
}
