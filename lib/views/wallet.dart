import 'package:flutter/material.dart';
import 'package:yababos/blocs/settings.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/events/settings.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/generated/l10n.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/setting.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/states/transaction.dart';
import 'package:yababos/views/transaction_editor.dart';
import 'package:yababos/views/transaction.dart';
import 'package:yababos/views/wallets.dart';

class WalletWidget extends StatefulWidget {
  final Wallet selectedWallet;
  final List<Wallet> wallets;

  const WalletWidget({this.selectedWallet, this.wallets});

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
              // Wallet select button
              title: TextButton(
                child: Text(
                  widget.selectedWallet.name,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return ListView.builder(
                        itemCount: widget.wallets.length,
                        itemBuilder: (BuildContext lcontext, int index) {
                          return ListTile(
                            title: Text(widget.wallets[index].name),
                            onTap: () {
                              BlocProvider.of<SettingsBloc>(context)
                                  .add(SettingAdd(Setting(
                                name: 'wallet',
                                value: widget.wallets[index].id,
                              )));
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
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
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext rcontext) =>
                                WalletsWidget()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text("Tags"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text("Export / Import"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
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
                        transaction: Transaction(
                            id: null, from: widget.selectedWallet.id, to: null),
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
