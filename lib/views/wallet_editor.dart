import 'package:flutter/material.dart';
import 'package:yababos/generated/l10n.dart';
import 'package:yababos/models/wallet.dart';

typedef OnSave = Function(Wallet wallet);
typedef OnDelete = Function(Wallet wallet);

class WidgetEditor extends StatelessWidget {
  final Wallet wallet;
  final OnSave onSave;
  final OnDelete onDelete;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  const WidgetEditor({
    @required this.wallet,
    @required this.onSave,
    this.onDelete,
  });

  bool _isEdit() {
    if (wallet.id != null) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEdit() ? S.of(context).editWallet : S.of(context).newWallet),
        actions: [
          _isEdit()
              ? FlatButton(
                  child: Text(
                    S.of(context).delete,
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    onDelete(wallet);
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
            // Name
            TextFormField(
              decoration: InputDecoration(labelText: S.of(context).name),
              initialValue: _isEdit() ? wallet.name : null,
              onSaved: (newValue) => wallet.name = newValue,
            ),
            // Currency
            TextFormField(
              decoration: InputDecoration(labelText: S.of(context).currency),
              initialValue: _isEdit() ? wallet.curreny : null,
              onSaved: (newValue) => wallet.curreny = newValue,
            ),
            // Amount
            TextFormField(
              decoration:
                  InputDecoration(labelText: S.of(context).initialAmount),
              initialValue: _isEdit() ? wallet.amount.toString() : null,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true, signed: false),
              onSaved: (newValue) => wallet.amount = double.parse(newValue),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          _formKey.currentState.save();
          onSave(wallet);
          Navigator.pop(context);
        },
      ),
    );
  }
}
