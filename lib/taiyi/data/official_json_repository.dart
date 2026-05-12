import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../core/school_repository.dart';
import '../core/school_config.dart';
import '../core/deity_definition.dart';

class OfficialJsonSchoolRepository implements SchoolRepository {
  final List<String> _schoolIds;
  final List<String> _deityIds;
  Map<String, TaiYiSchool>? _schoolCache;
  Map<String, DeityDefinition>? _deityCache;

  OfficialJsonSchoolRepository({
    required List<String> schoolIds,
    required List<String> deityIds,
  })  : _schoolIds = schoolIds,
        _deityIds = deityIds;

  Future<void> _ensureLoaded() async {
    if (_schoolCache != null && _deityCache != null) return;

    _schoolCache = {};
    for (final id in _schoolIds) {
      final jsonStr = await rootBundle.loadString('assets/schools/$id.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      _schoolCache![id] = TaiYiSchool.fromJson(json);
    }

    _deityCache = {};
    for (final id in _deityIds) {
      final jsonStr = await rootBundle.loadString('assets/deities/$id.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      _deityCache![id] = DeityDefinition.fromJson(json);
    }
  }

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async {
    await _ensureLoaded();
    return _schoolCache!.values.toList();
  }

  @override
  Future<TaiYiSchool?> loadSchool(String id) async {
    await _ensureLoaded();
    return _schoolCache![id];
  }

  @override
  Future<List<DeityDefinition>> loadAllDeities() async {
    await _ensureLoaded();
    return _deityCache!.values.toList();
  }

  @override
  Future<DeityDefinition?> loadDeity(String id) async {
    await _ensureLoaded();
    return _deityCache![id];
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
