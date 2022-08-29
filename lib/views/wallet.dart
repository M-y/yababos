import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:yababos/blocs/settings.dart';
import 'package:yababos/events/settings.dart';
import 'package:yababos/generated/l10n.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/setting.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/states/transaction.dart';
import 'package:yababos/views/overview.dart';
import 'package:yababos/views/transaction_editor.dart';
import 'package:yababos/views/transaction.dart';
import 'package:yababos/views/wallet_list.dart';

class WalletWidget extends StatefulWidget {
  final Wallet? selectedWallet;
  final List<Wallet> wallets;
  final DateTime month;

  const WalletWidget({this.selectedWallet, required this.wallets, required this.month});

  @override
  State<StatefulWidget> createState() => WalletWidgetState();
}

class WalletWidgetState extends State<WalletWidget> {
  DateTime? _month;

  @override
  void initState() {
    super.initState();
    _month = widget.month;
  }

  @override
  Widget build(BuildContext walletWidgetContext) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is WalletTransactionsLoaded) {
          List<Transaction> transactions = state.transactions;
          int? lastDate;

          return Scaffold(
            appBar: AppBar(
              // Wallet select button
              title: TextButton(
                child: Text(
                  widget.selectedWallet!.name!,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return WalletList(
                        wallets: widget.wallets,
                        onTap: (id) {
                          BlocProvider.of<SettingsBloc>(context)
                              .add(SettingAdd(Setting(
                            name: 'wallet',
                            value: id,
                          )));
                          Navigator.pop(context);
                        },
                        selected: widget.selectedWallet!.id,
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
                    title: Text(S.of(context).wallets),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/wallets');
                    },
                  ),
                  ListTile(
                    title: Text(S.of(context).tags),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/tags');
                    },
                  ),
                  ListTile(
                    title: Text(S.of(context).backup),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/backup');
                    },
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                // Overiview
                OverviewWidget(
                    '${state.balance} ${widget.selectedWallet!.curreny}'),
                // Date
                TextButton(
                  onPressed: () {
                    showMonthPicker(context: context, initialDate: _month!)
                        .then((date) {
                      setState(() {
                        _month = date;
                      });
                      BlocProvider.of<TransactionBloc>(context).add(
                          TransactionGetWallet(
                              widget.selectedWallet!.id, date!.year, date.month));
                    });
                  },
                  child: Text(
                    '${DateFormat.MMMM().format(_month!)}, ${_month!.year}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                // Transactions
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      Transaction transaction = transactions[index];
                      int date = transaction.when.year +
                          transaction.when.month +
                          transaction.when.day;
                      bool showDate = false;
                      if (lastDate != date) {
                        showDate = true;
                        lastDate = date;
                      }
                      return TransactionWidget(
                        transaction: transaction,
                        wallets: widget.wallets,
                        wallet: widget.selectedWallet!,
                        showDate: showDate,
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  walletWidgetContext,
                  MaterialPageRoute(
                    builder: (econtext) {
                      return TransactionEditor(
                        isNew: true,
                        wallets: widget.wallets.toList(),
                        transaction: Transaction(
                          id: 0,
                          from: widget.selectedWallet!.id,
                          to: 0,
                          amount: 0,
                          when: DateTime.now(),
                        ),
                        onSave: (transaction) {
                          if (transaction.tags != null)
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
