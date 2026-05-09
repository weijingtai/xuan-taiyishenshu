import 'package:json_annotation/json_annotation.dart';
import '../pan_enums.dart';
import 'algorithm_enums.dart';

part 'algorithm_spec.g.dart';

@JsonSerializable()
class PalaceStep {
  final String palace;
  final int staySteps;

  const PalaceStep({required this.palace, this.staySteps = 1});

  factory PalaceStep.fromJson(Map<String, dynamic> json) =>
      _$PalaceStepFromJson(json);
  Map<String, dynamic> toJson() => _$PalaceStepToJson(this);
}

@JsonSerializable()
class CycleStep {
  final int cycle;
  final int step;
  final String label;

  const CycleStep({
    required this.cycle,
    required this.step,
    required this.label,
  });

  factory CycleStep.fromJson(Map<String, dynamic> json) =>
      _$CycleStepFromJson(json);
  Map<String, dynamic> toJson() => _$CycleStepToJson(this);
}

@JsonSerializable()
class DunVariantConfig {
  final WalkDirection direction;
  final List<PalaceStep> palaceSeq;
  final String startPalace;

  const DunVariantConfig({
    required this.direction,
    required this.palaceSeq,
    required this.startPalace,
  });

  factory DunVariantConfig.fromJson(Map<String, dynamic> json) =>
      _$DunVariantConfigFromJson(json);
  Map<String, dynamic> toJson() => {
        'direction': _$WalkDirectionEnumMap[direction]!,
        'palaceSeq': palaceSeq.map((e) => e.toJson()).toList(),
        'startPalace': startPalace,
      };
}

@JsonSerializable()
class SteppedCycleParams {
  final int correction;
  final List<CycleStep> steps;
  final PalaceSystem palaceSystem;
  final List<PalaceStep>? palaceSeq;
  final WalkDirection? direction;
  final String? startPalace;
  final DunType? dunBinding;
  final DunVariantConfig? yangConfig;
  final DunVariantConfig? yinConfig;
  final List<TaiYiChartType>? chartRestriction;

  const SteppedCycleParams({
    this.correction = 0,
    required this.steps,
    required this.palaceSystem,
    this.palaceSeq,
    this.direction,
    this.startPalace,
    this.dunBinding,
    this.yangConfig,
    this.yinConfig,
    this.chartRestriction,
  });

  factory SteppedCycleParams.fromJson(Map<String, dynamic> json) =>
      _$SteppedCycleParamsFromJson(json);
  Map<String, dynamic> toJson() => {
        'correction': correction,
        'steps': steps.map((e) => e.toJson()).toList(),
        'palaceSystem': _$PalaceSystemEnumMap[palaceSystem]!,
        if (palaceSeq != null)
          'palaceSeq': palaceSeq!.map((e) => e.toJson()).toList(),
        if (direction != null)
          'direction': _$WalkDirectionEnumMap[direction],
        if (startPalace != null) 'startPalace': startPalace,
        if (dunBinding != null)
          'dunBinding': _$DunTypeEnumMap[dunBinding],
        if (yangConfig != null) 'yangConfig': yangConfig!.toJson(),
        if (yinConfig != null) 'yinConfig': yinConfig!.toJson(),
        if (chartRestriction != null)
          'chartRestriction':
              chartRestriction!.map((e) => _$TaiYiChartTypeEnumMap[e]!).toList(),
      };
}
