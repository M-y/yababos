import 'package:flutter/foundation.dart';

class Transaction {
  int id;
  int from; // from wallet
  int to; // to wallet
  double amount;
  List<String> tags;
  String description;

  Transaction({
    @required this.id,
    @required this.from,
    @required this.to,
    this.amount,
    this.tags,
    this.description,
  });
}
