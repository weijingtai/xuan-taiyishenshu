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

    if (source != null) {
      final copied = source.copyWith(
        id: newId,
        name: newName ?? '${source.name}副本',
        source: 'user',
        sourceId: sourceId,
        rootOfficialId: source.rootOfficialId ?? sourceId,
        lineage: source.lineage != null ? '${source.lineage} -> $newId' : 'official($sourceId) -> $newId',
      );
      await _userRepo.saveUserSchool(copied);
      return copied;
    }

    source = await _userRepo.loadSchool(sourceId);
    if (source == null) {
      throw ArgumentError('Source school not found: $sourceId');
    }

    final copied = source.copyWith(
      id: newId,
      name: newName ?? '${source.name}副本',
      source: 'user',
      sourceId: sourceId,
      rootOfficialId: source.rootOfficialId,
      lineage: '${source.lineage} -> $newId',
    );

    await _userRepo.saveUserSchool(copied);
    return copied;
  }
}
