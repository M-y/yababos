import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/settings.dart';
import 'package:yababos/blocs/wallet.dart';
import 'package:yababos/events/settings.dart';
import 'package:yababos/events/wallet.dart';
import 'app.dart';
import 'blocs/tag.dart';
import 'blocs/transaction.dart';
import 'repositories/repository.dart';

void main() {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) =>
            SettingsBloc(RepositorySelections.settingsRepository)
              ..add(SettingGet('wallet')),
      ),
      BlocProvider(
        create: (context) =>
            TransactionBloc(RepositorySelections.transactionRepository),
      ),
      BlocProvider(
        create: (context) => TagBloc(RepositorySelections.tagRepository),
      ),
      BlocProvider(
        create: (context) => WalletBloc(
            RepositorySelections.walletRepository,
            BlocProvider.of<SettingsBloc>(context),
            BlocProvider.of<TransactionBloc>(context))
          ..add(WalletGetAll()),
      ),
    ],
    child: Yababos(),
  ));
}
