import 'package:equatable/equatable.dart';
import 'package:yababos/models/tag.dart';

class TransactionSearch extends Equatable {
  final int? id;
  final int? from;
  final int? to;
  final double? amount;
  final DateTime? when;
  final List<Tag>? tags;
  final String? description;

  const TransactionSearch({
    this.id,
    this.from,
    this.to,
    this.amount,
    this.when,
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
