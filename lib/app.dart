import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'blocs/wallet.dart';
import 'generated/l10n.dart';
import 'package:yababos/views/wallet.dart';
import 'package:yababos/states/wallet.dart';
import 'package:yababos/views/wallets.dart';

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
      home: BlocBuilder<WalletBloc, WalletState>(builder: (context, state) {
        if (state is WalletLoaded) {
          if (state.wallets.length < 1) return WalletsWidget();

          return WalletWidget(
            selectedWallet: state.selectedWallet,
            wallets: state.wallets,
          );
        }
        return const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
