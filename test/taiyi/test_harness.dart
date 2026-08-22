import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistence_drift/taiyishenshu/taiyishenshu_drift.dart';
import 'package:persistence_assets/taiyishenshu/taiyishenshu_assets.dart';
import 'package:persistence_preferences/taiyishenshu/taiyishenshu_preferences.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart' show TaiyiRecordRepository, TaiyiDivinationRecordContract;
import 'fakes/memory_school_repository.dart';
import 'fakes/taiyi_contract_adapters.dart';

/// A shared test harness for TaiYiShenShu BDD/UI tests.
class TaiYiTestHarness {
  static final Map<String, String> _mockAssets = {};
  static bool _initialized = false;

  static Future<void> setup() async {
    if (_initialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = _FakePathProviderPlatform();

    // 太乙主题已不依赖 GoogleFonts；统一使用系统/Flutter 内置字体,
    // 测试无需注入 FontManifest 或字体替换开关。

    // Load actual JSON assets into memory for MockAssetBundle
    // Note: We use camelCase IDs in code but assets are kebab-case
    final schoolAssets = ['jing-mirror', 'tong-zong', 'ji-cheng'];
    for (final id in schoolAssets) {
      final path = 'assets/schools/$id.json';
      final bundlePath = 'packages/taiyishenshu/assets/schools/$id.json';
      _mockAssets[bundlePath] = File(path).readAsStringSync();
    }
    
    final deityAssets = [
      'tai-yi', 'zhu-da-jiang', 'ke-da-jiang', 'zhu-can-jiang', 'ke-can-jiang',
      'ding-da-jiang', 'ding-can-jiang', 'jun-ji', 'chen-ji', 'min-ji',
      'wu-fu', 'da-you', 'xiao-you', 'fei-fu', 'si-shen',
      'tian-yi-star', 'di-yi', 'zhi-fu-star', 'yang-jiu', 'bai-liu',
      'tai-sui', 'sui-po', 'zhi-fu', 'he-shen',
      'qing-long', 'zhu-que', 'bai-hu', 'xuan-wu', 'feng-bo', 'yu-shi',
      'qing-long-qi', 'hei-qi', 'chi-qi', 'gui-shen-zhi-shi',
      'wen-chang', 'ji-shen', 'shi-ji',
      'tian-huang', 'zi-wei', 'she-ti', 'xuan-yuan', 'zhao-yao',
      'tian-fu', 'xian-chi', 'jiang-gong', 'ming-tang', 'yu-tang',
    ];
    for (final id in deityAssets) {
      final path = 'assets/deities/$id.json';
      final bundlePath = 'packages/taiyishenshu/assets/deities/$id.json';
      _mockAssets[bundlePath] = File(path).readAsStringSync();
    }

    _initialized = true;
  }

  static MockAssetBundle createMockBundle() => MockAssetBundle(_mockAssets);

  static Future<TaiYiDataAssembly> createAssembly({Map<String, Object>? initialPrefs}) async {
    final bundle = createMockBundle();

    final officialMemoryRepo = MemorySchoolRepository();
    final userMemoryRepo = MemorySchoolRepository();

    // Pre-populate officialMemoryRepo with official schools from mock assets
    final schoolAssets = ['jing-mirror', 'tong-zong', 'ji-cheng'];
    for (final id in schoolAssets) {
      final path = 'assets/schools/$id.json';
      final bundlePath = 'packages/taiyishenshu/assets/schools/$id.json';
      final jsonStr = _mockAssets[bundlePath];
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr);
        final school = TaiYiSchool.fromJson(json);
        await officialMemoryRepo.saveSchool(school);
      }
    }

