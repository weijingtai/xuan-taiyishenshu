import 'package:meta/meta.dart';

import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';

/// 测试专用的内存用户流派 Repository。
///
/// **严禁在生产装配 (TaiYiDataAssembly.create) 中引用本类。**
/// 生产入口应使用 DriftUserRepository。
@visibleForTesting
class InMemoryUserSchoolRepository implements UserSchoolRepository {
  final Map<String, TaiYiSchool> _store = {};

  @override
  Future<List<TaiYiSchoolContract>> loadUserSchools() async {
    return _store.values.map((s) => s.toContract()).toList();
  }

  @override
  Future<TaiYiSchoolContract?> loadSchool(String id) async {
    return _store[id]?.toContract();
  }

  @override
  Future<void> saveUserSchool(TaiYiSchoolContract school) async {
    final model = school.toModel();
    _store[model.id] = model;
  }

  @override
  Future<void> deleteUserSchool(String id) async {
    _store.remove(id);
  }
}
