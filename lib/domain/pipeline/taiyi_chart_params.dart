import 'package:equatable/equatable.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';

import '../../taiyi/pan_enums.dart';

class TaiyiChartParams extends Equatable implements ModuleParams {
  final double latitude;
  final double longitude;
  final double altitude;
  final String timezone;
  final bool isMale;
  final String schoolId;
  final TaiYiChartType chartType;

  /// 记录唯一标识，空串时由 Calculator 落空 uuid。
  final String uuid;

  const TaiyiChartParams({
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.altitude = 0.0,
    this.timezone = 'Asia/Shanghai',
    this.isMale = false,
    this.schoolId = 'jingMirror',
    this.chartType = TaiYiChartType.year,
    this.uuid = '',
  });

  /// JSON 解码器（与 [toJson] 互逆）。
  ///
  /// - 缺字段套默认（坐标 0.0、时区 `Asia/Shanghai`、`isMale` false、
  ///   `schoolId` `jingMirror`、`chartType` year），不抛错。
  /// - 字段存在但类型不合法（如 `latitude: '39.9'`、`timezone: 42`、
  ///   `isMale: 'yes'`）或 `chartType` 非合法枚举名时抛 [FormatException]，
  ///   不静默兜底。
  factory TaiyiChartParams.fromJson(Map<String, dynamic> json) {
    final latitudeRaw = json['latitude'];
    if (latitudeRaw != null && latitudeRaw is! num) {
      throw FormatException('latitude 类型不合法: $latitudeRaw');
    }
    final longitudeRaw = json['longitude'];
    if (longitudeRaw != null && longitudeRaw is! num) {
      throw FormatException('longitude 类型不合法: $longitudeRaw');
    }
    final altitudeRaw = json['altitude'];
    if (altitudeRaw != null && altitudeRaw is! num) {
      throw FormatException('altitude 类型不合法: $altitudeRaw');
    }
    final timezoneRaw = json['timezone'];
    if (timezoneRaw != null && timezoneRaw is! String) {
      throw FormatException('timezone 类型不合法: $timezoneRaw');
    }
    final isMaleRaw = json['isMale'];
    if (isMaleRaw != null && isMaleRaw is! bool) {
      throw FormatException('isMale 类型不合法: $isMaleRaw');
    }
    final schoolIdRaw = json['schoolId'];
    if (schoolIdRaw != null && schoolIdRaw is! String) {
      throw FormatException('schoolId 类型不合法: $schoolIdRaw');
    }
    final chartTypeRaw = json['chartType'];
    if (chartTypeRaw != null) {
      if (chartTypeRaw is! String) {
        throw FormatException('chartType 类型不合法: $chartTypeRaw');
      }
      final matched = TaiYiChartType.values
          .where((e) => e.name == chartTypeRaw)
          .toList(growable: false);
      if (matched.isEmpty) {
        throw FormatException('chartType 非合法枚举名: $chartTypeRaw');
      }
    }
    final uuidRaw = json['uuid'];
    if (uuidRaw != null && uuidRaw is! String) {
      throw FormatException('uuid 类型不合法: $uuidRaw');
    }

    return TaiyiChartParams(
      latitude: (latitudeRaw as num?)?.toDouble() ?? 0.0,
      longitude: (longitudeRaw as num?)?.toDouble() ?? 0.0,
      altitude: (altitudeRaw as num?)?.toDouble() ?? 0.0,
      timezone: (timezoneRaw as String?) ?? 'Asia/Shanghai',
      isMale: (isMaleRaw as bool?) ?? false,
      schoolId: (schoolIdRaw as String?) ?? 'jingMirror',
      chartType: chartTypeRaw == null
          ? TaiYiChartType.year
          : TaiYiChartType.values.firstWhere((e) => e.name == chartTypeRaw),
      uuid: (uuidRaw as String?) ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'timezone': timezone,
    'isMale': isMale,
    'schoolId': schoolId,
    'chartType': chartType.name,
    'uuid': uuid,
  };

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    altitude,
    timezone,
    isMale,
    schoolId,
    chartType,
    uuid,
  ];
}
