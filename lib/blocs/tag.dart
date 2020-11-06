import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/tag.dart';
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
    }
  }

  _mapGetAlltoState(TagGetAll event) async {
    return TagLoaded(await _tagRepository.getAll());
  }

  _mapFindToState(TagFind event) async {
    return TagLoaded(await _tagRepository.find(event.tag));
  }
}
