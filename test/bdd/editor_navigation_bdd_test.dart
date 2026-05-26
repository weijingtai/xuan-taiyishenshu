import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/pages/taiyi_pan_page.dart';
import 'package:taiyishenshu/pages/entity_editor_page.dart';
import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import '../taiyi/test_harness.dart';

void main() {
  setUpAll(() async {
    await TaiYiTestHarness.setup();
  });

  tearDown(() async {
    await TaiYiTestHarness.dispose();
  });

  group('Full Management System BDD', () {
    testWidgets('Given user in Deity Dialog, When long pressing a deity, Then navigate to Editor', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final assembly = await TaiYiTestHarness.createAssembly();
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();

      await tester.pumpWidget(MaterialApp(home: TaiYiPanPage(controller: controller)));
      await tester.pump(const Duration(milliseconds: 500));

      // Open Dialog
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pump(const Duration(milliseconds: 500));

      // Find '太乙' text specifically in the dialog
      final deityText = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('太乙'),
      );
      expect(deityText, findsAtLeast(1));
      
      await tester.ensureVisible(deityText.first);
      await tester.pumpAndSettle();

      await tester.longPress(deityText.first);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify navigation to EntityEditorPage
      expect(find.byType(EntityEditorPage), findsOneWidget);
      expect(find.textContaining('星神编辑器'), findsOneWidget);
    });

    testWidgets('Given School Editor, When saving new school, Then it appears in selector bar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final assembly = await TaiYiTestHarness.createAssembly();
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();
      
      await tester.pumpWidget(MaterialApp(home: TaiYiPanPage(controller: controller)));
      await tester.pump(const Duration(milliseconds: 500));

      // Click add school
      final addBtn = find.byIcon(Icons.add_circle_outline);
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byType(EntityEditorPage), findsOneWidget);
      expect(find.textContaining('流派编辑器'), findsOneWidget);

      // Enter name
      final nameField = find.descendant(
        of: find.byType(EntityEditorPage),
        matching: find.byType(TextField),
      ).first;
      await tester.enterText(nameField, '自定义流派');
      await tester.pumpAndSettle();
      
      // Save
      final saveBtn = find.byKey(const Key('save_button'));
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should be back on Pan Page
      expect(find.byType(TaiYiPanPage), findsOneWidget);
      
      // Verify new school choice chip exists
      expect(find.text('自定义流派'), findsOneWidget);
    });
  });
}
