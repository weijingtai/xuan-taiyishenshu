import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/rules/foundation_result.dart';

void main() {
  final years = [2026, 2027, 1949];
  final tongZongYears = [2026, 2024];

  group('Discover correct expected values', () {
    for (final y in years) {
      test('jingMirror year $y', () {
        final result = FoundationResult.fromSchoolId(
          schoolId: 'jingMirror',
          year: y,
          isYang: true,
        );
        expect(result, isNotNull);
        print('=== jingMirror year $y ===');
        print('  accumulatedYear: ${result!.accumulatedYear}');
        print('  juNumber: ${result.juNumber}');
        print('  ruGongLabel: ${result.ruGongLabel}');
        print('  wuZiYuanJu: ${result.wuZiYuanJu}');
        print('  yuanShu: ${result.yuanShu}');
        print('  yuanName: ${result.yuanName}');
        print('  ruJiJiShu: ${result.ruJiJiShu}');
        print('  hostCount: ${result.hostCount}');
        print('  guestCount: ${result.guestCount}');
        print('  dingCount: ${result.dingCount}');
        print('  taiYiGong: ${result.taiYiGong}');
        print('  wenChangName: ${result.wenChangName}');
        print('  jiShenName: ${result.jiShenName}');
        print('  shiJiName: ${result.shiJiName}');
      });
    }

    for (final y in tongZongYears) {
      test('tongZong year $y', () {
        final result = FoundationResult.fromSchoolId(
          schoolId: 'tongZong',
          year: y,
          isYang: true,
        );
        expect(result, isNotNull);
        print('=== tongZong year $y ===');
        print('  hostCount: ${result!.hostCount}');
        print('  guestCount: ${result.guestCount}');
        print('  dingCount: ${result.dingCount}');
        print('  wenChangName: ${result.wenChangName}');
        print('  wenChangGong: ${result.wenChangGong}');
      });
    }
  });
}
