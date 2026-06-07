import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart';

void main() {
  group('Taiyi Jing Mirror year standard vectors', () {
    final cases = <({
      DateTime dateTime,
      int accumulatedYear,
      int juNumber,
      String ruGongLabel,
      int wuZiYuanJu,
      int yuanShu,
      String yuanName,
      int ruJiJiShu,
      int hostCount,
      int guestCount,
      int dingCount,
    })>[
      (
        dateTime: DateTime(2026, 6, 7, 15, 8),
        accumulatedYear: 1938583,
        juNumber: 55,
        ruGongLabel: '理天',
        wuZiYuanJu: 343,
        yuanShu: 5,
        yuanName: '壬子元',
        ruJiJiShu: 6,
        hostCount: 16,
        guestCount: 3,
        dingCount: 22,
      ),
      (
        dateTime: DateTime(2027, 6, 7, 15, 8),
        accumulatedYear: 1938584,
        juNumber: 56,
        ruGongLabel: '理地',
        wuZiYuanJu: 344,
        yuanShu: 5,
        yuanName: '壬子元',
        ruJiJiShu: 6,
        hostCount: 15,
        guestCount: 34,
        dingCount: 10,
      ),
      (
        dateTime: DateTime(1949, 6, 7, 15, 8),
        accumulatedYear: 1938506,
        juNumber: 50,
        ruGongLabel: '理地',
        wuZiYuanJu: 266,
        yuanShu: 4,
        yuanName: '庚子元',
        ruJiJiShu: 5,
        hostCount: 16,
        guestCount: 15,
        dingCount: 15,
      ),
    ];

    for (final c in cases) {
      test('${c.dateTime.year} matches provided Jing Mirror year chart', () {
        final pan = const TaiYiPanCalculator().calculate(
          dateTime: c.dateTime,
          schoolId: 'jingMirror',
          chartType: TaiYiChartType.year,
        );
        final yearJi = pan.yearJi;

        expect(pan.accumulatedYear, c.accumulatedYear);
        expect(pan.sequenceIndex, c.accumulatedYear);
        expect(pan.juNumber, c.juNumber);
        expect(yearJi, isNotNull);
        expect(yearJi!.jiNian, c.accumulatedYear);
        expect(yearJi.juShu, c.juNumber);
        expect(yearJi.taiYiRuGongNianShuLabel, c.ruGongLabel);
        expect(yearJi.wuZiYuanJu, c.wuZiYuanJu);
        expect(yearJi.yuanShu, c.yuanShu);
        expect(yearJi.wuZiYuanName, c.yuanName);
        expect(yearJi.ruJiJiShu, c.ruJiJiShu);

        expect(pan.hostGuest.hostCount, c.hostCount);
        expect(pan.hostGuest.guestCount, c.guestCount);
        expect(pan.hostGuest.dingCount, c.dingCount);
      });
    }
  });
}
