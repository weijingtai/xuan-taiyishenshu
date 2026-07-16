import 'package:flutter/foundation.dart';

import '../taiyi/taiyi_assembly.dart';
import '../taiyi/viewmodels/school_view_model.dart';
import '../taiyi/viewmodels/deity_view_model.dart';
import '../taiyi/usecases/calculate_pan_usecase.dart';
import '../taiyi/taiyi.dart';

class TaiYiPanController extends ChangeNotifier {
  final TaiYiDataAssembly assembly;

  late final SchoolViewModel schoolViewModel;
  late final DeityViewModel deityViewModel;
  late final CalculatePanUseCase calculatePanUseCase;

  TaiYiPanController({required this.assembly}) {

    calculatePanUseCase = assembly.calculatePanUseCase;

    // 3. Initialize ViewModels
    schoolViewModel = SchoolViewModel(
      loadSchoolsUseCase: assembly.loadSchoolsUseCase,
      copySchoolUseCase: assembly.copySchoolUseCase,
      saveUserSchoolUseCase: assembly.saveUserSchoolUseCase,
    );

    deityViewModel = DeityViewModel(
      loadDeitiesUseCase: assembly.loadDeitiesUseCase,
      copyDeityUseCase: assembly.copyDeityUseCase,
      saveUserDeityUseCase: assembly.saveUserDeityUseCase,
      deleteUserDeityUseCase: assembly.deleteUserDeityUseCase,
      toggleDeityPreferenceUseCase: assembly.toggleDeityPreferenceUseCase,
      deityAvailabilityUseCase: assembly.deityAvailabilityUseCase,
      preferenceRepository: assembly.preferenceRepo,
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
    // If not in cache, we assume visible for now, 
    // but the real source is the preference repo via CalculatePanUseCase.
    return _localVisibilityCache[id] ?? true;
  }

  Future<void> setDeityVisibility(String id, bool visible) async {
    _localVisibilityCache[id] = visible;
    // ZT-21 修复: 直接 setEnabled(id, visible), 不再 toggle, 防止重复调用脱钩。
    await deityViewModel.setDeityPreference(id, visible);

    // Immediately re-calculate to refresh UI with new visibility settings
    if (_panData != null) {
      await calculate(
        dateTime: _panData!.input.dateTime,
        schoolId: _panData!.input.schoolId,
        chartType: _panData!.input.chartType,
      );
    } else {
      notifyListeners();
    }
  }

  Future<void> loadSchools() async {
    await schoolViewModel.loadSchools();
    await deityViewModel.loadDeities();
    
    // Initialize local visibility cache from preference repository
    final prefs = await assembly.preferenceRepo.loadEnabledMap();
    _localVisibilityCache.addAll(prefs);
    notifyListeners();
  }


  Future<void> saveUserSchool(TaiYiSchool school) async {
    await schoolViewModel.saveSchool(school);
  }

  /// 切换当前流派并重新排盘。
  ///
  /// 内部直接调用 [calculate]，复用上次 [PanDataModel.input] 的 dateTime
  /// 与 chartType（若已有 panData）；否则回退到当前时间与 year 盘。
  ///
  /// 该方法是流派管理页面在用户点击列表行后触发"切换流派"动作的入口。
  /// 切换后 panData.accumulatedYear / juNumber / 主算落宫等参数会随流派
  /// epoch 与算法开关而变化，UI 监听 [notifyListeners] 即自动刷新。
  Future<void> switchSchool(String schoolId) async {
    final last = _panData?.input;
    await calculate(
      dateTime: last?.dateTime ?? DateTime.now(),
      schoolId: schoolId,
      chartType: last?.chartType ?? TaiYiChartType.year,
    );
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

      assembly.saveRecordUseCase(_panData!).catchError((_) {});
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



