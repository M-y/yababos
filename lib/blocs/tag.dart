import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/models/tag_repository.dart';
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
    }
  }

  Future<TagState> _mapGetAlltoState(TagGetAll event) async {
    return TagLoaded(await _tagRepository.getAll());
  }

  Future<TagState> _mapFindToState(TagFind event) async {
    List<Tag> found = await _tagRepository.find(event.tag);
    return TagLoaded(found);
  }

  Future<TagState> _mapAddManytoState(TagsAdd event) async {
    event.tags.forEach((tag) {
      _tagRepository.add(tag);
    });
    return TagLoaded(await _tagRepository.getAll());
  }

  Future<TagState> _mapAddtoState(TagAdd event) async {
    _tagRepository.add(event.tag);
    return TagLoaded(await _tagRepository.getAll());
  }

  Future<TagState> _mapDeletetoState(TagDelete event) async {
    _tagRepository.delete(event.tag.name);
    return TagLoaded(await _tagRepository.getAll());
  }

  Future<TagState> _mapUpdatetoState(TagUpdate event) async {
    _tagRepository.update(event.oldName, event.tag);
    return TagLoaded(await _tagRepository.getAll());
  }
}
