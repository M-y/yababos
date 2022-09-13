import 'package:flutter/material.dart';

class OverviewWidget extends StatelessWidget {
  final String balance;

  OverviewWidget(this.balance);

  @override
  Widget build(BuildContext context) {
    return Text(balance, style: Theme.of(context).textTheme.headline6);
  }
}
