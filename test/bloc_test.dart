import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/models/inmemory/tag.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/models/tag_repository.dart';
import 'package:yababos/states/tag.dart';

void main() {
  group('Tag', () {
    TagRepository tagRepository = TagInmemory();
    Tag sampleTag = Tag(name: 'sample');
    List<Tag> sampleTagList = [sampleTag];
    Tag newTag = Tag(name: 'new');
    List<Tag> newTagList = [newTag];
    List<Tag> allTags = [sampleTag, newTag];

    blocTest(
      'TagAdd',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagAdd(sampleTag)),
      expect: <TagState>[TagLoaded(sampleTagList)],
    );

    blocTest(
      'TagUpdate',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagUpdate(sampleTag.name, newTag)),
      expect: <TagState>[TagLoaded(newTagList)],
    );

    blocTest(
      'TagDelete',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagDelete(newTag)),
      expect: <TagState>[TagLoaded([])],
    );

    blocTest(
      'TagsAdd',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagsAdd(allTags)),
      expect: <TagState>[TagLoaded(allTags)],
    );

    blocTest(
      'TagFind',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagFind(Tag(name: 'sample'))),
      expect: <TagState>[TagLoaded(sampleTagList)],
    );

    blocTest(
      'TagGetAll',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagGetAll()),
      expect: <TagState>[TagLoaded(allTags)],
    );
  });
}
