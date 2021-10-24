import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/repositories/tag_repository.dart';
import 'package:yababos/states/tag.dart';

class TagBloc extends Bloc<TagEvent, TagState> {
  final TagRepository _tagRepository;

  TagBloc(this._tagRepository) : super(TagLoading());

  @override
  Stream<TagState> mapEventToState(TagEvent event) async* {
    if (event is TagGetAll) {
      yield await _mapGetAlltoState(event);
    } else if (event is TagFind) {
      yield await _mapFindToState(event);
    } else if (event is TagsAdd) {
      yield await _mapAddManytoState(event);
    } else if (event is TagAdd) {
      yield await _mapAddtoState(event);
    } else if (event is TagDelete) {
      yield await _mapDeletetoState(event);
    } else if (event is TagUpdate) {
      yield await _mapUpdatetoState(event);
    } else if (event is TagGetNone) {
      yield await _mapGetNonetoState(event);
    }
  }

  Future<TagState> _mapGetAlltoState(TagGetAll event) async {
    return TagLoaded(await _tagRepository.getAll());
  }

  Future<TagState> _mapFindToState(TagFind event) async {
    List<Tag> found = await _tagRepository.find(event.tag);
    return TagLoaded(found);
  }

  Future _tagAdd(Tag tag) async {
    if (await _tagRepository.get(tag.name) == null)
      await _tagRepository.add(tag);
  }

  Future<TagState> _mapAddManytoState(TagsAdd event) async {
    event.tags.forEach((tag) async {
      await _tagAdd(tag);
    });
    return TagLoaded(await _tagRepository.getAll());
  }

  Future<TagState> _mapAddtoState(TagAdd event) async {
    await _tagAdd(event.tag);
    return TagLoaded(await _tagRepository.getAll());
  }

  Future<TagState> _mapDeletetoState(TagDelete event) async {
    await _tagRepository.delete(event.tag.name);
    return TagLoaded(await _tagRepository.getAll());
  }

  Future<TagState> _mapUpdatetoState(TagUpdate event) async {
    await _tagRepository.update(event.oldName, event.tag);
    return TagLoaded(await _tagRepository.getAll());
  }

  Future<TagState> _mapGetNonetoState(TagGetNone event) async {
    return TagLoaded(List<Tag>());
  }
}
