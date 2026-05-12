import 'package:flutter/foundation.dart';

import '../taiyi/core/school_config.dart';
import '../taiyi/data/official_json_repository.dart';
import '../taiyi/taiyi.dart';

class TaiYiPanController extends ChangeNotifier {
  PanDataModel? _panData;
  bool _isCalculating = false;
  String? _error;

  List<TaiYiSchool> _availableSchools = [];
  List<TaiYiSchool> get availableSchools => _availableSchools;

  String get currentSchoolId =>
      _panData?.input.schoolId ?? 'jingMirror';

  PanDataModel? get panData => _panData;
  bool get isCalculating => _isCalculating;
  String? get error => _error;

  static final _calculator = TaiYiPanCalculator();

  Future<void> loadSchools() async {
    final repo = OfficialJsonSchoolRepository(
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
    _availableSchools = await repo.loadAllSchools();
    notifyListeners();
  }

  void calculate({
    required DateTime dateTime,
    String schoolId = 'jingMirror',
    TaiYiChartType chartType = TaiYiChartType.year,
  }) {
    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      _panData = _calculator.calculate(
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

  void recalculateWith({
    String? schoolId,
    TaiYiChartType? chartType,
  }) {
    if (_panData == null) return;
    calculate(
      dateTime: _panData!.input.dateTime,
      schoolId: schoolId ?? _panData!.input.schoolId,
      chartType: chartType ?? _panData!.input.chartType,
    );
  }
}
