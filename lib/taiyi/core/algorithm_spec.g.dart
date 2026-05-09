// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'algorithm_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PalaceStep _$PalaceStepFromJson(Map<String, dynamic> json) => PalaceStep(
      palace: json['palace'] as String,
      staySteps: (json['staySteps'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$PalaceStepToJson(PalaceStep instance) =>
    <String, dynamic>{
      'palace': instance.palace,
      'staySteps': instance.staySteps,
    };

CycleStep _$CycleStepFromJson(Map<String, dynamic> json) => CycleStep(
      cycle: (json['cycle'] as num).toInt(),
      step: (json['step'] as num).toInt(),
      label: json['label'] as String,
    );

Map<String, dynamic> _$CycleStepToJson(CycleStep instance) => <String, dynamic>{
      'cycle': instance.cycle,
      'step': instance.step,
      'label': instance.label,
    };

DunVariantConfig _$DunVariantConfigFromJson(Map<String, dynamic> json) =>
    DunVariantConfig(
      direction: $enumDecode(_$WalkDirectionEnumMap, json['direction']),
      palaceSeq: (json['palaceSeq'] as List<dynamic>)
          .map((e) => PalaceStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      startPalace: json['startPalace'] as String,
    );

Map<String, dynamic> _$DunVariantConfigToJson(DunVariantConfig instance) =>
    <String, dynamic>{
      'direction': _$WalkDirectionEnumMap[instance.direction]!,
      'palaceSeq': instance.palaceSeq,
      'startPalace': instance.startPalace,
    };

const _$WalkDirectionEnumMap = {
  WalkDirection.forward: 'forward',
  WalkDirection.reverse: 'reverse',
};

SteppedCycleParams _$SteppedCycleParamsFromJson(Map<String, dynamic> json) =>
    SteppedCycleParams(
      correction: (json['correction'] as num?)?.toInt() ?? 0,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => CycleStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      palaceSystem: $enumDecode(_$PalaceSystemEnumMap, json['palaceSystem']),
      palaceSeq: (json['palaceSeq'] as List<dynamic>?)
          ?.map((e) => PalaceStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      direction: $enumDecodeNullable(_$WalkDirectionEnumMap, json['direction']),
      startPalace: json['startPalace'] as String?,
      dunBinding: $enumDecodeNullable(_$DunTypeEnumMap, json['dunBinding']),
      yangConfig: json['yangConfig'] == null
          ? null
          : DunVariantConfig.fromJson(
              json['yangConfig'] as Map<String, dynamic>),
      yinConfig: json['yinConfig'] == null
          ? null
          : DunVariantConfig.fromJson(
              json['yinConfig'] as Map<String, dynamic>),
      chartRestriction: (json['chartRestriction'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$TaiYiChartTypeEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$SteppedCycleParamsToJson(SteppedCycleParams instance) =>
    <String, dynamic>{
      'correction': instance.correction,
      'steps': instance.steps,
      'palaceSystem': _$PalaceSystemEnumMap[instance.palaceSystem]!,
      'palaceSeq': instance.palaceSeq,
      'direction': _$WalkDirectionEnumMap[instance.direction],
      'startPalace': instance.startPalace,
      'dunBinding': _$DunTypeEnumMap[instance.dunBinding],
      'yangConfig': instance.yangConfig,
      'yinConfig': instance.yinConfig,
      'chartRestriction': instance.chartRestriction
          ?.map((e) => _$TaiYiChartTypeEnumMap[e]!)
          .toList(),
    };

const _$PalaceSystemEnumMap = {
  PalaceSystem.nineGong: 'nineGong',
  PalaceSystem.sixteenZhengJian: 'sixteenZhengJian',
  PalaceSystem.mixed: 'mixed',
};

const _$DunTypeEnumMap = {
  DunType.yang: 'yang',
  DunType.yin: 'yin',
};

const _$TaiYiChartTypeEnumMap = {
  TaiYiChartType.year: 'year',
  TaiYiChartType.month: 'month',
  TaiYiChartType.day: 'day',
  TaiYiChartType.hour: 'hour',
  TaiYiChartType.ke: 'ke',
};
