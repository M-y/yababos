import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/models/tag.dart';

import 'package:yababos/models/transaction.dart';
import 'package:yababos/generated/l10n.dart';
import 'package:yababos/states/tag.dart';

typedef OnSave = Function(Transaction transaction);
typedef OnDelete = Function(Transaction transaction);

class TransactionEditor extends StatelessWidget {
  final Transaction transaction;
  final OnSave onSave;
  final OnDelete onDelete;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  const TransactionEditor({
    @required this.transaction,
    @required this.onSave,
    this.onDelete,
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
        actions: [
          _isEdit()
              ? FlatButton(
                  child: Text(
                    S.of(context).delete,
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    onDelete(transaction);
                    Navigator.pop(context);
                  },
                )
              : Container()
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // From
            // To
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
              decoration: InputDecoration(labelText: S.of(context).tags),
              initialValue: transaction.tags ?? [],
              chipBuilder: (context, state, tag) {
                return InputChip(
                    label: Text((tag as Tag).name),
                    onDeleted: () => state.deleteChip(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap);
              },
              suggestionBuilder: (context, chipsInputState, data) {
                if (data != null) {
                  return ListTile(
                    title: Text((data as Tag).name),
                    onTap: () {
                      (data as Tag).name =
                          (data as Tag).name.replaceFirst(RegExp('^\\+ '), '');
                      chipsInputState.selectSuggestion(data);
                    },
                  );
                }
                return const Center(
                  child: LinearProgressIndicator(),
                  heightFactor: 10,
                  widthFactor: 10,
                );
              },
              findSuggestions: (query) async {
                Tag queryTag = Tag(name: query);

                // fire TagFind event on TagBloc
                Stream<TagState> fireEvent = BlocProvider.of<TagBloc>(context)
                    .mapEventToState(TagFind(queryTag));
                // wait for state
                TagState findState = await fireEvent.last;

                if (findState is TagLoaded) {
                  if (findState.tags.contains(queryTag)) return findState.tags;
                  return findState.tags + [Tag(name: '+ ' + query)];
                }
                return [null];
              },
              onChanged: (value) =>
                  transaction.tags = value.map((e) => (e as Tag)).toList(),
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
