import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:xuan_time_location/xuan_time_location.dart';

import 'taiyi_calculation_context.dart';
import 'taiyi_chart_calculator.dart';
import 'taiyi_chart_params.dart';

final class TaiyiPipelineExecutor {
  final TaiyiCalculationContext _context;
  final MomentResolver _momentResolver;

  TaiyiPipelineExecutor({
    TaiyiCalculationContext? context,
    MomentResolver? momentResolver,
  }) : _context = context ?? const TaiyiCalculationContext(),
       _momentResolver = momentResolver ?? const DefaultMomentResolver();

  Future<TaiyiDivinationRecordContract> execute(
    ChartRequest<TaiyiChartParams> request,
  ) async {
    final moment = _momentResolver.resolve(request.moment);
    final calculator = TaiyiChartCalculator(context: _context);
    return calculator.calculate(moment, request.params);
  }
}
