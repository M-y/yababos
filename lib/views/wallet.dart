import 'package:flutter/material.dart';
import 'package:yababos/generated/l10n.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/states/transaction.dart';
import 'package:yababos/views/transaction_editor.dart';
import 'package:yababos/views/transaction.dart';

class WalletWidget extends StatefulWidget {
  final int id;

  const WalletWidget(this.id);

  @override
  State<StatefulWidget> createState() => WalletWidgetState();
}

class WalletWidgetState extends State<WalletWidget> {
  @override
  Widget build(BuildContext walletWidgetContext) {
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
                return TransactionWidget(transactions[index]);
              },
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  walletWidgetContext,
                  MaterialPageRoute(
                    builder: (econtext) {
                      return TransactionEditor(
                        transaction:
                            Transaction(id: null, from: widget.id, to: null),
                        onSave: (transaction) =>
                            BlocProvider.of<TransactionBloc>(context)
                                .add(TransactionAdd(transaction)),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
