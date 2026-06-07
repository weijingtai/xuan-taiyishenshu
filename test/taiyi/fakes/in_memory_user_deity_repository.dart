import 'package:meta/meta.dart';

import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';

/// 测试专用的内存用户星神 Repository。
///
/// **严禁在生产装配 (TaiYiDataAssembly.create) 中引用本类。**
/// 生产入口应使用 DriftUserRepository。
@visibleForTesting
class InMemoryUserDeityRepository implements DeityRepository {
  final Map<String, DeityDefinition> _store = {};

  @override
  Future<List<DeityDefinitionContract>> loadUserDeities() async {
    return _store.values.map((d) => d.toContract()).toList();
  }

  @override
  Future<DeityDefinitionContract?> loadDeity(String id) async {
    return _store[id]?.toContract();
  }

  @override
  Future<void> saveUserDeity(DeityDefinitionContract deity) async {
    final model = deity.toModel();
    _store[model.id] = model;
  }

  @override
  Future<void> deleteUserDeity(String id) async {
    _store.remove(id);
  }
}
