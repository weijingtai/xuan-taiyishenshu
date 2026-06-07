import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';

void main() {
  group('TaiYi Metadata Full Regression', () {
    late TaiYiPanCalculator calculator;

    setUpAll(() {
      calculator = const TaiYiPanCalculator();
    });

    void runRegression(String category, TaiYiChartType chartType) {
      final file = File('test/taiyi/test_vectors/$category.json');
      final jsonString = file.readAsStringSync();
      final data = json.decode(jsonString);
      final vectors = data['vectors'] as List;

      for (final vector in vectors) {
        final input = vector['input'];
        final expected = vector['expected'];
        final sect = vector['sect'] ?? input['schoolId'];

        test('[$sect] ${vector['description'] ?? vector['id']}', () {
          final result = calculator.calculate(
            dateTime: DateTime.parse(input['dateTime']),
            schoolId: input['schoolId'],
            chartType: chartType,
          );

          void verify(String field, dynamic actual, dynamic expected) {
            expect(actual, expected,
                reason: '[$sect ${chartType.name}] $field mismatch: Expected $expected, Got $actual');
          }

          // 1. Basic Sequence & Ju
          verify('sequenceIndex', result.sequenceIndex, expected['accumulatedYear']);
          verify('juNumber', result.juNumber, expected['juNumber']);

          // 2. Dun Type (if present)
          if (expected.containsKey('dunType')) {
            final expectedDun = expected['dunType'] == 'yang' ? DunType.yang : DunType.yin;
            verify('dunType', result.dunType, expectedDun);
          }

          // 3. Host/Guest Counts (if present)
          if (expected.containsKey('hostCount')) {
            verify('hostCount', result.hostGuest.hostCount, expected['hostCount']);
          }
          if (expected.containsKey('guestCount')) {
            verify('guestCount', result.hostGuest.guestCount, expected['guestCount']);
          }
          if (expected.containsKey('dingCount')) {
            verify('dingCount', result.hostGuest.dingCount, expected['dingCount']);
          }
        });
      }
    }

    group('Year Chart', () => runRegression('year_metadata', TaiYiChartType.year));
    group('Month Chart', () => runRegression('month_metadata', TaiYiChartType.month));
    group('Day Chart', () => runRegression('day_metadata', TaiYiChartType.day));
    group('Hour Chart', () => runRegression('hour_metadata', TaiYiChartType.hour));
  });
}
