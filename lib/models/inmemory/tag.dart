import 'package:yababos/models/tag.dart';
import 'package:yababos/models/tag_repository.dart';

class TagInmemory extends TagRepository {
  List<Tag> _tags = [];

  @override
  Future add(Tag tag) {
    return Future(() {
      _tags.add(tag);
    });
  }

  @override
  Future delete(String name) {
    return Future(() async {
      Tag tag = await get(name);
      _tags.remove(tag);
    });
  }

  @override
  Future<Tag> get(String name) {
    return Future(() {
      return _tags.firstWhere((element) => element.name == name);
    });
  }

  @override
  Future<List<Tag>> getAll() {
    _tags.add(Tag(name: _tags.length.toString()));
    return Future.delayed(Duration(seconds: 3), () => _tags);
  }

  @override
  Future update(String oldName, Tag tag) {
    return Future(() {
      _tags[_tags.indexWhere((element) => element.name == oldName)] = tag;
    });
  }

  @override
  Future<List<Tag>> find(Tag tag) {
    return Future(() {
      return _tags.where((element) => element == tag).toList();
    });
  }
}
