import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';

void main() {
  const calculator = TaiYiPanCalculator();

  group('Official Schools Regression - Year Chart', () {
    test('金镜派 2026年 积年/局数验证', () {
      final result = calculator.calculate(
        dateTime: DateTime(2026, 5, 23),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
      
      expect(result.accumulatedYear, 1938583);
      expect(result.juNumber, 55);
    });

    test('统宗派 2026年 积年/局数验证', () {
      final result = calculator.calculate(
        dateTime: DateTime(2026, 5, 23),
        schoolId: 'tongZong',
        chartType: TaiYiChartType.year,
      );
      
      expect(result.accumulatedYear, 10155943);
      expect(result.juNumber, 55);
    });

    test('集成派 2026年 积年验证', () {
      final result = calculator.calculate(
        dateTime: DateTime(2026, 5, 23),
        schoolId: 'jiCheng',
        chartType: TaiYiChartType.year,
      );
      
      // 2026 - 1684 + 1 = 343
      expect(result.accumulatedYear, 343);
    });
  });
}
