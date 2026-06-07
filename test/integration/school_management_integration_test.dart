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

/// 真实 Assembly + 真实 Drift (memory) + 真实 OfficialJsonRepository 集成测试。
///
/// 反 FakeViewModel-only 红线: 本文件**不允许**出现任何 FakeViewModel /
/// MockSchoolViewModel — 所有断言都穿透到真实 Repository / UseCase / 计算器,
/// 验证以下 QA 打回项:
///
/// 1. 列表数据流: ViewModel -> LoadSchoolsUseCase -> OfficialJsonRepo + DriftUserRepo
/// 2. 复制官方流派 -> 真实写入 Drift
/// 3. 持久化: 同一 Drift instance 跨 controller 重建后副本仍在
/// 4. 切换流派 -> CalculatePanUseCase 触发 -> accumulatedYear / juNumber 真实变化
/// 5. 官方流派只读 (deleteSchool 抛 UnsupportedError 等已由 Task 12 覆盖,
///    本文件验证: UI 端从 ViewModel 拿到 source='official' 的项后, copy 仍能成功,
///    save / delete 不被本流程触发)
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

class _MockAssetBundle extends Fake implements AssetBundle {
  final Map<String, String> assets;
  _MockAssetBundle(this.assets);

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
          Uint8List.fromList(utf8.encode(assets[key]!)).buffer);
    }
    if (key.contains('AssetManifest')) return ByteData(0);
    throw FlutterError('Asset not found: $key');
  }
}

