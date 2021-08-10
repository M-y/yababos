import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:yababos/models/tag.dart';

class Transaction extends Equatable {
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

  @override
  List<Object> get props => [id, from, to, amount, tags, description];
}
