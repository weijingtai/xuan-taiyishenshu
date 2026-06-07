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

          // 1. Basic Sequence & Ju
          expect(result.sequenceIndex, expected['accumulatedYear'],
              reason: 'sequenceIndex mismatch');
          expect(result.juNumber, expected['juNumber'],
              reason: 'juNumber mismatch');

          // 2. Dun Type (if present)
          if (expected.containsKey('dunType')) {
            final expectedDun = expected['dunType'] == 'yang' ? DunType.yang : DunType.yin;
            expect(result.dunType, expectedDun, reason: 'dunType mismatch');
          }

          // 3. Host/Guest Counts (if present)
          if (expected.containsKey('hostCount')) {
            expect(result.hostGuest.hostCount, expected['hostCount'],
                reason: 'hostCount mismatch');
          }
          if (expected.containsKey('guestCount')) {
            expect(result.hostGuest.guestCount, expected['guestCount'],
                reason: 'guestCount mismatch');
          }
          if (expected.containsKey('dingCount')) {
            expect(result.hostGuest.dingCount, expected['dingCount'],
                reason: 'dingCount mismatch');
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
