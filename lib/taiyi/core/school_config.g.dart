// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolEpochConfig _$SchoolEpochConfigFromJson(Map<String, dynamic> json) =>
    SchoolEpochConfig(
      ancientBase: (json['ancientBase'] as num).toInt(),
      epochYear: (json['epochYear'] as num).toInt(),
      correction: (json['correction'] as num?)?.toInt() ?? 0,
      tropicalYear: (json['tropicalYear'] as num?)?.toDouble() ?? 365.2425,
      ancientMonthBase: (json['ancientMonthBase'] as num?)?.toInt() ?? 0,
      ancientDayBase: (json['ancientDayBase'] as num?)?.toInt() ?? 0,
      ancientHourBase: (json['ancientHourBase'] as num?)?.toInt() ?? 0,
      zhangSui: (json['zhangSui'] as num?)?.toInt() ?? 0,
      zhangYue: (json['zhangYue'] as num?)?.toInt() ?? 0,
      dayOffset: (json['dayOffset'] as num?)?.toInt() ?? 0,
      hourOffset: (json['hourOffset'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SchoolEpochConfigToJson(SchoolEpochConfig instance) =>
    <String, dynamic>{
      'ancientBase': instance.ancientBase,
      'epochYear': instance.epochYear,
      'correction': instance.correction,
      'tropicalYear': instance.tropicalYear,
      'ancientMonthBase': instance.ancientMonthBase,
      'ancientDayBase': instance.ancientDayBase,
      'ancientHourBase': instance.ancientHourBase,
      'zhangSui': instance.zhangSui,
      'zhangYue': instance.zhangYue,
      'dayOffset': instance.dayOffset,
      'hourOffset': instance.hourOffset,
    };

TaiYiSchool _$TaiYiSchoolFromJson(Map<String, dynamic> json) => TaiYiSchool(
      id: json['id'] as String,
      name: json['name'] as String,
      epoch: SchoolEpochConfig.fromJson(json['epoch'] as Map<String, dynamic>),
      source: json['source'] as String? ?? 'official',
      deityIds: (json['deityIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      overrides: json['overrides'] as Map<String, dynamic>?,
      wenChangStayRule: json['wenChangStayRule'] as bool? ?? true,
      useTwelveJiShen: json['useTwelveJiShen'] as bool? ?? false,
      palaceFormula: json['palaceFormula'] as String? ?? 'jingMirror',
      eightDoorMode: json['eightDoorMode'] as String? ?? 'dynamic',
      chartConfigs: (json['chartConfigs'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, ChartConfig.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      deityConfigs: (json['deityConfigs'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, DeityOverride.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      privateDeities: (json['privateDeities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sourceId: json['sourceId'] as String?,
      rootOfficialId: json['rootOfficialId'] as String?,
      lineage: json['lineage'] as String?,
    );

Map<String, dynamic> _$TaiYiSchoolToJson(TaiYiSchool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'source': instance.source,
      'epoch': instance.epoch.toJson(),
      'deityIds': instance.deityIds,
      'overrides': instance.overrides,
      'wenChangStayRule': instance.wenChangStayRule,
      'useTwelveJiShen': instance.useTwelveJiShen,
      'palaceFormula': instance.palaceFormula,
      'eightDoorMode': instance.eightDoorMode,
      'chartConfigs':
          instance.chartConfigs.map((k, e) => MapEntry(k, e.toJson())),
      'deityConfigs':
          instance.deityConfigs.map((k, e) => MapEntry(k, e.toJson())),
      'privateDeities': instance.privateDeities,
      'sourceId': instance.sourceId,
      'rootOfficialId': instance.rootOfficialId,
      'lineage': instance.lineage,
    };
