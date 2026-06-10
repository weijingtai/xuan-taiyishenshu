import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/rules/dun_resolver.dart';
import 'package:taiyishenshu/taiyi/rules/school_document.dart';

void main() {
  group('DunResolver (R8) Tests', () {
    test('winter and summer solstice boundaries for stabilizing', () {
      final ws = DunResolver.getWinterSolstice(2026, 'stabilizing');
      final ss = DunResolver.getSummerSolstice(2026, 'stabilizing');

      expect(ws.year == 2025 || ws.year == 2026, true);
      expect(ws.month, 12);
      expect([21, 22].contains(ws.day), true);

      expect(ss.year, 2026);
      expect(ss.month, 6);
      expect([21, 22].contains(ss.day), true);
    });

    test('winter and summer solstice boundaries for leveling', () {
      final ws = DunResolver.getWinterSolstice(2026, 'leveling');
      final ss = DunResolver.getSummerSolstice(2026, 'leveling');

      expect(ws.month == 12 || ws.month == 11, true);
      expect(ss.month == 6 || ss.month == 5, true);
    });

    test('isYangDun determines correct Dun type', () {
      // 2026-03-20 is after winter solstice 2025/2026 and before summer solstice 2026 -> Yang Dun
      expect(DunResolver.isYangDun(DateTime(2026, 3, 20), 'stabilizing'), true);

      // 2026-08-01 is after summer solstice 2026 and before winter solstice 2026 -> Yin Dun
      expect(DunResolver.isYangDun(DateTime(2026, 8, 1), 'stabilizing'), false);
    });

    test('jiaZiDayAnchor finds post-solstice anchor', () {
      final anchor = DunResolver.jiaZiDayAnchor(DateTime(2026, 12, 25), 'stabilizing');
      expect(anchor, isNotNull);
      expect(anchor.year == 2025 || anchor.year == 2026 || anchor.year == 2027, true);
    });

    test('winterReset calibration applies correction', () {
      final school = SchoolDocument(
        schemaVersion: 1,
        meta: SchoolMeta(id: 'fu_ying', name: 'Fu Ying', version: 1, source: 'test', owner: 'official'),
        palace: 'taiyi9',
        rules: [],
        charts: SchoolCharts(),
        dun: SchoolDun(resolver: 'resolver', termMode: 'stabilizing', calibration: 'winterReset'),
        foundation: SchoolFoundation(taiYiRef: '', wenChangRef: '', jiShenRef: '', shiJiRef: ''),
        threeCalc: SchoolThreeCalc(hostRef: '', guestRef: '', dingRef: ''),
        generals: SchoolGenerals(hostMajorRef: '', hostMinorRef: '', guestMajorRef: '', guestMinorRef: ''),
        deities: [],
        geJu: [],
      );

      // Cast date: Dec 25, 2026 (after winter solstice) -> Y calibrated to 2027
      final varsApplied = DunResolver.calibrateContextVars(DateTime(2026, 12, 25), school);
      expect(varsApplied['calibrationApplied'], true);
      expect(varsApplied['Y'], 2027);

      // Cast date: Nov 1, 2026 (before winter solstice) -> Y remains 2026
      final varsNotApplied = DunResolver.calibrateContextVars(DateTime(2026, 11, 1), school);
      expect(varsNotApplied['calibrationApplied'], false);
      expect(varsNotApplied['Y'], 2026);
    });
  });
}
