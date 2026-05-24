import '../core/deity_definition.dart';
import '../core/school_repository.dart';

/// Saves a user deity with lineage tracking.
class SaveUserDeityUseCase {
  final DeityRepository _userRepo;

  SaveUserDeityUseCase(this._userRepo);

  Future<void> call(DeityDefinition deity) async {
    await _userRepo.saveUserDeity(deity);
  }
}
