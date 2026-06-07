import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart'
    as contract;
import 'package:persistence_preferences/taiyishenshu/taiyishenshu_preferences.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart' as product;
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/chart_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_override.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';

// ---------------------------------------------------------------------------
// Contract-to-Product Adapters
// ---------------------------------------------------------------------------

/// Wraps a contract-typed [contract.SchoolRepository] into a product-typed
/// [product.SchoolRepository].
class ContractOfficialSchoolAdapter implements product.SchoolRepository {
  final contract.SchoolRepository _inner;
  ContractOfficialSchoolAdapter(this._inner);

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async =>
      (await _inner.loadAllSchools()).map((c) => c.toModel()).toList();

  @override
  Future<TaiYiSchool?> loadSchool(String id) async =>
      (await _inner.loadSchool(id))?.toModel();

  @override
  Future<List<DeityDefinition>> loadAllDeities() async =>
      (await _inner.loadAllDeities()).map((c) => c.toModel()).toList();

  @override
  Future<DeityDefinition?> loadDeity(String id) async =>
      (await _inner.loadDeity(id))?.toModel();

  @override
  Future<void> saveSchool(TaiYiSchool school) =>
      _inner.saveSchool(school.toContract());

  @override
  Future<void> saveDeity(DeityDefinition deity) =>
      _inner.saveDeity(deity.toContract());

  @override
  Future<void> deleteSchool(String id) => _inner.deleteSchool(id);

  @override
  Future<void> deleteDeity(String id) => _inner.deleteDeity(id);
}

/// Wraps a contract-typed [contract.UserSchoolRepository] into a product-typed
/// [product.UserSchoolRepository].
class ContractUserSchoolAdapter implements product.UserSchoolRepository {
  final contract.UserSchoolRepository _inner;
  ContractUserSchoolAdapter(this._inner);

  @override
  Future<List<TaiYiSchool>> loadUserSchools() async =>
      (await _inner.loadUserSchools()).map((c) => c.toModel()).toList();

  @override
  Future<TaiYiSchool?> loadSchool(String id) async =>
      (await _inner.loadSchool(id))?.toModel();

  @override
  Future<void> saveUserSchool(TaiYiSchool school) =>
      _inner.saveUserSchool(school.toContract());

  @override
  Future<void> deleteUserSchool(String id) => _inner.deleteUserSchool(id);
}

/// Wraps a contract-typed [contract.DeityRepository] into a product-typed
/// [product.DeityRepository].
class ContractDeityAdapter implements product.DeityRepository {
  final contract.DeityRepository _inner;
  ContractDeityAdapter(this._inner);

  @override
  Future<List<DeityDefinition>> loadUserDeities() async =>
      (await _inner.loadUserDeities()).map((c) => c.toModel()).toList();

  @override
  Future<DeityDefinition?> loadDeity(String id) async =>
      (await _inner.loadDeity(id))?.toModel();

  @override
  Future<void> saveUserDeity(DeityDefinition deity) =>
      _inner.saveUserDeity(deity.toContract());

  @override
  Future<void> deleteUserDeity(String id) => _inner.deleteUserDeity(id);
}

/// Wraps a contract-typed [contract.DummyDeityPreferenceRepository] into a
/// product-typed [product.DummyDeityPreferenceRepository].
class ContractDummyPreferenceAdapter implements product.DeityPreferenceRepository {
  final contract.DummyDeityPreferenceRepository _inner;
  ContractDummyPreferenceAdapter(this._inner);

  @override
  Future<bool> isEnabled(String deityId) => _inner.isEnabled(deityId);

  @override
  Future<void> setEnabled(String deityId, bool enabled) =>
      _inner.setEnabled(deityId, enabled);

  @override
  Future<Map<String, bool>> loadEnabledMap() => _inner.loadEnabledMap();
}

/// Wraps a [SharedPreferencesDeityPreferenceRepository] into a
/// product-typed [product.DeityPreferenceRepository].
class SharedPreferenceAdapter implements product.DeityPreferenceRepository {
  final SharedPreferencesDeityPreferenceRepository _inner;
  SharedPreferenceAdapter(this._inner);

  @override
  Future<bool> isEnabled(String deityId) => _inner.isEnabled(deityId);

  @override
  Future<void> setEnabled(String deityId, bool enabled) =>
      _inner.setEnabled(deityId, enabled);

  @override
  Future<Map<String, bool>> loadEnabledMap() => _inner.loadEnabledMap();
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
