import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart'
    show SchoolRepository, UserSchoolRepository, DeityRepository,
         DeityPreferenceRepository, TaiYiSchoolContract, DeityDefinitionContract;
import 'core/school_repository.dart'
    show
        TaiYiSchoolProductMapper,
        TaiYiSchoolContractProductMapper,
        DeityDefinitionProductMapper,
        DeityDefinitionContractProductMapper;
import 'core/school_config.dart';
import 'core/deity_definition.dart';
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
// Adapters: wrap contract-typed repos (from interface package) into
// product-typed repos (from core/school_repository.dart) so that product
// usecases can consume them without knowing about the contract layer.
// ---------------------------------------------------------------------------

/// Product-typed [SchoolRepository] that delegates to a contract-typed
/// [SchoolRepository] from the interface package.
class _ContractOfficialSchoolAdapter {
  final SchoolRepository _inner;
  _ContractOfficialSchoolAdapter(this._inner);

  Future<List<TaiYiSchool>> loadAllSchools() async =>
      (await _inner.loadAllSchools()).map((c) => c.toModel()).toList();

  Future<TaiYiSchool?> loadSchool(String id) async =>
      (await _inner.loadSchool(id))?.toModel();

  Future<List<DeityDefinition>> loadAllDeities() async =>
      (await _inner.loadAllDeities()).map((c) => c.toModel()).toList();

  Future<DeityDefinition?> loadDeity(String id) async =>
      (await _inner.loadDeity(id))?.toModel();

  Future<void> saveSchool(TaiYiSchool school) =>
      _inner.saveSchool(school.toContract());

  Future<void> saveDeity(DeityDefinition deity) =>
      _inner.saveDeity(deity.toContract());

  Future<void> deleteSchool(String id) => _inner.deleteSchool(id);

  Future<void> deleteDeity(String id) => _inner.deleteDeity(id);
}

class _ContractUserSchoolAdapter {
  final UserSchoolRepository _inner;
  _ContractUserSchoolAdapter(this._inner);

  Future<List<TaiYiSchool>> loadUserSchools() async =>
      (await _inner.loadUserSchools()).map((c) => c.toModel()).toList();

  Future<TaiYiSchool?> loadSchool(String id) async =>
      (await _inner.loadSchool(id))?.toModel();

  Future<void> saveUserSchool(TaiYiSchool school) =>
      _inner.saveUserSchool(school.toContract());

  Future<void> deleteUserSchool(String id) => _inner.deleteUserSchool(id);
}

class _ContractDeityAdapter {
  final DeityRepository _inner;
  _ContractDeityAdapter(this._inner);

  Future<List<DeityDefinition>> loadUserDeities() async =>
      (await _inner.loadUserDeities()).map((c) => c.toModel()).toList();

  Future<DeityDefinition?> loadDeity(String id) async =>
      (await _inner.loadDeity(id))?.toModel();

  Future<void> saveUserDeity(DeityDefinition deity) =>
      _inner.saveUserDeity(deity.toContract());

  Future<void> deleteUserDeity(String id) => _inner.deleteUserDeity(id);
}

// ---------------------------------------------------------------------------
// TaiYiDataAssembly — injectable, backend-agnostic
// ---------------------------------------------------------------------------

/// Handles the assembly of Repositories and UseCases.
/// This ensures that ViewModels do not directly instantiate Repositories.
///
/// Constructed by the example host (TYSS-22) which provides the concrete
/// backend repos. Product lib/ does NOT import any persistence_* package.
///
/// The constructor accepts **contract-typed** ports from the interface package.
/// Internal adapter wrappers convert to product-typed ports for the usecases.
class TaiYiDataAssembly {
  final SchoolRepository officialRepo;   // contract-typed (interface)
  final UserSchoolRepository userRepo;   // contract-typed (interface)
  final DeityRepository deityRepo;       // contract-typed (interface)
  final DeityPreferenceRepository preferenceRepo; // interface (primitives only)
  late final dynamic compositeRepo; // MultiSchoolRepository (product-typed)

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
    // Wrap contract-typed repos into product-typed adapters for usecases.
    final productOfficial = _ContractOfficialSchoolAdapter(officialRepo);
    final productUser = _ContractUserSchoolAdapter(userRepo);
    final productDeity = _ContractDeityAdapter(deityRepo);

    compositeRepo =
        _MultiSchoolAdapter([productOfficial, productUser]);

    loadSchoolsUseCase = LoadSchoolsUseCase(productOfficial, productUser);
    copySchoolUseCase = CopySchoolUseCase(productOfficial, productUser);
    saveUserSchoolUseCase = SaveUserSchoolUseCase(productUser);

    loadDeitiesUseCase = LoadDeitiesUseCase(productOfficial, productDeity);
    copyDeityUseCase = CopyDeityUseCase(productOfficial, productDeity);
    saveUserDeityUseCase = SaveUserDeityUseCase(productDeity);
    deleteUserDeityUseCase = DeleteUserDeityUseCase(productDeity);
    toggleDeityPreferenceUseCase = ToggleDeityPreferenceUseCase(preferenceRepo);
    deityAvailabilityUseCase = DeityAvailabilityUseCase(productOfficial, productUser);

    calculatePanUseCase = CalculatePanUseCase(
      schoolRepository: compositeRepo,
      deityPreferenceRepository: preferenceRepo,
    );
  }

  // create() and test() factories REMOVED — host constructs backends (TYSS-22)
}

// ---------------------------------------------------------------------------
// MultiSchoolAdapter — aggregates product-typed adapters
// ---------------------------------------------------------------------------

class _MultiSchoolAdapter {
  final List<_ContractOfficialSchoolAdapter> repositories;
  _MultiSchoolAdapter(this.repositories);

  Future<List<TaiYiSchool>> loadAllSchools() async {
    final all = <TaiYiSchool>[];
    for (final repo in repositories) {
      all.addAll(await repo.loadAllSchools());
    }
    return all;
  }

  Future<TaiYiSchool?> loadSchool(String id) async {
    for (final repo in repositories) {
      final s = await repo.loadSchool(id);
      if (s != null) return s;
    }
    return null;
  }

  Future<List<DeityDefinition>> loadAllDeities() async {
    final all = <DeityDefinition>[];
    for (final repo in repositories) {
      all.addAll(await repo.loadAllDeities());
    }
    return all;
  }

  Future<DeityDefinition?> loadDeity(String id) async {
    for (final repo in repositories) {
      final d = await repo.loadDeity(id);
      if (d != null) return d;
    }
    return null;
  }

  Future<void> saveSchool(TaiYiSchool school) async {
    throw UnimplementedError('Use specific repository to save');
  }

  Future<void> deleteSchool(String id) async {
    throw UnimplementedError('Use specific repository to delete');
  }

  Future<void> saveDeity(DeityDefinition deity) async {
    throw UnimplementedError('Use specific repository to save');
  }

  Future<void> deleteDeity(String id) async {
    throw UnimplementedError('Use specific repository to delete');
  }
}