Map<String, String> _loadOfficialAssets() {
  const schoolFiles = ['jing-mirror', 'tong-zong', 'ji-cheng'];
  const deityFiles = [
    'tai-yi', 'zhu-da-jiang', 'ke-da-jiang', 'zhu-can-jiang', 'ke-can-jiang',
    'ding-da-jiang', 'ding-can-jiang', 'jun-ji', 'chen-ji', 'min-ji',
    'wu-fu', 'da-you', 'xiao-you', 'fei-fu', 'si-shen',
    'tian-yi-star', 'di-yi', 'zhi-fu-star', 'yang-jiu', 'bai-liu',
    'tai-sui', 'sui-po', 'zhi-fu', 'he-shen',
    'qing-long', 'zhu-que', 'bai-hu', 'xuan-wu', 'feng-bo', 'yu-shi',
    'qing-long-qi', 'hei-qi', 'chi-qi', 'gui-shen-zhi-shi',
    'wen-chang', 'ji-shen', 'shi-ji',
  ];
  final m = <String, String>{};
  for (final id in schoolFiles) {
    m['assets/schools/$id.json'] = File('assets/schools/$id.json').readAsStringSync();
  }
  for (final id in deityFiles) {
    m['assets/deities/$id.json'] = File('assets/deities/$id.json').readAsStringSync();
  }
  return m;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();
  final mockAssets = _loadOfficialAssets();

  Future<TaiYiPanController> buildController(TaiYiDatabase db) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final assembly = await TaiYiTestHarness.createAssemblyFrom(
      bundle: _MockAssetBundle(mockAssets),
      prefs: prefs,
      db: db,
    );
    final controller = TaiYiPanController(assembly: assembly);
    await controller.loadSchools();
    return controller;
  }

  group('Task 14 / Story #4 — School Management Integration', () {
    test('a) 初次打开: 列表来自真实 Repository, 3 官方 + 0 用户', () async {
      final db = TaiYiDatabase.memory();
      addTearDown(db.close);
      final controller = await buildController(db);
      addTearDown(controller.dispose);

      final schools = controller.schoolViewModel.schools;
      expect(schools.length, 3,
          reason: '初始应仅有 jingMirror / tongZong / jiCheng 三派');
      expect(schools.map((s) => s.id),
          containsAll(['jingMirror', 'tongZong', 'jiCheng']));
      expect(schools.every((s) => s.source == 'official'), isTrue);
    });

    test('b) 复制 jingMirror -> 写入 Drift -> 列表 4 项, 重建 controller 仍 4 项 (持久化)',
        () async {
      final db = TaiYiDatabase.memory();
      addTearDown(db.close);
      final controller = await buildController(db);

      await controller.schoolViewModel.copySchool(
        sourceId: 'jingMirror',
        newId: 'user_jm_persist_test',
        newName: '我的金镜派-持久化',
      );

      // 内存视图: 应有 4 项
      expect(controller.schoolViewModel.schools.length, 4);
      final copied = controller.schoolViewModel.schools
          .firstWhere((s) => s.id == 'user_jm_persist_test');
      expect(copied.source, 'user');
      expect(copied.name, '我的金镜派-持久化');
      expect(copied.rootOfficialId, 'jingMirror');
      expect(copied.lineage, contains('jingMirror'));

      // dispose 当前 controller，使用同一 db 重建 controller 模拟应用重启
      controller.dispose();

      final controller2 = await buildController(db);
      addTearDown(controller2.dispose);

      expect(controller2.schoolViewModel.schools.length, 4,
          reason: '同一 Drift instance 重建 controller 后，用户副本必须仍然存在');
      final reloaded = controller2.schoolViewModel.schools
          .firstWhere((s) => s.id == 'user_jm_persist_test');
      expect(reloaded.name, '我的金镜派-持久化');
      expect(reloaded.source, 'user');
    });

    test('c) switchSchool: jingMirror -> tongZong, accumulatedYear 必须不同',
        () async {
      final db = TaiYiDatabase.memory();
      addTearDown(db.close);
      final controller = await buildController(db);
      addTearDown(controller.dispose);

      final probeDate = DateTime(2024, 5, 1);

      await controller.calculate(
        dateTime: probeDate,
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      final jingMirrorPan = controller.panData!;
      final jmAccumulated = jingMirrorPan.accumulatedYear;
      final jmJu = jingMirrorPan.juNumber;
      final jmHostPalace = jingMirrorPan.hostGuest.hostPalace.name;

      await controller.switchSchool('tongZong');
      final tongZongPan = controller.panData!;
      final tzAccumulated = tongZongPan.accumulatedYear;
      final tzJu = tongZongPan.juNumber;
      final tzHostPalace = tongZongPan.hostGuest.hostPalace.name;

      // 关键 numeric assertion: 不同流派 epoch 必然产生不同 accumulatedYear
      // jingMirror: ancientBase=1937281, epochYear=724
      //   -> 1937281 + (2024-724) = 1938581
      // tongZong:   ancientBase=10155219, epochYear=1303
      //   -> 10155219 + (2024-1303) = 10155940
      expect(jmAccumulated, isNot(equals(tzAccumulated)),
          reason: 'jingMirror 与 tongZong 的 accumulatedYear 必须不同');
      expect(jmAccumulated, 1938581);
      expect(tzAccumulated, 10155940);

      // 至少有一个可观察的盘面差异 (juNumber 或主算落宫)
      final differs = jmJu != tzJu || jmHostPalace != tzHostPalace;
      expect(differs, isTrue,
          reason:
              '切换流派后，至少 juNumber 或主算落宫之一应当变化 (jmJu=$jmJu, tzJu=$tzJu, jmHostPalace=$jmHostPalace, tzHostPalace=$tzHostPalace)');
    });

    test('d) 切换到用户副本: input.schoolId / schoolName 同步更新', () async {
      final db = TaiYiDatabase.memory();
      addTearDown(db.close);
      final controller = await buildController(db);
      addTearDown(controller.dispose);

      await controller.schoolViewModel.copySchool(
        sourceId: 'jingMirror',
        newId: 'user_jm_switch_test',
        newName: '我的金镜派-切换',
      );

      await controller.calculate(
        dateTime: DateTime(2024, 5, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      expect(controller.panData?.input.schoolId, 'jingMirror');

      await controller.switchSchool('user_jm_switch_test');
      expect(controller.panData?.input.schoolId, 'user_jm_switch_test');
      expect(controller.panData?.input.schoolName, '我的金镜派-切换');
      // 用户副本继承 jingMirror 的 epoch，因此 accumulatedYear 与 jingMirror 一致
      expect(controller.panData?.accumulatedYear, 1938581);
    });

    test('e) 官方流派在 Drift 用户表中不存在 -> AC2 / AC16 (官方资产不可派生写入)',
        () async {
      final db = TaiYiDatabase.memory();
      addTearDown(db.close);
      final controller = await buildController(db);
      addTearDown(controller.dispose);

      final userRepoSchools =
          await controller.assembly.officialRepo.loadAllSchools();
      expect(userRepoSchools, isEmpty,
          reason: '初次打开时 Drift userSchools 必须为空，官方流派不可能写入用户表');
    });
  });
}
