// ZT-21 AC13 测试: 隐藏核心星神触发警告, 隐藏非核心不触发, 恢复后清除。
//
// 反伪完成红线:
// - 不准只断言 controller.showHiddenWarning bool;
// - MUST 同时验证: a) bool 值正确; b) TaiYiPanPage 渲染后含/不含警告文本;
// - MUST 同时覆盖正向 (隐藏核心) / 逆向 (隐藏非核心不触发) / 还原 (恢复后清除) 三种场景。
//
// 文本统一: 用 SPEC 第 207 行权威文本 "盘面解释可能不完整" 作为 substring,
// 与 Playwright (ZT-25) 完全一致。Flutter UI 字面量 (taiyi_pan_page.dart:256)
// "部分基础星神或关键计算项已隐藏，盘面解释可能不完整。" 包含此子串, 不冲突。
//
// 覆盖 SPEC 验收条件:
//   AC13.1 隐藏 taiYi → showHiddenWarning==true + Page 含 "盘面解释可能不完整"
//   AC13.2 隐藏 qingLong (非核心) → showHiddenWarning==false + Page 不含警告
//   AC13.3 隐藏 taiYi → 恢复 → showHiddenWarning==false + Page 不含警告

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import 'package:taiyishenshu/database/taiyi_database.dart';
import 'package:taiyishenshu/pages/taiyi_pan_page.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';

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

Future<TaiYiPanController> _bootController() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final db = TaiYiDatabase.memory();
  final bundle = await _loadBundle();
  final assembly = TaiYiDataAssembly.test(bundle: bundle, prefs: prefs, db: db);
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

  group('ZT-21 AC13: 核心隐藏阈值 + 文本统一', () {
    testWidgets(
        'AC13_1_core_triggers: 隐藏 taiYi (核心) → showHiddenWarning==true + '
        'TaiYiPanPage 含 "盘面解释可能不完整"', (tester) async {
      final controller = await _bootController();

      // 前置: 默认无任何隐藏, banner 不应显示
      expect(
        controller.showHiddenWarning,
        isFalse,
        reason: '前置: 初始状态 showHiddenWarning 应为 false',
      );

      // 动作: 隐藏核心星神 taiYi
      await controller.setDeityVisibility('taiYi', false);

      // 断言 1: showHiddenWarning 立即为 true
      expect(
        controller.showHiddenWarning,
        isTrue,
        reason: 'AC13.1: 隐藏核心 taiYi 后 showHiddenWarning 必须为 true',
      );

      // 断言 2: 渲染主页面, banner 文本可见
      await tester.pumpWidget(
        MaterialApp(home: TaiYiPanPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('盘面解释可能不完整'),
        findsOneWidget,
        reason:
            'AC13.1: 隐藏核心后, TaiYiPanPage 必须渲染包含 SPEC 子串 "盘面解释可能不完整" 的 banner',
      );
    });

    testWidgets(
        'AC13_2_noncore_silent: 隐藏 qingLong (非核心) → showHiddenWarning==false + '
        'TaiYiPanPage 不含警告', (tester) async {
      final controller = await _bootController();

      // 前置
      expect(controller.showHiddenWarning, isFalse);

      // 动作: 隐藏非核心 qingLong (青龙) — 它不在
      // controller.showHiddenWarning 内部 coreDeities ['taiYi','wenChang','shiJi','jiShen'] 中
      await controller.setDeityVisibility('qingLong', false);

      // 断言 1: showHiddenWarning 仍为 false
      expect(
        controller.showHiddenWarning,
        isFalse,
        reason:
            'AC13.2 (逆向 + 反 false-positive): 隐藏非核心星神不应触发警告。'
            '核心集合为 {taiYi, wenChang, shiJi, jiShen}; qingLong 不在其中。',
      );

      // 断言 2: 主页面不渲染 banner
      await tester.pumpWidget(
        MaterialApp(home: TaiYiPanPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('盘面解释可能不完整'),
        findsNothing,
        reason:
            'AC13.2: 隐藏非核心后, TaiYiPanPage 不应渲染 "盘面解释可能不完整" 警告',
      );
    });

    testWidgets(
        'AC13_3_restore_clears: 隐藏 taiYi → 恢复 taiYi → '
        'showHiddenWarning==false + 警告消失', (tester) async {
      final controller = await _bootController();

      // 1) 隐藏 taiYi
      await controller.setDeityVisibility('taiYi', false);
      expect(controller.showHiddenWarning, isTrue);

      await tester.pumpWidget(
        MaterialApp(home: TaiYiPanPage(controller: controller)),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('盘面解释可能不完整'),
        findsOneWidget,
        reason: '前置: 隐藏后 banner 出现',
      );

      // 2) 恢复 taiYi
      await controller.setDeityVisibility('taiYi', true);
      await tester.pumpAndSettle();

      expect(
        controller.showHiddenWarning,
        isFalse,
        reason: 'AC13.3: 恢复核心后 showHiddenWarning 必须为 false',
      );

      expect(
        find.textContaining('盘面解释可能不完整'),
        findsNothing,
        reason: 'AC13.3: 恢复核心后 banner 必须消失',
      );
    });
  });
}
