import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/taiyi/usecases/load_schools_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/save_user_school_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/copy_school_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/load_deities_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/save_user_deity_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/copy_deity_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/deity_availability_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/toggle_deity_preference_usecase.dart';
import '../fakes/in_memory_user_school_repository.dart';
import '../fakes/in_memory_user_deity_repository.dart';
import '../fakes/in_memory_deity_preference_repository.dart';

// Minimal mock for SchoolRepository (official, read-only)
class MockOfficialSchoolRepo implements SchoolRepository {
  final List<TaiYiSchool> schools;
  final List<DeityDefinition> deities;

  MockOfficialSchoolRepo({this.schools = const [], this.deities = const []});

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async => schools;
  @override
  Future<TaiYiSchool?> loadSchool(String id) async =>
      schools.where((s) => s.id == id).firstOrNull;
  @override
  Future<List<DeityDefinition>> loadAllDeities() async => deities;
  @override
  Future<DeityDefinition?> loadDeity(String id) async =>
      deities.where((d) => d.id == id).firstOrNull;
  @override
  Future<void> saveSchool(TaiYiSchool school) =>
      throw UnsupportedError('read-only');
  @override
  Future<void> saveDeity(DeityDefinition deity) =>
      throw UnsupportedError('read-only');
  @override
  Future<void> deleteSchool(String id) =>
      throw UnsupportedError('read-only');
  @override
  Future<void> deleteDeity(String id) =>
      throw UnsupportedError('read-only');
}

const _epoch = SchoolEpochConfig(ancientBase: 100, epochYear: 200);
const _officialSchool = TaiYiSchool(
  id: 'jingMirror',
  name: '金镜派',
  epoch: _epoch,
  source: 'official',
  deityIds: ['taiYi', 'junJi'],
);
const _officialDeity = DeityDefinition(
  id: 'taiYi',
  name: '太乙',
  layer: EnumDeityLayer.tianPan,
  algorithm: DeityAlgorithmSpec(
    templateId: AlgorithmTemplateId.steppedCycle,
  ),
  source: 'official',
);

