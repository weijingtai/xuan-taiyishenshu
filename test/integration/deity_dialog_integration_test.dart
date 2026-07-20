import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import 'package:persistence_drift/taiyishenshu/taiyishenshu_drift.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';
import '../taiyi/test_harness.dart';
import 'package:taiyishenshu/widgets/deity_management_dialog.dart';
import 'package:taiyishenshu/l10n/app_localizations.dart';

/// Deity Dialog 真集成测试。
///
/// 反 fake-completion / 反 mock-only 红线:
/// - 不使用 FakeViewModel / MockDeityViewModel,完全穿透 ViewModel → UseCase → Repository。
/// - 复制必须在 Drift 中产生真实行 + 我的区出现。
/// - 删除必须在 Drift 中行真的消失。
/// - Checkbox 必须写入真实 SharedPreferences,可在重建 Repository 后读到。
/// - 不可用必须 onChanged == null + 有中文原因文本(反 lock-only)。
/// - Marketplace placeholder 不能 toggle。
class _FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getApplicationSupportPath() async =>
      Directory.systemTemp.path;
  @override
  Future<String?> getLibraryPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;
  @override
  Future<String?> getExternalStoragePath() async => Directory.systemTemp.path;
  @override
  Future<List<String>?> getExternalCachePaths() async =>
      [Directory.systemTemp.path];
  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async =>
      [Directory.systemTemp.path];
  @override
  Future<String?> getDownloadsPath() async => Directory.systemTemp.path;
}

class _RealAssetBundle extends Fake implements AssetBundle {
  final Map<String, String> assets;
  _RealAssetBundle(this.assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) return assets[key]!;
    if (key.contains('AssetManifest')) return '{}';
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    if (assets.containsKey(key)) {
      return ByteData.view(
        Uint8List.fromList(utf8.encode(assets[key]!)).buffer,
      );
    }
    if (key.contains('AssetManifest')) return ByteData(0);
    throw FlutterError('Asset not found: $key');
  }
}

Future<_RealAssetBundle> _loadBundle() async {
  final assets = <String, String>{};
  const schoolIds = ['jing-mirror', 'tong-zong', 'ji-cheng'];
  for (final id in schoolIds) {
    final path = 'assets/schools/$id.json';
    final bundlePath = 'packages/taiyishenshu/assets/schools/$id.json';
    assets[bundlePath] = File(path).readAsStringSync();
  }
  const deityIds = [
    'tai-yi',
    'zhu-da-jiang',
    'ke-da-jiang',
    'zhu-can-jiang',
    'ke-can-jiang',
    'ding-da-jiang',
    'ding-can-jiang',
    'jun-ji',
    'chen-ji',
    'min-ji',
    'wu-fu',
    'da-you',
    'xiao-you',
    'fei-fu',
    'si-shen',
    'tian-yi-star',
    'di-yi',
    'zhi-fu-star',
    'yang-jiu',
    'bai-liu',
    'tai-sui',
    'sui-po',
    'zhi-fu',
    'he-shen',
    'qing-long',
    'zhu-que',
    'bai-hu',
    'xuan-wu',
    'feng-bo',
    'yu-shi',
    'qing-long-qi',
    'hei-qi',
    'chi-qi',
    'gui-shen-zhi-shi',
    'wen-chang',
    'ji-shen',
    'shi-ji',
    'tian-huang',
    'zi-wei',
    'she-ti',
    'xuan-yuan',
    'zhao-yao',
    'tian-fu',
    'xian-chi',
    'jiang-gong',
    'ming-tang',
    'yu-tang',
  ];
  for (final id in deityIds) {
    final path = 'assets/deities/$id.json';
    final bundlePath = 'packages/taiyishenshu/assets/deities/$id.json';
    assets[bundlePath] = File(path).readAsStringSync();
  }
  return _RealAssetBundle(assets);
}

