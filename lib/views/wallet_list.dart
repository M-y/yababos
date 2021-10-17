import 'package:flutter/material.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/generated/l10n.dart';

typedef OnTap = Function(int id);

class WalletList extends StatelessWidget {
  final List<Wallet> wallets;
  final OnTap onTap;
  final bool outside;

  const WalletList(
      {Key key, @required this.wallets, this.onTap, this.outside = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Wallet> wallets = this.wallets.toList();
    if (outside) wallets.add(Wallet(id: null, name: S.of(context).outside));

    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: wallets.length,
      itemBuilder: (BuildContext lcontext, int index) {
        return ListTile(
          title: Text(wallets[index].name),
          onTap: () {
            onTap(wallets[index].id);
          },
        );
      },
    );
  }
}
