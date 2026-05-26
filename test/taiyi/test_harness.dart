import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';
import 'package:taiyishenshu/database/taiyi_database.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A shared test harness for TaiYiShenShu BDD/UI tests.
class TaiYiTestHarness {
  static final Map<String, String> _mockAssets = {};
  static bool _initialized = false;
  static TaiYiDatabase? _db;

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
    SharedPreferences.setMockInitialValues(initialPrefs ?? {});
    final prefs = await SharedPreferences.getInstance();
    
    // Ensure clean DB for each assembly in tests
    if (_db != null) {
      await _db!.close();
    }
    _db = TaiYiDatabase.memory();
    
    return TaiYiDataAssembly.test(
      bundle: createMockBundle(),
      prefs: prefs,
      db: _db,
    );
  }

  static Future<void> dispose() async {
    await _db?.close();
    _db = null;
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
