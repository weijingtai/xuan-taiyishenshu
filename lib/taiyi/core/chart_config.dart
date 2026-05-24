import 'package:json_annotation/json_annotation.dart';

part 'chart_config.g.dart';

@JsonSerializable()
class ChartConfig {
  final int dayOffset;
  final int hourOffset;
  final int zhangSui;
  final int zhangYue;
  final String hostGuestBase;
  final String? dayBaseSchoolId;
  final String? hourBaseSchoolId;

  const ChartConfig({
    this.dayOffset = 0,
    this.hourOffset = 0,
    this.zhangSui = 0,
    this.zhangYue = 0,
    this.hostGuestBase = 'default',
    this.dayBaseSchoolId,
    this.hourBaseSchoolId,
  });

  factory ChartConfig.fromJson(Map<String, dynamic> json) =>
      _$ChartConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ChartConfigToJson(this);
}
