import 'core/school_config.dart';
import 'core/deity_definition.dart';
import 'core/school_repository.dart';
import 'usecases/load_schools_usecase.dart';
import 'usecases/copy_school_usecase.dart';
import 'usecases/save_user_school_usecase.dart';
import 'usecases/load_deities_usecase.dart';
import 'usecases/copy_deity_usecase.dart';
import 'usecases/save_user_deity_usecase.dart';
import 'usecases/delete_user_deity_usecase.dart';
import 'usecases/toggle_deity_preference_usecase.dart';
import 'usecases/deity_availability_usecase.dart';
import 'usecases/calculate_pan_usecase.dart';

// ---------------------------------------------------------------------------
// Adapter: wraps UserSchoolRepository as SchoolRepository so the composite
// can aggregate both official + user schools for pan calculations.
// ---------------------------------------------------------------------------

class _UserSchoolAsSchoolRepo implements SchoolRepository {
  final UserSchoolRepository _userRepo;
  _UserSchoolAsSchoolRepo(this._userRepo);

  @override
  Future<List<TaiYiSchool>> loadAllSchools() => _userRepo.loadUserSchools();

  @override
  Future<TaiYiSchool?> loadSchool(String id) => _userRepo.loadSchool(id);

  @override
  Future<List<DeityDefinition>> loadAllDeities() async => [];

  @override
  Future<DeityDefinition?> loadDeity(String id) async => null;

  @override
  Future<void> saveSchool(TaiYiSchool school) =>
      _userRepo.saveUserSchool(school);

  @override
  Future<void> deleteSchool(String id) => _userRepo.deleteUserSchool(id);

  @override
  Future<void> saveDeity(DeityDefinition deity) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteDeity(String id) async => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// TaiYiDataAssembly — injectable, backend-agnostic
// ---------------------------------------------------------------------------

/// Handles the assembly of Repositories and UseCases.
/// This ensures that ViewModels do not directly instantiate Repositories.
///
/// Constructed by the example host (TYSS-22) which provides the concrete
/// backend repos. Product lib/ does NOT import any persistence_* package.
class TaiYiDataAssembly {
  final SchoolRepository officialRepo;
  final UserSchoolRepository userRepo;
  final DeityRepository deityRepo;
  final DeityPreferenceRepository preferenceRepo;
  late final SchoolRepository compositeRepo;

  // UseCases
  late final LoadSchoolsUseCase loadSchoolsUseCase;
  late final CopySchoolUseCase copySchoolUseCase;
  late final SaveUserSchoolUseCase saveUserSchoolUseCase;
  late final LoadDeitiesUseCase loadDeitiesUseCase;
  late final CopyDeityUseCase copyDeityUseCase;
  late final SaveUserDeityUseCase saveUserDeityUseCase;
  late final DeleteUserDeityUseCase deleteUserDeityUseCase;
  late final ToggleDeityPreferenceUseCase toggleDeityPreferenceUseCase;
  late final DeityAvailabilityUseCase deityAvailabilityUseCase;
  late final CalculatePanUseCase calculatePanUseCase;

  TaiYiDataAssembly({
    required this.officialRepo,
    required this.userRepo,
    required this.deityRepo,
    required this.preferenceRepo,
  }) {
    compositeRepo =
        MultiSchoolRepository([officialRepo, _UserSchoolAsSchoolRepo(userRepo)]);

    loadSchoolsUseCase = LoadSchoolsUseCase(officialRepo, userRepo);
    copySchoolUseCase = CopySchoolUseCase(officialRepo, userRepo);
    saveUserSchoolUseCase = SaveUserSchoolUseCase(userRepo);

    loadDeitiesUseCase = LoadDeitiesUseCase(officialRepo, deityRepo);
    copyDeityUseCase = CopyDeityUseCase(officialRepo, deityRepo);
    saveUserDeityUseCase = SaveUserDeityUseCase(deityRepo);
    deleteUserDeityUseCase = DeleteUserDeityUseCase(deityRepo);
    toggleDeityPreferenceUseCase = ToggleDeityPreferenceUseCase(preferenceRepo);
    deityAvailabilityUseCase = DeityAvailabilityUseCase(officialRepo, userRepo);

    calculatePanUseCase = CalculatePanUseCase(
      schoolRepository: compositeRepo,
      deityPreferenceRepository: preferenceRepo,
    );
  }

  // create() and test() factories REMOVED — host constructs backends (TYSS-22)
}


class MultiSchoolRepository implements SchoolRepository {
  final List<SchoolRepository> repositories;
  MultiSchoolRepository(this.repositories);

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async {
    final all = <TaiYiSchool>[];
    for (final repo in repositories) {
      all.addAll(await repo.loadAllSchools());
    }
    return all;
  }

  @override
  Future<TaiYiSchool?> loadSchool(String id) async {
    for (final repo in repositories) {
      final s = await repo.loadSchool(id);
      if (s != null) return s;
    }
    return null;
  }

  @override
  Future<List<DeityDefinition>> loadAllDeities() async {
    final all = <DeityDefinition>[];
    for (final repo in repositories) {
      all.addAll(await repo.loadAllDeities());
    }
    return all;
  }

  @override
  Future<DeityDefinition?> loadDeity(String id) async {
    for (final repo in repositories) {
      final d = await repo.loadDeity(id);
      if (d != null) return d;
    }
    return null;
  }

  @override
  Future<void> saveSchool(TaiYiSchool school) async {
    throw UnimplementedError('Use specific repository to save');
  }

  @override
  Future<void> deleteSchool(String id) async {
    throw UnimplementedError('Use specific repository to delete');
  }

  @override
  Future<void> saveDeity(DeityDefinition deity) async {
    throw UnimplementedError('Use specific repository to save');
  }

  @override
  Future<void> deleteDeity(String id) async {
    throw UnimplementedError('Use specific repository to delete');
  }
}
