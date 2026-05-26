import '../core/deity_definition.dart';
import '../core/school_repository.dart';

/// Copies a deity (official or user) to create a new user deity.
/// Generates lineage via description field.
class CopyDeityUseCase {
  final SchoolRepository _officialRepo;
  final DeityRepository _userRepo;

  CopyDeityUseCase(this._officialRepo, this._userRepo);

  /// [sourceId] — id of the source deity to copy.
  /// [newId] — id for the new deity.
  /// [newName] — display name for the new deity.
  Future<DeityDefinition> call({
    required String sourceId,
    required String newId,
    String? newName,
  }) async {
    DeityDefinition? source = await _officialRepo.loadDeity(sourceId);

    if (source != null) {
      final copied = source.copyWith(
        id: newId,
        name: newName ?? '${source.name}副本',
        source: 'user',
        sourceId: sourceId,
        rootOfficialId: source.rootOfficialId ?? sourceId,
        lineage: source.lineage != null ? '${source.lineage} -> $newId' : 'official($sourceId) -> $newId',
        description: '派生自官方星神: ${source.name}',
      );
      await _userRepo.saveUserDeity(copied);
      return copied;
    }

    source = await _userRepo.loadDeity(sourceId);
    if (source == null) {
      throw ArgumentError('Source deity not found: $sourceId');
    }

    final copied = source.copyWith(
      id: newId,
      name: newName ?? '${source.name}副本',
      source: 'user',
      sourceId: sourceId,
      rootOfficialId: source.rootOfficialId,
      lineage: '${source.lineage} -> $newId',
      description: '派生自用户星神: ${source.name}',
    );
    await _userRepo.saveUserDeity(copied);
    return copied;
  }
}
