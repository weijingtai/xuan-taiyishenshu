import '../core/school_repository.dart';
import '../core/deity_definition.dart';

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
