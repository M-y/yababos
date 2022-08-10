import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/states/tag.dart';
import 'package:yababos/states/transaction.dart';
import 'package:yababos/views/transaction.dart';

class SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ChipsInput(
            maxChips: 1,
            chipBuilder: (context, state, tag) {
              return InputChip(
                  label: Text((tag as Tag).name),
                  onDeleted: () => state.deleteChip(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap);
            },
            suggestionBuilder: (context, chipsInputState, data) {
              if (data != null) {
                return ListTile(
                  title: Text((data as Tag).name),
                  onTap: () {
                    (data as Tag).name =
                        (data as Tag).name.replaceFirst(RegExp('^\\+ '), '');
                    chipsInputState.selectSuggestion(data);
                  },
                );
              }
              return const Center(
                child: LinearProgressIndicator(),
                heightFactor: 10,
                widthFactor: 10,
              );
            },
            findSuggestions: (query) async {
              Tag queryTag = Tag(name: query);

              // fire TagFind event on TagBloc
              BlocProvider.of<TagBloc>(context).add(TagFind(queryTag));
              // wait for state
              TagState findState =
                  await BlocProvider.of<TagBloc>(context).stream.last;

              if (findState is TagLoaded) {
                if (findState.tags.contains(queryTag)) return findState.tags;
                return findState.tags + [Tag(name: '+ ' + query)];
              }
              return [null];
            },
            onChanged: (value) => BlocProvider.of<TransactionBloc>(context).add(
                TransactionSearch(Transaction(
                    id: null,
                    from: null,
                    to: null,
                    amount: null,
                    when: null,
                    description: null,
                    tags: List<Tag>.from(
                        [Tag(name: (value.first as Tag).name)])))),
          ),
          BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
            if (state is TransactionsFound) {
              return Text(state.balance.toString());
            }
            return Text('');
          }),
          BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
            if (state is TransactionsFound) {
              List<Transaction> transactions = state.transactions;
              int lastDate;

              return Expanded(
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
                      wallets: <Wallet>[],
                      wallet: Wallet(id: null),
                      showDate: showDate,
                    );
                  },
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
