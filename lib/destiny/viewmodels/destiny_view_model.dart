import 'package:flutter/foundation.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import '../core/destiny_engine.dart';

class DestinyViewModel extends ChangeNotifier {
  final DestinyEngine engine;

  DestinyResultContract? _result;
  bool _isLoading = false;
  String? _error;

  DestinyViewModel({DestinyEngine? engine})
      : engine = engine ?? const DestinyEngine();

  DestinyResultContract? get result => _result;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> calculate({
    required DateTime birthTime,
    required DestinyConfigContract config,
    String schoolId = 'tongZong',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _result = engine.calculate(
        birthTime: birthTime,
        config: config,
        schoolId: schoolId,
      );
    } catch (e) {
      _error = e.toString();
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
