import 'package:equatable/equatable.dart';
import 'package:yababos/models/tag.dart';

class Transaction extends Equatable {
  int id;
  int from; // from wallet
  int to; // to wallet
  double amount;
  DateTime when;
  List<Tag>? tags;
  String? description;

  Transaction({
    /*required*/ required this.id,
    /*required*/ required this.from,
    /*required*/ required this.to,
    /*required*/ required this.amount,
    /*required*/ required this.when,
    this.tags,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        from,
        to,
        amount,
        when,
        (tags == null) ? null : List.from(tags!.map((tag) => tag.props)),
        description
      ];
}
