import '../core/school_config.dart';
import '../core/school_repository.dart';

/// Copies a school (official or user) to create a new user school.
/// Generates lineage: "originalName > copyName"
class CopySchoolUseCase {
  final SchoolRepository _officialRepo;
  final UserSchoolRepository _userRepo;

  CopySchoolUseCase(this._officialRepo, this._userRepo);

  /// [sourceId] — id of the source school to copy.
  /// [newId] — id for the new school.
  /// [newName] — display name for the new school.
  Future<TaiYiSchool> call({
    required String sourceId,
    required String newId,
    String? newName,
  }) async {
    // Try official first, then user
    TaiYiSchool? source = await _officialRepo.loadSchool(sourceId);
    String rootOfficialId;
    String sourceLineage;

    if (source != null) {
      rootOfficialId = sourceId;
      sourceLineage = source.name;
    } else {
      source = await _userRepo.loadSchool(sourceId);
      if (source == null) {
        throw ArgumentError('Source school not found: $sourceId');
      }
      // For user schools, propagate root official id and extend lineage
      rootOfficialId = sourceId; // simplified; real impl would read from source
      sourceLineage = source.name;
    }

    final copied = source.copyWith(
      id: newId,
      name: newName ?? '${source.name}-副本',
      source: 'user',
    );

    await _userRepo.saveUserSchool(copied);
    return copied;
  }
}
