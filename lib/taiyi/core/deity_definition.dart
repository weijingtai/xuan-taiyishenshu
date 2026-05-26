import 'package:json_annotation/json_annotation.dart';
import '../../enums/deity_kind.dart';
import 'algorithm_enums.dart';

part 'deity_definition.g.dart';

@JsonSerializable()
class DeityAlgorithmSpec {
  final AlgorithmTemplateId templateId;
  final Map<String, dynamic> params;

  const DeityAlgorithmSpec({
    required this.templateId,
    this.params = const {},
  });

  factory DeityAlgorithmSpec.fromJson(Map<String, dynamic> json) =>
      _$DeityAlgorithmSpecFromJson(json);
  Map<String, dynamic> toJson() => _$DeityAlgorithmSpecToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DeityDefinition {
  final String id;
  final String name;
  final EnumDeityLayer layer;
  final DeityAlgorithmSpec algorithm;
  final int priority;
  final String? description;
  final String source;
  final String tier;
  final List<String> chartTypes;
  final List<String> schoolScopes;
  final String? displayStyle;
  final String? color;
  
  // Derivation tracking
  final String? sourceId;
  final String? rootOfficialId;
  final String? lineage;

  const DeityDefinition({
    required this.id,
    required this.name,
    required this.layer,
    required this.algorithm,
    this.priority = 50,
    this.description,
    this.source = 'official',
    this.tier = 'core',
    this.chartTypes = const [],
    this.schoolScopes = const [],
    this.displayStyle,
    this.color,
    this.sourceId,
    this.rootOfficialId,
    this.lineage,
  });

  DeityDefinition copyWith({
    String? id,
    String? name,
    EnumDeityLayer? layer,
    DeityAlgorithmSpec? algorithm,
    int? priority,
    String? description,
    String? source,
    String? tier,
    List<String>? chartTypes,
    List<String>? schoolScopes,
    String? displayStyle,
    String? color,
    String? sourceId,
    String? rootOfficialId,
    String? lineage,
  }) {
    return DeityDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      layer: layer ?? this.layer,
      algorithm: algorithm ?? this.algorithm,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      source: source ?? this.source,
      tier: tier ?? this.tier,
      chartTypes: chartTypes ?? this.chartTypes,
      schoolScopes: schoolScopes ?? this.schoolScopes,
      displayStyle: displayStyle ?? this.displayStyle,
      color: color ?? this.color,
      sourceId: sourceId ?? this.sourceId,
      rootOfficialId: rootOfficialId ?? this.rootOfficialId,
      lineage: lineage ?? this.lineage,
    );
  }

  factory DeityDefinition.fromJson(Map<String, dynamic> json) =>
      _$DeityDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$DeityDefinitionToJson(this);
}
