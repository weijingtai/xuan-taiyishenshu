import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';

/// 模拟官方资产仓库（只读）
class MockOfficialRepository implements SchoolRepository {
  final List<TaiYiSchool> schools;
  final List<DeityDefinition> deities;

  MockOfficialRepository({this.schools = const [], this.deities = const []});

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async => schools;

  @override
  Future<TaiYiSchool?> loadSchool(String id) async => 
      schools.firstWhere((s) => s.id == id);

  @override
  Future<List<DeityDefinition>> loadAllDeities() async => deities;

  @override
  Future<DeityDefinition?> loadDeity(String id) async =>
      deities.firstWhere((d) => d.id == id);

  @override
  Future<void> saveSchool(TaiYiSchool school) => throw UnsupportedError('Official assets are read-only');

  @override
  Future<void> saveDeity(DeityDefinition deity) => throw UnsupportedError('Official assets are read-only');

  @override
  Future<void> deleteSchool(String id) => throw UnsupportedError('Official assets are read-only');

  @override
  Future<void> deleteDeity(String id) => throw UnsupportedError('Official assets are read-only');
}

/// 模拟用户自定义资产仓库（读写）
class MockUserRepository implements SchoolRepository {
  final Map<String, TaiYiSchool> schools = {};
  final Map<String, DeityDefinition> deities = {};

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async => schools.values.toList();

  @override
  Future<TaiYiSchool?> loadSchool(String id) async => schools[id];

  @override
  Future<List<DeityDefinition>> loadAllDeities() async => deities.values.toList();

  @override
  Future<DeityDefinition?> loadDeity(String id) async => deities[id];

  @override
  Future<void> saveSchool(TaiYiSchool school) async => schools[school.id] = school;

  @override
  Future<void> saveDeity(DeityDefinition deity) async => deities[deity.id] = deity;

  @override
  Future<void> deleteSchool(String id) async => schools.remove(id);

  @override
  Future<void> deleteDeity(String id) async => deities.remove(id);
}

/// 模拟显示偏好仓库（读写）
class MockPreferenceRepository implements DeityPreferenceRepository {
  final Map<String, bool> preferences = {};

  @override
  Future<Map<String, bool>> loadEnabledMap() async => Map.from(preferences);

  @override
  Future<bool> isEnabled(String deityId) async => preferences[deityId] ?? true;

  @override
  Future<void> setEnabled(String deityId, bool enabled) async => preferences[deityId] = enabled;
}

/// 组合仓库，符合 UseCase 所需的单一入口接口
class MockCombinedRepository implements SchoolRepository {
  final List<SchoolRepository> delegates;

  MockCombinedRepository(this.delegates);

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async {
    final List<TaiYiSchool> all = [];
    for (var d in delegates) {
      all.addAll(await d.loadAllSchools());
    }
    return all;
  }

  @override
  Future<TaiYiSchool?> loadSchool(String id) async {
    for (var d in delegates) {
      final s = await d.loadSchool(id);
      if (s != null) return s;
    }
    return null;
  }

  @override
  Future<List<DeityDefinition>> loadAllDeities() async {
    final List<DeityDefinition> all = [];
    for (var d in delegates) {
      all.addAll(await d.loadAllDeities());
    }
    return all;
  }

  @override
  Future<DeityDefinition?> loadDeity(String id) async {
    for (var d in delegates) {
      final dDef = await d.loadDeity(id);
      if (dDef != null) return dDef;
    }
    return null;
  }

  @override
  Future<void> saveSchool(TaiYiSchool school) => throw UnsupportedError('Combined repository is read-only for save');
  @override
  Future<void> saveDeity(DeityDefinition deity) => throw UnsupportedError('Combined repository is read-only for save');
  @override
  Future<void> deleteSchool(String id) => throw UnsupportedError('Combined repository is read-only for delete');
  @override
  Future<void> deleteDeity(String id) => throw UnsupportedError('Combined repository is read-only for delete');
}
