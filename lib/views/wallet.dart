import 'package:flutter/material.dart';

class Wallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WalletState();
}

class WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: ListView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
