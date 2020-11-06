import 'package:yababos/models/tag.dart';

abstract class TagEvent {
  const TagEvent();
}

class TagGetAll extends TagEvent {}

class TagFind extends TagEvent {
  final Tag tag;

  const TagFind(this.tag);
}
