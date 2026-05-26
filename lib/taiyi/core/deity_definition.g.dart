// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deity_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeityAlgorithmSpec _$DeityAlgorithmSpecFromJson(Map<String, dynamic> json) =>
    DeityAlgorithmSpec(
      templateId: $enumDecode(_$AlgorithmTemplateIdEnumMap, json['templateId']),
      params: json['params'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DeityAlgorithmSpecToJson(DeityAlgorithmSpec instance) =>
    <String, dynamic>{
      'templateId': _$AlgorithmTemplateIdEnumMap[instance.templateId]!,
      'params': instance.params,
    };

const _$AlgorithmTemplateIdEnumMap = {
  AlgorithmTemplateId.steppedCycle: 'steppedCycle',
  AlgorithmTemplateId.branchWalker: 'branchWalker',
  AlgorithmTemplateId.cumulativeWalk: 'cumulativeWalk',
  AlgorithmTemplateId.relativeOffset: 'relativeOffset',
  AlgorithmTemplateId.fixedPosition: 'fixedPosition',
  AlgorithmTemplateId.customFormula: 'customFormula',
};

DeityDefinition _$DeityDefinitionFromJson(Map<String, dynamic> json) =>
    DeityDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      layer: $enumDecode(_$EnumDeityLayerEnumMap, json['layer']),
      algorithm: DeityAlgorithmSpec.fromJson(
          json['algorithm'] as Map<String, dynamic>),
      priority: (json['priority'] as num?)?.toInt() ?? 50,
      description: json['description'] as String?,
      source: json['source'] as String? ?? 'official',
      tier: json['tier'] as String? ?? 'core',
      chartTypes: (json['chartTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      schoolScopes: (json['schoolScopes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      displayStyle: json['displayStyle'] as String?,
      color: json['color'] as String?,
      sourceId: json['sourceId'] as String?,
      rootOfficialId: json['rootOfficialId'] as String?,
      lineage: json['lineage'] as String?,
    );

Map<String, dynamic> _$DeityDefinitionToJson(DeityDefinition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'layer': _$EnumDeityLayerEnumMap[instance.layer]!,
      'algorithm': instance.algorithm.toJson(),
      'priority': instance.priority,
      'description': instance.description,
      'source': instance.source,
      'tier': instance.tier,
      'chartTypes': instance.chartTypes,
      'schoolScopes': instance.schoolScopes,
      'displayStyle': instance.displayStyle,
      'color': instance.color,
      'sourceId': instance.sourceId,
      'rootOfficialId': instance.rootOfficialId,
      'lineage': instance.lineage,
    };

const _$EnumDeityLayerEnumMap = {
  EnumDeityLayer.diPan: 'diPan',
  EnumDeityLayer.renPan: 'renPan',
  EnumDeityLayer.tianPan: 'tianPan',
  EnumDeityLayer.shenPan: 'shenPan',
  EnumDeityLayer.mingPan: 'mingPan',
};
