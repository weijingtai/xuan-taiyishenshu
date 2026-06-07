import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';

class FakeSchoolRepository implements SchoolRepository {
  @override
  Future<void> deleteDeity(String id) async {}
  @override
  Future<void> deleteSchool(String id) async {}
  @override
  Future<List<DeityDefinition>> loadAllDeities() async => [];
  @override
  Future<DeityDefinition?> loadDeity(String id) async => null;
  @override
  Future<List<TaiYiSchool>> loadAllSchools() async => [];
  @override
  Future<TaiYiSchool?> loadSchool(String id) async => null;
  @override
  Future<void> saveDeity(DeityDefinition deity) async {}
  @override
  Future<void> saveSchool(TaiYiSchool school) async {}
}

class FakeUserSchoolRepository implements UserSchoolRepository {
  @override
  Future<void> deleteUserSchool(String id) async {}
  @override
  Future<TaiYiSchool?> loadSchool(String id) async => null;
  @override
  Future<List<TaiYiSchool>> loadUserSchools() async => [];
  @override
  Future<void> saveUserSchool(TaiYiSchool school) async {}
}

class FakeDeityRepository implements DeityRepository {
  @override
  Future<void> deleteUserDeity(String id) async {}
  @override
  Future<DeityDefinition?> loadDeity(String id) async => null;
  @override
  Future<List<DeityDefinition>> loadUserDeities() async => [];
  @override
  Future<void> saveUserDeity(DeityDefinition deity) async {}
}

void main() {
  test('TaiYiDataAssembly injects fake repositories successfully', () {
    final assembly = TaiYiDataAssembly(
      officialRepo: FakeSchoolRepository(),
      userRepo: FakeUserSchoolRepository(),
      deityRepo: FakeDeityRepository(),
      preferenceRepo: DummyDeityPreferenceRepository(),
    );

    expect(assembly.officialRepo, isA<FakeSchoolRepository>());
    expect(assembly.userRepo, isA<FakeUserSchoolRepository>());
    expect(assembly.deityRepo, isA<FakeDeityRepository>());
    expect(assembly.preferenceRepo, isA<DummyDeityPreferenceRepository>());
  });
}
