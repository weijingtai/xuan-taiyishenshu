import 'school_config.dart';
import 'deity_definition.dart';
import 'chart_config.dart';
import 'deity_override.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'algorithm_enums.dart';
import '../../enums/deity_kind.dart';

// ---------------------------------------------------------------------------
// Re-export contract DTOs from the interface package
// (NOT re-exporting SchoolRepository/UserSchoolRepository/DeityRepository
// because this file defines product-typed versions for use by product code.)
// ---------------------------------------------------------------------------

export 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart'
    show
        TaiYiSchoolContract,
        DeityDefinitionContract,
        SchoolEpochConfigContract,
        DeityAlgorithmSpecContract,
        DeityPreferenceRepository,
        DummyDeityPreferenceRepository;

// ---------------------------------------------------------------------------
// Product-typed repository interfaces (used by product usecases/viewmodels)
//
// These are SEPARATE from the contract-typed ports in the interface package.
// Backends implement the contract-typed ports; the example host wraps them
// into these product-typed interfaces via adapter classes in taiyi_assembly.dart.
// ---------------------------------------------------------------------------

abstract class SchoolRepository {
  Future<List<TaiYiSchool>> loadAllSchools();
  Future<TaiYiSchool?> loadSchool(String id);
  Future<List<DeityDefinition>> loadAllDeities();
  Future<DeityDefinition?> loadDeity(String id);
  Future<void> saveSchool(TaiYiSchool school);
  Future<void> saveDeity(DeityDefinition deity);
  Future<void> deleteSchool(String id);
  Future<void> deleteDeity(String id);
}

abstract class UserSchoolRepository {
  Future<List<TaiYiSchool>> loadUserSchools();
  Future<TaiYiSchool?> loadSchool(String id);
  Future<void> saveUserSchool(TaiYiSchool school);
  Future<void> deleteUserSchool(String id);
}

abstract class DeityRepository {
  Future<List<DeityDefinition>> loadUserDeities();
  Future<DeityDefinition?> loadDeity(String id);
  Future<void> saveUserDeity(DeityDefinition deity);
  Future<void> deleteUserDeity(String id);
}

// DeityPreferenceRepository + DummyDeityPreferenceRepository re-exported from
// the interface package (they use only String/bool/Map — no product types).

// ---------------------------------------------------------------------------
// TaiYiSchool ↔ TaiYiSchoolContract (product boundary)
// ---------------------------------------------------------------------------

extension TaiYiSchoolProductMapper on TaiYiSchool {
  TaiYiSchoolContract toContract() {
    return TaiYiSchoolContract(
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

extension TaiYiSchoolContractProductMapper on TaiYiSchoolContract {
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

// ---------------------------------------------------------------------------
// SchoolEpochConfig ↔ SchoolEpochConfigContract
// ---------------------------------------------------------------------------

extension _SchoolEpochConfigProductMapper on SchoolEpochConfig {
  SchoolEpochConfigContract toContract() {
    return SchoolEpochConfigContract(
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

extension SchoolEpochConfigContractProductMapper on SchoolEpochConfigContract {
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

// ---------------------------------------------------------------------------
// DeityDefinition ↔ DeityDefinitionContract
// ---------------------------------------------------------------------------

extension DeityDefinitionProductMapper on DeityDefinition {
  DeityDefinitionContract toContract() {
    return DeityDefinitionContract(
      id: id,
      name: name,
      layer: layer.name,
      algorithm: DeityAlgorithmSpecContract(
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

extension DeityDefinitionContractProductMapper on DeityDefinitionContract {
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
