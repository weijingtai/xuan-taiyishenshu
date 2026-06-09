import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/enums/datetime_strategy_enums.dart';
import 'package:tyme/tyme.dart';

void main() {
  group('metaphysics_core contract gate', () {
    test('verify metaphysics_core imports and JieQiType usage', () {
      expect(JieQiType.values.length, 2);
      expect(JieQiType.leveling.name, '平气法');
      expect(JieQiType.stabilizing.name, '定气法');
    });

    test('extract winter and summer solstice times', () {
      final winterTerm = SolarTerm.fromIndex(2026, 0); // 冬至
      final summerTerm = SolarTerm.fromIndex(2026, 12); // 夏至

      expect(winterTerm.getName(), '冬至');
      expect(summerTerm.getName(), '夏至');

      final winterJd = winterTerm.getJulianDay();
      final winterSolarTime = winterJd.getSolarTime();
      final winterDateTime = DateTime(
        winterSolarTime.getYear(),
        winterSolarTime.getMonth(),
        winterSolarTime.getDay(),
        winterSolarTime.getHour(),
        winterSolarTime.getMinute(),
        winterSolarTime.getSecond(),
      );

      expect(winterDateTime.year == 2025 || winterDateTime.year == 2026, true);
      expect(winterDateTime.month, 12);
      expect([21, 22].contains(winterDateTime.day), true);
    });

    test('flat vs apparent term modes representation', () {
      final levelingMode = JieQiType.leveling;
      final stabilizingMode = JieQiType.stabilizing;
      expect(levelingMode, JieQiType.leveling);
      expect(stabilizingMode, JieQiType.stabilizing);
    });

    test('post-solstice Jia Zi day anchoring adapter decision', () {
      final solsticeTerm = SolarTerm.fromIndex(2026, 0); // 冬至
      final solsticeJd = solsticeTerm.getJulianDay();
      final solsticeSolarTime = solsticeJd.getSolarTime();
      final solsticeDate = DateTime(
        solsticeSolarTime.getYear(),
        solsticeSolarTime.getMonth(),
        solsticeSolarTime.getDay(),
        12, 0, 0, // noon
      );

      DateTime? jiaZiDay;
      for (int i = 0; i < 65; i++) {
        final checkDate = solsticeDate.add(Duration(days: i));
        final checkSolarTime = SolarTime.fromYmdHms(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          12, 0, 0,
        );
        final checkEc = checkSolarTime.getLunarHour().getEightChar();
        final dayGanzhiStr = checkEc.getDay().getName();
        if (dayGanzhiStr == '甲子') {
          jiaZiDay = checkDate;
          break;
        }
      }

      expect(jiaZiDay, isNotNull);
      expect(jiaZiDay!.year == 2025 || jiaZiDay.year == 2026 || jiaZiDay.year == 2027, true);
    });
  });
}
