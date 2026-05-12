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

@JsonSerializable()
class DeityDefinition {
  final String id;
  final String name;
  final EnumDeityLayer layer;
  final DeityAlgorithmSpec algorithm;
  final int priority;
  final String? description;
  final String source;

  const DeityDefinition({
    required this.id,
    required this.name,
    required this.layer,
    required this.algorithm,
    this.priority = 50,
    this.description,
    this.source = 'official',
  });

  factory DeityDefinition.fromJson(Map<String, dynamic> json) =>
      _$DeityDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$DeityDefinitionToJson(this);
}
