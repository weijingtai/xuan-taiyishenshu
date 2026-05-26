import 'school_config.dart';
import 'deity_definition.dart';

/// Combined repository interface (backward-compatible).
/// Existing tests and code depend on this exact shape.
abstract class SchoolRepository {
  Future<List<TaiYiSchool>> loadAllSchools();
  Future<TaiYiSchool?> loadSchool(String id);
  Future<List<DeityDefinition>> loadAllDeities();
  Future<DeityDefinition?> loadDeity(String id);
  Future<void> saveSchool(TaiYiSchool school);
  Future<void> saveDeity(DeityDefinition deity);
  Future<void> deleteSchool(String id);
  Future<void> deleteDeity(String id);
}

/// User school repository — stores user-created/modified schools.
abstract class UserSchoolRepository {
  Future<List<TaiYiSchool>> loadUserSchools();
  Future<TaiYiSchool?> loadSchool(String id);
  Future<void> saveUserSchool(TaiYiSchool school);
  Future<void> deleteUserSchool(String id);
}

/// Deity repository — stores user-created/modified deities.
abstract class DeityRepository {
  Future<List<DeityDefinition>> loadUserDeities();
  Future<DeityDefinition?> loadDeity(String id);
  Future<void> saveUserDeity(DeityDefinition deity);
  Future<void> deleteUserDeity(String id);
}

/// Deity display preference repository.
abstract class DeityPreferenceRepository {
  Future<bool> isEnabled(String deityId);
  Future<void> setEnabled(String deityId, bool enabled);
  Future<Map<String, bool>> loadEnabledMap();
}

class DummyDeityPreferenceRepository implements DeityPreferenceRepository {
  @override
  Future<bool> isEnabled(String deityId) async => true;
  @override
  Future<void> setEnabled(String deityId, bool enabled) async {}
  @override
  Future<Map<String, bool>> loadEnabledMap() async => {};
}

