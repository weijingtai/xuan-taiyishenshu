import 'package:flutter/services.dart' show AssetBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../database/taiyi_database.dart';
import 'core/school_config.dart';
import 'core/deity_definition.dart';
import 'core/school_repository.dart';
import 'data/official_json_repository.dart';
import 'data/drift_user_repository.dart';
import 'data/shared_preferences_deity_preference_repository.dart';
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

/// Handles the assembly of Repositories and UseCases.
/// This ensures that ViewModels do not directly instantiate Repositories.
class TaiYiDataAssembly {
  final AssetBundle? bundle;

  // Repositories
  late final SchoolRepository officialRepo;
  late final DriftUserRepository userRepo;
  late final DeityPreferenceRepository preferenceRepo;
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

  // Private constructor
  TaiYiDataAssembly._({
    this.bundle,
    required SharedPreferences prefs,
    required TaiYiDatabase db,
  }) {
    officialRepo = OfficialJsonSchoolRepository(
      bundle: bundle,
      schoolIds: ['jingMirror', 'tongZong', 'jiCheng'],
      deityIds: [
        'taiYi', 'zhuDaJiang', 'keDaJiang', 'zhuCanJiang', 'keCanJiang',
        'dingDaJiang', 'dingCanJiang', 'junJi', 'chenJi', 'minJi',
        'wuFu', 'daYou', 'xiaoYou', 'feiFu', 'siShen',
        'tianYiStar', 'diYi', 'zhiFuStar', 'yangJiu', 'baiLiu',
        'taiSui', 'suiPo', 'zhiFu', 'heShen',
        'qingLong', 'zhuQue', 'baiHu', 'xuanWu', 'fengBo', 'yuShi',
        'qingLongQi', 'heiQi', 'chiQi', 'guiShenZhiShi',
        'wenChang', 'jiShen', 'shiJi',
      ],
    );
    userRepo = DriftUserRepository(db);
    preferenceRepo = SharedPreferencesDeityPreferenceRepository(prefs);
    compositeRepo = MultiSchoolRepository([officialRepo, userRepo]);

    loadSchoolsUseCase = LoadSchoolsUseCase(officialRepo, userRepo);
    copySchoolUseCase = CopySchoolUseCase(officialRepo, userRepo);
    saveUserSchoolUseCase = SaveUserSchoolUseCase(userRepo);

    loadDeitiesUseCase = LoadDeitiesUseCase(officialRepo, userRepo);
    copyDeityUseCase = CopyDeityUseCase(officialRepo, userRepo);
    saveUserDeityUseCase = SaveUserDeityUseCase(userRepo);
    deleteUserDeityUseCase = DeleteUserDeityUseCase(userRepo);
    toggleDeityPreferenceUseCase = ToggleDeityPreferenceUseCase(preferenceRepo);
    deityAvailabilityUseCase = DeityAvailabilityUseCase(officialRepo, userRepo);

    calculatePanUseCase = CalculatePanUseCase(
      schoolRepository: compositeRepo,
      deityPreferenceRepository: preferenceRepo,
    );
  }

  /// Factory method to create and initialize the assembly.
  static Future<TaiYiDataAssembly> create({AssetBundle? bundle}) async {
    final prefs = await SharedPreferences.getInstance();
    final db = TaiYiDatabase();
    return TaiYiDataAssembly._(bundle: bundle, prefs: prefs, db: db);
  }

  /// Factory for testing with provided dependencies.
  factory TaiYiDataAssembly.test({
    AssetBundle? bundle,
    required SharedPreferences prefs,
    TaiYiDatabase? db,
  }) {
    return TaiYiDataAssembly._(
      bundle: bundle,
      prefs: prefs,
      db: db ?? TaiYiDatabase.memory(),
    );
  }
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