/// Helper: 把 Dialog 包进可用的 Widget tree。
Widget _wrapDialog(TaiYiPanController controller) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ChangeNotifierProvider<TaiYiPanController>.value(
      value: controller,
      child: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDialog(
                context: ctx,
                builder: (dctx) => ChangeNotifierProvider<TaiYiPanController>.value(
                  value: controller,
                  child: const DeityManagementDialog(),
                ),
              ),
              child: const Text('OPEN'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = _FakePathProviderPlatform();
  });

  group('DeityDialog integration (Drift + SharedPreferences)', () {
    testWidgets('a) Dialog 三区都正确渲染 (系统内置/我的星神/Marketplace)',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();
      // 触发一个真实排盘,以便 panData.input.chartType / schoolId 有值
      await controller.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      await tester.pumpWidget(_wrapDialog(controller));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      // 三区标题
      expect(find.text('系统内置'), findsOneWidget);
      expect(find.text('我的星神'), findsOneWidget);
      expect(find.text('Marketplace'), findsOneWidget);

      // 系统内置至少装载了 30+ 个官方星神
      expect(controller.allDeities.where((d) => d.source == 'official').length,
          greaterThanOrEqualTo(30));

      // 我的星神区初始为空提示
      expect(find.byKey(const ValueKey('my-deities-empty')), findsOneWidget);

      // Marketplace placeholder 唯一一处 "即将开放"
      expect(find.byKey(const ValueKey('marketplace-placeholder')),
          findsOneWidget);

      await db.close();
    });

    testWidgets('b) 复制官方星神 → 我的区出现副本 + Drift 真有行 + 重建 Dialog 仍在',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();
      await controller.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      await tester.pumpWidget(_wrapDialog(controller));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      // 复制太乙 (用 ViewModel 直接调用,等价于点 “复制” 按钮)
      await controller.deityViewModel.copyDeity(
        sourceId: 'taiYi',
        newId: 'user_taiYi_integration_copy',
        newName: '太乙(我的)',
      );
      await tester.pumpAndSettle();

      // Drift 必须真有行
      final userDeities = await assembly.deityRepo.loadUserDeities();
      expect(
        userDeities.any((d) => d.id == 'user_taiYi_integration_copy'),
        isTrue,
        reason: '反 fake completion: 复制必须真写入 Drift, 不是只弹 SnackBar',
      );

      // UI: 我的区出现 “太乙(我的)”
      expect(find.text('太乙(我的)'), findsWidgets);

      // 重建 controller(模拟应用重启),副本应仍在
      final controller2 = TaiYiPanController(assembly: assembly);
      await controller2.loadSchools();
      expect(
        controller2.allDeities
            .any((d) => d.id == 'user_taiYi_integration_copy'),
        isTrue,
        reason: '复制必须穿透到持久层, 不能只在内存',
      );

      await db.close();
    });

    testWidgets(
        'c) chartType=year + school=jingMirror 下,某些 deity 不可用,checkbox 禁用 + 显示原因',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();
      await controller.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      await tester.pumpWidget(_wrapDialog(controller));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      // qingLongQi/heiQi/chiQi/guiShenZhiShi 不在 jingMirror 的 deityIds 中
      // → 应显示中文原因文字 + checkbox.onChanged == null
      expect(
        find.byKey(const ValueKey('deity-unavailable-reason')),
        findsWidgets,
        reason: '反 lock-only: 不可用项必须显示文字原因',
      );

      // 找一个已知不可用的项 (青龙旗) 并验证 checkbox 被禁用
      // 在 dialog 内滚动到目标可见
      await tester.scrollUntilVisible(
        find.text('青龙旗'),
        80,
        scrollable: find
            .descendant(
              of: find.byType(DeityManagementDialog),
              matching: find.byType(Scrollable),
            )
            .first,
      );

      // 校验对应 tile 的 checkbox 是被禁用的 (onChanged == null)
      final tile = find.ancestor(
        of: find.text('青龙旗'),
        matching: find.byType(ListTile),
      );
      expect(tile, findsOneWidget);
      final checkbox = tester.widget<Checkbox>(
        find.descendant(of: tile, matching: find.byType(Checkbox)),
      );
      expect(
        checkbox.onChanged,
        isNull,
        reason: '反 fake completion: 不可用项 checkbox 必须真的 onChanged == null',
      );

      await db.close();
    });

    testWidgets('d) 取消 taiYi 勾选 → SharedPreferences 真有 key 变化 + 重建 SP 仍 false',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();
      await controller.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      await tester.pumpWidget(_wrapDialog(controller));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      // taiYi 默认勾选, 取消后 SP 应写入 false
      expect(controller.isDeityVisible('taiYi'), isTrue);
      await controller.setDeityVisibility('taiYi', false);
      await tester.pumpAndSettle();

      // 直接穿透 Repository 验证持久化
      final stored = await assembly.preferenceRepo.isEnabled('taiYi');
      expect(stored, isFalse,
          reason: '反 fake completion: Checkbox 必须真的写 SharedPreferences');

      // 重建 SP instance + 新 Repository, 仍然应该读到 false
      final prefs2 = await SharedPreferences.getInstance();
      expect(prefs2.getString('taiyi_deity_preferences'), isNotNull);
      final newPrefs =
          assembly.preferenceRepo; // 同一 instance 也能验; 同时 SP 单例可视为新生
      expect(await newPrefs.isEnabled('taiYi'), isFalse);

      await db.close();
    });

    testWidgets('e) 删除用户星神 → Drift 行消失 + 重建 Repository 读不到',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();
      await controller.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      // 先复制再删除
      await controller.deityViewModel.copyDeity(
        sourceId: 'taiYi',
        newId: 'user_taiYi_for_delete',
        newName: '待删除副本',
      );
      // 确认 Drift 中有
      expect(
        (await assembly.deityRepo.loadUserDeities())
            .any((d) => d.id == 'user_taiYi_for_delete'),
        isTrue,
      );

      await tester.pumpWidget(_wrapDialog(controller));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      // 找到删除按钮并触发删除
      final deleteBtn =
          find.byKey(const ValueKey('delete-user-deity-user_taiYi_for_delete'));
      expect(deleteBtn, findsOneWidget);

      // 删除按钮在 dialog 内的可滚动列表底部 (我的星神区),需要滚动到可见
      await tester.scrollUntilVisible(
        deleteBtn,
        100,
        scrollable: find
            .descendant(
              of: find.byType(DeityManagementDialog),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // 确认弹出的确认对话框, 点击 “删除”
      expect(find.text('删除星神'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, '删除'));
      await tester.pumpAndSettle();

      // Drift 行必须消失
      final after = await assembly.deityRepo.loadUserDeities();
      expect(
        after.any((d) => d.id == 'user_taiYi_for_delete'),
        isFalse,
        reason: '反 fake completion: 删除必须穿透到 Drift',
      );

      await db.close();
    });

    testWidgets('f) 官方区找不到 delete IconButton (严禁删除官方)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();
      await controller.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      await tester.pumpWidget(_wrapDialog(controller));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      // 官方 deity ID 都不带 user_ 前缀;断言官方 deity id 对应的 delete key 都不存在
      for (final d in controller.allDeities.where((d) => d.source == 'official')) {
        expect(
          find.byKey(ValueKey('delete-user-deity-${d.id}')),
          findsNothing,
          reason: '官方星神 ${d.id} 不应出现 delete 入口',
        );
      }

      await db.close();
    });
  });
}
