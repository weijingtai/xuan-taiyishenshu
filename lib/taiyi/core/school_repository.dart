import 'school_config.dart';
import 'deity_definition.dart';

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
