import 'dart:ui';
import 'package:yababos/models/tag.dart';
import 'package:yababos/repositories/sqlite/yababos.dart';
import 'package:yababos/repositories/tag.dart';

class TagSqlite extends TagRepository {
  @override
  Future add(Tag tag) {
    return Future(() async {
      await (await YababosSqlite.getDatabase()).rawInsert('''
        INSERT INTO tags
        (
          name,
          color
        )
        VALUES
        (
          ?,
          ?
        )
        ''', [
        tag.name,
        tag.color.value,
      ]);
    });
  }

  @override
  Future delete(String name) {
    return Future(() async {
      await (await YababosSqlite.getDatabase())
          .rawDelete('DELETE FROM tags WHERE name = ?', [name]);
    });
  }

  @override
  Future<List<Tag>> find(Tag tag) {
    return Future(() async {
      List<Tag> tags = List<Tag>();
      List<Map<String, Object>> records =
          await (await YababosSqlite.getDatabase()).rawQuery(
              'SELECT * FROM tags WHERE name LIKE ?', ["%${tag.name}%"]);
      for (var record in records) {
        tags.add(_mapRecord(record));
      }
      return tags;
    });
  }

  @override
  Future<Tag> get(String name) {
    return Future(() async {
      List<Map<String, Object>> record =
          await (await YababosSqlite.getDatabase())
              .rawQuery('SELECT * FROM tags WHERE name = ?', [name]);
      if (record.isEmpty) return null;
      return _mapRecord(record[0]);
    });
  }

  @override
  Future<List<Tag>> getAll() {
    return Future(() async {
      List<Tag> tags = List<Tag>();
      List<Map<String, Object>> records =
          await (await YababosSqlite.getDatabase())
              .rawQuery('SELECT * FROM tags');
      for (var record in records) {
        tags.add(_mapRecord(record));
      }
      return tags;
    });
  }

  @override
  Future update(String oldName, Tag tag) {
    return Future(() async {
      if (await get(oldName) == null) throw new Exception();
      await (await YababosSqlite.getDatabase()).rawUpdate('''
        UPDATE tags SET
          name = ?,
          color = ?
        WHERE name = ?
        ''', [
        tag.name,
        tag.color.value,
        oldName,
      ]);
    });
  }

  Tag _mapRecord(Map<String, Object> record) {
    return Tag(
      name: record['name'],
      color: Color(record['color']),
    );
  }
}
