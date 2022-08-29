import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/models/tag.dart';

import 'package:yababos/models/transaction.dart';
import 'package:yababos/generated/l10n.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/states/tag.dart';
import 'package:yababos/views/wallet_list.dart';

typedef OnSave = Function(Transaction transaction);
typedef OnDelete = Function(Transaction transaction);

class TransactionEditor extends StatefulWidget {
  final List<Wallet> wallets;
  final Transaction transaction;
  final OnSave onSave;
  final OnDelete? onDelete;
  final bool isNew;

  const TransactionEditor({
    required this.wallets,
    required this.transaction,
    required this.onSave,
    this.onDelete,
    this.isNew = false,
  });

  @override
  State<StatefulWidget> createState() => TransactionEditorState();
}

class TransactionEditorState extends State<TransactionEditor> {
  late Transaction transaction;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    transaction = widget.transaction;
    return Scaffold(
      appBar: AppBar(
        title: Text(!widget.isNew
            ? S.of(context).editTransaction
            : S.of(context).newTransaction),
        actions: [
          !widget.isNew
              ? TextButton(
                  child: Text(
                    S.of(context).delete,
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    widget.onDelete!(transaction);
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
            Row(
              children: [
                // From
                Expanded(
                  child: WalletList(
                    key: Key("from"),
                    outside: true,
                    wallets: widget.wallets,
                    onTap: (id) => transaction.from = id,
                    selected: transaction.from,
                  ),
                ),
                // To
                Expanded(
                  child: WalletList(
                    key: Key("to"),
                    outside: true,
                    wallets: widget.wallets,
                    onTap: (id) => transaction.to = id,
                    selected: transaction.to,
                  ),
                ),
              ],
            ),
            // When
            DateTimePicker(
              key: Key("when"),
              initialDate: transaction.when,
              onSaved: (newValue) =>
                  transaction.when = DateTime.parse(newValue!),
              initialValue: transaction.when.toIso8601String(),
              icon: Icon(Icons.event),
              firstDate: DateTime(1900, 1, 1),
              lastDate: DateTime.now().add(Duration(days: 365 * 100)),
            ),
            // Amount
            TextFormField(
              key: Key("amount"),
              decoration: InputDecoration(labelText: S.of(context).amount),
              initialValue:
                  !widget.isNew ? transaction.amount.toString() : null,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true, signed: false),
              onSaved: (newValue) =>
                  transaction.amount = double.parse(newValue!),
            ),
            // Tags
            ChipsInput(
              key: Key("tags"),
              decoration: InputDecoration(labelText: S.of(context).tags),
              initialValue: transaction.tags ?? [],
              chipBuilder: (context, state, dynamic tag) {
                return InputChip(
                    label: Text((tag as Tag).name),
                    onDeleted: () => state.deleteChip(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap);
              },
              suggestionBuilder: (context, chipsInputState, dynamic data) {
                if (data != null) {
                  return ListTile(
                    title: Text((data as Tag).name),
                    onTap: () {
                      data.name = data.name.replaceFirst(RegExp('^\\+ '), '');
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
                BlocProvider.of<TagBloc>(context).add(TagFind(queryTag));
                // wait for state
                TagState findState =
                    await BlocProvider.of<TagBloc>(context).stream.last;

                if (findState is TagLoaded) {
                  if (findState.tags.contains(queryTag)) return findState.tags;
                  return findState.tags + [Tag(name: '+ ' + query)];
                }
                return [null];
              },
              onChanged: (value) => transaction.tags =
                  value.map((e) => (e as Tag?)).toList() as List<Tag>?,
            ),
            // Description
            TextFormField(
              key: Key("description"),
              decoration:
                  InputDecoration(labelText: S.of(context).description),
              initialValue: !widget.isNew ? transaction.description : null,
              onSaved: (newValue) => transaction.description = newValue,
              maxLines: 10,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          _formKey.currentState!.save();
          widget.onSave(transaction);
          Navigator.pop(context);
        },
      ),
    );
  }
}
