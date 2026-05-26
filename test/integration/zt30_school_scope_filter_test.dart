// ZT-30 — Story #5 全链路整合: schoolScopes 过滤 (AC10 矩阵明确缺口)
//
// AC 矩阵 AC10 缺口 #2 原文:
//   "'适用流派'/'适用盘型' 在 Drift round-trip 保留已验, 但实际'切换流派时不在
//    schoolScopes 中的用户星神被过滤掉'这个语义未验证 (即 schoolScopes=jiCheng
//    的用户星神在 jingMirror 盘上不应出现)"
//
// 反伪完成红线:
// - 不准 Mock — 必须真盘真 Drift 验证
// - 必须在切换流派前后断言同一星神的出现/消失

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

  group('ZT-30 AC30.3: schoolScopes 过滤 (AC10 矩阵明确缺口)', () {
    test(
        'school_scope_filter: schoolScopes=[jiCheng] 用户星神在 jingMirror 盘不出现, 切到 jiCheng 才出现',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          TaiYiDataAssembly.test(bundle: bundle, prefs: prefs, db: db);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();

      // 通过 ViewModel copyDeity 创建初始副本, 再用 saveUserDeity 限定 schoolScopes
      const scopedId = 'user_wc_jicheng_only_zt30';
      await controller.deityViewModel.copyDeity(
        sourceId: 'wenChang',
        newId: scopedId,
        newName: '文昌·限定集成',
      );

      // 取出副本, 直接通过 ViewModel.saveDeity 设置 schoolScopes=['jiCheng']
      final copied =
          controller.deityViewModel.deities.firstWhere((d) => d.id == scopedId);
      final scoped = copied.copyWith(
        schoolScopes: const ['jiCheng'],
      );
      await controller.deityViewModel.saveDeity(scoped);

      // Drift 直接读验证 schoolScopes 真落盘
      final fromDrift = await assembly.userRepo.loadDeity(scopedId);
      expect(fromDrift!.schoolScopes, equals(['jiCheng']),
          reason: 'AC10 前置: schoolScopes 必须真写入 Drift');

      // 测试 1: 在 jingMirror 盘上, 该副本不应出现
      final probeDate = DateTime(2024, 6, 1);
      await controller.calculate(
        dateTime: probeDate,
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      final jmNames = _allPalaceNames(controller.panData!);
      expect(
        jmNames,
        isNot(contains('文昌·限定集成')),
        reason:
            'AC10 关键: schoolScopes=[jiCheng] 的用户星神不应出现在 jingMirror 盘 '
            '(CalculatePanUseCase 第 56-62 行的 schoolScopes 过滤逻辑必须穿透到盘面)',
      );
      // 官方 文昌 仍在 (schoolScopes 为空 → 全流派可见)
      expect(jmNames, contains('文昌'),
          reason: 'AC10 对照: 官方 文昌 schoolScopes 为空, 仍应在 jingMirror 上');

      // 测试 2: 切到 jiCheng 盘, 副本应出现
      await controller.calculate(
        dateTime: probeDate,
        schoolId: 'jiCheng',
        chartType: TaiYiChartType.year,
      );
      final jcNames = _allPalaceNames(controller.panData!);
      expect(
        jcNames,
        contains('文昌·限定集成'),
        reason: 'AC10 关键: schoolScopes=[jiCheng] 在 jiCheng 盘上必须出现',
      );

      // 测试 3 (逆向回归): 重新切回 jingMirror, 副本应再次消失 (无状态泄露)
      await controller.calculate(
        dateTime: probeDate,
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      expect(
        _allPalaceNames(controller.panData!),
        isNot(contains('文昌·限定集成')),
        reason: 'AC10 回归: 重新切回 jingMirror 后副本必须再次消失 (不应有状态残留)',
      );

      controller.dispose();
      await db.close();
    });

    test(
        'chartTypes_filter: chartTypes=[month] 用户星神在 year 盘不出现, 切到 month 盘出现',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = TaiYiDatabase.memory();
      final bundle = await _loadBundle();
      final assembly =
          TaiYiDataAssembly.test(bundle: bundle, prefs: prefs, db: db);
      final controller = TaiYiPanController(assembly: assembly);
      await controller.loadSchools();

      const monthOnlyId = 'user_wc_month_only_zt30';
      await controller.deityViewModel.copyDeity(
        sourceId: 'wenChang',
        newId: monthOnlyId,
        newName: '文昌·月限定',
      );
      final copied = controller.deityViewModel.deities
          .firstWhere((d) => d.id == monthOnlyId);
      // chartTypes=[month] 不限定 schoolScopes (留空 = 全流派)
      final scoped = copied.copyWith(chartTypes: const ['month']);
      await controller.deityViewModel.saveDeity(scoped);

      final probeDate = DateTime(2024, 6, 1);
      // 年盘上不应出现
      await controller.calculate(
        dateTime: probeDate,
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      expect(
        _allPalaceNames(controller.panData!),
        isNot(contains('文昌·月限定')),
        reason: 'AC10 chartTypes: chartTypes=[month] 不应出现在 year 盘',
      );

      // 月盘上应出现
      await controller.calculate(
        dateTime: probeDate,
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.month,
      );
      expect(
        _allPalaceNames(controller.panData!),
        contains('文昌·月限定'),
        reason: 'AC10 chartTypes: chartTypes=[month] 必须出现在 month 盘',
      );

      controller.dispose();
      await db.close();
    });
  });
}
