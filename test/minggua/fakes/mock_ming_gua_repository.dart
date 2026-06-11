import 'package:meta/meta.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/minggua/core/gua_sequence.dart';

/// 测试专用的内存 MingGuaRepository。
///
/// **严禁在生产装配中引用本类。**
/// 生产入口应使用 Drift / JSON 等持久化实现。
@visibleForTesting
class MockMingGuaRepository implements MingGuaRepository {
  MockMingGuaRepository({this.throwOnLoad = false}) {
    // Pre-load the default 统宗 config.
    final defaultConfig = MingGuaConfigContract(
      id: 'tongZong',
      name: '统宗宝鉴',
      epochBase: 10153917,
      guaSequence: kTaiYiGuaSequence,
      dongYaoRule: 'standard',
      source: 'official',
    );
    _configs[defaultConfig.id] = defaultConfig;
  }

  final bool throwOnLoad;
  final Map<String, MingGuaConfigContract> _configs = {};

  @override
  Future<List<MingGuaConfigContract>> loadAllConfigs() async {
    if (throwOnLoad) {
      throw Exception('MockMingGuaRepository: loadAllConfigs forced error');
    }
    return _configs.values.toList();
  }

  @override
  Future<MingGuaConfigContract?> loadConfig(String id) async {
    if (throwOnLoad) {
      throw Exception('MockMingGuaRepository: loadConfig forced error');
    }
    return _configs[id];
  }

  @override
  Future<void> saveConfig(MingGuaConfigContract config) async {
    _configs[config.id] = config;
  }

  @override
  Future<void> deleteConfig(String id) async {
    _configs.remove(id);
  }
}
