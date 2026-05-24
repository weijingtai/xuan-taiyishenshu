import 'package:flutter/foundation.dart';
import '../core/school_config.dart';
import '../usecases/load_schools_usecase.dart';
import '../usecases/save_user_school_usecase.dart';
import '../usecases/copy_school_usecase.dart';

class SchoolViewModel extends ChangeNotifier {
  final LoadSchoolsUseCase loadSchoolsUseCase;
  final CopySchoolUseCase copySchoolUseCase;
  final SaveUserSchoolUseCase saveUserSchoolUseCase;

  List<TaiYiSchool> _schools = [];
  TaiYiSchool? _currentSchool;
  bool _isLoading = false;

  SchoolViewModel({
    required this.loadSchoolsUseCase,
    required this.copySchoolUseCase,
    required this.saveUserSchoolUseCase,
  });

  List<TaiYiSchool> get schools => _schools;
  TaiYiSchool? get currentSchool => _currentSchool;
  bool get isLoading => _isLoading;

  Future<void> loadSchools() async {
    _isLoading = true;
    notifyListeners();

    try {
      _schools = await loadSchoolsUseCase();
      // If we don't have a current school but have loaded schools, we can default to the first one or keep it null.
      // Keeping it as is.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectSchool(String id) {
    try {
      _currentSchool = _schools.firstWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      // Not found, do nothing or handle error
    }
  }

  Future<void> copySchool({
    required String sourceId,
    required String newId,
    String? newName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await copySchoolUseCase(
        sourceId: sourceId,
        newId: newId,
        newName: newName,
      );
      // Reload the list to include the new school
      _schools = await loadSchoolsUseCase();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSchool(TaiYiSchool school) async {
    _isLoading = true;
    notifyListeners();

    try {
      await saveUserSchoolUseCase(school);
      _schools = await loadSchoolsUseCase();
      if (_currentSchool?.id == school.id) {
        _currentSchool = school;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