    // Pre-populate officialMemoryRepo with official deities from mock assets
    final deityAssets = [
      'tai-yi', 'zhu-da-jiang', 'ke-da-jiang', 'zhu-can-jiang', 'ke-can-jiang',
      'ding-da-jiang', 'ding-can-jiang', 'jun-ji', 'chen-ji', 'min-ji',
      'wu-fu', 'da-you', 'xiao-you', 'fei-fu', 'si-shen',
      'tian-yi-star', 'di-yi', 'zhi-fu-star', 'yang-jiu', 'bai-liu',
      'tai-sui', 'sui-po', 'zhi-fu', 'he-shen',
      'qing-long', 'zhu-que', 'bai-hu', 'xuan-wu', 'feng-bo', 'yu-shi',
      'qing-long-qi', 'hei-qi', 'chi-qi', 'gui-shen-zhi-shi',
      'wen-chang', 'ji-shen', 'shi-ji',
      'tian-huang', 'zi-wei', 'she-ti', 'xuan-yuan', 'zhao-yao',
      'tian-fu', 'xian-chi', 'jiang-gong', 'ming-tang', 'yu-tang',
    ];
    for (final id in deityAssets) {
      final path = 'assets/deities/$id.json';
      final bundlePath = 'packages/taiyishenshu/assets/deities/$id.json';
      final jsonStr = _mockAssets[bundlePath];
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr);
        final deity = DeityDefinition.fromJson(json);
        await officialMemoryRepo.saveDeity(deity);
      }
    }

    return TaiYiDataAssembly(
      officialRepo: officialMemoryRepo,
      userRepo: userMemoryRepo,
      deityRepo: userMemoryRepo,
      preferenceRepo: DummyDeityPreferenceRepository(),
      recordRepo: FakeTaiyiRecordRepository(),
    );
  }

  /// Create assembly from explicit bundle/prefs/db (for integration tests).
  static Future<TaiYiDataAssembly> createAssemblyFrom({
    required AssetBundle bundle,
    required SharedPreferences prefs,
    required dynamic db,
  }) async {
    final officialRepo = OfficialJsonSchoolRepository(
      schoolIds: ['jingMirror', 'tongZong', 'jiCheng'],
      deityIds: [
        'taiYi', 'zhuDaJiang', 'keDaJiang', 'zhuCanJiang', 'keCanJiang',
        'dingDaJiang', 'dingCanJiang', 'junJi', 'chenJi', 'minJi',
        'wuFu', 'daYou', 'xiaoYou', 'feiFu', 'siShen',
        'tianYiStar', 'diYi', 'zhiFuStar', 'yangJiu', 'baiLiu',
        'taiSui', 'suiPo', 'zhiFu', 'heShen',
        'qingLong', 'zhuQue', 'baiHu', 'xuanWu', 'fengBo', 'yuShi',
        'qingLongQi', 'heiQi', 'chiQi', 'guiShenZhiShi',
        'wenChang', 'jiShen', 'shiJi',
        'tianHuang', 'ziWei', 'sheTi', 'xuanYuan', 'zhaoYao',
        'tianFu', 'xianChi', 'jiangGong', 'mingTang', 'yuTang',
      ],
      bundle: bundle,
    );
    final userRepo = DriftUserRepository(db);
    final prefRepo = SharedPreferencesDeityPreferenceRepository(prefs);

    // Wrap contract repos into product-typed ports
    final productOfficial = ContractOfficialSchoolAdapter(officialRepo);
    final productUser = ContractUserSchoolAdapter(userRepo);
    final productDeity = ContractDeityAdapter(userRepo);
    final productPreference = SharedPreferenceAdapter(prefRepo);

    return TaiYiDataAssembly(
      officialRepo: productOfficial,
      userRepo: productUser,
      deityRepo: productDeity,
      preferenceRepo: productPreference,
      recordRepo: FakeTaiyiRecordRepository(),
    );
  }

  static Future<void> dispose() async {
    // Nothing to dispose with in-memory fakes
  }
}

class _FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getApplicationSupportPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getLibraryPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getApplicationDocumentsPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getExternalStoragePath() async => Directory.systemTemp.path;
  @override
  Future<List<String>?> getExternalCachePaths() async => [Directory.systemTemp.path];
  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async => [Directory.systemTemp.path];
  @override
  Future<String?> getDownloadsPath() async => Directory.systemTemp.path;
}

class MockAssetBundle extends Fake implements AssetBundle {
  final Map<String, String> assets;
  MockAssetBundle(this.assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) return assets[key]!;
    if (key.contains('AssetManifest')) return '{}';
    throw FlutterError('Asset not found in MockAssetBundle: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    if (assets.containsKey(key)) {
      return ByteData.view(Uint8List.fromList(utf8.encode(assets[key]!)).buffer);
    }
    if (key.contains('AssetManifest')) return ByteData(0);
    throw FlutterError('Asset not found in MockAssetBundle: $key');
  }
}

class FakeTaiyiRecordRepository implements TaiyiRecordRepository {
  @override
  Future<Result<Rev>> put(TaiyiDivinationRecordContract entity, RequestContext ctx, {Precondition pre = const Unconditional()}) async => const Ok(Rev('rev_1'));

  @override
  Future<Result<Page<TaiyiDivinationRecordContract>>> query(Map<String, Object?> spec, PageRequest page, RequestContext ctx) async => const Ok(Page(items: []));

  @override
  Future<Result<TaiyiDivinationRecordContract?>> get(String id, RequestContext ctx) async => const Ok(null);

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async => const Ok(false);

  @override
  Future<Result<void>> softDelete(String id, RequestContext ctx, {Precondition pre = const Unconditional()}) async => const Ok(null);

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async => const Ok(null);

  @override
  Future<Result<TaiyiDivinationRecordContract?>> getIncludingDeleted(String id, RequestContext ctx) async => const Ok(null);

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async => const Ok(0);

  @override
  Stream<Result<List<TaiyiDivinationRecordContract>>> watch(Map<String, Object?> spec, RequestContext ctx) => Stream.value(const Ok([]));

  @override
  Future<Result<BatchOutcome<String>>> putAll(List<TaiyiDivinationRecordContract> entities, RequestContext ctx) async => const Ok(BatchOutcome([]));

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async => Ok(await body());
}
