import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/models/repository.dart';
import 'generated/l10n.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/views/wallet.dart';

class Yababos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yababos',
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) =>
            TransactionBloc(RepositorySelections.transactionRepository)
              ..add(TransactionGetAll()),
        child: WalletWidget(0),
      ),
    );
  }
}
