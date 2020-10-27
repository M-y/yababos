import 'package:flutter/material.dart';
import 'package:yababos/views/wallet.dart';

class Yababos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yababos',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Wallet(),
    );
  }
}
