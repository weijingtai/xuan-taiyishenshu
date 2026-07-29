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

  const TaiyiChartParams({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timezone,
    this.isMale = false,
    this.schoolId = 'jingMirror',
    this.chartType = TaiYiChartType.year,
  });

  @override
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'timezone': timezone,
    'isMale': isMale,
    'schoolId': schoolId,
    'chartType': chartType.name,
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
  ];
}
