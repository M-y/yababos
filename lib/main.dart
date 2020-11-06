import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'blocs/tag.dart';
import 'blocs/transaction.dart';
import 'events/transaction.dart';
import 'models/repository.dart';

void main() {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) =>
            TransactionBloc(RepositorySelections.transactionRepository)
              ..add(TransactionGetAll()),
      ),
      BlocProvider(
        create: (context) => TagBloc(RepositorySelections.tagRepository),
      ),
    ],
    child: Yababos(),
  ));
}
