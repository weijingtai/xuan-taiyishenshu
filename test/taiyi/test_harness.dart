import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart'
    as contract;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'fakes/memory_school_repository.dart';

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
      _mockAssets[path] = File(path).readAsStringSync();
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
    ];
    for (final id in deityAssets) {
      final path = 'assets/deities/$id.json';
      _mockAssets[path] = File(path).readAsStringSync();
    }

    _initialized = true;
  }

  static MockAssetBundle createMockBundle() => MockAssetBundle(_mockAssets);

  static Future<TaiYiDataAssembly> createAssembly({Map<String, Object>? initialPrefs}) async {
    final bundle = createMockBundle();

    final memoryRepo = MemorySchoolRepository();

    return TaiYiDataAssembly(
      officialRepo: _ContractSchoolFake(memoryRepo),
      userRepo: _ContractUserSchoolFake(memoryRepo),
      deityRepo: _ContractDeityFake(memoryRepo),
      preferenceRepo: contract.DummyDeityPreferenceRepository(),
    );
  }

  static Future<void> dispose() async {
    // Nothing to dispose with in-memory fakes
  }
}

// ---------------------------------------------------------------------------
// Contract wrappers — adapt MemorySchoolRepository (product-side) to
// contract-typed interfaces required by TaiYiDataAssembly constructor.
// ---------------------------------------------------------------------------

class _ContractSchoolFake implements contract.SchoolRepository {
  final MemorySchoolRepository _inner;
  _ContractSchoolFake(this._inner);

  @override
  Future<List<contract.TaiYiSchoolContract>> loadAllSchools() async =>
      (await _inner.loadAllSchools()).map((s) => s.toContract()).toList();

  @override
  Future<contract.TaiYiSchoolContract?> loadSchool(String id) async =>
      (await _inner.loadSchool(id))?.toContract();

  @override
  Future<List<contract.DeityDefinitionContract>> loadAllDeities() async =>
      (await _inner.loadAllDeities()).map((d) => d.toContract()).toList();

  @override
  Future<contract.DeityDefinitionContract?> loadDeity(String id) async =>
      (await _inner.loadDeity(id))?.toContract();

  @override
  Future<void> saveSchool(contract.TaiYiSchoolContract school) async =>
      _inner.saveSchool(school.toModel());

  @override
  Future<void> saveDeity(contract.DeityDefinitionContract deity) async =>
      _inner.saveDeity(deity.toModel());

  @override
  Future<void> deleteSchool(String id) => _inner.deleteSchool(id);

  @override
  Future<void> deleteDeity(String id) => _inner.deleteDeity(id);
}

class _ContractUserSchoolFake implements contract.UserSchoolRepository {
  final MemorySchoolRepository _inner;
  _ContractUserSchoolFake(this._inner);

  @override
  Future<List<contract.TaiYiSchoolContract>> loadUserSchools() async =>
      (await _inner.loadUserSchools()).map((s) => s.toContract()).toList();

  @override
  Future<contract.TaiYiSchoolContract?> loadSchool(String id) async =>
      (await _inner.loadSchool(id))?.toContract();

  @override
  Future<void> saveUserSchool(contract.TaiYiSchoolContract school) async =>
      _inner.saveUserSchool(school.toModel());

  @override
  Future<void> deleteUserSchool(String id) => _inner.deleteUserSchool(id);
}

class _ContractDeityFake implements contract.DeityRepository {
  final MemorySchoolRepository _inner;
  _ContractDeityFake(this._inner);

  @override
  Future<List<contract.DeityDefinitionContract>> loadUserDeities() async =>
      (await _inner.loadUserDeities()).map((d) => d.toContract()).toList();

  @override
  Future<contract.DeityDefinitionContract?> loadDeity(String id) async =>
      (await _inner.loadDeity(id))?.toContract();

  @override
  Future<void> saveUserDeity(contract.DeityDefinitionContract deity) async =>
      _inner.saveUserDeity(deity.toModel());

  @override
  Future<void> deleteUserDeity(String id) => _inner.deleteUserDeity(id);
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
