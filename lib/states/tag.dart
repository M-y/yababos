import 'package:equatable/equatable.dart';
import 'package:yababos/models/tag.dart';

abstract class TagState extends Equatable {
  const TagState();

  @override
  List<Object> get props => [];
}

class TagLoading extends TagState {}

class TagLoaded extends TagState {
  final List<Tag> tags;

  const TagLoaded(this.tags);

  @override
  List<Object> get props => [tags];
}
