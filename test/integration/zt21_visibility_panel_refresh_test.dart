// ZT-21 AC9 测试: 勾选/取消星神后, panData.palaces 立即反映该偏好。
//
// 反伪完成红线:
// - 不准 Mock panData;
// - 不准只断言 ViewModel state 或 SharedPreferences;
// - MUST 断言 controller.panData!.palaces 中 PanComputedItem.name 真的出现/消失。
//
// 覆盖 SPEC 验收条件:
//   AC9.1 取消 wenChang → palaces 中 "文昌" 不再出现
//   AC9.2 取消 / 恢复 junJi (君基) round-trip → 状态前后一致
//   AC9.3 重复 setDeityVisibility(id, false) 幂等 (反 toggle 漏洞回归)

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import 'package:persistence_drift/taiyishenshu/taiyishenshu_drift.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';
import '../taiyi/test_harness.dart';
import 'package:taiyishenshu/taiyi/pan_data_model.dart';

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
    assets["packages/taiyishenshu/" + path] = File(path).readAsStringSync();
  }
  for (final id in _deityKebabIds) {
    final path = 'assets/deities/$id.json';
    assets["packages/taiyishenshu/" + path] = File(path).readAsStringSync();
  }
  return _RealAssetBundle(assets);
}

/// 收集盘面 (所有宫) 中出现的 PanComputedItem.name 列表。
Set<String> _allPalaceNames(PanDataModel pan) {
  final names = <String>{};
  for (final palace in pan.palaces) {
    for (final item in palace.items) {
      names.add(item.name);
    }
  }
  return names;
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = _FakePathProviderPlatform();
  });

  group('ZT-21 AC9: 勾选 → 盘面立即刷新', () {
    test('AC9_1_wenChang: 取消文昌 → palaces 中 "文昌" 立即消失', () async {
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

      // 前置: panData 包含 "文昌"
      final beforeNames = _allPalaceNames(controller.panData!);
      expect(
        beforeNames,
        contains('文昌'),
        reason: '前置条件: jingMirror 年盘默认应包含 文昌 落宫',
      );

      // 动作: 取消文昌
      await controller.setDeityVisibility('wenChang', false);

      // 验证 SharedPreferences 真有写入
      expect(
        await assembly.preferenceRepo.isEnabled('wenChang'),
        isFalse,
        reason: 'AC9: setDeityVisibility(id, false) 必须把 SP 设为 false',
      );

      // 验证盘面落宫立即变化 (核心 AC9 断言)
      final afterNames = _allPalaceNames(controller.panData!);
      expect(
        afterNames,
        isNot(contains('文昌')),
        reason:
            'AC9: 取消文昌后, panData.palaces 中 PanComputedItem.name == "文昌" '
            '必须立即消失。这不是 SP 写入断言, 这是盘面实际内容断言。',
      );

      await db.close();
    });

    test('AC9_2_junJi_round_trip: 取消 → 恢复 君基 → 盘面前后一致', () async {
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

      final initialNames = _allPalaceNames(controller.panData!);
      expect(
        initialNames,
        contains('君基'),
        reason: '前置: jingMirror 默认含 junJi (君基)',
      );

      // 取消 junJi
      await controller.setDeityVisibility('junJi', false);
      expect(
        _allPalaceNames(controller.panData!),
        isNot(contains('君基')),
        reason: 'AC9: 取消君基后, panData 中 "君基" 必须立即消失',
      );
      expect(
        await assembly.preferenceRepo.isEnabled('junJi'),
        isFalse,
      );

      // 恢复 junJi
      await controller.setDeityVisibility('junJi', true);
      expect(
        _allPalaceNames(controller.panData!),
        contains('君基'),
        reason: 'AC9: 恢复君基后, panData 中 "君基" 必须立即重新出现',
      );
      expect(
        await assembly.preferenceRepo.isEnabled('junJi'),
        isTrue,
      );

      await db.close();
    });

    test('AC9_3_idempotent: 重复 setDeityVisibility(id, false) 幂等 (反 toggle 漏洞)',
        () async {
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

      // 第一次设 false
      await controller.setDeityVisibility('wenChang', false);
      expect(await assembly.preferenceRepo.isEnabled('wenChang'), isFalse);
      expect(
        _allPalaceNames(controller.panData!),
        isNot(contains('文昌')),
      );

      // 第二次设 false (本来 toggle 实现会变 true, 这是漏洞)
      await controller.setDeityVisibility('wenChang', false);
      expect(
        await assembly.preferenceRepo.isEnabled('wenChang'),
        isFalse,
        reason: 'AC9 幂等性: 重复 set(id, false) 必须保持 false, 不能被 toggle 翻转',
      );
      expect(
        _allPalaceNames(controller.panData!),
        isNot(contains('文昌')),
        reason: 'AC9 幂等性: 盘面仍不应包含 "文昌"',
      );

      await db.close();
    });
  });
}
