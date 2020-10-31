import 'package:flutter/material.dart';
import 'package:yababos/generated/l10n.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/states/transaction.dart';
import 'package:yababos/views/transaction_editor.dart';
import 'package:yababos/views/transaction_item.dart';

class Wallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WalletState();
}

class WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          List<Transaction> transactions = state.transactions;

          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).wallet),
            ),
            body: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return TransactionItem(transactions[index]);
              },
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (econtext) => TransactionEditor(
                        transaction: Transaction(id: null, from: 1, to: null),
                        onSave: (transaction) =>
                            BlocProvider.of<TransactionBloc>(context)
                                .add(TransactionAdd(transaction)),
                      ),
                    ));
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
