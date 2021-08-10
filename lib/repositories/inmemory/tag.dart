import 'package:yababos/models/tag.dart';
import 'package:yababos/repositories/tag_repository.dart';

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
      return _tags.firstWhere(
        (element) => element.name == name,
        orElse: () => null,
      );
    });
  }

  @override
  Future<List<Tag>> getAll() {
    return Future.delayed(Duration(seconds: 3), () => _tags);
  }

  @override
  Future update(String oldName, Tag tag) {
    return Future(() {
      int index = _tags.indexWhere((element) => element.name == oldName);
      if (index == -1) throw new Exception();
      _tags[index] = tag;
    });
  }

  @override
  Future<List<Tag>> find(Tag tag) {
    return Future(() {
      return _tags.where((element) => element.name.contains(tag.name)).toList();
    });
  }
}