void main() {
  group('LoadSchoolsUseCase', () {
    test('merges official and user schools', () async {
      final official = MockOfficialSchoolRepo(schools: [_officialSchool]);
      final userRepo = InMemoryUserSchoolRepository();
      await userRepo.saveUserSchool(const TaiYiSchool(
        id: 'user_1',
        name: '用户派',
        epoch: _epoch,
        source: 'user',
      ));

      final useCase = LoadSchoolsUseCase(official, userRepo);
      final result = await useCase();
      expect(result.length, 2);
      expect(result.map((s) => s.id), containsAll(['jingMirror', 'user_1']));
    });
  });

  group('SaveUserSchoolUseCase', () {
    test('saves to user repo', () async {
      final userRepo = InMemoryUserSchoolRepository();
      final useCase = SaveUserSchoolUseCase(userRepo);
      await useCase(const TaiYiSchool(
        id: 'saved',
        name: '保存的',
        epoch: _epoch,
        source: 'user',
      ));
      final loaded = await userRepo.loadSchool('saved');
      expect(loaded, isNotNull);
      expect(loaded!.name, '保存的');
    });
  });

  group('CopySchoolUseCase', () {
    test('copies official school', () async {
      final official = MockOfficialSchoolRepo(schools: [_officialSchool]);
      final userRepo = InMemoryUserSchoolRepository();
      final useCase = CopySchoolUseCase(official, userRepo);

      final copied = await useCase(
        sourceId: 'jingMirror',
        newId: 'user_jm',
        newName: '我的金镜派',
      );

      expect(copied.id, 'user_jm');
      expect(copied.name, '我的金镜派');
      expect(copied.source, 'user');

      // Should be saved in user repo
      final saved = await userRepo.loadSchool('user_jm');
      expect(saved, isNotNull);
    });

    test('throws for non-existent source', () async {
      final official = MockOfficialSchoolRepo();
      final userRepo = InMemoryUserSchoolRepository();
      final useCase = CopySchoolUseCase(official, userRepo);

      expect(
        () => useCase(sourceId: 'nonexistent', newId: 'x'),
        throwsArgumentError,
      );
    });
  });

  group('LoadDeitiesUseCase', () {
    test('merges official and user deities', () async {
      final official = MockOfficialSchoolRepo(deities: [_officialDeity]);
      final userRepo = InMemoryUserDeityRepository();
      await userRepo.saveUserDeity(const DeityDefinition(
        id: 'custom',
        name: '自定义',
        layer: EnumDeityLayer.diPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.fixedPosition,
        ),
        source: 'user',
      ));

      final useCase = LoadDeitiesUseCase(official, userRepo);
      final result = await useCase();
      expect(result.length, 2);
    });
  });

  group('SaveUserDeityUseCase', () {
    test('saves to user repo', () async {
      final userRepo = InMemoryUserDeityRepository();
      final useCase = SaveUserDeityUseCase(userRepo);
      await useCase(const DeityDefinition(
        id: 'saved_deity',
        name: '保存的星神',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.steppedCycle,
        ),
        source: 'user',
      ));
      expect(await userRepo.loadDeity('saved_deity'), isNotNull);
    });
  });

  group('CopyDeityUseCase', () {
    test('copies official deity with lineage', () async {
      final official = MockOfficialSchoolRepo(deities: [_officialDeity]);
      final userRepo = InMemoryUserDeityRepository();
      final useCase = CopyDeityUseCase(official, userRepo);

      final copied = await useCase(
        sourceId: 'taiYi',
        newId: 'user_taiYi',
        newName: '我的太乙',
      );

      expect(copied.id, 'user_taiYi');
      expect(copied.source, 'user');
      expect(copied.description, contains('太乙'));
    });

    test('throws for non-existent deity', () async {
      final official = MockOfficialSchoolRepo();
      final userRepo = InMemoryUserDeityRepository();
      final useCase = CopyDeityUseCase(official, userRepo);

      expect(
        () => useCase(sourceId: 'nope', newId: 'x'),
        throwsArgumentError,
      );
    });
  });

  group('DeityAvailabilityUseCase', () {
    test('deity in school list is available', () async {
      final official = MockOfficialSchoolRepo(schools: [_officialSchool]);
      final userRepo = InMemoryUserSchoolRepository();
      final useCase = DeityAvailabilityUseCase(official, userRepo);

      expect(await useCase(schoolId: 'jingMirror', deityId: 'taiYi'), true);
      expect(await useCase(schoolId: 'jingMirror', deityId: 'junJi'), true);
      expect(await useCase(schoolId: 'jingMirror', deityId: 'other'), false);
    });

    test('empty deityIds means all available', () async {
      final official = MockOfficialSchoolRepo(
        schools: [
          const TaiYiSchool(
            id: 'open',
            name: 'Open',
            epoch: _epoch,
            deityIds: [],
          ),
        ],
      );
      final userRepo = InMemoryUserSchoolRepository();
      final useCase = DeityAvailabilityUseCase(official, userRepo);

      expect(await useCase(schoolId: 'open', deityId: 'anything'), true);
    });

    test('non-existent school returns false', () async {
      final official = MockOfficialSchoolRepo();
      final userRepo = InMemoryUserSchoolRepository();
      final useCase = DeityAvailabilityUseCase(official, userRepo);

      expect(await useCase(schoolId: 'nope', deityId: 'taiYi'), false);
    });
  });

  group('ToggleDeityPreferenceUseCase', () {
    test('toggles from default (enabled) to disabled', () async {
      final prefRepo = InMemoryDeityPreferenceRepository();
      final useCase = ToggleDeityPreferenceUseCase(prefRepo);

      final newState = await useCase('taiYi');
      expect(newState, false);
      expect(await prefRepo.isEnabled('taiYi'), false);
    });

    test('toggles back to enabled', () async {
      final prefRepo = InMemoryDeityPreferenceRepository();
      final useCase = ToggleDeityPreferenceUseCase(prefRepo);

      await useCase('taiYi');
      final newState = await useCase('taiYi');
      expect(newState, true);
    });
  });
}
