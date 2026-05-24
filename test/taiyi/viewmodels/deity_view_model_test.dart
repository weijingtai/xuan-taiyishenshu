import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:taiyishenshu/taiyi/usecases/load_deities_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/save_user_deity_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/copy_deity_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/delete_user_deity_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/toggle_deity_preference_usecase.dart';
import 'package:taiyishenshu/taiyi/usecases/deity_availability_usecase.dart';
import 'package:taiyishenshu/taiyi/viewmodels/deity_view_model.dart';

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

class InMemoryUserSchoolRepo implements UserSchoolRepository {
  final Map<String, TaiYiSchool> _store = {};

  InMemoryUserSchoolRepo({List<TaiYiSchool> initial = const []}) {
    for (var s in initial) {
      _store[s.id] = s;
    }
  }

  @override
  Future<List<TaiYiSchool>> loadUserSchools() async => _store.values.toList();
  @override
  Future<TaiYiSchool?> loadSchool(String id) async => _store[id];
  @override
  Future<void> saveUserSchool(TaiYiSchool school) async => _store[school.id] = school;
  @override
  Future<void> deleteUserSchool(String id) async => _store.remove(id);
}

class InMemoryDeityRepo implements DeityRepository {
  final Map<String, DeityDefinition> _store = {};

  @override
  Future<List<DeityDefinition>> loadUserDeities() async => _store.values.toList();
  @override
  Future<DeityDefinition?> loadDeity(String id) async => _store[id];
  @override
  Future<void> saveUserDeity(DeityDefinition deity) async => _store[deity.id] = deity;
  @override
  Future<void> deleteUserDeity(String id) async => _store.remove(id);
}

class InMemoryDeityPrefRepo implements DeityPreferenceRepository {
  final Map<String, bool> _store = {};

  @override
  Future<bool> isEnabled(String deityId) async => _store[deityId] ?? true;
  @override
  Future<void> setEnabled(String deityId, bool enabled) async => _store[deityId] = enabled;
  @override
  Future<Map<String, bool>> loadEnabledMap() async => Map.of(_store);
}

const _epoch = SchoolEpochConfig(ancientBase: 100, epochYear: 200);
const _officialSchool = TaiYiSchool(
  id: 'jingMirror',
  name: '金镜派',
  epoch: _epoch,
  source: 'official',
  deityIds: ['taiyi_deity'],
);

final _officialDeity = DeityDefinition(
  id: 'taiyi_deity',
  name: '太一',
  layer: EnumDeityLayer.tianPan,
  algorithm: const DeityAlgorithmSpec(
    templateId: AlgorithmTemplateId.fixedPosition,
  ),
  source: 'official',
);

void main() {
  group('DeityViewModel', () {
    late DeityViewModel viewModel;
    late InMemoryDeityRepo userDeityRepo;
    late InMemoryDeityPrefRepo prefRepo;
    late InMemoryUserSchoolRepo userSchoolRepo;

    setUp(() {
      final officialRepo = MockOfficialSchoolRepo(
        schools: [_officialSchool],
        deities: [_officialDeity],
      );
      userDeityRepo = InMemoryDeityRepo();
      prefRepo = InMemoryDeityPrefRepo();
      userSchoolRepo = InMemoryUserSchoolRepo();

      viewModel = DeityViewModel(
        loadDeitiesUseCase: LoadDeitiesUseCase(officialRepo, userDeityRepo),
        copyDeityUseCase: CopyDeityUseCase(officialRepo, userDeityRepo),
        saveUserDeityUseCase: SaveUserDeityUseCase(userDeityRepo),
        deleteUserDeityUseCase: DeleteUserDeityUseCase(userDeityRepo),
        toggleDeityPreferenceUseCase: ToggleDeityPreferenceUseCase(prefRepo),
        deityAvailabilityUseCase: DeityAvailabilityUseCase(officialRepo, userSchoolRepo),
      );
    });

    test('loadDeities populates the deities list', () async {
      expect(viewModel.deities, isEmpty);
      expect(viewModel.isLoading, isFalse);

      await viewModel.loadDeities();

      expect(viewModel.deities, isNotEmpty);
      expect(viewModel.deities.first.id, 'taiyi_deity');
    });

    test('copyDeity creates a new user deity and reloads', () async {
      await viewModel.loadDeities();
      
      await viewModel.copyDeity(
        sourceId: 'taiyi_deity',
        newId: 'user_taiyi',
        newName: '我的太一',
      );

      expect(viewModel.deities.length, 2);
      expect(viewModel.deities.any((d) => d.id == 'user_taiyi'), isTrue);
    });

    test('saveDeity updates user deity and reloads', () async {
      await viewModel.loadDeities();
      
      await viewModel.copyDeity(
        sourceId: 'taiyi_deity',
        newId: 'user_taiyi',
        newName: '我的太一',
      );

      final userDeity = viewModel.deities.firstWhere((d) => d.id == 'user_taiyi');
      final updatedDeity = userDeity.copyWith(name: '修改太一');

      await viewModel.saveDeity(updatedDeity);

      expect(viewModel.deities.firstWhere((d) => d.id == 'user_taiyi').name, '修改太一');
    });

    test('toggleDeityPreference toggles the preference', () async {
      final newState = await viewModel.toggleDeityPreference('taiyi_deity');
      expect(newState, isFalse); // default is true, so toggle is false

      final newState2 = await viewModel.toggleDeityPreference('taiyi_deity');
      expect(newState2, isTrue);
    });

    test('checkAvailability returns correct availability', () async {
      // 'taiyi_deity' is in 'jingMirror' school
      final isAvailable = await viewModel.checkAvailability(
        schoolId: 'jingMirror',
        deityId: 'taiyi_deity',
      );
      expect(isAvailable, isTrue);

      final isAvailable2 = await viewModel.checkAvailability(
        schoolId: 'jingMirror',
        deityId: 'other_deity',
      );
      expect(isAvailable2, isFalse);
    });

    test('deleteDeity removes user deity and reloads', () async {
      await viewModel.loadDeities();
      
      await viewModel.copyDeity(
        sourceId: 'taiyi_deity',
        newId: 'user_taiyi',
        newName: '我的太一',
      );

      expect(viewModel.deities.length, 2);

      await viewModel.deleteDeity('user_taiyi');

      expect(viewModel.deities.length, 1);
      expect(viewModel.deities.any((d) => d.id == 'user_taiyi'), isFalse);
    });
  });
}
