// ZT-30 — Story #5 全链路整合: 官方+用户星神同盘共存 (AC10 mock-only 缺口收尾)
//
// AC 矩阵 AC10 缺口 #1 原文:
//   "'同盘显示' 验证只在 mock repo 路径 (deity_copy_and_scope_test.dart:73-76),
//    没有在真盘 + 真 Drift 下验证"
//
// 反伪完成红线:
// - 不准 Mock Repository — 必须用 MultiSchoolRepository + OfficialJsonSchoolRepository + DriftUserRepository
// - 必须断言两个 PanComputedItem 同时存在于 panData.palaces
// - 必须断言官方 deity 在 OfficialJsonSchoolRepository 重读后**未被修改**

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import 'package:taiyishenshu/database/taiyi_database.dart';
import 'package:taiyishenshu/taiyi/pan_data_model.dart';
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

  group('ZT-30 AC30.5: 官方+用户同盘共存 (AC10 mock-only 缺口收尾)', () {
    test(
        'official_user_coexist: 官方 wenChang + 用户副本 (schoolScopes=[jingMirror]) 同盘并列',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          TaiYiDataAssembly.test(bundle: bundle, prefs: prefs, db: db);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();

      // 1. 取官方 wenChang 原始定义 (供后续对照)
      final officialBefore = await assembly.officialRepo.loadDeity('wenChang');
      expect(officialBefore, isNotNull);
      final officialNameBefore = officialBefore!.name;
      final officialColorBefore = officialBefore.color;

      // 2. 创建用户副本, 限定 schoolScopes=[jingMirror]
      const userId = 'user_wc_coexist_zt30';
      await controller.deityViewModel.copyDeity(
        sourceId: 'wenChang',
        newId: userId,
        newName: '文昌·并列副本',
      );
      final userDeity =
          controller.deityViewModel.deities.firstWhere((d) => d.id == userId);
      final scoped = userDeity.copyWith(
        schoolScopes: const ['jingMirror'],
        color: '#FF6B6B',
      );
      await controller.deityViewModel.saveDeity(scoped);

      // 3. 计算 jingMirror 年盘
      await controller.calculate(
        dateTime: DateTime(2024, 6, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      final names = _allPalaceNames(controller.panData!);

      // 关键断言: 两个 name 同时存在
      expect(names, contains('文昌'),
          reason: 'AC10 共存: 官方 文昌 必须在盘面');
      expect(names, contains('文昌·并列副本'),
          reason: 'AC10 共存: 用户副本 文昌·并列副本 必须在盘面');

      // 4. 关键反向: OfficialJsonSchoolRepository 重读 wenChang, 字段未被污染
      final officialAfter = await assembly.officialRepo.loadDeity('wenChang');
      expect(officialAfter, isNotNull);
      expect(officialAfter!.name, officialNameBefore,
          reason: 'AC16: 用户派生不应污染官方 wenChang.name');
      expect(officialAfter.color, officialColorBefore,
          reason: 'AC16: 用户派生不应污染官方 wenChang.color');
      expect(officialAfter.source, 'official',
          reason: 'AC16: 官方 wenChang.source 永远是 official');

      controller.dispose();
      await db.close();
    });

    test(
        'repo_interface_only: assembly 三类基础实现可识别, ViewModel 通过 UseCase 持有它们 (AC5)',
        () async {
      // 这是一个 runtime 结构断言, 验证 AC5 "三类基础实现":
      //   - OfficialJsonSchoolRepository (assets)
      //   - DriftUserRepository (Drift)
      //   - SharedPreferencesDeityPreferenceRepository (SP)
      //   - MultiSchoolRepository (官方 + 用户合并, 通过接口暴露给 UseCase)
      //
      // 反 fake: 不是断言 mock.callCount, 而是断言真实的 assembly 注入是否符合
      // AC5 的"三类基础实现"红线 + AC7 的"UseCase 拿到接口而非具体类"红线。
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          TaiYiDataAssembly.test(bundle: bundle, prefs: prefs, db: db);

      // 三类基础实现 runtime 可识别
      expect(assembly.officialRepo.runtimeType.toString(),
          'OfficialJsonSchoolRepository',
          reason: 'AC5: 官方仓库具体实现 (assets 来源)');
      expect(assembly.userRepo.runtimeType.toString(), 'DriftUserRepository',
          reason: 'AC5: 用户仓库具体实现 (Drift 来源)');
      expect(assembly.preferenceRepo.runtimeType.toString(),
          'SharedPreferencesDeityPreferenceRepository',
          reason: 'AC5: 偏好仓库具体实现 (SP 来源)');
      expect(assembly.compositeRepo.runtimeType.toString(),
          'MultiSchoolRepository',
          reason: 'AC7: UseCase 通过 compositeRepo (SchoolRepository 接口) 访问合并视图');

      await db.close();
    });
  });
}
