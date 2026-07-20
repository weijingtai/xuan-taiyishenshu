// ZT-21 AC9 重启恢复测试: 偏好写入 SharedPreferences 后, 销毁 Controller/Assembly
// 重建 → 偏好仍被恢复, 且重新排盘后 panData.palaces 仍反映该偏好。
//
// 反伪完成红线:
// - 不准 Mock panData;
// - 不准只断言 SP key 存在;
// - MUST 销毁 controller1 + assembly1, 用同一 mock SP 重新构造 assembly2 + controller2,
//   并断言 controller2.isDeityVisible(id) 与 panData.palaces 内容一致;
// - MUST 验证恢复路径 (重启后再勾回去, 盘面再次出现该项)。
//
// 覆盖 SPEC 验收条件:
//   AC9.4 销毁→重建后, isDeityVisible(junJi)==false 且 panData 不含 君基
//   AC9.5 重建后再 setDeityVisibility(junJi, true) → panData 重新含 君基, SP 写入 true

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

  group('ZT-21 AC9 (SP 持久化): 重建 Controller/Assembly 后偏好恢复', () {
    test(
        'AC9_4_restart_recovery: 隐藏 junJi → 销毁 controller/assembly '
        '→ 同 SP+同 DB 重建 → isDeityVisible(junJi)==false + panData 不含 君基',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();

      // === 第一轮 (写入偏好) ===
      final assembly1 = await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller1 = TaiYiPanController(assembly: assembly1);
      await controller1.loadSchools();
      await controller1.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      expect(
        _allPalaceNames(controller1.panData!),
        contains('君基'),
        reason: '前置: 默认 jingMirror 年盘应含 君基',
      );

      // 用户操作: 隐藏 junJi
      await controller1.setDeityVisibility('junJi', false);

      expect(
        await assembly1.preferenceRepo.isEnabled('junJi'),
        isFalse,
        reason: '前置: SP 必须真的写入 false',
      );
      expect(
        _allPalaceNames(controller1.panData!),
        isNot(contains('君基')),
        reason: '前置: 第一轮中, 隐藏 junJi 后 panData 已不含 君基',
      );

      // 销毁 controller1 (模拟应用关闭)
      controller1.dispose();

      // === 第二轮 (重建, 模拟应用重启) ===
      // 用同一 prefs (持久层未销毁) 和 同一 db 重建 assembly + controller
      final assembly2 = await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller2 = TaiYiPanController(assembly: assembly2);
      await controller2.loadSchools();
      await controller2.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      // 偏好层断言: SP 中 junJi 仍是 false
      expect(
        await assembly2.preferenceRepo.isEnabled('junJi'),
        isFalse,
        reason: 'AC9.4: 重建 assembly 后, SP 中 junJi 必须仍为 false',
      );

      // Controller 层断言: 重建后的 controller 必须从 SP 恢复 cache
      expect(
        controller2.isDeityVisible('junJi'),
        isFalse,
        reason:
            'AC9.4: 重建 controller 后, isDeityVisible(junJi) 必须为 false '
            '(loadSchools 内部 hydrate cache from preferenceRepo)',
      );

      // 盘面层断言: 重新排盘后 panData 必须不含 君基
      expect(
        _allPalaceNames(controller2.panData!),
        isNot(contains('君基')),
        reason: 'AC9.4: 重启后重新排盘, panData.palaces 仍不应包含 君基',
      );

      await db.close();
    });

    test(
        'AC9_5_restart_then_restore: 重启后再 setDeityVisibility(junJi, true) '
        '→ panData 重新出现 君基 + SP 写入 true',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();

      // === 第一轮: 隐藏 junJi ===
      final assembly1 = await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller1 = TaiYiPanController(assembly: assembly1);
      await controller1.loadSchools();
      await controller1.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      await controller1.setDeityVisibility('junJi', false);
      expect(
        _allPalaceNames(controller1.panData!),
        isNot(contains('君基')),
      );
      controller1.dispose();

      // === 第二轮: 重建 + 恢复 ===
      final assembly2 = await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller2 = TaiYiPanController(assembly: assembly2);
      await controller2.loadSchools();
      await controller2.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      // 前置: 第二轮重建后, 君基仍隐藏
      expect(
        _allPalaceNames(controller2.panData!),
        isNot(contains('君基')),
        reason: '前置: 重启后偏好仍生效',
      );

      // 重启后再勾回 junJi (用户重新启用)
      await controller2.setDeityVisibility('junJi', true);

      expect(
        await assembly2.preferenceRepo.isEnabled('junJi'),
        isTrue,
        reason: 'AC9.5: 恢复后 SP 必须写入 true',
      );
      expect(
        controller2.isDeityVisible('junJi'),
        isTrue,
        reason: 'AC9.5: 恢复后 controller cache 必须为 true',
      );
      expect(
        _allPalaceNames(controller2.panData!),
        contains('君基'),
        reason: 'AC9.5: 恢复后, 重启会话内的 panData 必须重新含 君基',
      );

      // 再做一次"重启"以确认 true 状态本身可持久化
      controller2.dispose();
      final assembly3 = await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller3 = TaiYiPanController(assembly: assembly3);
      await controller3.loadSchools();
      await controller3.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      expect(
        _allPalaceNames(controller3.panData!),
        contains('君基'),
        reason: 'AC9.5: true 状态本身也可跨重启持久化',
      );

      await db.close();
    });
  });
}
