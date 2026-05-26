import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import 'package:taiyishenshu/pages/school_manager_page.dart';
import '../taiyi/test_harness.dart';

/// ZenTao Task 14 widget-level test for [SchoolManagerPage].
///
/// 这层测试聚焦于 UI 结构:
/// - 真实装配 (`TaiYiTestHarness.createAssembly`) -> 真实 Drift / OfficialJson Repository。
/// - 不使用 FakeViewModel-only。
/// - 持久化、排盘变化等深度断言交给
///   `test/integration/school_management_integration_test.dart`。
void main() {
  setUpAll(() async {
    await TaiYiTestHarness.setup();
  });

  tearDown(() async {
    await TaiYiTestHarness.dispose();
  });

  group('SchoolManagerPage [Task 14]', () {
    testWidgets('显示官方流派分区与官方三派', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final assembly = await TaiYiTestHarness.createAssembly();
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();

      await tester.pumpWidget(
        MaterialApp(home: SchoolManagerPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('流派管理'), findsOneWidget);
      expect(find.text('官方流派 (只读)'), findsOneWidget);
      expect(find.text('我的流派 (可编辑)'), findsOneWidget);
      expect(find.text('金镜派'), findsOneWidget);
      expect(find.text('统宗派'), findsOneWidget);
      expect(find.text('集成派'), findsOneWidget);
    });

    testWidgets('官方流派不暴露编辑入口 (反假完成红线 #5)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final assembly = await TaiYiTestHarness.createAssembly();
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();

      await tester.pumpWidget(
        MaterialApp(home: SchoolManagerPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      // 官方三派任何一个都不应该展示 edit 按钮
      expect(find.byKey(const Key('edit-jingMirror')), findsNothing);
      expect(find.byKey(const Key('edit-tongZong')), findsNothing);
      expect(find.byKey(const Key('edit-jiCheng')), findsNothing);

      // 但 copy / info 入口必须存在
      expect(find.byKey(const Key('copy-jingMirror')), findsOneWidget);
      expect(find.byKey(const Key('info-jingMirror')), findsOneWidget);
    });

    testWidgets('复制官方流派后用户分区出现新副本，并显示 edit 入口', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final assembly = await TaiYiTestHarness.createAssembly();
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();

      await tester.pumpWidget(
        MaterialApp(home: SchoolManagerPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('copy-jingMirror')));
      await tester.pumpAndSettle();

      final nameField = find.byKey(const Key('copy-name-field'));
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, '我的金镜派-test');

      await tester.tap(find.byKey(const Key('copy-confirm-button')));
      await tester.pumpAndSettle();

      // 用户副本应出现，且带 edit 按钮 (官方派生)
      expect(find.text('我的金镜派-test'), findsOneWidget);
      // 用户副本的 edit IconButton 应存在 (key 以 edit-user_jingMirror_* 前缀)
      final editButtons =
          find.byWidgetPredicate((w) => w is IconButton && (w.icon is Icon) && (w.icon as Icon).icon == Icons.edit);
      expect(editButtons, findsWidgets);
    });

    testWidgets('点击行触发 switchSchool，盘面 input.schoolId 更新', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final assembly = await TaiYiTestHarness.createAssembly();
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();
      // 先排一次盘以获得 panData.input
      await controller.calculate(
        dateTime: DateTime(2024, 5, 1),
        schoolId: 'jingMirror',
      );

      expect(controller.panData?.input.schoolId, 'jingMirror');

      await tester.pumpWidget(
        MaterialApp(home: SchoolManagerPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('school-row-tongZong')));
      await tester.pumpAndSettle();

      expect(controller.panData?.input.schoolId, 'tongZong');
    });
  });
}
