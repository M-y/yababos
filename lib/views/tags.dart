import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/generated/l10n.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/states/tag.dart';
import 'package:yababos/views/tag_editor.dart';

class TagsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<TagBloc, TagState>(
        builder: (bcontext, state) {
          if (state is TagLoaded) {
            List<Tag> tags = state.tags;

            if (tags.isEmpty) {
              return Center(
                child: Text(S.of(context)!.noTags),
              );
            } else {
              return ListView.builder(
                  itemCount: tags.length,
                  itemBuilder: (BuildContext lcontext, int index) {
                    return Card(
                      child: InkWell(
                        child: Center(
                          child: Text(tags[index].name),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (econtext) {
                                return TagEditor(
                                  tag: tags[index],
                                  onSave: (tag) =>
                                      BlocProvider.of<TagBloc>(context)
                                        ..add(TagGetNone())
                                        ..add(TagUpdate(tags[index].name, tag)),
                                  onDelete: (tag) =>
                                      BlocProvider.of<TagBloc>(context)
                                        ..add(TagGetNone())
                                        ..add(TagDelete(tag)),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  });
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (econtext) {
                return TagEditor(
                  tag: Tag(name: "new"),
                  onSave: (tag) => BlocProvider.of<TagBloc>(context)
                    ..add(TagGetNone())
                    ..add(TagAdd(tag)),
                  isNew: true,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
