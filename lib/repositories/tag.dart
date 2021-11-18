import 'package:yababos/models/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getAll();
  Future<Tag> get(String name);

  Future add(Tag tag);
  Future update(String oldName, Tag tag);
  Future delete(String name);

  Future<List<Tag>> find(Tag tag);

  Future clear();
}
