import 'dart:convert';

import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

import '../../taiyi/taiyi_pan_calculator.dart';
import 'taiyi_calculation_context.dart';
import 'taiyi_chart_params.dart';

final class TaiyiChartCalculator
    implements ChartCalculator<TaiyiChartParams, TaiyiDivinationRecordContract> {
  final TaiyiCalculationContext context;

  const TaiyiChartCalculator({
    this.context = const TaiyiCalculationContext(),
  });

  @override
  String get module => 'taiyishenshu';

  @override
  TaiyiDivinationRecordContract calculate(
    ResolvedMoment moment,
    TaiyiChartParams params,
  ) {
    final calculator = const TaiYiPanCalculator();

    final panResult = calculator.calculate(
      dateTime: moment.nominalTime,
      schoolId: params.schoolId,
      chartType: params.chartType,
    );

    final paramsData = {
      'eightChars': moment.eightChars.toString(),
      'schoolId': params.schoolId,
      'chartType': params.chartType.name,
      'latitude': params.latitude,
      'longitude': params.longitude,
      'altitude': params.altitude,
      'timezone': params.timezone,
      'isMale': params.isMale,
    };

    return TaiyiDivinationRecordContract(
      uuid: params.uuid,
      question: '太乙神数排盘',
      datetimeJson: moment.nominalTime.toIso8601String(),
      schoolId: params.schoolId,
      juNumber: panResult.juNumber,
      taiYiPalaceJson: jsonEncode(panResult.taiYiPalace.name),
      ninePalaceJson: jsonEncode(panResult.palaces.map((p) => p.toJson()).toList()),
      deitiesJson: null,
      paramsJson: jsonEncode({
        ...paramsData,
        'panResult': panResult.toJson(),
      }),
      createdAt: moment.nominalTime,
      updatedAt: null,
      deletedAt: null,
    );
  }
}
