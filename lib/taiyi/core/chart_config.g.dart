// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartConfig _$ChartConfigFromJson(Map<String, dynamic> json) => ChartConfig(
      dayOffset: (json['dayOffset'] as num?)?.toInt() ?? 0,
      hourOffset: (json['hourOffset'] as num?)?.toInt() ?? 0,
      zhangSui: (json['zhangSui'] as num?)?.toInt() ?? 0,
      zhangYue: (json['zhangYue'] as num?)?.toInt() ?? 0,
      hostGuestBase: json['hostGuestBase'] as String? ?? 'default',
      dayBaseSchoolId: json['dayBaseSchoolId'] as String?,
      hourBaseSchoolId: json['hourBaseSchoolId'] as String?,
    );

Map<String, dynamic> _$ChartConfigToJson(ChartConfig instance) =>
    <String, dynamic>{
      'dayOffset': instance.dayOffset,
      'hourOffset': instance.hourOffset,
      'zhangSui': instance.zhangSui,
      'zhangYue': instance.zhangYue,
      'hostGuestBase': instance.hostGuestBase,
      'dayBaseSchoolId': instance.dayBaseSchoolId,
      'hourBaseSchoolId': instance.hourBaseSchoolId,
    };
