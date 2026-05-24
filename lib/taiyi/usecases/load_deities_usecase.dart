import '../core/deity_definition.dart';
import '../core/school_repository.dart';

/// Loads all available deities (official + user).
class LoadDeitiesUseCase {
  final SchoolRepository _officialRepo;
  final DeityRepository _userRepo;

  LoadDeitiesUseCase(this._officialRepo, this._userRepo);

  Future<List<DeityDefinition>> call() async {
    final official = await _officialRepo.loadAllDeities();
    final user = await _userRepo.loadUserDeities();
    return [...official, ...user];
  }
}
