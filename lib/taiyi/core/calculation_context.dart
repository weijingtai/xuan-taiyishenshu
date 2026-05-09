import '../../enums/gong.dart';
import '../pan_enums.dart';

class CalculationContext {
  final int ji;
  final int year;
  final int juNumber;
  final DunType dun;
  final TaiYiChartType chartType;
  final Map<String, DeityPlacementResult> computedDeities;

  const CalculationContext({
    required this.ji,
    required this.year,
    required this.juNumber,
    required this.dun,
    required this.chartType,
    this.computedDeities = const {},
  });

  CalculationContext copyWith({
    Map<String, DeityPlacementResult>? computedDeities,
  }) {
    return CalculationContext(
      ji: ji,
      year: year,
      juNumber: juNumber,
      dun: dun,
      chartType: chartType,
      computedDeities: computedDeities ?? this.computedDeities,
    );
  }
}

class DeityPlacementResult {
  final EnumTaiYiGong? gong;
  final List<StepResult> steps;
  final String? formula;
  final String? note;

  const DeityPlacementResult({
    this.gong,
    this.steps = const [],
    this.formula,
    this.note,
  });
}

class StepResult {
  final String label;
  final int quotient;
  final String quotientLabel;
  final int remainder;
  final String remainderLabel;

  const StepResult({
    required this.label,
    required this.quotient,
    required this.quotientLabel,
    required this.remainder,
    required this.remainderLabel,
  });
}
