import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';

void main() {
  const calculator = TaiYiPanCalculator();

  group('Taiyi Diagnostics', () {
    test('TongZong Month 2026-05 Diagnostic', () {
      final result = calculator.calculate(
        dateTime: DateTime.parse('2026-05-23T08:25:00Z'),
        schoolId: 'tongZong',
        chartType: TaiYiChartType.month,
      );
      print('DIAGNOSTIC: TongZong Month 2026-05');
      print('  sequenceIndex: ${result.sequenceIndex}');
      print('  juNumber: ${result.juNumber}');
      print('  taiYiPalace: ${result.taiYiPalace}');
      print('  wenChangPalace: ${result.hostGuest.hostPalace}');
      print('  shiJiPalace: ${result.hostGuest.guestPalace}');
      print('  dingMuPalace: ${result.hostGuest.dingPalace}');
      print('  hostCount: ${result.hostGuest.hostCount}');
      print('  guestCount: ${result.hostGuest.guestCount}');
      print('  dingCount: ${result.hostGuest.dingCount}');
      print('  hostDetail: ${result.hostGuest.hostCountDetail?.detail}');
      print('  guestDetail: ${result.hostGuest.guestCountDetail?.detail}');
      print('  dingDetail: ${result.hostGuest.dingCountDetail?.detail}');
    });
  });
}
