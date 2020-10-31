import 'package:flutter/material.dart';
import 'package:yababos/generated/l10n.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/states/transaction.dart';

class Wallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WalletState();
}

class WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final Transaction transaction1 =
            Transaction(id: 1, from: null, to: null);
        final Transaction transaction2 =
            Transaction(id: 2, from: null, to: null);

        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).wallet),
          ),
          body: ListView(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              BlocProvider.of<TransactionBloc>(context)
                  .add(TransactionAdd(transaction1));

              transaction1.description = 'test';
              BlocProvider.of<TransactionBloc>(context)
                  .add(TransactionUpdate(transaction1));

              BlocProvider.of<TransactionBloc>(context)
                  .add(TransactionDelete(transaction1.id));
              BlocProvider.of<TransactionBloc>(context)
                  .add(TransactionAdd(transaction2));
              BlocProvider.of<TransactionBloc>(context)
                  .add(TransactionGet(transaction2.id));
            },
          ),
        );
      },
    );
  }
}
