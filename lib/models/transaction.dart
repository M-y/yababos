import 'package:flutter/foundation.dart';
import 'package:yababos/models/tag.dart';

class Transaction {
  int id;
  int from; // from wallet
  int to; // to wallet
  double amount;
  List<Tag> tags;
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
