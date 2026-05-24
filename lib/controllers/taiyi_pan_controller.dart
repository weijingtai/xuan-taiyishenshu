import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle;

import '../taiyi/viewmodels/school_view_model.dart';
import '../taiyi/viewmodels/deity_view_model.dart';
import '../taiyi/usecases/calculate_pan_usecase.dart';
import '../taiyi/taiyi.dart';
import '../taiyi/core/school_config.dart';
import '../taiyi/core/deity_definition.dart';
import '../taiyi/core/school_repository.dart';
import '../taiyi/data/official_json_repository.dart';
import '../taiyi/data/memory_school_repository.dart';
import '../taiyi/data/in_memory_deity_preference_repository.dart';
import '../taiyi/usecases/load_schools_usecase.dart';
import '../taiyi/usecases/copy_school_usecase.dart';
import '../taiyi/usecases/save_user_school_usecase.dart';
import '../taiyi/usecases/load_deities_usecase.dart';
import '../taiyi/usecases/copy_deity_usecase.dart';
import '../taiyi/usecases/save_user_deity_usecase.dart';
import '../taiyi/usecases/delete_user_deity_usecase.dart';
import '../taiyi/usecases/toggle_deity_preference_usecase.dart';
import '../taiyi/usecases/deity_availability_usecase.dart';


class TaiYiPanController extends ChangeNotifier {
  final AssetBundle? bundle;

  late final SchoolViewModel schoolViewModel;
  late final DeityViewModel deityViewModel;
  late final CalculatePanUseCase calculatePanUseCase;

  TaiYiPanController({this.bundle}) {
    // 1. Initialize Repositories
    final officialRepo = OfficialJsonSchoolRepository(
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
    final userRepo = MemorySchoolRepository();
    final preferenceRepo = InMemoryDeityPreferenceRepository();

    // Composite Repository
    final compositeRepo = MultiSchoolRepository([officialRepo, userRepo]);

    // 2. Initialize UseCases
    final loadSchools = LoadSchoolsUseCase(officialRepo, userRepo);
    final copySchool = CopySchoolUseCase(officialRepo, userRepo);
    final saveUserSchool = SaveUserSchoolUseCase(userRepo);

    final loadDeities = LoadDeitiesUseCase(officialRepo, userRepo);
    final copyDeity = CopyDeityUseCase(officialRepo, userRepo);
    final saveUserDeity = SaveUserDeityUseCase(userRepo);
    final deleteUserDeity = DeleteUserDeityUseCase(userRepo);
    final togglePreference = ToggleDeityPreferenceUseCase(preferenceRepo);
    final checkAvailability = DeityAvailabilityUseCase(officialRepo, userRepo);

    calculatePanUseCase = CalculatePanUseCase(
      schoolRepository: compositeRepo,
      deityPreferenceRepository: preferenceRepo,
    );

    // 3. Initialize ViewModels
    schoolViewModel = SchoolViewModel(
      loadSchoolsUseCase: loadSchools,
      copySchoolUseCase: copySchool,
      saveUserSchoolUseCase: saveUserSchool,
    );

    deityViewModel = DeityViewModel(
      loadDeitiesUseCase: loadDeities,
      copyDeityUseCase: copyDeity,
      saveUserDeityUseCase: saveUserDeity,
      deleteUserDeityUseCase: deleteUserDeity,
      toggleDeityPreferenceUseCase: togglePreference,
      deityAvailabilityUseCase: checkAvailability,
    );

    // Forward notifications from ViewModels
    schoolViewModel.addListener(notifyListeners);
    deityViewModel.addListener(notifyListeners);
  }

  PanDataModel? _panData;
  bool _isCalculating = false;
  String? _error;

  PanDataModel? get panData => _panData;
  bool get isCalculating => _isCalculating;
  String? get error => _error;

  List<TaiYiSchool> get availableSchools => schoolViewModel.schools;
  List<DeityDefinition> get allDeities => deityViewModel.deities;
  List<DeityDefinition> get officialDeities => deityViewModel.deities.where((d) => !d.id.startsWith('user_')).toList();

  bool get showHiddenWarning {
    const coreDeities = ['taiYi', 'wenChang', 'shiJi', 'jiShen'];
    return coreDeities.any((id) => !isDeityVisible(id));
  }

  final Map<String, bool> _localVisibilityCache = {};

  bool isDeityVisible(String id) {
    return _localVisibilityCache[id] ?? true;
  }

  void setDeityVisibility(String id, bool visible) {
    _localVisibilityCache[id] = visible;
    deityViewModel.toggleDeityPreference(id);
    notifyListeners();
  }

  Future<void> loadSchools() async {
    await schoolViewModel.loadSchools();
    await deityViewModel.loadDeities();
    
    // Initialize cache from repository (simplified for this task)
    // In a real app, we'd wait for the preference repo
  }


  Future<void> saveUserSchool(TaiYiSchool school) async {
    await schoolViewModel.saveSchool(school);
  }

  Future<void> calculate({
    required DateTime dateTime,
    String schoolId = 'jingMirror',
    TaiYiChartType chartType = TaiYiChartType.year,
  }) async {
    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      _panData = await calculatePanUseCase(
        dateTime: dateTime,
        schoolId: schoolId,
        chartType: chartType,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _panData = null;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    schoolViewModel.removeListener(notifyListeners);
    deityViewModel.removeListener(notifyListeners);
    super.dispose();
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


