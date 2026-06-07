import 'package:meta/meta.dart';

import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';

/// 测试专用的内存 Repository。
///
/// **严禁在生产装配 (TaiYiDataAssembly) 中引用本类。**
/// 生产入口应使用 Drift + OfficialJson + SharedPreferences。
@visibleForTesting
class MemorySchoolRepository implements SchoolRepository, UserSchoolRepository, DeityRepository {
  final Map<String, TaiYiSchool> _schools = {};
  final Map<String, DeityDefinition> _deities = {};

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async {
    return _schools.values.toList();
  }

  @override
  Future<List<TaiYiSchool>> loadUserSchools() async {
    return _schools.values.toList();
  }

  @override
  Future<TaiYiSchool?> loadSchool(String id) async {
    return _schools[id];
  }

  @override
  Future<List<DeityDefinition>> loadAllDeities() async {
    return _deities.values.toList();
  }

  @override
  Future<List<DeityDefinition>> loadUserDeities() async {
    return _deities.values.toList();
  }

  @override
  Future<DeityDefinition?> loadDeity(String id) async {
    return _deities[id];
  }

  @override
  Future<void> saveSchool(TaiYiSchool school) async {
    _schools[school.id] = school;
  }

  @override
  Future<void> saveUserSchool(TaiYiSchool school) async {
    _schools[school.id] = school;
  }

  @override
  Future<void> saveDeity(DeityDefinition deity) async {
    _deities[deity.id] = deity;
  }

  @override
  Future<void> saveUserDeity(DeityDefinition deity) async {
    _deities[deity.id] = deity;
  }

  @override
  Future<void> deleteSchool(String id) async {
    _schools.remove(id);
  }

  @override
  Future<void> deleteUserSchool(String id) async {
    _schools.remove(id);
  }

  @override
  Future<void> deleteDeity(String id) async {
    _deities.remove(id);
  }

  @override
  Future<void> deleteUserDeity(String id) async {
    _deities.remove(id);
  }
}
