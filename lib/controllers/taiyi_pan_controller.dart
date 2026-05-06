import 'package:flutter/foundation.dart';

import '../taiyi/taiyi.dart';

class TaiYiPanController extends ChangeNotifier {
  PanDataModel? _panData;
  bool _isCalculating = false;
  String? _error;

  PanDataModel? get panData => _panData;
  bool get isCalculating => _isCalculating;
  String? get error => _error;

  static final _calculator = TaiYiPanCalculator();

  void calculate({
    required DateTime dateTime,
    TaiYiSchool school = TaiYiSchool.jingMirror,
    TaiYiChartType chartType = TaiYiChartType.year,
  }) {
    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      _panData = _calculator.calculate(
        dateTime: dateTime,
        school: school,
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
    TaiYiSchool? school,
    TaiYiChartType? chartType,
  }) {
    if (_panData == null) return;
    calculate(
      dateTime: _panData!.input.dateTime,
      school: school ?? _panData!.input.school,
      chartType: chartType ?? _panData!.input.chartType,
    );
  }
}
