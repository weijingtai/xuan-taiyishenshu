import 'package:meta/meta.dart';

import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';

/// 测试专用的内存 Repository。
///
/// **严禁在生产装配 (TaiYiDataAssembly.create) 中引用本类。**
/// 生产入口应使用 Drift + OfficialJson + SharedPreferences。
@visibleForTesting
class MemorySchoolRepository implements SchoolRepository, UserSchoolRepository, DeityRepository {
  final Map<String, TaiYiSchool> _schools = {};
  final Map<String, DeityDefinition> _deities = {};

  @override
  Future<List<TaiYiSchoolContract>> loadAllSchools() async {
    return _schools.values.map((s) => s.toContract()).toList();
  }

  @override
  Future<List<TaiYiSchoolContract>> loadUserSchools() async {
    return _schools.values.map((s) => s.toContract()).toList();
  }

  @override
  Future<TaiYiSchoolContract?> loadSchool(String id) async {
    return _schools[id]?.toContract();
  }

  @override
  Future<List<DeityDefinitionContract>> loadAllDeities() async {
    return _deities.values.map((d) => d.toContract()).toList();
  }

  @override
  Future<List<DeityDefinitionContract>> loadUserDeities() async {
    return _deities.values.map((d) => d.toContract()).toList();
  }

  @override
  Future<DeityDefinitionContract?> loadDeity(String id) async {
    return _deities[id]?.toContract();
  }

  @override
  Future<void> saveSchool(TaiYiSchoolContract school) async {
    final model = school.toModel();
    _schools[model.id] = model;
  }

  @override
  Future<void> saveUserSchool(TaiYiSchoolContract school) async {
    final model = school.toModel();
    _schools[model.id] = model;
  }

  @override
  Future<void> saveDeity(DeityDefinitionContract deity) async {
    final model = deity.toModel();
    _deities[model.id] = model;
  }

  @override
  Future<void> saveUserDeity(DeityDefinitionContract deity) async {
    final model = deity.toModel();
    _deities[model.id] = model;
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
