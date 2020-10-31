import 'package:flutter/material.dart';
import 'package:yababos/generated/l10n.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/states/transaction.dart';
import 'package:yababos/views/transactionitem.dart';

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
                final Transaction transaction1 = Transaction(
                  id: 1,
                  from: 1,
                  to: null,
                  amount: 9.99,
                  description: 'milk',
                  tags: ['market'],
                );

                BlocProvider.of<TransactionBloc>(context)
                    .add(TransactionAdd(transaction1));
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
