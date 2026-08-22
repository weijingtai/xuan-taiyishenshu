import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart'
    as contract;
import 'package:taiyishenshu/taiyi/core/school_repository.dart' as product;
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/chart_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_override.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';

/// Shared [RequestContext] for adapter calls (local anonymous scope).
final _ctx = RequestContext(scopeUid: 'local-anonymous');

/// Unwrap a [Result] or throw the error.
T _unwrap<T>(Result<T> result) => switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };

// ---------------------------------------------------------------------------
// Contract-to-Product Adapters
// ---------------------------------------------------------------------------

/// Wraps a contract-typed [contract.SchoolRepository] into a product-typed
/// [product.SchoolRepository].
class ContractOfficialSchoolAdapter implements product.SchoolRepository {
  final contract.SchoolRepository _inner;
  ContractOfficialSchoolAdapter(this._inner);

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async {
    final result = await _inner.query(const {}, PageRequest(limit: 100), _ctx);
    return _unwrap(result).items.map((c) => c.toModel()).toList();
  }

  @override
  Future<TaiYiSchool?> loadSchool(String id) async {
    final result = await _inner.get(id, _ctx);
    return _unwrap(result)?.toModel();
  }

  @override
  Future<List<DeityDefinition>> loadAllDeities() async {
    // Deity data comes from the DeityRepository, not SchoolRepository.
    // This adapter delegates to SchoolRepository only; deities are loaded
    // via the separate DeityRepository adapter.
    return [];
  }

  @override
  Future<DeityDefinition?> loadDeity(String id) async => null;

  @override
  Future<void> saveSchool(TaiYiSchool school) async {
    final result = await _inner.put(school.toContract(), _ctx);
    _unwrap(result);
  }

  @override
  Future<void> saveDeity(DeityDefinition deity) async {}

  @override
  Future<void> deleteSchool(String id) async {
    // Contract SchoolRepository doesn't expose a delete method.
    // Official schools are read-only; this should never be called.
    throw UnsupportedError('Cannot delete official school document');
  }

  @override
  Future<void> deleteDeity(String id) async {}
}

/// Wraps a contract-typed [contract.UserSchoolRepository] into a product-typed
/// [product.UserSchoolRepository].
class ContractUserSchoolAdapter implements product.UserSchoolRepository {
  final contract.UserSchoolRepository _inner;
  ContractUserSchoolAdapter(this._inner);

  @override
  Future<List<TaiYiSchool>> loadUserSchools() async {
    final result = await _inner.query(const {}, PageRequest(limit: 100), _ctx);
    return _unwrap(result).items.map((c) => c.toModel()).toList();
  }

  @override
  Future<TaiYiSchool?> loadSchool(String id) async {
    final result = await _inner.get(id, _ctx);
    return _unwrap(result)?.toModel();
  }

  @override
  Future<void> saveUserSchool(TaiYiSchool school) async {
    final result = await _inner.put(school.toContract(), _ctx);
    _unwrap(result);
  }

  @override
  Future<void> deleteUserSchool(String id) async {
    // Contract UserSchoolRepository doesn't expose a delete method directly.
    // Use put with an empty/null sentinel if needed in the future.
    throw UnsupportedError('Delete not yet supported on UserSchoolRepository L0 slice');
  }
}

/// Wraps a contract-typed [contract.DeityRepository] into a product-typed
/// [product.DeityRepository].
class ContractDeityAdapter implements product.DeityRepository {
  final contract.DeityRepository _inner;
  ContractDeityAdapter(this._inner);

  @override
  Future<List<DeityDefinition>> loadUserDeities() async {
    final result = await _inner.query(const {}, PageRequest(limit: 100), _ctx);
    return _unwrap(result).items.map((c) => c.toModel()).toList();
  }

  @override
  Future<DeityDefinition?> loadDeity(String id) async {
    final result = await _inner.get(id, _ctx);
    return _unwrap(result)?.toModel();
  }

  @override
  Future<void> saveUserDeity(DeityDefinition deity) async {
    final result = await _inner.put(deity.toContract(), _ctx);
    _unwrap(result);
  }

  @override
  Future<void> deleteUserDeity(String id) async {
    throw UnsupportedError('Delete not yet supported on DeityRepository L0 slice');
  }
}

/// Wraps a contract-typed [contract.DummyDeityPreferenceRepository] into a
/// product-typed [product.DummyDeityPreferenceRepository].
class ContractDummyPreferenceAdapter implements product.DeityPreferenceRepository {
  final contract.DummyDeityPreferenceRepository _inner;
  ContractDummyPreferenceAdapter(this._inner);

  @override
  Future<bool> isEnabled(String deityId) async {
    final result = await _inner.get(deityId, _ctx);
    return _unwrap(result) ?? true;
  }

  @override
  Future<void> setEnabled(String deityId, bool enabled) async {
    final result = await _inner.put(enabled, _ctx);
    _unwrap(result);
  }

