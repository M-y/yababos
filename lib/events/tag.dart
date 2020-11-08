import 'package:yababos/models/tag.dart';

abstract class TagEvent {
  const TagEvent();
}

class TagGetAll extends TagEvent {}

class TagFind extends TagEvent {
  final Tag tag;

  const TagFind(this.tag);
}

class TagsAdd extends TagEvent {
  final List<Tag> tags;

  const TagsAdd(this.tags);
}

class TagAdd extends TagEvent {
  final Tag tag;

  const TagAdd(this.tag);
}

class TagDelete extends TagEvent {
  final Tag tag;

  const TagDelete(this.tag);
}

class TagUpdate extends TagEvent {
  final String oldName;
  final Tag tag;

  const TagUpdate(this.oldName, this.tag);
}
