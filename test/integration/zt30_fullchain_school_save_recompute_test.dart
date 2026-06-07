// ZT-30 — Story #5 全链路整合: 流派编辑→保存→盘面重算 (AC3 / AC7 / AC11 收尾)
//
// 反伪完成红线:
// - 不准 Mock panData / Mock ViewModel / Mock Repository;
// - MUST 走真实 SchoolViewModel → SaveUserSchoolUseCase → DriftUserRepository → 重算;
// - MUST 在 controller.calculate 后断言 accumulatedYear 真实变化。
//
// 链路: SchoolViewModel.copySchool → DriftUserRepository.saveUserSchool →
//       (load) → SchoolViewModel.saveSchool(updated) → DriftUserRepository.saveUserSchool →
//       (重建 controller) → 重新 loadSchools → controller.calculate(schoolId: copyId, ...) →
//       panData.accumulatedYear 反映新 epoch。

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

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = _FakePathProviderPlatform();
  });

  group('ZT-30 AC30.1: 流派编辑→保存→盘面重算 (AC3/AC7/AC11 收尾)', () {
    test(
        'fullchain_school_save_recompute: copy→edit epoch→save→switch→accumulatedYear 真变化',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();

      // Baseline: 计算官方 jingMirror 在 2024-06-15 的 accumulatedYear
      final probeDate = DateTime(2024, 6, 15, 12, 0);
      await controller.calculate(
        dateTime: probeDate,
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      final baselineAY = controller.panData!.accumulatedYear;
      expect(baselineAY, 1938581,
          reason: 'jingMirror baseline accumulatedYear 固定值 (反 vector 漂移)');

      // 链路 1: SchoolViewModel.copySchool → DriftUserRepository
      const copyId = 'user_jm_zt30_fullchain';
      await controller.schoolViewModel.copySchool(
        sourceId: 'jingMirror',
        newId: copyId,
        newName: '我的金镜派-ZT30-全链路',
      );
      // VM cache 立即可见
      expect(
        controller.schoolViewModel.schools.any((s) => s.id == copyId),
        isTrue,
        reason: 'AC3: copySchool 后 ViewModel 列表必须立即反映 Drift 新行',
      );

      // 直接读 Drift 验证持久化 (不是 VM 内存 cache 自卖自夸)
      final fromDrift = await assembly.userRepo.loadSchool(copyId);
      expect(fromDrift, isNotNull,
          reason: 'AC3: copySchool 必须穿透 ViewModel 写入真 Drift');
      expect(fromDrift!.source, 'user');
      expect(fromDrift.sourceId, 'jingMirror');
      expect(fromDrift.rootOfficialId, 'jingMirror');
      expect(fromDrift.lineage, contains('jingMirror'));
      expect(fromDrift.lineage, contains(copyId));

      // 链路 2: SchoolViewModel.saveSchool(updated) — 改 epochYear +100
      final shifted = fromDrift.copyWith(
        epoch: fromDrift.epoch.copyWith(
          epochYear: fromDrift.epoch.epochYear + 100,
        ),
      );
      await controller.schoolViewModel.saveSchool(shifted);

      // 直接读 Drift 验证更新落到 SQLite
      final reloaded = await assembly.userRepo.loadSchool(copyId);
      expect(reloaded!.epoch.epochYear, fromDrift.epoch.epochYear + 100,
          reason: 'AC3: saveSchool 必须把 epochYear 变化真实写入 Drift');

      // 链路 3: switchSchool → controller.calculate → accumulatedYear 真变化
      await controller.switchSchool(copyId);
      expect(controller.panData?.input.schoolId, copyId,
          reason: 'AC7: switchSchool 后 panData.input.schoolId 同步');
      expect(controller.panData?.input.schoolName, '我的金镜派-ZT30-全链路',
          reason: 'AC7: switchSchool 后 panData.input.schoolName 同步');
      final modifiedAY = controller.panData!.accumulatedYear;
      // epochYear +100 → (targetYear - epochYear) -100 → accumulatedYear -100
      expect(modifiedAY, baselineAY - 100,
          reason:
              'AC7: epochYear 修改 +100 必须导致 accumulatedYear 精确 -100 ($baselineAY → $modifiedAY)');

      // 链路 4: 重建 controller (复用同 db+prefs) → 副本仍存在 + 仍可切换
      controller.dispose();
      final assembly2 =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);
      final controller2 = TaiYiPanController(assembly: assembly2);
      await controller2.loadSchools();
      expect(
        controller2.schoolViewModel.schools.any((s) => s.id == copyId),
        isTrue,
        reason: 'AC11: 重建 controller 后副本必须仍可加载 (持久化)',
      );
      await controller2.calculate(
        dateTime: probeDate,
        schoolId: copyId,
        chartType: TaiYiChartType.year,
      );
      expect(controller2.panData!.accumulatedYear, baselineAY - 100,
          reason: 'AC11: 重建后用副本排盘的 accumulatedYear 必须仍是 -100 后的值');
      controller2.dispose();
      await db.close();
    });
  });
}
