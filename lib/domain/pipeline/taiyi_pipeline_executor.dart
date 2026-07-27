import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

import 'taiyi_chart_calculator.dart';
import 'taiyi_chart_params.dart';

class TaiyiPipelineResult {
  final TaiyiDivinationRecordContract chart;

  const TaiyiPipelineResult({required this.chart});
}

class TaiyiPipelineExecutor {
  const TaiyiPipelineExecutor();

  TaiyiPipelineResult execute({
    required ResolvedMoment moment,
    required TaiyiChartParams params,
  }) {
    final calculator = const TaiyiChartCalculator();
    final chart = calculator.calculate(moment, params);
    return TaiyiPipelineResult(chart: chart);
  }
}
