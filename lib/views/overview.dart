import 'package:flutter/material.dart';

class OverviewWidget extends StatelessWidget {
  final String balance;

  OverviewWidget(this.balance);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(balance, style: Theme.of(context).textTheme.headline6),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => Navigator.of(context).pushNamed('/search'),
        )
      ],
    );
  }
}
