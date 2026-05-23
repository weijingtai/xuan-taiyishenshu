import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/taiyi/taiyi.dart';
import '../../lib/taiyi/pan_enums.dart';

void main() {
  group('TaiYi Metadata Verification (Month/Day/Hour)', () {
    late TaiYiPanCalculator calculator;
    late List<dynamic> testVectors;

    setUpAll(() {
      calculator = const TaiYiPanCalculator();
      // 这里的路径取决于测试运行时的根目录
      final file =
          File('../test-vectors/taiyishenshu/metadata_test_vectors.json');
      final jsonString = file.readAsStringSync();
      final data = json.decode(jsonString);
      testVectors = data['vectors'];
    });

    test('Verify metadata against test vectors', () {
      for (final vector in testVectors) {
        final input = vector['input'];
        final expected = vector['expected'];

        final chartType = TaiYiChartType.values.firstWhere(
          (e) => e.name == input['chartType'],
        );

        final result = calculator.calculate(
          dateTime: DateTime.parse(input['dateTime']),
          schoolId: input['schoolId'],
          chartType: chartType,
        );

        expect(result.accumulatedYear, expected['accumulatedYear'],
            reason: 'Vector ${vector['id']} failed: accumulatedYear mismatch');
        expect(result.sequenceIndex, expected['sequenceIndex'],
            reason: 'Vector ${vector['id']} failed: sequenceIndex mismatch');
        expect(result.juNumber, expected['juNumber'],
            reason: 'Vector ${vector['id']} failed: juNumber mismatch');
        expect(result.dunType.name, expected['dunType'],
            reason: 'Vector ${vector['id']} failed: dunType mismatch');
      }
    });
  });
}
