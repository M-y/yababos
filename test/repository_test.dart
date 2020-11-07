import 'package:flutter_test/flutter_test.dart';
import 'package:yababos/models/inmemory/tag.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/models/tag_repository.dart';

void main() {
  group('Tag', () {
    TagRepository tagRepository = TagInmemory();

    test('add', () async {
      Tag sampleTag = Tag(name: 'test');
      tagRepository.add(sampleTag);

      expect(await tagRepository.get(sampleTag.name), sampleTag);
    });

    test('get', () async {
      expect((await tagRepository.get('test')).name, 'test');
      expect(await tagRepository.get('not available'), null);
    });

    test('getAll', () async {
      expect(await tagRepository.getAll(), isInstanceOf<List<Tag>>());
    });

    test('update', () async {
      Tag updateTag = Tag(name: 'updated');
      tagRepository.update('test', updateTag);

      expect(await tagRepository.get('test'), null);
      expect(tagRepository.update('test', updateTag), throwsException);
      expect(await tagRepository.get('updated'), updateTag);
    });

    test('find', () async {
      Tag find = Tag(name: 'updated');
      Tag toNotFind = Tag(name: 'not available');

      expect(await tagRepository.find(find), isInstanceOf<List<Tag>>());
      expect((await tagRepository.find(find)).length, 1);
      expect(await tagRepository.find(toNotFind), isInstanceOf<List<Tag>>());
      expect((await tagRepository.find(toNotFind)).length, 0);
    });

    test('delete', () async {
      await tagRepository.delete('updated');

      expect(await tagRepository.get('updated'), null);
    });
  });
}
