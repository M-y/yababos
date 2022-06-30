import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/repositories/tag.dart';
import 'package:yababos/states/tag.dart';

class TagBloc extends Bloc<TagEvent, TagState> {
  final TagRepository _tagRepository;

  TagBloc(this._tagRepository) : super(TagLoading()) {
    on<TagGetAll>(_mapGetAlltoState);
    on<TagFind>(_mapFindToState);
    on<TagsAdd>(_mapAddManytoState);
    on<TagAdd>(_mapAddtoState);
    on<TagDelete>(_mapDeletetoState);
    on<TagUpdate>(_mapUpdatetoState);
    on<TagGetNone>(_mapGetNonetoState);
  }

  Future<void> _mapGetAlltoState(
      TagGetAll event, Emitter<TagState> emit) async {
    return emit(TagLoaded(await _tagRepository.getAll()));
  }

  Future<void> _mapFindToState(TagFind event, Emitter<TagState> emit) async {
    List<Tag> found = await _tagRepository.find(event.tag);
    return emit(TagLoaded(found));
  }

  Future _tagAdd(Tag tag) async {
    if (await _tagRepository.get(tag.name) == null)
      await _tagRepository.add(tag);
  }

  Future<void> _mapAddManytoState(TagsAdd event, Emitter<TagState> emit) async {
    for (Tag tag in event.tags) {
      await _tagAdd(tag);
    }
    return emit(TagLoaded(await _tagRepository.getAll()));
  }

  Future<void> _mapAddtoState(TagAdd event, Emitter<TagState> emit) async {
    await _tagAdd(event.tag);
    return emit(TagLoaded(await _tagRepository.getAll()));
  }

  Future<void> _mapDeletetoState(
      TagDelete event, Emitter<TagState> emit) async {
    await _tagRepository.delete(event.tag.name);
    return emit(TagLoaded(await _tagRepository.getAll()));
  }

  Future<void> _mapUpdatetoState(
      TagUpdate event, Emitter<TagState> emit) async {
    await _tagRepository.update(event.oldName, event.tag);
    return emit(TagLoaded(await _tagRepository.getAll()));
  }

  Future<void> _mapGetNonetoState(
      TagGetNone event, Emitter<TagState> emit) async {
    return emit(TagLoaded(<Tag>[]));
  }
}
