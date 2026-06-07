// ZT-30 — Story #5 全链路整合: 星神编辑→保存→盘面包含 (AC3 / AC7 / AC10 收尾)
//
// 反伪完成红线:
// - 必须用 真 OfficialJsonSchoolRepository 加载 wenChang 官方星神
// - 必须用 真 DriftUserRepository 写入用户副本
// - 必须 controller.calculate 后断言 panData.palaces.expand(items) 包含用户副本 name
//   (不只是 deityVM.deities 长度断言)
//
// 链路: DeityViewModel.copyDeity → CopyDeityUseCase → DriftUserRepository.saveUserDeity →
//       loadDeities → controller.calculate → CalculatePanUseCase.execute →
//       MultiSchoolRepository.loadAllDeities (官方 + 用户) → TaiYiPanCalculator → panData.palaces

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
import 'package:taiyishenshu/taiyi/pan_data_model.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';
import '../taiyi/test_harness.dart';

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
  Future<List<String>?> getExternalStoragePaths(
          {StorageDirectory? type}) async =>
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

  group('ZT-30 AC30.2: 星神编辑→保存→盘面包含 (AC3/AC7/AC10 收尾)', () {
    test(
        'fullchain_deity_save_reload: 用户复制星神→改名→保存→重新计算→panData 包含新名',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();

      // Baseline: jingMirror 年盘默认应含官方 "文昌"
      final probeDate = DateTime(2024, 6, 1);
      await controller.calculate(
        dateTime: probeDate,
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      final baselineNames = _allPalaceNames(controller.panData!);
      expect(baselineNames, contains('文昌'),
          reason: '前置: 官方 jingMirror 年盘必含 文昌');
      expect(baselineNames, isNot(contains('文昌·我的派生')),
          reason: '前置: 不应预先存在用户副本');

      // 链路 1: DeityViewModel.copyDeity → DriftUserRepository
      const copyId = 'user_wc_zt30_save_reload';
      await controller.deityViewModel.copyDeity(
        sourceId: 'wenChang',
        newId: copyId,
        newName: '文昌·我的派生',
      );
      // 直接读 Drift 验证持久化
      final fromDrift = await assembly.userRepo.loadDeity(copyId);
      expect(fromDrift, isNotNull,
          reason: 'AC3: copyDeity 必须穿透 ViewModel 写入真 Drift');
      expect(fromDrift!.source, 'user');
      expect(fromDrift.sourceId, 'wenChang');
      expect(fromDrift.rootOfficialId, 'wenChang');
      expect(fromDrift.lineage, contains('wenChang'));
      expect(fromDrift.name, '文昌·我的派生');

      // VM 列表立即可见
      expect(
        controller.deityViewModel.deities.any((d) => d.id == copyId),
        isTrue,
        reason: 'AC7: copyDeity 后 ViewModel.deities 必须立即反映新行',
      );

      // 链路 2: controller.calculate 重新排盘 → CalculatePanUseCase 重新加载 MultiSchoolRepository
      //         → 用户副本进入 effectiveDefinitions → 引擎执行 → name 出现在 palaces
      await controller.calculate(
        dateTime: probeDate,
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      final afterNames = _allPalaceNames(controller.panData!);
      expect(
        afterNames,
        contains('文昌·我的派生'),
        reason:
            'AC10: 用户副本必须在 jingMirror 年盘的 PanComputedItem.name 中出现 '
            '(走完整 MVVM→UseCase→Repo→Calculator 链路, 而非 mock-only)',
      );
      // 官方 wenChang 仍然在 (用户副本是并列, 不是替换)
      expect(
        afterNames,
        contains('文昌'),
        reason: 'AC10: 用户副本不应替换官方 文昌, 两者必须共存',
      );

      // 链路 3: 重建 controller → 用户副本仍存在, 盘面仍可计算包含
      controller.dispose();
      final assembly2 =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller2 = TaiYiPanController(assembly: assembly2);
      await controller2.loadSchools();
      expect(
        controller2.deityViewModel.deities.any((d) => d.id == copyId),
        isTrue,
        reason: 'AC3 持久化: 重建 controller 后用户副本必须仍可加载',
      );
      await controller2.calculate(
        dateTime: probeDate,
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      expect(
        _allPalaceNames(controller2.panData!),
        contains('文昌·我的派生'),
        reason: 'AC3 持久化: 重建后用户副本必须仍出现在盘面',
      );
      controller2.dispose();
      await db.close();
    });
  });
}
