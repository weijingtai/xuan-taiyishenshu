import 'dart:convert';
import 'package:drift/drift.dart';
import '../../database/taiyi_database.dart';
import '../core/school_repository.dart';
import '../core/school_config.dart';
import '../core/deity_definition.dart';

class DriftUserRepository implements SchoolRepository, UserSchoolRepository, DeityRepository {
  final TaiYiDatabase db;

  DriftUserRepository(this.db);

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async {
    final rows = await db.select(db.userSchools).get();
    return rows.map((row) => TaiYiSchool.fromJson(jsonDecode(row.contentJson))).toList();
  }

  @override
  Future<List<TaiYiSchool>> loadUserSchools() async => loadAllSchools();

  @override
  Future<TaiYiSchool?> loadSchool(String id) async {
    final row = await (db.select(db.userSchools)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return TaiYiSchool.fromJson(jsonDecode(row.contentJson));
  }

  @override
  Future<List<DeityDefinition>> loadAllDeities() async {
    final rows = await db.select(db.userDeities).get();
    return rows.map((row) => DeityDefinition.fromJson(jsonDecode(row.contentJson))).toList();
  }

  @override
  Future<List<DeityDefinition>> loadUserDeities() async => loadAllDeities();

  @override
  Future<DeityDefinition?> loadDeity(String id) async {
    final row = await (db.select(db.userDeities)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return DeityDefinition.fromJson(jsonDecode(row.contentJson));
  }

  @override
  Future<void> saveSchool(TaiYiSchool school) async {
    await db.into(db.userSchools).insertOnConflictUpdate(
      UserSchoolsCompanion(
        id: Value(school.id),
        name: Value(school.name),
        source: Value(school.source),
        contentJson: Value(jsonEncode(school.toJson())),
      ),
    );
  }

  @override
  Future<void> saveUserSchool(TaiYiSchool school) async => saveSchool(school);

  @override
  Future<void> saveDeity(DeityDefinition deity) async {
    await db.into(db.userDeities).insertOnConflictUpdate(
      UserDeitiesCompanion(
        id: Value(deity.id),
        name: Value(deity.name),
        source: Value(deity.source),
        contentJson: Value(jsonEncode(deity.toJson())),
      ),
    );
  }

  @override
  Future<void> saveUserDeity(DeityDefinition deity) async => saveDeity(deity);

  @override
  Future<void> deleteSchool(String id) async {
    await (db.delete(db.userSchools)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> deleteUserSchool(String id) async => deleteSchool(id);

  @override
  Future<void> deleteDeity(String id) async {
    await (db.delete(db.userDeities)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> deleteUserDeity(String id) async => deleteDeity(id);
}
