import 'package:json_annotation/json_annotation.dart';
import 'deity_definition.dart';

part 'deity_override.g.dart';

@JsonSerializable()
class DeityOverride {
  final bool active;
  final int correction;
  final Map<String, dynamic> params;
  final DeityAlgorithmSpec? algorithm;

  const DeityOverride({
    this.active = true,
    this.correction = 0,
    this.params = const {},
    this.algorithm,
  });

  factory DeityOverride.fromJson(Map<String, dynamic> json) =>
      _$DeityOverrideFromJson(json);
  Map<String, dynamic> toJson() => _$DeityOverrideToJson(this);
}
