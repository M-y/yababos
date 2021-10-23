import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/wallet.dart';
import 'package:yababos/events/wallet.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/states/wallet.dart';
import 'package:yababos/views/wallet_editor.dart';
import 'package:yababos/generated/l10n.dart';

class WalletsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (wcontext, state) {
          if (state is WalletsLoaded) {
            List<Wallet> wallets = state.wallets;

            if (wallets.length == 0) {
              return Center(child: Text(S.of(context).noWallets));
            } else {
              return ListView.builder(
                itemCount: wallets.length,
                itemBuilder: (BuildContext lcontext, int index) {
                  return Card(
                    child: InkWell(
                      child: Center(
                        child: Text(wallets[index].name),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (econtext) {
                              return WalletEditor(
                                wallet: wallets[index],
                                onSave: (wallet) =>
                                    BlocProvider.of<WalletBloc>(context)
                                      ..add(WalletGetNone())
                                      ..add(WalletUpdate(wallet)),
                                onDelete: (wallet) =>
                                    BlocProvider.of<WalletBloc>(context)
                                      ..add(WalletGetNone())
                                      ..add(WalletDelete(wallet.id)),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (econtext) {
                return WalletEditor(
                  wallet: Wallet(id: null),
                  onSave: (wallet) => BlocProvider.of<WalletBloc>(context)
                    ..add(WalletGetNone())
                    ..add(WalletAdd(wallet)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
