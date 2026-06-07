// ZT-21 AC8 widget 测试: Dialog 三区结构 + Marketplace 不可交互 + 不可用项原因。
//
// 反伪完成红线:
// - 不准 Mock controller / Mock ViewModel;
// - MUST 用真 assembly + 真 Drift + 真 SharedPreferences (穿透到 Repository);
// - MUST 验证 Marketplace 占位被 AbsorbPointer 包裹 (absorbing == true);
// - MUST 验证不可用 deity 的 ListTile 真有 ValueKey('deity-unavailable-reason') 文本节点
//   且文本非空、非 "未知"。
//
// 覆盖 SPEC 验收条件:
//   AC8.1 三区标题 "系统内置" / "我的星神" / "Marketplace" 各 findsOneWidget
//   AC8.2 Marketplace 占位存在 + AbsorbPointer.absorbing == true (不可交互)
//   AC8.3 我的星神区初始为空时, ValueKey('my-deities-empty') findsOneWidget
//   AC8.4 chartType=year + schoolId=jingMirror 下, 至少一个不可用星神 (青龙旗)
//         的 Checkbox.onChanged == null, 且其 ListTile 有可见的中文原因文本
//   AC8.5 至少 30 个 source=='official' 星神被加载

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

const _deityKebabIds = [
  'tai-yi', 'zhu-da-jiang', 'ke-da-jiang', 'zhu-can-jiang', 'ke-can-jiang',
  'ding-da-jiang', 'ding-can-jiang', 'jun-ji', 'chen-ji', 'min-ji',
  'wu-fu', 'da-you', 'xiao-you', 'fei-fu', 'si-shen',
  'tian-yi-star', 'di-yi', 'zhi-fu-star', 'yang-jiu', 'bai-liu',
  'tai-sui', 'sui-po', 'zhi-fu', 'he-shen',
  'qing-long', 'zhu-que', 'bai-hu', 'xuan-wu', 'feng-bo', 'yu-shi',
  'qing-long-qi', 'hei-qi', 'chi-qi', 'gui-shen-zhi-shi',
  'wen-chang', 'ji-shen', 'shi-ji',
];

Future<_RealAssetBundle> _loadBundle() async {
  final assets = <String, String>{};
  const schoolIds = ['jing-mirror', 'tong-zong', 'ji-cheng'];
  for (final id in schoolIds) {
    final path = 'assets/schools/$id.json';
    assets[path] = File(path).readAsStringSync();
  }
  for (final id in _deityKebabIds) {
    final path = 'assets/deities/$id.json';
    assets[path] = File(path).readAsStringSync();
  }
  return _RealAssetBundle(assets);
}

