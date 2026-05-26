import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/school_repository.dart';

class SharedPreferencesDeityPreferenceRepository implements DeityPreferenceRepository {
  static const String _key = 'taiyi_deity_preferences';
  final SharedPreferences prefs;

  SharedPreferencesDeityPreferenceRepository(this.prefs);

  @override
  Future<bool> isEnabled(String deityId) async {
    final Map<String, bool> map = await loadEnabledMap();
    return map[deityId] ?? true;
  }

  @override
  Future<void> setEnabled(String deityId, bool enabled) async {
    final Map<String, bool> map = await loadEnabledMap();
    map[deityId] = enabled;
    await prefs.setString(_key, jsonEncode(map));
  }

  @override
  Future<Map<String, bool>> loadEnabledMap() async {
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      return {};
    }
  }
}
