import 'package:meta/meta.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
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
      guaSequence: kTaiYiGuaSequence.map((g) => g.name).toList(),
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

  // ── L0 slice methods ──

  @override
  Future<Result<MingGuaConfigContract?>> get(String id, RequestContext ctx) async =>
      throwOnLoad ? throw Exception('forced error') : Ok(_configs[id]);

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async =>
      Ok(_configs.containsKey(id));

  @override
  Future<Result<Rev>> put(
    MingGuaConfigContract entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    _configs[entity.id] = entity;
    return const Ok(Rev('rev_1'));
  }

  @override
  Future<Result<Page<MingGuaConfigContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async => Ok(Page(items: _configs.values.toList()));

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async =>
      Ok(_configs.length);

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    final r = await body();
    return Ok(r);
  }
}
