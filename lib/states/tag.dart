import 'package:yababos/models/tag.dart';

abstract class TagState {
  const TagState();
}

class TagLoading extends TagState {}

class TagLoaded extends TagState {
  List<Tag> tags;

  TagLoaded(this.tags);
}
