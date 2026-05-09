import 'package:json_annotation/json_annotation.dart';

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

  factory SchoolEpochConfig.fromJson(Map<String, dynamic> json) =>
      _$SchoolEpochConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SchoolEpochConfigToJson(this);
}

@JsonSerializable()
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
  });

  factory TaiYiSchool.fromJson(Map<String, dynamic> json) =>
      _$TaiYiSchoolFromJson(json);
  Map<String, dynamic> toJson() => _$TaiYiSchoolToJson(this);
}
