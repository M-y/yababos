import 'package:flutter/material.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/generated/l10n.dart';

typedef OnTap = Function(int id);

class WalletList extends StatefulWidget {
  final List<Wallet> wallets;
  final OnTap? onTap;
  final bool outside;
  int? selected;

  WalletList(
      {Key? key,
      required this.wallets,
      this.onTap,
      this.outside = false,
      this.selected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => WalletListState();
}

class WalletListState extends State<WalletList> {
  @override
  Widget build(BuildContext context) {
    List<ListTile> walletButtons = <ListTile>[];
    if (widget.outside)
      walletButtons.add(ListTile(
        selected: widget.selected == 0,
        title: Text(
          S.of(context).outside,
          style: TextStyle(color: Colors.grey),
        ),
        onTap: () {
          widget.onTap!(0);
          setState(() {
            widget.selected = 0;
          });
        },
      ));

    for (Wallet wallet in widget.wallets) {
      walletButtons.add(ListTile(
        selected: widget.selected == wallet.id,
        title: Text(wallet.name!),
        onTap: () {
          widget.onTap!(wallet.id);
          setState(() {
            widget.selected = wallet.id;
          });
        },
      ));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: walletButtons.length,
      itemBuilder: (BuildContext lcontext, int index) {
        return walletButtons[index];
      },
    );
  }
}
