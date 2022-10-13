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
      appBar: AppBar(
        leading: BackButton(),
      ),
      body: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: S.of(context).search),
            onChanged: (value) => BlocProvider.of<TransactionBloc>(context)
                .add(TransactionSearchOr(model.TransactionSearch(
              id: null,
              from: null,
              to: null,
              amount: null,
              when: null,
              description: value,
              tags: List<Tag>.from([Tag(name: value)]),
            ))),
          ),
          // Summary
          BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
            Widget? balance;
            if (state is TransactionsFound && state.transactions.length > 0) {
              balance = Text(state.balance.toString(), key: Key("balance"));
            }

            if (state is TransactionsFound) {
              Widget foundLength = Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "${state.transactions.length} found",
                  style: Theme.of(context).textTheme.caption,
                ),
              );

              if (balance == null)
                return foundLength;
              else
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [balance, foundLength]);
            }
            return const Text('');
          }),
          // Transactions
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
            
            if (state is TransactionLoading)
              return const Center(child: CircularProgressIndicator());
            return const Text('');
          })
        ],
      ),
    );
  }
}
