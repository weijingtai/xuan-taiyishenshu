import '../core/school_repository.dart';
import '../core/school_config.dart';

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
