// ZT-30 — Story #5 全链路整合: 多级 lineage (AC12 矩阵缺口)
//
// AC 矩阵 AC12 缺口 #2 原文:
//   "多级派生 (用户星神 A 派生出用户星神 B) 的 lineage 链是否包含两层未验证"
//
// 反伪完成红线:
// - 不准用注入字符串 (如 lineage: '官方 > 我的派生') 来通过, 必须靠 CopyDeityUseCase 真生成
// - 必须断言 B.lineage 同时包含官方源 ID 和中间用户 A 的 ID
// - rootOfficialId 必须仍指向最初官方源 (不是 A)

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:persistence_drift/taiyishenshu/taiyishenshu_drift.dart';
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
    assets["packages/taiyishenshu/" + path] = File(path).readAsStringSync();
  }
  for (final id in _deityKebabIds) {
    final path = 'assets/deities/$id.json';
    assets["packages/taiyishenshu/" + path] = File(path).readAsStringSync();
  }
  return _RealAssetBundle(assets);
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = _FakePathProviderPlatform();
  });

  group('ZT-30 AC30.4: 多级 lineage (AC12 矩阵缺口)', () {
    test(
        'multilevel_lineage_deity: official(taiYi) → user_a → user_b, B.lineage 含两层链, rootOfficialId 仍是 taiYi',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);

      // Level 1: 官方 taiYi → user_a
      const userAId = 'user_taiyi_level1_zt30';
      final userA = await assembly.copyDeityUseCase(
        sourceId: 'taiYi',
        newId: userAId,
        newName: '太乙·一级派生',
      );
      expect(userA.source, 'user');
      expect(userA.sourceId, 'taiYi');
      expect(userA.rootOfficialId, 'taiYi');
      expect(userA.lineage, isNotNull);
      expect(userA.lineage, contains('taiYi'));
      expect(userA.lineage, contains(userAId));
      // 严格: 一级派生只有一层 ' -> '
      expect(userA.lineage!.split(' -> ').length, 2,
          reason: 'AC12: 一级派生 lineage 应该只有两段 (official + userA)');

      // Level 2: user_a → user_b (派生自用户星神, 不是官方)
      const userBId = 'user_taiyi_level2_zt30';
      final userB = await assembly.copyDeityUseCase(
        sourceId: userAId,
        newId: userBId,
        newName: '太乙·二级派生',
      );
      expect(userB.source, 'user',
          reason: 'AC12: 二级派生 source 仍是 user');
      expect(userB.sourceId, userAId,
          reason: 'AC12: 二级派生 sourceId 指向直接父级 (user_a), 不是根 (taiYi)');
      expect(userB.rootOfficialId, 'taiYi',
          reason:
              'AC12 关键: 二级派生的 rootOfficialId 必须仍指向最初官方源 taiYi (不是 user_a), '
              '否则会切断派生链的根追溯');

      // 关键断言: lineage 同时包含三段
      expect(userB.lineage, isNotNull);
      expect(userB.lineage, contains('taiYi'),
          reason: 'AC12: 二级派生 lineage 必须保留官方根 (taiYi)');
      expect(userB.lineage, contains(userAId),
          reason: 'AC12: 二级派生 lineage 必须保留中间用户层 (user_a)');
      expect(userB.lineage, contains(userBId),
          reason: 'AC12: 二级派生 lineage 必须包含自身 ID');
      // 严格: 二级派生 lineage 应有 3 段 (官方 -> user_a -> user_b)
      expect(userB.lineage!.split(' -> ').length, 3,
          reason: 'AC12: 二级派生 lineage 应该有三段 (official + userA + userB)');

      // 持久化验证: 重建 repository 后 lineage 仍正确
      final reloadedB = await assembly.deityRepo.loadDeity(userBId);
      expect(reloadedB, isNotNull);
      expect(reloadedB!.lineage, userB.lineage,
          reason: 'AC3+AC12: lineage 字段必须真实持久化到 Drift, toJson/fromJson 不丢失');
      expect(reloadedB.rootOfficialId, 'taiYi',
          reason: 'AC3+AC12: rootOfficialId 必须真实持久化');
      expect(reloadedB.sourceId, userAId,
          reason: 'AC3+AC12: sourceId 必须真实持久化');

      await db.close();
    });

    test(
        'multilevel_lineage_school: official(jingMirror) → user_a → user_b, B.rootOfficialId 仍是 jingMirror',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          await TaiYiTestHarness.createAssemblyFrom(bundle: bundle, prefs: prefs, db: db);

      const userAId = 'user_jm_level1_zt30';
      final userA = await assembly.copySchoolUseCase(
        sourceId: 'jingMirror',
        newId: userAId,
        newName: '金镜派·一级',
      );
      expect(userA.rootOfficialId, 'jingMirror');
      expect(userA.lineage, contains('jingMirror'));
      expect(userA.lineage, contains(userAId));

      const userBId = 'user_jm_level2_zt30';
      final userB = await assembly.copySchoolUseCase(
        sourceId: userAId,
        newId: userBId,
        newName: '金镜派·二级',
      );
      expect(userB.sourceId, userAId);
      expect(userB.rootOfficialId, 'jingMirror',
          reason: 'AC12 关键: 二级派生流派 rootOfficialId 必须仍是 jingMirror');
      expect(userB.lineage, contains('jingMirror'));
      expect(userB.lineage, contains(userAId));
      expect(userB.lineage, contains(userBId));
      expect(userB.lineage!.split(' -> ').length, 3,
          reason: 'AC12: 二级派生流派 lineage 应有三段');

      // 持久化
      final reloadedB = await assembly.userRepo.loadSchool(userBId);
      expect(reloadedB!.rootOfficialId, 'jingMirror');
      expect(reloadedB.sourceId, userAId);
      expect(reloadedB.lineage, userB.lineage);

      await db.close();
    });
  });
}
