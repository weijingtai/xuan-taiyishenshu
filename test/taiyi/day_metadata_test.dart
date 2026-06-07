import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/taiyi/taiyi.dart';

void main() {
  const calculator = TaiYiPanCalculator();
  final file = File('test/taiyi/test_vectors/day_metadata.json');
  final jsonString = file.readAsStringSync();
  final data = json.decode(jsonString);
  final List<dynamic> testVectors = data['vectors'];

  group('TaiYi Day Metadata Verification', () {
    void defineTestsForSchool(String sect, String label) {
      group(label, () {
        final schoolVectors = testVectors.where((v) => v['sect'] == sect).toList();
        for (final vector in schoolVectors) {
          final input = vector['input'];
          final expected = vector['expected'];
          final description = vector['description'] ?? vector['id'];

          test(description, () {
            final result = calculator.calculate(
              dateTime: DateTime.parse(input['dateTime']),
              schoolId: input['schoolId'],
              chartType: TaiYiChartType.day,
            );

            expect(result.sequenceIndex, expected['accumulatedYear'],
                reason: 'sequenceIndex mismatch');
            expect(result.juNumber, expected['juNumber'],
                reason: 'juNumber mismatch');

          });
        }
      });
    }

    defineTestsForSchool('jingMirror', '金镜式');
    defineTestsForSchool('tongZong', '统宗式');
  });
}
