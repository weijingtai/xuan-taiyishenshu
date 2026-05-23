import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/taiyi/taiyi.dart';
import '../../lib/taiyi/pan_enums.dart';

void main() {
  group('TaiYi Month Metadata Verification', () {
    late TaiYiPanCalculator calculator;
    late List<dynamic> testVectors;

    setUpAll(() {
      calculator = const TaiYiPanCalculator();
      final file = File('../test-vectors/taiyishenshu/month_metadata.json');
      final jsonString = file.readAsStringSync();
      final data = json.decode(jsonString);
      testVectors = data['vectors'];
    });

    group('金镜派', () {
      test('Verify Month metadata against jingMirror vectors', () {
        final schoolVectors = testVectors.where((v) => v['sect'] == 'jingMirror').toList();
        for (final vector in schoolVectors) {
          final input = vector['input'];
          final expected = vector['expected'];

          final result = calculator.calculate(
            dateTime: DateTime.parse(input['dateTime']),
            schoolId: input['schoolId'],
            chartType: TaiYiChartType.month,
          );

          expect(result.sequenceIndex, expected['accumulatedYear'],
              reason: 'Vector ${vector['id']} failed: sequenceIndex mismatch');
          expect(result.juNumber, expected['juNumber'],
              reason: 'Vector ${vector['id']} failed: juNumber mismatch');
        }
      });
    });

    group('统宗派', () {
      test('Verify Month metadata against tongZong vectors', () {
        final schoolVectors = testVectors.where((v) => v['sect'] == 'tongZong').toList();
        for (final vector in schoolVectors) {
          final input = vector['input'];
          final expected = vector['expected'];

          final result = calculator.calculate(
            dateTime: DateTime.parse(input['dateTime']),
            schoolId: input['schoolId'],
            chartType: TaiYiChartType.month,
          );

          expect(result.sequenceIndex, expected['accumulatedYear'],
              reason: 'Vector ${vector['id']} failed: sequenceIndex mismatch');
          expect(result.juNumber, expected['juNumber'],
              reason: 'Vector ${vector['id']} failed: juNumber mismatch');
        }
      });
    });
  });
}
