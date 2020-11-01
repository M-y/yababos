import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

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
            // Amount
            TextFormField(
              decoration: InputDecoration(labelText: S.of(context).amount),
              initialValue: _isEdit() ? transaction.amount.toString() : null,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true, signed: false),
              onSaved: (newValue) =>
                  transaction.amount = double.parse(newValue),
            ),
            // Tags
            ChipsInput(
              decoration: InputDecoration(labelText: 'Tags'),
              chipBuilder: (context, state, data) {
                return InputChip(
                    label: Text(data.toString()),
                    onDeleted: () => state.deleteChip(data),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap);
              },
              suggestionBuilder: (context, state, data) {
                return ListTile(
                  title: Text(data.toString()),
                  onTap: () => state.selectSuggestion(data),
                );
              },
              findSuggestions: (query) {
                return <String>[query];
              },
              onChanged: (value) {
                transaction.tags = value.map((e) => e.toString()).toList();
              },
            ),
            // Description
            TextFormField(
              decoration: InputDecoration(labelText: S.of(context).description),
              initialValue: _isEdit() ? transaction.description : null,
              onSaved: (newValue) => transaction.description = newValue,
              maxLines: 10,
            ),
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
