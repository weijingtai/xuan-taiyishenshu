import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';

class FakeSchoolRepository implements SchoolRepository {
  @override
  Future<void> deleteDeity(String id) async {}
  @override
  Future<void> deleteSchool(String id) async {}
  @override
  Future<List<DeityDefinitionContract>> loadAllDeities() async => [];
  @override
  Future<DeityDefinitionContract?> loadDeity(String id) async => null;
  @override
  Future<List<TaiYiSchoolContract>> loadAllSchools() async => [];
  @override
  Future<TaiYiSchoolContract?> loadSchool(String id) async => null;
  @override
  Future<void> saveDeity(DeityDefinitionContract deity) async {}
  @override
  Future<void> saveSchool(TaiYiSchoolContract school) async {}
}

class FakeUserSchoolRepository implements UserSchoolRepository {
  @override
  Future<void> deleteUserSchool(String id) async {}
  @override
  Future<TaiYiSchoolContract?> loadSchool(String id) async => null;
  @override
  Future<List<TaiYiSchoolContract>> loadUserSchools() async => [];
  @override
  Future<void> saveUserSchool(TaiYiSchoolContract school) async {}
}

class FakeDeityRepository implements DeityRepository {
  @override
  Future<void> deleteUserDeity(String id) async {}
  @override
  Future<DeityDefinitionContract?> loadDeity(String id) async => null;
  @override
  Future<List<DeityDefinitionContract>> loadUserDeities() async => [];
  @override
  Future<void> saveUserDeity(DeityDefinitionContract deity) async {}
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
