// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deity_override.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeityOverride _$DeityOverrideFromJson(Map<String, dynamic> json) =>
    DeityOverride(
      active: json['active'] as bool? ?? true,
      correction: (json['correction'] as num?)?.toInt() ?? 0,
      params: json['params'] as Map<String, dynamic>? ?? const {},
      algorithm: json['algorithm'] == null
          ? null
          : DeityAlgorithmSpec.fromJson(
              json['algorithm'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeityOverrideToJson(DeityOverride instance) =>
    <String, dynamic>{
      'active': instance.active,
      'correction': instance.correction,
      'params': instance.params,
      'algorithm': instance.algorithm,
    };
