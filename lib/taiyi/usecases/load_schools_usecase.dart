import '../core/school_config.dart';
import '../core/school_repository.dart';

/// Loads all available schools (official + user).
class LoadSchoolsUseCase {
  final SchoolRepository _officialRepo;
  final UserSchoolRepository _userRepo;

  LoadSchoolsUseCase(this._officialRepo, this._userRepo);

  Future<List<TaiYiSchool>> call() async {
    final official = await _officialRepo.loadAllSchools();
    final user = await _userRepo.loadUserSchools();
    return [...official, ...user];
  }
}
