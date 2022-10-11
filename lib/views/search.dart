import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/models/transaction_search.dart' as model;
import 'package:yababos/models/wallet.dart';
import 'package:yababos/states/transaction.dart';
import 'package:yababos/views/transactions.dart';
import 'package:yababos/generated/l10n.dart';

class SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: S.of(context).search),
            onChanged: (value) => BlocProvider.of<TransactionBloc>(context)
                .add(TransactionSearch(model.TransactionSearch(
              id: null,
              from: null,
              to: null,
              amount: null,
              when: null,
              description: value,
              tags: List<Tag>.from([Tag(name: value)]),
            ))),
          ),
          BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
            if (state is TransactionsFound) {
              return Text(state.balance.toString(), key: Key("balance"));
            }
            return const Text('');
          }),
          BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
            if (state is TransactionsFound) {
              return Text("${state.transactions.length} found");
            }
            return const Text('');
          }),
          BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
            if (state is TransactionsFound) {
              return Expanded(
                child: TransactionsWidget(
                  transactions: state.transactions,
                  wallets: <Wallet>[],
                  selectedWallet: Wallet(id: 0),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          })
        ],
      ),
    );
  }
}
