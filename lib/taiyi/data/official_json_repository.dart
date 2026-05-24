import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import '../core/school_repository.dart';
import '../core/school_config.dart';
import '../core/deity_definition.dart';

class OfficialJsonSchoolRepository implements SchoolRepository {
  final List<String> schoolIds;
  final List<String> deityIds;
  final AssetBundle bundle;

  OfficialJsonSchoolRepository({
    required this.schoolIds,
    required this.deityIds,
    AssetBundle? bundle,
  }) : bundle = bundle ?? rootBundle;

  final Map<String, TaiYiSchool> _schools = {};
  final Map<String, DeityDefinition> _deities = {};
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    for (final id in schoolIds) {
      try {
        final jsonStr = await bundle.loadString('assets/schools/$id.json');
        final json = jsonDecode(jsonStr);
        _schools[id] = TaiYiSchool.fromJson(json);
      } catch (e) {
        // Log or handle missing asset
        debugPrint('Warning: school asset not found for $id');
      }
    }

    for (final id in deityIds) {
      try {
        final jsonStr = await bundle.loadString('assets/deities/$id.json');
        final json = jsonDecode(jsonStr);
        _deities[id] = DeityDefinition.fromJson(json);
      } catch (e) {
        debugPrint('Warning: deity asset not found for $id');
      }
    }

    _loaded = true;
  }

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async {
    await _ensureLoaded();
    return _schools.values.toList();
  }

  @override
  Future<TaiYiSchool?> loadSchool(String id) async {
    await _ensureLoaded();
    return _schools[id];
  }

  @override
  Future<List<DeityDefinition>> loadAllDeities() async {
    await _ensureLoaded();
    return _deities.values.toList();
  }

  @override
  Future<DeityDefinition?> loadDeity(String id) async {
    await _ensureLoaded();
    return _deities[id];
  }

  @override
  Future<void> saveSchool(TaiYiSchool school) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> saveDeity(DeityDefinition deity) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> deleteSchool(String id) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> deleteDeity(String id) =>
      throw UnsupportedError('Official repository is read-only');
}
