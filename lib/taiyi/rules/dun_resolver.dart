import 'package:metaphysics_core/enums.dart';
import 'package:enumeration/enums.dart';
import 'package:tyme/tyme.dart';
import 'school_document.dart';

class DunResolver {
  static final Map<int, DateTime> _cfCache = {};

  static DateTime _chunFenForYear(int year) {
    final cached = _cfCache[year];
    if (cached != null) return cached;
    try {
      final term = SolarTerm.fromIndex(year, 6);
      final jd = term.getJulianDay();
      final solarTime = jd.getSolarTime();
      final found = DateTime(
        solarTime.getYear(),
        solarTime.getMonth(),
        solarTime.getDay(),
        solarTime.getHour(),
        solarTime.getMinute(),
        solarTime.getSecond(),
      );
      _cfCache[year] = found;
      return found;
    } catch (e) {
      final fallback = DateTime(year, 3, 20, 0, 0, 0);
      _cfCache[year] = fallback;
      return fallback;
    }
  }

  static DateTime getWinterSolstice(int year, String termMode) {
    if (termMode == 'leveling') {
      final cf = _chunFenForYear(year);
      const double tropicalYearDays = 365.2422;
      final Duration levelingInterval = Duration(
        milliseconds: (tropicalYearDays / 24 * 24 * 60 * 60 * 1000).round(),
      );
      return cf.subtract(levelingInterval * 6);
    } else {
      final term = SolarTerm.fromIndex(year, 0); // 冬至
      final jd = term.getJulianDay();
      final solarTime = jd.getSolarTime();
      return DateTime(
        solarTime.getYear(),
        solarTime.getMonth(),
        solarTime.getDay(),
        solarTime.getHour(),
        solarTime.getMinute(),
        solarTime.getSecond(),
      );
    }
  }

  static DateTime getSummerSolstice(int year, String termMode) {
    if (termMode == 'leveling') {
      final cf = _chunFenForYear(year);
      const double tropicalYearDays = 365.2422;
      final Duration levelingInterval = Duration(
        milliseconds: (tropicalYearDays / 24 * 24 * 60 * 60 * 1000).round(),
      );
      return cf.add(levelingInterval * 6);
    } else {
      final term = SolarTerm.fromIndex(year, 12); // 夏至
      final jd = term.getJulianDay();
      final solarTime = jd.getSolarTime();
      return DateTime(
        solarTime.getYear(),
        solarTime.getMonth(),
        solarTime.getDay(),
        solarTime.getHour(),
        solarTime.getMinute(),
        solarTime.getSecond(),
      );
    }
  }

  /// Determine whether the given [dateTime] falls under Yang Dun (阳遁) or Yin Dun (阴遁).
  /// [termMode] is either 'leveling' (平气) or 'stabilizing' (定气).
  static bool isYangDun(DateTime dateTime, String termMode) {
    // wsPrev: Winter Solstice of previous year
    final wsPrev = getWinterSolstice(dateTime.year - 1, termMode);
    // ssCur: Summer Solstice of current year
    final ssCur = getSummerSolstice(dateTime.year, termMode);
    // wsCur: Winter Solstice of current year
    final wsCur = getWinterSolstice(dateTime.year, termMode);
    // ssNext: Summer Solstice of next year
    final ssNext = getSummerSolstice(dateTime.year + 1, termMode);

    final list = [
      (wsPrev, true),
      (ssCur, false),
      (wsCur, true),
      (ssNext, false),
    ];
    list.sort((a, b) => a.$1.compareTo(b.$1));

    for (int i = 0; i < list.length - 1; i++) {
      final cur = list[i].$1;
      final next = list[i + 1].$1;
      if ((dateTime.isAfter(cur) || dateTime.isAtSameMomentAs(cur)) && dateTime.isBefore(next)) {
        return list[i].$2;
      }
    }

    return dateTime.isAfter(wsCur) || dateTime.isAtSameMomentAs(wsCur);
  }

  /// Find the first Jia Zi day on or after the solstice corresponding to the [date]'s Dun cycle.
  static DateTime jiaZiDayAnchor(DateTime date, String termMode) {
    final wsPrev = getWinterSolstice(date.year - 1, termMode);
    final ssCur = getSummerSolstice(date.year, termMode);
    final wsCur = getWinterSolstice(date.year, termMode);
    final ssNext = getSummerSolstice(date.year + 1, termMode);

    final list = [
      (wsPrev, true),
      (ssCur, false),
      (wsCur, true),
      (ssNext, false),
    ];
    list.sort((a, b) => a.$1.compareTo(b.$1));

    DateTime activeSolstice = wsPrev;
    for (int i = 0; i < list.length - 1; i++) {
      final cur = list[i].$1;
      final next = list[i + 1].$1;
      if ((date.isAfter(cur) || date.isAtSameMomentAs(cur)) && date.isBefore(next)) {
        activeSolstice = cur;
        break;
      }
    }
    if (date.isAfter(wsCur) || date.isAtSameMomentAs(wsCur)) {
      activeSolstice = wsCur;
    }

    final startDay = DateTime(activeSolstice.year, activeSolstice.month, activeSolstice.day, 12, 0, 0);
    for (int i = 0; i < 65; i++) {
      final checkDate = startDay.add(Duration(days: i));
      final checkSolarTime = SolarTime.fromYmdHms(
        checkDate.year,
        checkDate.month,
        checkDate.day,
        12, 0, 0,
      );
      final checkEc = checkSolarTime.getLunarHour().getEightChar();
      final dayGanzhiStr = checkEc.getDay().getName();
      if (dayGanzhiStr == '甲子') {
        return DateTime(checkDate.year, checkDate.month, checkDate.day);
      }
    }
    throw StateError('Jia Zi day not found after solstice');
  }

  /// Run winterReset calibration logic for school.
  /// If [school] specifies `calibration: "winterReset"`, and [dateTime] is on or after the Winter Solstice
  /// of the current Gregorian year, return the calibrated variables (incrementing year Y by 1 and setting metadata).
  static Map<String, dynamic> calibrateContextVars(DateTime dateTime, SchoolDocument school) {
    final dun = school.dun;
    if (dun.calibration == 'winterReset') {
      final ws = getWinterSolstice(dateTime.year + 1, dun.termMode);
      if (dateTime.isAfter(ws) || dateTime.isAtSameMomentAs(ws)) {
        return {
          'Y': dateTime.year + 1,
          'calibrationApplied': true,
          'calibrationSource': 'winterReset'
        };
      }
    }
    return {
      'Y': dateTime.year,
      'calibrationApplied': false
    };
  }
}
