import 'school_config.dart';
import 'deity_definition.dart';
import 'chart_config.dart';
import 'deity_override.dart';
import 'algorithm_enums.dart';
import '../../enums/deity_kind.dart';

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

abstract class UserSchoolRepository {
Future<List<TaiYiSchool>> loadUserSchools();
Future<TaiYiSchool?> loadSchool(String id);
Future<void> saveUserSchool(TaiYiSchool school);
Future<void> deleteUserSchool(String id);
}

abstract class DeityRepository {
Future<List<DeityDefinition>> loadUserDeities();
Future<DeityDefinition?> loadDeity(String id);
Future<void> saveUserDeity(DeityDefinition deity);
Future<void> deleteUserDeity(String id);
}

/// Deity display preference repository (product-owned port).
abstract class DeityPreferenceRepository {
Future<bool> isEnabled(String deityId);
Future<void> setEnabled(String deityId, bool enabled);
Future<Map<String, bool>> loadEnabledMap();
}

/// Dummy implementation for testing.
class DummyDeityPreferenceRepository implements DeityPreferenceRepository {
@override
Future<bool> isEnabled(String deityId) async => true;
@override
Future<void> setEnabled(String deityId, bool enabled) async {}
@override
Future<Map<String, bool>> loadEnabledMap() async => {};
}
