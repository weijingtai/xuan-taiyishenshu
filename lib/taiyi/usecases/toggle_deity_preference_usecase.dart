import '../core/school_repository.dart';

/// Toggles a deity's display preference (enabled/disabled).
class ToggleDeityPreferenceUseCase {
  final DeityPreferenceRepository _prefRepo;

  ToggleDeityPreferenceUseCase(this._prefRepo);

  /// Toggles the enabled state for [deityId].
  /// Returns the new state after toggle.
  Future<bool> call(String deityId) async {
    final current = await _prefRepo.isEnabled(deityId);
    final newState = !current;
    await _prefRepo.setEnabled(deityId, newState);
    return newState;
  }
}
