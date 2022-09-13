import 'package:flutter/material.dart';

class OverviewWidget extends StatelessWidget {
  final String balance;
  final String income;
  final String expense;

  const OverviewWidget(
      {required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(balance, style: Theme.of(context).textTheme.headlineLarge),
        Icon(Icons.arrow_downward, color: Colors.green),
        Text('+' + income, style: Theme.of(context).textTheme.bodyMedium),
        Icon(Icons.arrow_upward, color: Colors.red),
        Text('-' + expense, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
