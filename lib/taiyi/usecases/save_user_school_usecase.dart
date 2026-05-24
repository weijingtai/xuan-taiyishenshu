import '../core/school_config.dart';
import '../core/school_repository.dart';

/// Saves a user school with lineage tracking.
class SaveUserSchoolUseCase {
  final UserSchoolRepository _userRepo;

  SaveUserSchoolUseCase(this._userRepo);

  Future<void> call(TaiYiSchool school) async {
    await _userRepo.saveUserSchool(school);
  }
}
