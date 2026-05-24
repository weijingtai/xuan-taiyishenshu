import '../core/school_repository.dart';

class InMemoryDeityPreferenceRepository implements DeityPreferenceRepository {
  final Map<String, bool> _enabledMap = {};

  @override
  Future<bool> isEnabled(String deityId) async {
    return _enabledMap[deityId] ?? true; // default enabled
  }

  @override
  Future<void> setEnabled(String deityId, bool enabled) async {
    _enabledMap[deityId] = enabled;
  }

  @override
  Future<Map<String, bool>> loadEnabledMap() async {
    return Map<String, bool>.from(_enabledMap);
  }
}
