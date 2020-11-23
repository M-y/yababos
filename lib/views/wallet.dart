import 'package:flutter/material.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/generated/l10n.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/states/transaction.dart';
import 'package:yababos/views/transaction_editor.dart';
import 'package:yababos/views/transaction.dart';
import 'package:yababos/views/wallets.dart';

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
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    child: Text("Yababos"),
                  ),
                  ListTile(
                    title: Text("Wallets"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext rcontext) {
                          return WalletsWidget();
                        }),
                      );
                    },
                  ),
                  ListTile(
                    title: Text("Tags"),
                    onTap: () {},
                  )
                ],
              ),
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
                        onSave: (transaction) {
                          if (transaction.tags != null)
                            BlocProvider.of<TagBloc>(context)
                                .add(TagsAdd(transaction.tags));
                          BlocProvider.of<TransactionBloc>(context)
                              .add(TransactionAdd(transaction));
                        },
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
