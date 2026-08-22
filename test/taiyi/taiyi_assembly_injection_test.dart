import 'package:flutter_test/flutter_test.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart' show TaiyiRecordRepository, TaiyiDivinationRecordContract;

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

class FakeTaiyiRecordRepository implements TaiyiRecordRepository {
  @override
  Future<Result<Rev>> put(TaiyiDivinationRecordContract entity, RequestContext ctx, {Precondition pre = const Unconditional()}) async => const Ok(Rev('rev_1'));

  @override
  Future<Result<Page<TaiyiDivinationRecordContract>>> query(Map<String, Object?> spec, PageRequest page, RequestContext ctx) async => const Ok(Page(items: []));

  @override
  Future<Result<TaiyiDivinationRecordContract?>> get(String id, RequestContext ctx) async => const Ok(null);

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async => const Ok(false);

  @override
  Future<Result<void>> softDelete(String id, RequestContext ctx, {Precondition pre = const Unconditional()}) async => const Ok(null);

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async => const Ok(null);

  @override
  Future<Result<TaiyiDivinationRecordContract?>> getIncludingDeleted(String id, RequestContext ctx) async => const Ok(null);

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async => const Ok(0);

  @override
  Stream<Result<List<TaiyiDivinationRecordContract>>> watch(Map<String, Object?> spec, RequestContext ctx) => Stream.value(const Ok([]));

  @override
  Future<Result<BatchOutcome<String>>> putAll(List<TaiyiDivinationRecordContract> entities, RequestContext ctx) async => const Ok(BatchOutcome([]));

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async => Ok(await body());
}

void main() {
  test('TaiYiDataAssembly injects fake repositories successfully', () {
    final assembly = TaiYiDataAssembly(
      officialRepo: FakeSchoolRepository(),
      userRepo: FakeUserSchoolRepository(),
      deityRepo: FakeDeityRepository(),
      preferenceRepo: DummyDeityPreferenceRepository(),
      recordRepo: FakeTaiyiRecordRepository(),
    );

    expect(assembly.officialRepo, isA<FakeSchoolRepository>());
    expect(assembly.userRepo, isA<FakeUserSchoolRepository>());
    expect(assembly.deityRepo, isA<FakeDeityRepository>());
    expect(assembly.preferenceRepo, isA<DummyDeityPreferenceRepository>());
    expect(assembly.recordRepo, isA<FakeTaiyiRecordRepository>());
  });
}
