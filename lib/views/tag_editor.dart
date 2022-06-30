import 'package:flutter/material.dart';
import 'package:yababos/generated/l10n.dart';
import 'package:yababos/models/tag.dart';

typedef OnSave = Function(Tag tag);
typedef OnDelete = Function(Tag tag);

class TagEditor extends StatefulWidget {
  final Tag tag;
  final OnSave onSave;
  final OnDelete onDelete;

  final List<Color> availableColors = List.from([
    Colors.white,
    Colors.grey,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.brown,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.teal,
    Colors.yellow,
  ]);

  TagEditor({
    @required this.tag,
    @required this.onSave,
    this.onDelete,
  });

  @override
  State<StatefulWidget> createState() => TagEditorState();
}

class TagEditorState extends State<TagEditor> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Color _pickedColor;

  @override
  void initState() {
    _pickedColor = widget.tag.color;
    super.initState();
  }

  bool _isEdit() {
    if (widget.tag.name != null) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit() ? S.of(context).editTag : S.of(context).newTag),
        actions: [
          _isEdit()
              ? TextButton(
                  child: Text(
                    S.of(context).delete,
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    widget.onDelete(widget.tag);
                    Navigator.pop(context);
                  },
                )
              : Container()
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Name
            TextFormField(
              decoration: InputDecoration(labelText: S.of(context).name),
              initialValue: _isEdit() ? widget.tag.name : null,
              onSaved: (newValue) => widget.tag.name = newValue,
            ),
            // Color
            Container(
              width: double.infinity,
              height: 200,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 50,
                    childAspectRatio: 1 / 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: widget.availableColors.length,
                itemBuilder: (gcontext, index) {
                  final itemColor = widget.availableColors[index];

                  return InkWell(
                    onTap: () {
                      widget.tag.color = itemColor;
                      setState(() {
                        _pickedColor = itemColor;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color: itemColor,
                          shape: BoxShape.circle,
                          border:
                              Border.all(width: 1, color: Colors.grey[300])),
                      child: itemColor.value == _pickedColor.value
                          ? Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.black,
                              ),
                            )
                          : Container(),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          _formKey.currentState.save();
          widget.onSave(widget.tag);
          Navigator.pop(context);
        },
      ),
    );
  }
}
