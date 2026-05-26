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

  group('Deity Management BDD', () {
    testWidgets('AC8: Dialog shows sections', (tester) async {
      final assembly = await TaiYiTestHarness.createAssembly();
      final controller = TaiYiPanController(assembly: assembly);

      await tester.pumpWidget(MaterialApp(home: TaiYiPanPage(controller: controller)));
      await tester.pump(const Duration(milliseconds: 500));

      // Find by icon is safer if we know which one it is
      final managementBtn = find.byIcon(Icons.auto_awesome);
      await tester.tap(managementBtn);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('系统内置'), findsOneWidget);
      expect(find.text('我的星神'), findsOneWidget);
      expect(find.text('Marketplace'), findsOneWidget);

      // Marketplace placeholder is present and shown as 即将开放 (产品占位)
      expect(find.byKey(const ValueKey('marketplace-placeholder')),
          findsOneWidget);
      // 我的星神区初始为空: 显示空状态指引
      expect(find.byKey(const ValueKey('my-deities-empty')), findsOneWidget);
    });

    testWidgets('AC10: Copy deity shows SnackBar', (tester) async {
      final assembly = await TaiYiTestHarness.createAssembly();
      final controller = TaiYiPanController(assembly: assembly);
      await tester.pumpWidget(MaterialApp(home: TaiYiPanPage(controller: controller)));
      await tester.pump(const Duration(milliseconds: 500));

      final managementBtn = find.byIcon(Icons.auto_awesome);
      await tester.tap(managementBtn);
      await tester.pump(const Duration(milliseconds: 500));

      final copyBtn = find.byIcon(Icons.copy).first;
      await tester.tap(copyBtn);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('已复制'), findsOneWidget);
    });

    testWidgets('AC11: 我的区出现可编辑/可删除入口', (tester) async {
      final assembly = await TaiYiTestHarness.createAssembly();
      final controller = TaiYiPanController(assembly: assembly);
      // 直接通过 ViewModel 复制一个 (绕过 UI 触发,本测试聚焦 “我的区入口”)
      await controller.deityViewModel.copyDeity(
        sourceId: 'taiYi',
        newId: 'user_taiYi_bdd',
        newName: '太乙(我的)',
      );

      await tester.pumpWidget(MaterialApp(home: TaiYiPanPage(controller: controller)));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pump(const Duration(milliseconds: 500));

      // 我的区出现复制后的名字
      expect(find.text('太乙(我的)'), findsOneWidget);

      // 我的区有 delete 入口 (用 ValueKey 精确定位, 反 fake completion)
      expect(
        find.byKey(const ValueKey('delete-user-deity-user_taiYi_bdd')),
        findsOneWidget,
      );
    });

    testWidgets('AC12: Editor shows lineage', (tester) async {
        final assembly = await TaiYiTestHarness.createAssembly();
        await tester.pumpWidget(
          MaterialApp(
            home: EntityEditorPage(
              type: EntityType.deity,
              initialName: '我的太乙',
              lineage: '官方 > 我的派生',
              controller: TaiYiPanController(assembly: assembly),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('传承链'), findsOneWidget);
        expect(find.text('官方 > 我的派生'), findsOneWidget);
    });
  });
}
