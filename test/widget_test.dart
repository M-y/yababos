import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/views/tag_editor.dart';
import 'l10n_helper.dart';

void main() {
  group("Tag Editor", () {
      bool isCalled = false;
      Widget tagEditor = L10nHelper.build(TagEditor(
        tag: Tag(name: "Existing tag", color: Colors.green),
        onSave: (tag) => isCalled = true,
        onDelete: (tag) => isCalled = true,
      ));

    testWidgets("Calling onSave method", (widgetTester) async {
        await widgetTester.pumpWidget(tagEditor);
        await widgetTester.pumpAndSettle();

        await widgetTester.tap(find.byType(FloatingActionButton));
        expect(isCalled, true);
        isCalled = false;
      });

      testWidgets("Calling onDelete method", (widgetTester) async {
        await widgetTester.pumpWidget(tagEditor);
        await widgetTester.pumpAndSettle();

        String delete = L10nHelper.getLocalizations().delete;
        await widgetTester.tap(find.descendant(
            of: find.byType(TextButton), matching: find.text(delete)));

        expect(isCalled, true);
        isCalled = false;
      });
    group("New tag / Edit tag behaviour", () {

      Widget newTagWidget = L10nHelper.build(TagEditor(
        tag: Tag(name: ""),
        onSave: (tag) => null,
        isNew: true,
      ));
      Widget editTagWidget = L10nHelper.build(TagEditor(
        tag: Tag(name: "Existing tag", color: Colors.green),
        onSave: (tag) => null,
      ));
      String editTag = L10nHelper.getLocalizations().editTag;
      String newTag = L10nHelper.getLocalizations().newTag;

      testWidgets("Appbar title on edit", (widgetTester) async {
        await widgetTester.pumpWidget(editTagWidget);
        await widgetTester.pumpAndSettle();

        expect(find.text(editTag), findsOneWidget);
        expect(find.text(newTag), findsNothing);
      });

      testWidgets("Appbar title on new", (widgetTester) async {
        await widgetTester.pumpWidget(newTagWidget);
        await widgetTester.pumpAndSettle();

        expect(find.text(newTag), findsOneWidget);
        expect(find.text(editTag), findsNothing);
      });

      testWidgets("Delete button appears on edit", (widgetTester) async {
        await widgetTester.pumpWidget(editTagWidget);
        await widgetTester.pumpAndSettle();

        String delete = L10nHelper.getLocalizations().delete;
        expect(find.text(delete), findsOneWidget);
      });

      testWidgets("Delete button disappears on new", (widgetTester) async {
        await widgetTester.pumpWidget(newTagWidget);
        await widgetTester.pumpAndSettle();

        String delete = L10nHelper.getLocalizations().delete;
        expect(find.text(delete), findsNothing);
      });

      testWidgets("Existing tag name on name field", (widgetTester) async {
        await widgetTester.pumpWidget(editTagWidget);
        await widgetTester.pumpAndSettle();

        expect(find.text("Existing tag"), findsOneWidget);
      });

      testWidgets("Existing tag color on color field", (widgetTester) async {
        await widgetTester.pumpWidget(editTagWidget);
        await widgetTester.pumpAndSettle();

        var finder = find
            .ancestor(
              of: find.byKey(Key("pickedColor")),
              matching: find.byType(Container),
            )
            .evaluate();
        Color? c =
            ((finder.first.widget as Container).decoration as BoxDecoration)
                .color;
        expect(c, equals(Colors.green));
      });

      
    });
  });
}
