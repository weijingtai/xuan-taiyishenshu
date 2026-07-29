import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

import 'taiyi_calculation_context.dart';
import 'taiyi_chart_calculator.dart';
import 'taiyi_chart_params.dart';

class TaiyiPipelineResult {
  final TaiyiDivinationRecordContract chart;

  const TaiyiPipelineResult({required this.chart});
}

class TaiyiPipelineExecutor {
  const TaiyiPipelineExecutor();

  Future<TaiyiPipelineResult> execute({
    required ResolvedMoment moment,
    required TaiyiChartParams params,
  }) async {
    final context = await TaiyiCalculationContext.load();
    final calculator = TaiyiChartCalculator(context: context);
    final chart = calculator.calculate(moment, params);
    return TaiyiPipelineResult(chart: chart);
  }
}
