import '../core/school_repository.dart';

class DeleteUserDeityUseCase {
  final DeityRepository repository;

  DeleteUserDeityUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteUserDeity(id);
  }
}
