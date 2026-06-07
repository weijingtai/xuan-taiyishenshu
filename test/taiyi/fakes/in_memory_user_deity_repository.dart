import 'package:meta/meta.dart';

import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';

/// 测试专用的内存用户星神 Repository。
///
/// **严禁在生产装配 (TaiYiDataAssembly) 中引用本类。**
/// 生产入口应使用 DriftUserRepository。
@visibleForTesting
class InMemoryUserDeityRepository implements DeityRepository {
  final Map<String, DeityDefinition> _store = {};

  @override
  Future<List<DeityDefinition>> loadUserDeities() async {
    return _store.values.toList();
  }

  @override
  Future<DeityDefinition?> loadDeity(String id) async {
    return _store[id];
  }

  @override
  Future<void> saveUserDeity(DeityDefinition deity) async {
    _store[deity.id] = deity;
  }

  @override
  Future<void> deleteUserDeity(String id) async {
    _store.remove(id);
  }
}
