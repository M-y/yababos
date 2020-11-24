import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:yababos/blocs/settings.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/events/settings.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/models/inmemory/settings.dart';
import 'package:yababos/models/inmemory/tag.dart';
import 'package:yababos/models/setting.dart';
import 'package:yababos/models/settings_repository.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/models/tag_repository.dart';
import 'package:yababos/states/settings.dart';
import 'package:yababos/states/tag.dart';

void main() {
  group('Settings', () {
    SettingsRepository settingsRepository = SettingsInmemory();
    Setting sampleSetting = Setting(name: 'sample', value: 1);
    Setting sampleSettingChanged = Setting(name: 'sample', value: 2);

    blocTest(
      'add setting',
      build: () => SettingsBloc(settingsRepository),
      act: (bloc) => bloc.add(SettingAdd(sampleSetting)),
      expect: <SettingState>[SettingChanged(sampleSetting)],
    );

    blocTest(
      'add same setting',
      build: () => SettingsBloc(settingsRepository),
      act: (bloc) => bloc.add(SettingAdd(sampleSetting)),
      expect: <SettingState>[SettingLoaded(sampleSetting)],
    );

    blocTest(
      'update setting',
      build: () => SettingsBloc(settingsRepository),
      act: (bloc) => bloc.add(SettingAdd(sampleSettingChanged)),
      expect: <SettingState>[SettingChanged(sampleSettingChanged)],
    );

    blocTest(
      'get setting',
      build: () => SettingsBloc(settingsRepository),
      act: (bloc) => bloc.add(SettingGet('sample')),
      expect: <SettingState>[SettingLoaded(sampleSettingChanged)],
    );
  });

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

    blocTest(
      'duplicate add',
      build: () => TagBloc(tagRepository),
      act: (bloc) => bloc.add(TagAdd(sampleTag)),
      expect: <TagState>[TagLoaded(allTags)],
    );
  });
}
