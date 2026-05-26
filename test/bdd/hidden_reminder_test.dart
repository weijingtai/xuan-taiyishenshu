import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/pages/taiyi_pan_page.dart';
import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import '../taiyi/test_harness.dart';

void main() {
  setUpAll(() async {
    await TaiYiTestHarness.setup();
  });

  tearDown(() async {
    await TaiYiTestHarness.dispose();
  });

  group('AC13: Critical Hidden Reminder BDD', () {
    testWidgets('隐藏太乙应触发警告提示', (tester) async {
      final assembly = await TaiYiTestHarness.createAssembly();
      final controller = TaiYiPanController(assembly: assembly);

      await tester.pumpWidget(
        MaterialApp(
          home: TaiYiPanPage(controller: controller),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 200));

      // Use the correct camelCase ID 'taiYi' instead of kebab-case
      await controller.setDeityVisibility('taiYi', false);
      await tester.pump(const Duration(milliseconds: 200));

      // Verify warning message appears on the main page
      expect(find.textContaining('部分基础星神或关键计算项已隐藏'), findsOneWidget);
    });
  });
}
