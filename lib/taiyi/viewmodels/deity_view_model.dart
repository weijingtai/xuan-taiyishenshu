import 'package:flutter/foundation.dart';
import '../core/deity_definition.dart';
import '../usecases/load_deities_usecase.dart';
import '../usecases/save_user_deity_usecase.dart';
import '../usecases/copy_deity_usecase.dart';
import '../usecases/delete_user_deity_usecase.dart';
import '../usecases/toggle_deity_preference_usecase.dart';
import '../usecases/deity_availability_usecase.dart';

class DeityViewModel extends ChangeNotifier {
  final LoadDeitiesUseCase loadDeitiesUseCase;
  final CopyDeityUseCase copyDeityUseCase;
  final SaveUserDeityUseCase saveUserDeityUseCase;
  final DeleteUserDeityUseCase deleteUserDeityUseCase;
  final ToggleDeityPreferenceUseCase toggleDeityPreferenceUseCase;
  final DeityAvailabilityUseCase deityAvailabilityUseCase;

  List<DeityDefinition> _deities = [];
  bool _isLoading = false;

  DeityViewModel({
    required this.loadDeitiesUseCase,
    required this.copyDeityUseCase,
    required this.saveUserDeityUseCase,
    required this.deleteUserDeityUseCase,
    required this.toggleDeityPreferenceUseCase,
    required this.deityAvailabilityUseCase,
  });

  List<DeityDefinition> get deities => _deities;
  bool get isLoading => _isLoading;

  Future<void> loadDeities() async {
    _isLoading = true;
    notifyListeners();

    try {
      _deities = await loadDeitiesUseCase();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> copyDeity({
    required String sourceId,
    required String newId,
    String? newName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await copyDeityUseCase(
        sourceId: sourceId,
        newId: newId,
        newName: newName,
      );
      _deities = await loadDeitiesUseCase();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveDeity(DeityDefinition deity) async {
    _isLoading = true;
    notifyListeners();

    try {
      await saveUserDeityUseCase(deity);
      _deities = await loadDeitiesUseCase();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDeity(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await deleteUserDeityUseCase(id);
      _deities = await loadDeitiesUseCase();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleDeityPreference(String deityId) async {
    return await toggleDeityPreferenceUseCase(deityId);
  }

  Future<bool> checkAvailability({
    required String schoolId,
    required String deityId,
  }) async {
    return await deityAvailabilityUseCase(
      schoolId: schoolId,
      deityId: deityId,
    );
  }
}
