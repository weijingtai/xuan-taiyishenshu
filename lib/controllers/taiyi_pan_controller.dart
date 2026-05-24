import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle;

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