Widget _wrapDialog(TaiYiPanController controller) {
  return MaterialApp(
    home: ChangeNotifierProvider<TaiYiPanController>.value(
      value: controller,
      child: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDialog(
                context: ctx,
                builder: (dctx) =>
                    ChangeNotifierProvider<TaiYiPanController>.value(
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

Future<TaiYiPanController> _bootController() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final db = TaiYiDatabase.memory();
  final bundle = await _loadBundle();
  final assembly = await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
  final controller = TaiYiPanController(assembly: assembly);
  await controller.loadSchools();
  await controller.calculate(
    dateTime: DateTime(2024, 6, 1),
    schoolId: 'jingMirror',
    chartType: TaiYiChartType.year,
  );
  return controller;
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = _FakePathProviderPlatform();
  });

  group('ZT-21 AC8: Dialog 三区 + 置灰原因', () {
    testWidgets('AC8_1: 三区标题 "系统内置" / "我的星神" / "Marketplace" 各 findsOneWidget',
        (tester) async {
      final controller = await _bootController();
      await tester.pumpWidget(_wrapDialog(controller));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      expect(
        find.text('系统内置'),
        findsOneWidget,
        reason: 'AC8.1: Dialog 必须显示 "系统内置" 分区标题',
      );
      expect(
        find.text('我的星神'),
        findsOneWidget,
        reason: 'AC8.1: Dialog 必须显示 "我的星神" 分区标题',
      );
      expect(
        find.text('Marketplace'),
        findsOneWidget,
        reason: 'AC8.1: Dialog 必须显示 "Marketplace" 分区标题',
      );
    });

    testWidgets(
        'AC8_2: Marketplace 占位 findsOneWidget + AbsorbPointer.absorbing==true (不可交互)',
        (tester) async {
      final controller = await _bootController();
      await tester.pumpWidget(_wrapDialog(controller));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      final placeholder = find.byKey(const ValueKey('marketplace-placeholder'));
      expect(
        placeholder,
        findsOneWidget,
        reason: 'AC8.2: Marketplace 必须有占位 (产品占位, 不能放真实可点击项)',
      );

      // 反 fake completion: 占位必须真的不可交互
      // 找占位 widget 在 widget tree 中最近的 AbsorbPointer 祖先
      final absorbPointer = find.ancestor(
        of: placeholder,
        matching: find.byType(AbsorbPointer),
      );
      expect(
        absorbPointer,
        findsWidgets,
        reason: 'AC8.2: Marketplace 占位必须被 AbsorbPointer 包裹',
      );
      final firstAbsorb = tester.widget<AbsorbPointer>(absorbPointer.first);
      expect(
        firstAbsorb.absorbing,
        isTrue,
        reason:
            'AC8.2 (反 lock-only 反 fake): AbsorbPointer.absorbing 必须为 true, '
            '否则占位会响应点击',
      );
    });

    testWidgets(
        'AC8_3: 我的星神区初始为空时, ValueKey("my-deities-empty") findsOneWidget',
        (tester) async {
      final controller = await _bootController();
      await tester.pumpWidget(_wrapDialog(controller));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('my-deities-empty')),
        findsOneWidget,
        reason: 'AC8.3: 初始无用户星神时, "我的星神" 区必须显示空状态提示',
      );
      // 同时校验空状态文本内容 (反 hard-code: 必须有引导用户复制的提示)
      expect(
        find.textContaining('复制'),
        findsWidgets,
        reason: 'AC8.3: 空状态提示必须含 "复制" 引导文字',
      );
    });

    testWidgets(
        'AC8_4: 不可用星神 (青龙旗) Checkbox.onChanged==null + 中文原因文本非空且非"未知"',
        (tester) async {
      final controller = await _bootController();
      await tester.pumpWidget(_wrapDialog(controller));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      // jingMirror 流派 deityIds 不含 qingLongQi (青龙旗)
      // → 应被判定为不可用 → checkbox.onChanged==null + 显示原因
      final reasonKeyFinder =
          find.byKey(const ValueKey('deity-unavailable-reason'));
      expect(
        reasonKeyFinder,
        findsWidgets,
        reason:
            'AC8.4: jingMirror 年盘下至少有一个不可用星神 (如 青龙旗), '
            '必须出现 ValueKey("deity-unavailable-reason") 文本节点',
      );

      // 定位 "青龙旗" 这条 ListTile 并验证其 checkbox 被禁用
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
      final qingLongQiTile = find.ancestor(
        of: find.text('青龙旗'),
        matching: find.byType(ListTile),
      );
      expect(
        qingLongQiTile,
        findsOneWidget,
        reason: 'AC8.4: 青龙旗 ListTile 必须存在',
      );

      final checkbox = tester.widget<Checkbox>(
        find.descendant(of: qingLongQiTile, matching: find.byType(Checkbox)),
      );
      expect(
        checkbox.onChanged,
        isNull,
        reason: 'AC8.4 (反 lock-only): 不可用项 Checkbox.onChanged 必须真为 null',
      );

      // 该 ListTile 内必须有原因文本节点
      final reasonInTile = find.descendant(
        of: qingLongQiTile,
        matching: find.byKey(const ValueKey('deity-unavailable-reason')),
      );
      expect(
        reasonInTile,
        findsOneWidget,
        reason: 'AC8.4: 青龙旗 tile 内必须有原因文本节点',
      );
      // 文本内容必须非空 且 非 "未知"
      final reasonText = tester.widget<Text>(reasonInTile);
      final reasonStr = reasonText.data ?? '';
      expect(
        reasonStr.isEmpty,
        isFalse,
        reason: 'AC8.4: 原因文本不能为空',
      );
      expect(
        reasonStr,
        isNot(equals('未知')),
        reason: 'AC8.4 (反 placeholder): 原因不能写死 "未知", 必须给出具体原因',
      );
      // 必须包含 "流派" 或 "盘型" 之一 (这是当前 _resolveUnavailableReason 的 2 种合法原因)
      expect(
        reasonStr.contains('流派') || reasonStr.contains('盘型'),
        isTrue,
        reason: 'AC8.4: 原因必须明确说明 "不适用于当前流派" 或 "不适用于当前盘型"',
      );
    });

    testWidgets('AC8_5: 至少 30 个 source==official 星神被加载 (数据驱动, 非硬编码)',
        (tester) async {
      final controller = await _bootController();
      await tester.pumpWidget(_wrapDialog(controller));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      final officialCount =
          controller.allDeities.where((d) => d.source == 'official').length;
      expect(
        officialCount,
        greaterThanOrEqualTo(30),
        reason:
            'AC8.5: 系统内置区必须装载至少 30 个官方星神 (反硬编码: 应来自 assets/deities/*.json)',
      );
    });
  });
}
