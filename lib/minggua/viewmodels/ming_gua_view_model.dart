import 'package:flutter/foundation.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import '../usecases/calculate_ming_gua_usecase.dart';

class MingGuaViewModel extends ChangeNotifier {
  final CalculateMingGuaUseCase calculateUseCase;

  MingGuaResultContract? _result;
  bool _isLoading = false;
  String? _error;

  MingGuaViewModel({required this.calculateUseCase});

  MingGuaResultContract? get result => _result;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> calculate({required int year, String? configId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _result = await calculateUseCase(year: year, configId: configId);
    } catch (e) {
      _error = e.toString();
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
