import 'package:meta/meta.dart';

import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';

/// 测试专用的内存用户流派 Repository。
///
/// **严禁在生产装配 (TaiYiDataAssembly) 中引用本类。**
/// 生产入口应使用 DriftUserRepository。
@visibleForTesting
class InMemoryUserSchoolRepository implements UserSchoolRepository {
  final Map<String, TaiYiSchool> _store = {};

  @override
  Future<List<TaiYiSchool>> loadUserSchools() async {
    return _store.values.toList();
  }

  @override
  Future<TaiYiSchool?> loadSchool(String id) async {
    return _store[id];
  }

  @override
  Future<void> saveUserSchool(TaiYiSchool school) async {
    _store[school.id] = school;
  }

  @override
  Future<void> deleteUserSchool(String id) async {
    _store.remove(id);
  }
}
