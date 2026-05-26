import 'package:flutter/foundation.dart';
import '../core/deity_definition.dart';
import '../core/school_repository.dart';
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
  // 偏好 Repository 直接注入, 用于支持 “设定偏好为某个具体值” (区别于 toggle)。
  // 修复 ZT-21 中 setDeityVisibility(id, false) 调 toggle 的脱钩漏洞。
  final DeityPreferenceRepository? _preferenceRepository;

  List<DeityDefinition> _deities = [];
  bool _isLoading = false;

  DeityViewModel({
    required this.loadDeitiesUseCase,
    required this.copyDeityUseCase,
    required this.saveUserDeityUseCase,
    required this.deleteUserDeityUseCase,
    required this.toggleDeityPreferenceUseCase,
    required this.deityAvailabilityUseCase,
    DeityPreferenceRepository? preferenceRepository,
  }) : _preferenceRepository = preferenceRepository;

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

  /// 把指定星神的显示偏好设为具体值 (区别于 toggle)。
  ///
  /// 修复 ZT-21 toggle 漏洞: setDeityVisibility(id, false) 反复调用会
  /// 在 toggle 路径下交替翻转, 与本地 cache 脱钩。
  /// 调用方需注入 [DeityPreferenceRepository], 否则抛 StateError。
  Future<void> setDeityPreference(String deityId, bool enabled) async {
    if (_preferenceRepository == null) {
      throw StateError(
        'DeityViewModel.setDeityPreference 需要在构造时注入 preferenceRepository',
      );
    }
    await _preferenceRepository.setEnabled(deityId, enabled);
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
