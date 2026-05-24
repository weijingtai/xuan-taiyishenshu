import 'package:json_annotation/json_annotation.dart';
import 'chart_config.dart';
import 'deity_override.dart';

part 'school_config.g.dart';

@JsonSerializable()
class SchoolEpochConfig {
  final int ancientBase;
  final int epochYear;
  final int correction;
  final double tropicalYear;

  const SchoolEpochConfig({
    required this.ancientBase,
    required this.epochYear,
    this.correction = 0,
    this.tropicalYear = 365.2425,
  });

  int calculateAccumulatedYear(int targetYear) {
    return ancientBase + (targetYear - epochYear) + correction;
  }

  SchoolEpochConfig copyWith({int? correction}) {
    return SchoolEpochConfig(
      ancientBase: ancientBase,
      epochYear: epochYear,
      correction: correction ?? this.correction,
      tropicalYear: tropicalYear,
    );
  }

  factory SchoolEpochConfig.fromJson(Map<String, dynamic> json) =>
      _$SchoolEpochConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SchoolEpochConfigToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TaiYiSchool {
  final String id;
  final String name;
  final String source;
  final SchoolEpochConfig epoch;
  final List<String> deityIds;
  final Map<String, dynamic>? overrides;
  final bool wenChangStayRule;
  final bool useTwelveJiShen;
  final String palaceFormula;
  final String eightDoorMode;
  final Map<String, ChartConfig> chartConfigs;
  final Map<String, DeityOverride> deityConfigs;
  final List<String> privateDeities;

  const TaiYiSchool({
    required this.id,
    required this.name,
    required this.epoch,
    this.source = 'official',
    this.deityIds = const [],
    this.overrides,
    this.wenChangStayRule = true,
    this.useTwelveJiShen = false,
    this.palaceFormula = 'jingMirror',
    this.eightDoorMode = 'dynamic',
    this.chartConfigs = const {},
    this.deityConfigs = const {},
    this.privateDeities = const [],
  });

  TaiYiSchool copyWith({
    String? id,
    String? name,
    String? source,
    SchoolEpochConfig? epoch,
    List<String>? deityIds,
    Map<String, dynamic>? overrides,
    bool? wenChangStayRule,
    bool? useTwelveJiShen,
    String? palaceFormula,
    String? eightDoorMode,
    Map<String, ChartConfig>? chartConfigs,
    Map<String, DeityOverride>? deityConfigs,
    List<String>? privateDeities,
  }) {
    return TaiYiSchool(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      epoch: epoch ?? this.epoch,
      deityIds: deityIds ?? this.deityIds,
      overrides: overrides ?? this.overrides,
      wenChangStayRule: wenChangStayRule ?? this.wenChangStayRule,
      useTwelveJiShen: useTwelveJiShen ?? this.useTwelveJiShen,
      palaceFormula: palaceFormula ?? this.palaceFormula,
      eightDoorMode: eightDoorMode ?? this.eightDoorMode,
      chartConfigs: chartConfigs ?? this.chartConfigs,
      deityConfigs: deityConfigs ?? this.deityConfigs,
      privateDeities: privateDeities ?? this.privateDeities,
    );
  }

  factory TaiYiSchool.fromJson(Map<String, dynamic> json) =>
      _$TaiYiSchoolFromJson(json);
  Map<String, dynamic> toJson() => _$TaiYiSchoolToJson(this);
}
