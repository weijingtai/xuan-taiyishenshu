import '../core/school_repository.dart';
import '../core/school_config.dart';

/// Determines whether a deity is available for a given school/chart type.
class DeityAvailabilityUseCase {
  final SchoolRepository _officialRepo;
  final UserSchoolRepository _userRepo;

  DeityAvailabilityUseCase(this._officialRepo, this._userRepo);

  /// Returns true if [deityId] is in the [school]'s deity list
  /// (or the school has no filter, meaning all are available).
  Future<bool> call({
    required String schoolId,
    required String deityId,
  }) async {
    TaiYiSchool? school = await _officialRepo.loadSchool(schoolId);
    school ??= await _userRepo.loadSchool(schoolId);

    if (school == null) return false;

    // If the school has no deity filter, all are available
    if (school.deityIds.isEmpty) return true;

    return school.deityIds.contains(deityId);
  }
}