  @override
  Future<Map<String, bool>> loadEnabledMap() async {
    // DummyDeityPreferenceRepository only stores a single boolean value,
    // not a map. Return an empty map for the dummy case.
    return {};
  }
}

// ---------------------------------------------------------------------------
// DTO Mappers (product <-> contract)
// ---------------------------------------------------------------------------

extension TaiYiSchoolProductMapper on TaiYiSchool {
  contract.TaiYiSchoolContract toContract() {
    return contract.TaiYiSchoolContract(
      id: id,
      name: name,
      source: source,
      epoch: epoch.toContract(),
      deityIds: deityIds,
      overrides: overrides,
      wenChangStayRule: wenChangStayRule,
      useTwelveJiShen: useTwelveJiShen,
      palaceFormula: palaceFormula,
      eightDoorMode: eightDoorMode,
      chartConfigs: {
        for (final e in chartConfigs.entries) e.key: e.value.toJson(),
      },
      deityConfigs: {
        for (final e in deityConfigs.entries) e.key: e.value.toJson(),
      },
      privateDeities: privateDeities,
      sourceId: sourceId,
      rootOfficialId: rootOfficialId,
      lineage: lineage,
    );
  }
}

extension TaiYiSchoolContractProductMapper on contract.TaiYiSchoolContract {
  TaiYiSchool toModel() {
    return TaiYiSchool(
      id: id,
      name: name,
      source: source,
      epoch: epoch.toModel(),
      deityIds: deityIds,
      overrides: overrides,
      wenChangStayRule: wenChangStayRule,
      useTwelveJiShen: useTwelveJiShen,
      palaceFormula: palaceFormula,
      eightDoorMode: eightDoorMode,
      chartConfigs: {
        for (final e in chartConfigs.entries)
          e.key: ChartConfig.fromJson(Map<String, dynamic>.from(e.value)),
      },
      deityConfigs: {
        for (final e in deityConfigs.entries)
          e.key: DeityOverride.fromJson(Map<String, dynamic>.from(e.value)),
      },
      privateDeities: privateDeities,
      sourceId: sourceId,
      rootOfficialId: rootOfficialId,
      lineage: lineage,
    );
  }
}

extension _SchoolEpochConfigProductMapper on SchoolEpochConfig {
  contract.SchoolEpochConfigContract toContract() {
    return contract.SchoolEpochConfigContract(
      ancientBase: ancientBase,
      epochYear: epochYear,
      correction: correction,
      tropicalYear: tropicalYear,
      ancientMonthBase: ancientMonthBase,
      ancientDayBase: ancientDayBase,
      ancientHourBase: ancientHourBase,
      zhangSui: zhangSui,
      zhangYue: zhangYue,
      dayOffset: dayOffset,
      hourOffset: hourOffset,
    );
  }
}

extension SchoolEpochConfigContractProductMapper on contract.SchoolEpochConfigContract {
  SchoolEpochConfig toModel() {
    return SchoolEpochConfig(
      ancientBase: ancientBase,
      epochYear: epochYear,
      correction: correction,
      tropicalYear: tropicalYear,
      ancientMonthBase: ancientMonthBase,
      ancientDayBase: ancientDayBase,
      ancientHourBase: ancientHourBase,
      zhangSui: zhangSui,
      zhangYue: zhangYue,
      dayOffset: dayOffset,
      hourOffset: hourOffset,
    );
  }
}

extension DeityDefinitionProductMapper on DeityDefinition {
  contract.DeityDefinitionContract toContract() {
    return contract.DeityDefinitionContract(
      id: id,
      name: name,
      layer: layer.name,
      algorithm: contract.DeityAlgorithmSpecContract(
        templateId: algorithm.templateId.name,
        params: algorithm.params,
      ),
      priority: priority,
      description: description,
      source: source,
      tier: tier,
      chartTypes: chartTypes,
      schoolScopes: schoolScopes,
      displayStyle: displayStyle,
      color: color,
      sourceId: sourceId,
      rootOfficialId: rootOfficialId,
      lineage: lineage,
    );
  }
}

extension DeityDefinitionContractProductMapper on contract.DeityDefinitionContract {
  DeityDefinition toModel() {
    return DeityDefinition(
      id: id,
      name: name,
      layer: EnumDeityLayer.values.byName(layer),
      algorithm: DeityAlgorithmSpec(
        templateId: AlgorithmTemplateId.values.byName(algorithm.templateId),
        params: algorithm.params,
      ),
      priority: priority,
      description: description,
      source: source,
      tier: tier,
      chartTypes: chartTypes,
      schoolScopes: schoolScopes,
      displayStyle: displayStyle,
      color: color,
      sourceId: sourceId,
      rootOfficialId: rootOfficialId,
      lineage: lineage,
    );
  }
}
