import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart'
    as contract;
import 'core/school_repository.dart' as product;
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
class _ContractOfficialSchoolAdapter implements product.SchoolRepository {
  final contract.SchoolRepository _inner;
  _ContractOfficialSchoolAdapter(this._inner);

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async =>
      (await _inner.loadAllSchools()).map((c) => c.toModel()).toList();

  @override
  Future<TaiYiSchool?> loadSchool(String id) async =>
      (await _inner.loadSchool(id))?.toModel();

  @override
  Future<List<DeityDefinition>> loadAllDeities() async =>
      (await _inner.loadAllDeities()).map((c) => c.toModel()).toList();

  @override
  Future<DeityDefinition?> loadDeity(String id) async =>
      (await _inner.loadDeity(id))?.toModel();

  @override
  Future<void> saveSchool(TaiYiSchool school) =>
      _inner.saveSchool(school.toContract());

  @override
  Future<void> saveDeity(DeityDefinition deity) =>
      _inner.saveDeity(deity.toContract());

  @override
  Future<void> deleteSchool(String id) => _inner.deleteSchool(id);

  @override
  Future<void> deleteDeity(String id) => _inner.deleteDeity(id);
}

class _ContractUserSchoolAdapter implements product.UserSchoolRepository {
  final contract.UserSchoolRepository _inner;
  _ContractUserSchoolAdapter(this._inner);

  @override
  Future<List<TaiYiSchool>> loadUserSchools() async =>
      (await _inner.loadUserSchools()).map((c) => c.toModel()).toList();

  @override
  Future<TaiYiSchool?> loadSchool(String id) async =>
      (await _inner.loadSchool(id))?.toModel();

  @override
  Future<void> saveUserSchool(TaiYiSchool school) =>
      _inner.saveUserSchool(school.toContract());

  @override
  Future<void> deleteUserSchool(String id) => _inner.deleteUserSchool(id);
}

class _ContractDeityAdapter implements product.DeityRepository {
  final contract.DeityRepository _inner;
  _ContractDeityAdapter(this._inner);

  @override
  Future<List<DeityDefinition>> loadUserDeities() async =>
      (await _inner.loadUserDeities()).map((c) => c.toModel()).toList();

  @override
  Future<DeityDefinition?> loadDeity(String id) async =>
      (await _inner.loadDeity(id))?.toModel();

  @override
  Future<void> saveUserDeity(DeityDefinition deity) =>
      _inner.saveUserDeity(deity.toContract());

  @override
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
  final contract.SchoolRepository officialRepo;   // contract-typed (interface)
  final contract.UserSchoolRepository userRepo;   // contract-typed (interface)
  final contract.DeityRepository deityRepo;       // contract-typed (interface)
  final contract.DeityPreferenceRepository preferenceRepo; // interface (primitives only)
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
        _MultiSchoolAdapter([productOfficial]);

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

class _MultiSchoolAdapter implements product.SchoolRepository {
  final List<product.SchoolRepository> repositories;
  _MultiSchoolAdapter(this.repositories);

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
