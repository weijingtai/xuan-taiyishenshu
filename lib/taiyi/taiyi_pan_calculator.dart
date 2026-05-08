import '../enums/deity_kind.dart';
import '../enums/eight_door.dart';
import '../enums/geju.dart';
import '../enums/god.dart';
import '../enums/gong.dart';
import '../enums/taiyi_enum_extensions.dart';
import '../models/custom_deity_definition.dart';
import '../models/geju_model.dart';
import '../models/pan_computed_item.dart';
import '../models/ren_pan_model.dart';
import '../models/shen_pan_model.dart';
import '../models/tian_pan_model.dart';
import '../models/year_ji_model.dart';
import 'pan_data_model.dart';
import 'pan_enums.dart';
import 'taiyi_constants.dart';

class TaiYiPanCalculator {
  const TaiYiPanCalculator();

  static const String algorithmVersion = 'taiyi-pan-mvp-0.2.0';

  PanDataModel calculate({
    required DateTime dateTime,
    TaiYiSchool school = TaiYiSchool.jingMirror,
    TaiYiChartType chartType = TaiYiChartType.year,
    bool useTrueSolarTime = false,
    String? location,
  }) {
    return _calculate(
      dateTime: dateTime,
      school: school,
      chartType: chartType,
      useTrueSolarTime: useTrueSolarTime,
      location: location,
      customDefinitions: const [],
    );
  }

  Future<PanDataModel> calculateWithCustomDeities({
    required DateTime dateTime,
    required CustomDeityRepository customDeityRepository,
    TaiYiSchool school = TaiYiSchool.jingMirror,
    TaiYiChartType chartType = TaiYiChartType.year,
    bool useTrueSolarTime = false,
    String? location,
  }) async {
    final customDefinitions =
        await customDeityRepository.loadDefinitions(school: school);
    return _calculate(
      dateTime: dateTime,
      school: school,
      chartType: chartType,
      useTrueSolarTime: useTrueSolarTime,
      location: location,
      customDefinitions: customDefinitions,
    );
  }

  PanDataModel _calculate({
    required DateTime dateTime,
    required TaiYiSchool school,
    required TaiYiChartType chartType,
    required bool useTrueSolarTime,
    required String? location,
    required List<CustomDeityDefinition> customDefinitions,
  }) {
    final input = PanInputModel(
      dateTime: dateTime,
      school: school,
      chartType: chartType,
      useTrueSolarTime: useTrueSolarTime,
      location: location,
    );

final rule = _RuleProfile.forSchool(school);
    final accumulatedYear = _calculateAccumulatedYear(dateTime, rule);
    final yearJi = chartType == TaiYiChartType.year
        ? _computeYearJi(accumulatedYear)
        : null;
    final int juNumber;
    final int accumulatedSeqValue;
    if (chartType == TaiYiChartType.year) {
      juNumber = yearJi!.juShu;
      accumulatedSeqValue = accumulatedYear;
    } else {
      accumulatedSeqValue = _calculateAccumulatedSequenceValue(
        dateTime: dateTime,
        chartType: chartType,
        accumulatedYear: accumulatedYear,
        rule: rule,
      );
      juNumber = _computeJuNumberFromAccumulatedValue(accumulatedSeqValue);
    }
    final dunType = _resolveDunType(dateTime, chartType);
    final taiYiPalace = _calculateTaiYiPalace(juNumber, rule);
    final wenChangPalace = _calculateWenChangPalace(
      juNumber: juNumber,
      dunType: dunType,
      rule: rule,
    );
    final jiShenPalace = _calculateJiShenPalace(
      dateTime: dateTime,
      juNumber: juNumber,
      chartType: chartType,
      rule: rule,
    );
    final eightDoorsByPalace = _calculateEightDoors(
      accumulatedYear: accumulatedYear,
      chartType: chartType,
      taiYiPalace: taiYiPalace,
      rule: rule,
    );
    final yearBranch = twelveBranches[_positiveModulo(dateTime.year - 4, 12)];
    final hostGuest = _calculateHostGuest(
      juNumber: juNumber,
      taiYiPalace: taiYiPalace,
      wenChangPalace: wenChangPalace,
      yearBranch: yearBranch,
      rule: rule,
      dunType: dunType,
    );

    final diPan = createDiPan();
    final renPan = _buildRenPan(
      juNumber: juNumber,
      chartType: chartType,
      dunType: dunType,
      taiYiPalace: taiYiPalace,
      wenChangPalace: wenChangPalace,
      jiShenPalace: jiShenPalace,
      rule: rule,
    );
    final tianPan = _buildTianPan(
      accumulatedYear: accumulatedYear,
      taiYiPalace: taiYiPalace,
      wenChangPalace: wenChangPalace,
      hostGuest: hostGuest,
      rule: rule,
    );
    final shenPan = _buildShenPan(
      accumulatedYear: accumulatedYear,
      dateTime: dateTime,
      taiYiPalace: taiYiPalace,
      rule: rule,
    );
    final geJu = _buildGeJu(
      taiYiPalace: taiYiPalace,
      wenChangPalace: wenChangPalace,
      shiJiGong: renPan.shiJiGong,
      hostGuest: hostGuest,
      tianPan: tianPan,
    );

    final builtInItems = _buildBuiltInItems(
      taiYiPalace: taiYiPalace,
      wenChangPalace: wenChangPalace,
      jiShenPalace: jiShenPalace,
      eightDoorsByPalace: eightDoorsByPalace,
      hostGuest: hostGuest,
      tianPan: tianPan,
      shenPan: shenPan,
      renPan: renPan,
    );
    final customItems = _calculateCustomItems(
      definitions: customDefinitions,
      input: input,
      juNumber: juNumber,
      dunType: dunType,
      builtInItems: builtInItems,
      warnings: rule.warnings,
    );
    final placedItems = [
      ...builtInItems,
      ...customItems.where((item) => item.isPlaced),
    ];
    final unplacedItems = customItems
        .where((item) => !item.isPlaced)
        .toList(growable: false)
      ..sort(_compareComputedItem);
    final palaces = _buildPalaces(items: placedItems);

return PanDataModel(
      input: input,
      algorithmVersion: algorithmVersion,
      accumulatedYear: accumulatedYear,
      sequenceIndex: accumulatedSeqValue,
      juNumber: juNumber,
      dunType: dunType,
      taiYiPalace: taiYiPalace,
      wenChangPalace: wenChangPalace,
      jiShenPalace: jiShenPalace,
      schoolBase: rule.isAncientSchool
          ? '${rule.school.label}基数: ${rule.ancientBase}'
          : '${rule.school.label}起算年: ${rule.contemporaryEpochYear}',
      palaces: palaces,
      eightDoorsByPalace: eightDoorsByPalace,
      unplacedItems: List.unmodifiable(unplacedItems),
      hostGuest: hostGuest,
      warnings: [
        if (useTrueSolarTime) '当前版本保留真太阳时参数，但尚未修正地方时。',
        ...rule.warnings,
      ],
      diPan: diPan,
      renPan: renPan,
      tianPan: tianPan,
      shenPan: shenPan,
      geJu: geJu,
      yearJi: yearJi,
    );
  }

  int _calculateAccumulatedYear(DateTime dateTime, _RuleProfile rule) {
    if (!rule.isAncientSchool) {
      return dateTime.year - rule.contemporaryEpochYear + 1;
    }
    if (rule.school == TaiYiSchool.tongZong) {
      return rule.ancientBase + (dateTime.year - rule.ancientEpochYear) + 1;
    }
    return rule.ancientBase + (dateTime.year - rule.ancientEpochYear);
  }

  int _calculateAccumulatedSequenceValue({
    required DateTime dateTime,
    required TaiYiChartType chartType,
    required int accumulatedYear,
    required _RuleProfile rule,
  }) {
    switch (chartType) {
      case TaiYiChartType.year:
        return accumulatedYear;
      case TaiYiChartType.month:
        return _accumulatedMonth(accumulatedYear, dateTime, rule);
      case TaiYiChartType.day:
        return _accumulatedDay(accumulatedYear, dateTime, rule);
      case TaiYiChartType.hour:
        return _accumulatedHour(accumulatedYear, dateTime, rule);
      case TaiYiChartType.ke:
        throw UnsupportedError('刻家暂未实现。');
    }
  }

  int _accumulatedMonth(int accumulatedYear, DateTime dateTime, _RuleProfile rule) {
    final tianZhengMonth = _toTianZhengMonth(dateTime.month);
    if (rule.zhangSui > 0 && rule.zhangYue > 0) {
      final jiYue = (accumulatedYear * rule.zhangYue) ~/ rule.zhangSui;
      return jiYue + tianZhengMonth;
    }
    return (accumulatedYear - 1) * 12 + tianZhengMonth;
  }

  int _toTianZhengMonth(int solarMonth) {
    return switch (solarMonth) {
      1 => 3,
      2 => 4,
      3 => 5,
      4 => 6,
      5 => 7,
      6 => 8,
      7 => 9,
      8 => 10,
      9 => 11,
      10 => 12,
      11 => 1,
      12 => 2,
      _ => 1,
    };
  }

  int _accumulatedDay(int accumulatedYear, DateTime dateTime, _RuleProfile rule) {
    final dongZhi = _dateOfWinterSolstice(dateTime.year);
    final dongZhiDoy = dongZhi.difference(DateTime(dateTime.year)).inDays + 1;
    final currentDoy = _dayOfYear(dateTime);
    int daysSinceDongZhi = currentDoy - dongZhiDoy;
    if (daysSinceDongZhi < 0) {
      daysSinceDongZhi += (rule.tropicalYear * 12).round();
    }
    final dongZhiJiRi = ((accumulatedYear - 1) * rule.tropicalYear).round();
    return dongZhiJiRi + daysSinceDongZhi;
  }

  int _accumulatedHour(int accumulatedYear, DateTime dateTime, _RuleProfile rule) {
    final dongZhi = _dateOfWinterSolstice(dateTime.year);
    final xiaZhi = _dateOfSummerSolstice(dateTime.year);
    final dongZhiDoy = dongZhi.difference(DateTime(dateTime.year)).inDays + 1;
    final xiaZhiDoy = xiaZhi.difference(DateTime(dateTime.year)).inDays + 1;
    final currentDoy = _dayOfYear(dateTime);
    int zhiDoy;
    if (currentDoy >= xiaZhiDoy) {
      zhiDoy = xiaZhiDoy;
    } else {
      zhiDoy = dongZhiDoy;
    }
    int daysSinceZhi = currentDoy - zhiDoy;
    if (daysSinceZhi < 0) {
      daysSinceZhi += 365;
    }
    final zhiJiRi = ((accumulatedYear - 1) * rule.tropicalYear).round();
    final erZhiJiRi = zhiJiRi + daysSinceZhi;
    final erZhiJiShi = (erZhiJiRi - 1) * 12;
    final shiZhi = ((dateTime.hour + 1) ~/ 2) % 12;
    return erZhiJiShi + shiZhi;
  }

  DateTime _dateOfSummerSolstice(int year) {
    return DateTime(year, 6, 21);
  }

  int _computeJuNumberFromAccumulatedValue(int seqValue) {
    final zhouJiYu = seqValue % 360;
    final yuanYu = zhouJiYu % 72;
    return yuanYu + 1;
  }

  /// 计算年计（岁计）太乙核心参数。
  ///
  /// 基于积年数（传统积年，非101539体系）计算五子元局及相关参数。
  ///
  /// 公式：
  /// - 五子元局 = 积年数 % 360
  /// - 元数 = int(五子元局 / 72) + 1（1-5：甲子元1、丙子元2、戊子元3、庚子元4、壬子元5）
  /// - 局数 = 五子元局 % 72（1-72局，0代表72局）
  /// - 入纪纪数 = int(五子元局 / 60) + 1（1-6纪）
  /// - 入纪年数 = 五子元局 % 60（0-59）
  /// - 年卦编号 = 积年数 % 64（0-63）
  /// - 太乙行宫年数 = 积年数 % 24
  /// - 太乙行宫宫数 = int(太乙行宫年数 / 3) + 1（1-9）
  /// - 太乙入宫年书 = 太乙行宫年数 % 3（0→理天，1→理地，2→理人）
  YearJiDataModel _computeYearJi(int accumulatedYear) {
    final wuZiYuanJu = accumulatedYear % 360;
    final yuanShu = wuZiYuanJu ~/ 72 + 1;
    final wuZiYuanIdx = yuanShu - 1;
    final wuZiYuanName = wuZiYuanNames[wuZiYuanIdx];
    final juShu = wuZiYuanJu % 72;
    final juShuFixed = juShu == 0 ? 72 : juShu;
    final ruJiJiShu = wuZiYuanJu ~/ 60 + 1;
    final ruJiNianShu = wuZiYuanJu % 60;
    final nianGuaBianHao = accumulatedYear % 64;
    final taiYiXingGongNianShu = accumulatedYear % 24;
    final taiYiXingGongGongShu = taiYiXingGongNianShu ~/ 3 + 1;
    final taiYiRuGongNianShu = taiYiXingGongNianShu % 3;
    final taiYiRuGongNianShuLabel = switch (taiYiRuGongNianShu) {
      0 => '理天',
      1 => '理地',
      2 => '理人',
      _ => '理天',
    };
    return YearJiDataModel(
      jiNian: accumulatedYear,
      wuZiYuanJu: wuZiYuanJu,
      yuanShu: yuanShu,
      wuZiYuanName: wuZiYuanName,
      juShu: juShuFixed,
      ruJiJiShu: ruJiJiShu,
      ruJiNianShu: ruJiNianShu,
      nianGuaBianHao: nianGuaBianHao,
      taiYiXingGongNianShu: taiYiXingGongNianShu,
      taiYiXingGongGongShu: taiYiXingGongGongShu,
      taiYiRuGongNianShu: taiYiRuGongNianShu,
      taiYiRuGongNianShuLabel: taiYiRuGongNianShuLabel,
    );
  }

  DateTime _dateOfWinterSolstice(int year) => DateTime(year, 12, 21);

  DunType _resolveDunType(DateTime dateTime, TaiYiChartType chartType) {
    if (chartType != TaiYiChartType.hour) return DunType.yang;
    final winterSolstice = DateTime(dateTime.year, 12, 21);
    final summerSolstice = DateTime(dateTime.year, 6, 21);
    if (!dateTime.isBefore(winterSolstice) ||
        dateTime.isBefore(summerSolstice)) {
      return DunType.yang;
    }
    return DunType.yin;
  }

  EnumTaiYiGong _calculateTaiYiPalace(int juNumber, _RuleProfile rule) {
    final groupIndex = switch (rule.taiYiPalaceFormula) {
      _TaiYiPalaceFormula.jingMirror => (juNumber - 1) ~/ 3,
      _TaiYiPalaceFormula.jiCheng => juNumber ~/ 3,
    };
    final index = _positiveModulo(
        groupIndex + rule.taiYiPalaceShift, taiYiPalaceOrder.length);
    return taiYiPalaceOrder[index];
  }

  EnumTaiYiGong _calculateWenChangPalace({
    required int juNumber,
    required DunType dunType,
    required _RuleProfile rule,
  }) {
    final startBranch = dunType == DunType.yang ? '申' : '寅';
    final startIndex = sixteenDeities.indexOf(startBranch);
    final step = juNumber - 1;
    final index =
        dunType == DunType.yang ? startIndex + step : startIndex - step;
    var deity = sixteenDeities[_positiveModulo(index, sixteenDeities.length)];
    if (!rule.usesWenChangStayRule && branchPalace[deity] == null) {
      deity = _nearestBranchFromSixteen(index);
    }
    return branchPalace[deity] ?? _intercardinalPalace(deity);
  }

  EnumTaiYiGong _calculateJiShenPalace({
    required DateTime dateTime,
    required int juNumber,
    required TaiYiChartType chartType,
    required _RuleProfile rule,
  }) {
    if (_usesSharedYearEyeRules(rule, chartType)) {
      return _positionToPalace(_calculateTongZongJiShenPosition(juNumber));
    }
    final yearBranch = twelveBranches[_positiveModulo(dateTime.year - 4, 12)];
    final sequence = rule.usesTwelveJiShen ? twelveDeities : sixteenDeities;
    final startIndex = sequence.indexOf('艮');
    final normalizedStartIndex =
        startIndex == -1 ? sequence.indexOf('寅') : startIndex;
    final targetIndex = sequence.indexOf(yearBranch);
    if (targetIndex == -1) return branchPalace[yearBranch]!;
    final steps =
        _positiveModulo(targetIndex - normalizedStartIndex, sequence.length);
    return sequence[_positiveModulo(
                normalizedStartIndex + steps, sequence.length)] ==
            '艮'
        ? EnumTaiYiGong.Gen
        : branchPalace[sequence[_positiveModulo(
                normalizedStartIndex + steps, sequence.length)]] ??
            EnumTaiYiGong.Center;
  }

  Map<EnumTaiYiGong, EnumEightDoor> _calculateEightDoors({
    required int accumulatedYear,
    required TaiYiChartType chartType,
    required EnumTaiYiGong taiYiPalace,
    required _RuleProfile rule,
  }) {
    final Map<EnumTaiYiGong, EnumEightDoor> result = {};
    if (rule.fixedEightDoors) {
      for (var i = 0; i < taiYiPalaceOrder.length; i++) {
        result[taiYiPalaceOrder[i]] = eightDoorOrder[i];
      }
      return Map.unmodifiable(result);
    }

    if (_usesSharedYearEyeRules(rule, chartType)) {
      const eightDoorClockwisePalaces = [
        EnumTaiYiGong.Qian,
        EnumTaiYiGong.Kan,
        EnumTaiYiGong.Gen,
        EnumTaiYiGong.Zhen,
        EnumTaiYiGong.Xun,
        EnumTaiYiGong.Li,
        EnumTaiYiGong.Kun,
        EnumTaiYiGong.Dui,
      ];
      final normalizedRemainder =
          _positiveModulo(accumulatedYear, 240, zeroAsMod: true);
      final valueDoorIndex = (normalizedRemainder - 1) ~/ 30;
      final startDoor = eightDoorOrder[valueDoorIndex];
      final startDoorIndex = eightDoorOrder.indexOf(startDoor);
      final startPalaceIndex = eightDoorClockwisePalaces.indexOf(taiYiPalace);
      for (var i = 0; i < eightDoorClockwisePalaces.length; i++) {
        result[eightDoorClockwisePalaces[
                _positiveModulo(startPalaceIndex + i, eightDoorClockwisePalaces.length)]] =
            eightDoorOrder[
                _positiveModulo(startDoorIndex + i, eightDoorOrder.length)];
      }
      return Map.unmodifiable(result);
    }

    final start = taiYiPalaceOrder.indexOf(taiYiPalace);
    for (var i = 0; i < taiYiPalaceOrder.length; i++) {
      result[taiYiPalaceOrder[
              _positiveModulo(start + i, taiYiPalaceOrder.length)]] =
          eightDoorOrder[i];
    }
    return Map.unmodifiable(result);
  }

HostGuestDataModel _calculateHostGuest({
    required int juNumber,
    required EnumTaiYiGong taiYiPalace,
    required EnumTaiYiGong wenChangPalace,
    required String yearBranch,
    required _RuleProfile rule,
    required DunType dunType,
  }) {
  final wenChangDeity = _findWenChangDeity(juNumber);
  final wenChangPos = _sixteenGodPosition(wenChangDeity);
  final taiYiPos = _palaceToZhengDeityPosition(taiYiPalace);
  final shiJiDeity = _findShiJiDeity(juNumber);
  final shiJiPos = _sixteenGodPosition(shiJiDeity);
  final hostResult = _samePalaceCountWithDetail(
    startDeity: wenChangDeity,
    startPos: wenChangPos,
    taiYiPalace: taiYiPalace,
    taiYiPos: taiYiPos,
    schoolLabel: rule.school.label,
  ) ??
      _walkAndSumWithDetail(wenChangPos, taiYiPos, rule.school.label);
  final guestResult = _samePalaceCountWithDetail(
    startDeity: shiJiDeity,
    startPos: shiJiPos,
    taiYiPalace: taiYiPalace,
    taiYiPos: taiYiPos,
    schoolLabel: rule.school.label,
  ) ??
      _walkAndSumWithDetail(shiJiPos, taiYiPos, rule.school.label);

    final dingMuName = _calculateDingMuPosition(
      yearBranch: yearBranch,
      wenChangDeity: wenChangDeity,
    );
    final dingMuPos = _sixteenGodPosition(dingMuName);
    final dingMuPalace = _deityToPalace(dingMuName);
  final dingResult = _samePalaceCountWithDetail(
    startDeity: dingMuName,
    startPos: dingMuPos,
    taiYiPalace: taiYiPalace,
    taiYiPos: taiYiPos,
    schoolLabel: rule.school.label,
  ) ??
      _walkAndSumWithDetail(dingMuPos, taiYiPos, rule.school.label);
    final dingCount = dingResult.count;
    final dingPalace = dingMuPalace;

    final schoolBase = rule.isAncientSchool
        ? '${rule.school.label}基数: ${rule.ancientBase}'
        : '${rule.school.label}起算年: ${rule.contemporaryEpochYear}';

    return HostGuestDataModel(
      hostCount: hostResult.count,
      guestCount: guestResult.count,
      dingCount: dingCount,
    hostPalace: _deityToPalace(wenChangDeity),
    guestPalace: _deityToPalace(shiJiDeity),
      dingPalace: dingPalace,
      dingMuPalace: dingMuPalace,
      dingMuName: dingMuName,
      method: '$schoolBase · ${rule.methodNote}',
      hostCountDetail: HostCountDetail(
        isZhengGong: !_isJianShen(wenChangDeity),
        detail: hostResult.detail,
      ),
      guestCountDetail: HostCountDetail(
        isZhengGong: !_isJianShen(shiJiDeity),
        detail: guestResult.detail,
      ),
      dingCountDetail: HostCountDetail(
        isZhengGong: !_isJianShen(dingMuName),
        detail: dingResult.detail,
      ),
    );
  }

/// 天目（文昌）计算。
  ///
  /// 使用 God.WenChang_Seq 序列，从申起顺行，乾/坤各停2年，18年一循环。
  /// 位置 = juNumber % 18
  String _findWenChangDeity(int juNumber) {
    final pos = juNumber % 18;
    final actualPos = pos == 0 ? 18 : pos;
    return WenChang_Seq[actualPos - 1].singleName;
  }

  /// 计神计算。
  ///
  /// 使用 God.JiShen_Seq 序列，12年一循环。
  /// 位置 = juNumber % 12
  String _findJiShenBranch(int juNumber) {
    final pos = juNumber % 12;
    final actualPos = pos == 0 ? 12 : pos;
    return JiShen_Seq[actualPos - 1].singleName;
  }

  /// 始击计算。
  ///
  /// 计神和天目同时顺时针旋转，计神旋转到艮位，天目旋转后的位置即为始击。
  String _findShiJiDeity(int juNumber) {
    final jiShen = _findJiShenBranch(juNumber);
    final wenChang = _findWenChangDeity(juNumber);
    final jiShenIdx = _sixteenGodSequence.indexOf(jiShen);
    final wenChangIdx = _sixteenGodSequence.indexOf(wenChang);
    final genIdx = _sixteenGodSequence.indexOf('艮');
    final stepsToGen = (genIdx - jiShenIdx + 16) % 16;
    final shiJiIdx = (wenChangIdx + stepsToGen) % 16;
    return _sixteenGodSequence[shiJiIdx];
  }

  String _calculateTongZongTianMuPosition(int juNumber) {
    const sequence = [
      '\u7533',
      '\u9149',
      '\u620c',
      '\u4e7e',
      '\u4e7e',
      '\u4ea5',
      '\u5b50',
      '\u4e11',
      '\u826e',
      '\u5bc5',
      '\u536f',
      '\u8fb0',
      '\u5dfd',
      '\u5df3',
      '\u5348',
      '\u672a',
      '\u5764',
      '\u5764',
    ];
    final index = _positiveModulo(juNumber, sequence.length, zeroAsMod: true) - 1;
    return sequence[index];
  }

  String _calculateTongZongJiShenPosition(int juNumber) {
    const sequence = [
      '\u5bc5',
      '\u4e11',
      '\u5b50',
      '\u4ea5',
      '\u620c',
      '\u9149',
      '\u7533',
      '\u672a',
      '\u5348',
      '\u5df3',
      '\u8fb0',
      '\u536f',
    ];
    final index = _positiveModulo(juNumber, sequence.length, zeroAsMod: true) - 1;
    return sequence[index];
  }

  String _calculateTongZongShiJiPosition({
    required String tianMuPosition,
    required String jiShenPosition,
  }) {
    const sequence = [
      '\u5b50',
      '\u4e11',
      '\u826e',
      '\u5bc5',
      '\u536f',
      '\u8fb0',
      '\u5dfd',
      '\u5df3',
      '\u5348',
      '\u672a',
      '\u5764',
      '\u7533',
      '\u9149',
      '\u620c',
      '\u4e7e',
      '\u4ea5',
    ];
    final jiShenIndex = sequence.indexOf(jiShenPosition);
    final tianMuIndex = sequence.indexOf(tianMuPosition);
    final genIndex = sequence.indexOf('\u826e');
    if (jiShenIndex == -1 || tianMuIndex == -1 || genIndex == -1) {
      return tianMuPosition;
    }
    final stepsToGen = _positiveModulo(genIndex - jiShenIndex, sequence.length);
    return sequence[_positiveModulo(tianMuIndex + stepsToGen, sequence.length)];
  }

  EnumTaiYiGong _positionToPalace(String position) {
    return switch (position) {
      '\u4e7e' => EnumTaiYiGong.Qian,
      '\u4ea5' => EnumTaiYiGong.Qian,
      '\u620c' => EnumTaiYiGong.Qian,
      '\u9149' => EnumTaiYiGong.Dui,
      '\u7533' => EnumTaiYiGong.Kun,
      '\u5764' => EnumTaiYiGong.Kun,
      '\u672a' => EnumTaiYiGong.Kun,
      '\u5348' => EnumTaiYiGong.Li,
      '\u5df3' => EnumTaiYiGong.Xun,
      '\u5dfd' => EnumTaiYiGong.Xun,
      '\u8fb0' => EnumTaiYiGong.Xun,
      '\u536f' => EnumTaiYiGong.Zhen,
      '\u5bc5' => EnumTaiYiGong.Gen,
      '\u826e' => EnumTaiYiGong.Gen,
      '\u4e11' => EnumTaiYiGong.Gen,
      '\u5b50' => EnumTaiYiGong.Kan,
      _ => EnumTaiYiGong.Center,
    };
  }

  bool _usesSharedYearEyeRules(_RuleProfile rule, TaiYiChartType chartType) {
    if (chartType != TaiYiChartType.year) return false;
    return rule.school == TaiYiSchool.jingMirror ||
        rule.school == TaiYiSchool.tongZong;
  }

  static const _countingSequence = [
    '\u4e7e',
    '\u4ea5',
    '\u5b50',
    '\u4e11',
    '\u826e',
    '\u5bc5',
    '\u536f',
    '\u8fb0',
    '\u5dfd',
    '\u5df3',
    '\u5348',
    '\u672a',
    '\u5764',
    '\u7533',
    '\u9149',
    '\u620c',
  ];

  static const _countingPalaceNumbers = {
    '\u4e7e': 1,
    '\u5b50': 8,
    '\u826e': 3,
    '\u536f': 4,
    '\u5dfd': 9,
    '\u5348': 2,
    '\u5764': 7,
    '\u9149': 6,
  };

  String _countingPositionForPalace(EnumTaiYiGong palace) {
    return switch (palace) {
      EnumTaiYiGong.Qian => '\u4e7e',
      EnumTaiYiGong.Li => '\u5348',
      EnumTaiYiGong.Gen => '\u826e',
      EnumTaiYiGong.Zhen => '\u536f',
      EnumTaiYiGong.Xun => '\u5dfd',
      EnumTaiYiGong.Dui => '\u9149',
      EnumTaiYiGong.Kun => '\u5764',
      EnumTaiYiGong.Kan => '\u5b50',
      EnumTaiYiGong.Center => '\u4e2d',
    };
  }

  int _calculateSharedYearCount({
    required String startPosition,
    required String endPosition,
  }) {
    final startIndex = _countingSequence.indexOf(startPosition);
    final endIndex = _countingSequence.indexOf(endPosition);
    if (startIndex == -1 || endIndex == -1) return 0;

    if (startPosition == endPosition) {
      return _countingPalaceNumbers[startPosition] ??
          (_countingPalaceNumbers.containsKey(startPosition) ? 0 : 1);
    }

    var sum = 0;
    if (!_countingPalaceNumbers.containsKey(startPosition)) {
      sum += 1;
    }

    var index = startIndex;
    while (index != endIndex) {
      final position = _countingSequence[index];
      sum += _countingPalaceNumbers[position] ?? 0;
      index = (index + 1) % _countingSequence.length;
    }
    return sum;
  }

  static const _taiSuiHeShen = {
    '\u5b50': '\u4e11',
    '\u4e11': '\u5b50',
    '\u5bc5': '\u4ea5',
    '\u4ea5': '\u5bc5',
    '\u536f': '\u620c',
    '\u620c': '\u536f',
    '\u8fb0': '\u9149',
    '\u9149': '\u8fb0',
    '\u5df3': '\u7533',
    '\u7533': '\u5df3',
    '\u5348': '\u672a',
    '\u672a': '\u5348',
  };

  String _calculateSharedYearDingMuPosition({
    required String yearBranch,
    required String tianMuPosition,
  }) {
    final heShen = _taiSuiHeShen[yearBranch];
    final taiSuiIndex = _countingSequence.indexOf(yearBranch);
    final heShenIndex = heShen == null ? -1 : _countingSequence.indexOf(heShen);
    final tianMuIndex = _countingSequence.indexOf(tianMuPosition);
    if (taiSuiIndex == -1 || heShenIndex == -1 || tianMuIndex == -1) {
      return tianMuPosition;
    }
    final delta = taiSuiIndex - heShenIndex;
    return _countingSequence[
        _positiveModulo(tianMuIndex + delta, _countingSequence.length)];
  }

  int _normalizeCountToTen(int count) {
    final remainder = count % 10;
    return remainder == 0 ? 10 : remainder;
  }

  int _guestOrDingGeneralNumber(int count) {
    final ones = count % 10;
    if (ones != 0) return ones;
    final remainder = count % 9;
    return remainder == 0 ? 9 : remainder;
  }

  EnumTaiYiGong _generalNumberToGong(int number) {
    return switch (number) {
      1 || 10 => EnumTaiYiGong.Qian,
      2 => EnumTaiYiGong.Li,
      3 => EnumTaiYiGong.Gen,
      4 => EnumTaiYiGong.Zhen,
      5 => EnumTaiYiGong.Center,
      6 => EnumTaiYiGong.Dui,
      7 => EnumTaiYiGong.Kun,
      8 => EnumTaiYiGong.Kan,
      9 => EnumTaiYiGong.Xun,
      _ => EnumTaiYiGong.Center,
    };
  }

  EnumTaiYiGong _palaceFromSteppedCycle({
    required int accumulatedYear,
    required int cycle,
    required int stepYears,
    required String startPosition,
    bool reverse = false,
  }) {
    final remainder = _positiveModulo(accumulatedYear, cycle, zeroAsMod: true);
    final steps = (remainder - 1) ~/ stepYears;
    final startIndex = _countingSequence.indexOf(startPosition);
    if (startIndex == -1) return EnumTaiYiGong.Center;
    final offset = reverse ? -steps : steps;
    final position = _countingSequence[
        _positiveModulo(startIndex + offset, _countingSequence.length)];
    return _positionToPalace(position);
  }

  static const _jianShenDeities = {'寅', '申', '巳', '亥', '辰', '戌', '丑', '未'};

  static bool _isJianShen(String deity) => _jianShenDeities.contains(deity);

  String _deityAtPosition(int pos) {
    return _sixteenGodSequence[(pos - 1) % 16];
  }

  int _palaceToZhengDeityPosition(EnumTaiYiGong palace) {
    return switch (palace) {
      EnumTaiYiGong.Qian => 15,
      EnumTaiYiGong.Kan => 1,
      EnumTaiYiGong.Gen => 3,
      EnumTaiYiGong.Zhen => 5,
      EnumTaiYiGong.Xun => 7,
      EnumTaiYiGong.Li => 9,
      EnumTaiYiGong.Kun => 11,
      EnumTaiYiGong.Dui => 13,
      _ => 1,
    };
  }

  static const List<int> _zhengDeityPositions = [1, 3, 5, 7, 9, 11, 13, 15];

  bool _isZhengDeity(int pos) => _zhengDeityPositions.contains(pos);

  int _hostGuestPalaceNumber(EnumTaiYiGong palace) {
    return palace.order >= 5 ? palace.order + 1 : palace.order;
  }

  ({int count, String detail})? _samePalaceCountWithDetail({
    required String startDeity,
    required int startPos,
    required EnumTaiYiGong taiYiPalace,
    required int taiYiPos,
    required String schoolLabel,
  }) {
    final startPalace = _deityToPalace(startDeity);
    if (startPalace != taiYiPalace) return null;

    if (startPos == taiYiPos) {
      final count = _hostGuestPalaceNumber(taiYiPalace);
      return (
        count: count,
        detail: '$schoolLabel: $startDeity(同宫同神取宫数$count) = $count',
      );
    }

    return (
      count: 1,
      detail: '$schoolLabel: $startDeity(同宫不同神取1) = 1',
    );
  }

  ({int count, String detail}) _walkAndSumWithDetail(int startPos, int taiYiPos, String schoolLabel) {
    int sum = 0;
    final steps = <String>[];
    final startDeity = _deityAtPosition(startPos);
    if (_isZhengDeity(startPos)) {
      final palace = _deityToPalace(startDeity);
      final num = _hostGuestPalaceNumber(palace);
      sum += num;
      steps.add('$startDeity($num)');
    } else {
      sum += 1;
      steps.add('1(间神起)');
    }
    int cur = startPos % 16 + 1;
    for (var i = 0; i < 16; i++) {
      if (cur == taiYiPos) break;
      if (_isZhengDeity(cur)) {
        final deity = _deityAtPosition(cur);
        final palace = _deityToPalace(deity);
        final num = _hostGuestPalaceNumber(palace);
        sum += num;
        steps.add('$deity($num)');
      }
      cur = cur % 16 + 1;
    }
    return (count: sum, detail: '$schoolLabel: ${steps.join(" + ")} = $sum');
  }

  String _calculateDingMuPosition({
    required String yearBranch,
    required String wenChangDeity,
  }) {
    final heShenBranch = _branchComplement(yearBranch);
    final taiSuiPos = _sixteenGodPosition(yearBranch);
    final heShenPos = _sixteenGodPosition(heShenBranch);
    final wenChangPos = _sixteenGodPosition(wenChangDeity);
    final shift = taiSuiPos - heShenPos;
    final dingMuPos = _positiveModulo(wenChangPos + shift - 1, 16) + 1;
    return _sixteenGodByPosition(dingMuPos);
  }

  static const _sixteenGodSequence = [
    '子',
    '丑',
    '艮',
    '寅',
    '卯',
    '辰',
    '巽',
    '巳',
    '午',
    '未',
    '坤',
    '申',
    '酉',
    '戌',
    '乾',
    '亥',
  ];

  int _sixteenGodPosition(String branch) {
    final idx = _sixteenGodSequence.indexOf(branch);
    return idx >= 0 ? idx + 1 : 1;
  }

  String _sixteenGodByPosition(int position) {
    return _sixteenGodSequence[(position - 1) % 16];
  }

  String _branchComplement(String branch) {
    return switch (branch) {
      '子' => '丑',
      '丑' => '子',
      '寅' => '亥',
      '亥' => '寅',
      '卯' => '戌',
      '戌' => '卯',
      '辰' => '酉',
      '酉' => '辰',
      '巳' => '申',
      '申' => '巳',
      '午' => '未',
      '未' => '午',
      _ => branch,
    };
  }

  EnumTaiYiGong _deityToPalace(String deity) {
    if (gongNumber12ToPalace.containsKey(deity)) {
      return gongNumber12ToPalace[deity]!;
    }
    return branchPalace[deity] ?? _intercardinalPalace(deity);
  }

  List<PanComputedItem> _buildBuiltInItems({
    required EnumTaiYiGong taiYiPalace,
    required EnumTaiYiGong wenChangPalace,
    required EnumTaiYiGong jiShenPalace,
    required Map<EnumTaiYiGong, EnumEightDoor> eightDoorsByPalace,
    required HostGuestDataModel hostGuest,
    required TianPanModel tianPan,
    required ShenPanModel shenPan,
    required RenPanModel renPan,
  }) {
    final items = <PanComputedItem>[
      PanComputedItem(
          id: 'builtIn:taiYi',
          name: '太乙',
          kind: PanComputedItemKind.deity,
          gong: taiYiPalace,
          source: PanComputedItemSource.builtIn,
          priority: 10),
      PanComputedItem(
          id: 'builtIn:wenChang',
          name: '文昌',
          kind: PanComputedItemKind.eye,
          gong: wenChangPalace,
          source: PanComputedItemSource.builtIn,
          priority: 20),
      PanComputedItem(
          id: 'builtIn:shiJi',
          name: '始击',
          kind: PanComputedItemKind.eye,
          gong: renPan.shiJiGong,
          source: PanComputedItemSource.builtIn,
          priority: 25,
          metadata: {'deityKind': EnumDeityKind.shiJi.name}),
      PanComputedItem(
          id: 'builtIn:jiShen',
          name: '计神',
          kind: PanComputedItemKind.eye,
          gong: jiShenPalace,
          source: PanComputedItemSource.builtIn,
          priority: 15),
      for (final entry in eightDoorsByPalace.entries)
        eightDoorItem(door: entry.value, gong: entry.key),
      PanComputedItem(
          id: 'builtIn:hostCount',
          name: '主算',
          kind: PanComputedItemKind.count,
          gong: null,
          source: PanComputedItemSource.builtIn,
          priority: 35,
          metadata: {'count': hostGuest.hostCount}),
      PanComputedItem(
          id: 'builtIn:guestCount',
          name: '客算',
          kind: PanComputedItemKind.count,
          gong: null,
          source: PanComputedItemSource.builtIn,
          priority: 35,
          metadata: {'count': hostGuest.guestCount}),
    ];

    for (final p in tianPan.toPlacements()) {
      items.add(PanComputedItem(
          id: 'builtIn:tian:${p.kind.name}',
          name: p.kind.label,
          kind: PanComputedItemKind.deity,
          gong: p.gong,
          source: PanComputedItemSource.builtIn,
          priority: 40));
    }
    for (final p in shenPan.toPlacements()) {
      items.add(PanComputedItem(
          id: 'builtIn:shen:${p.kind.name}',
          name: p.kind.label,
          kind: PanComputedItemKind.deity,
          gong: p.gong,
          source: PanComputedItemSource.builtIn,
          priority: 45));
    }
    return items;
  }

  RenPanModel _buildRenPan({
    required int juNumber,
    required TaiYiChartType chartType,
    required DunType dunType,
    required EnumTaiYiGong taiYiPalace,
    required EnumTaiYiGong wenChangPalace,
    required EnumTaiYiGong jiShenPalace,
    required _RuleProfile rule,
  }) {
    if (_usesSharedYearEyeRules(rule, chartType)) {
      final tianMuPosition = _calculateTongZongTianMuPosition(juNumber);
      final jiShenPosition = _calculateTongZongJiShenPosition(juNumber);
      final shiJiPosition = _calculateTongZongShiJiPosition(
        tianMuPosition: tianMuPosition,
        jiShenPosition: jiShenPosition,
      );
      final Map<EnumTaiYiGong, List<String>> godsByPalace = {};
      for (final deity in sixteenDeities) {
        final deityGong = _deityGongForSequence(deity);
        godsByPalace.putIfAbsent(deityGong, () => []).add(deity);
      }
      return RenPanModel(
        sixteenGodsByPalace: Map.from(godsByPalace),
        tianMuGong: _positionToPalace(tianMuPosition),
        shiJiGong: _positionToPalace(shiJiPosition),
        jiShenGong: _positionToPalace(jiShenPosition),
        tianMuName: tianMuPosition,
        shiJiName: shiJiPosition,
        jiShenName: jiShenPosition,
        methodNote: rule.methodNote,
      );
    }
final sequence = rule.usesTwelveJiShen ? twelveDeities : sixteenDeities;
  final wenChangIndex =
      sequence.indexOf(sixteenDeities.contains('申') ? '申' : '寅');
  final tianMuIndex = _positiveModulo(
        wenChangIndex + (rule.school == TaiYiSchool.jingMirror ? 8 : 3),
        sequence.length);
    final shiJiIndex = _positiveModulo(tianMuIndex + 4, sequence.length);

    final Map<EnumTaiYiGong, List<String>> godsByPalace = {};
    for (var i = 0; i < sequence.length; i++) {
      final deityName = _deityNameForSequence(sequence[i]);
      final deityGong = _deityGongForSequence(sequence[i]);
      godsByPalace.putIfAbsent(deityGong, () => []).add(deityName);
    }

    return RenPanModel(
      sixteenGodsByPalace: Map.from(godsByPalace),
      tianMuGong: _deityGongForSequence(sequence[tianMuIndex]),
      shiJiGong: _deityGongForSequence(sequence[shiJiIndex]),
      jiShenGong: jiShenPalace,
      tianMuName: _deityNameForSequence(sequence[tianMuIndex]),
      shiJiName: _deityNameForSequence(sequence[shiJiIndex]),
      jiShenName: '计神',
      methodNote: rule.methodNote,
    );
  }

  String _deityNameForSequence(String item) => item;
  EnumTaiYiGong _deityGongForSequence(String item) {
    return branchPalace[item] ?? _intercardinalPalace(item);
  }

  TianPanModel _buildTianPan({
    required int accumulatedYear,
    required EnumTaiYiGong taiYiPalace,
    required EnumTaiYiGong wenChangPalace,
    required HostGuestDataModel hostGuest,
    required _RuleProfile rule,
  }) {
    final hostGeneralNumber = _normalizeCountToTen(hostGuest.hostCount);
    final guestGeneralNumber = _normalizeCountToTen(hostGuest.guestCount);
    final hostGeneralGong = _calculateGeneralGong(hostGeneralNumber, rule);
    final guestGeneralGong = _calculateGeneralGong(guestGeneralNumber, rule);
    final hostDeputyGeneralGong =
        _calculateDeputyGeneralGong(hostGeneralNumber, rule);
    final guestDeputyGeneralGong =
        _calculateDeputyGeneralGong(guestGeneralNumber, rule);

  EnumTaiYiGong? dingGeneralGong;
  EnumTaiYiGong? dingDeputyGeneralGong;
  EnumTaiYiGong? junJiGong;
  EnumTaiYiGong? chenJiGong;
  EnumTaiYiGong? minJiGong;
  EnumTaiYiGong? wuFuGong;
  EnumTaiYiGong? daYouGong;
  EnumTaiYiGong? xiaoYouGong;
  EnumTaiYiGong? feiFuGong;
  EnumTaiYiGong? siShenGong;
  EnumTaiYiGong? tianYiGong2;
  EnumTaiYiGong? diYiGong;
  EnumTaiYiGong? zhiFuGong2;
  int? siShenRuGongNianShu;
  int? tianYiRuGongNianShu;
  int? diYiRuGongNianShu;
  int? zhiFuRuGongNianShu;

  final dingGeneralNumber = _guestOrDingGeneralNumber(hostGuest.dingCount);
  dingGeneralGong = _calculateGeneralGong(dingGeneralNumber, rule);
  dingDeputyGeneralGong =
      _calculateGuestOrDingDeputyGeneralGong(dingGeneralNumber);

  if (rule.school == TaiYiSchool.jingMirror) {
    junJiGong = _calculateJunJi(accumulatedYear, rule);
    chenJiGong = _calculateChenJi(accumulatedYear, rule);
    minJiGong = _calculateMinJi(accumulatedYear, rule);
    wuFuGong = _calculateWuFu(accumulatedYear, rule);
    daYouGong = _calculateDaYou(accumulatedYear, rule);
    xiaoYouGong = _calculateXiaoYou(accumulatedYear, rule);
    feiFuGong = _calculateFeiFu(taiYiPalace, rule);
  } else if (rule.school == TaiYiSchool.tongZong) {
    junJiGong = _calculateJunJi(accumulatedYear, rule);
    chenJiGong = _calculateChenJi(accumulatedYear, rule);
    minJiGong = _calculateMinJi(accumulatedYear, rule);
    wuFuGong = _calculateWuFu(accumulatedYear, rule);
    daYouGong = _calculateDaYou(accumulatedYear, rule);
    xiaoYouGong = _calculateXiaoYou(accumulatedYear, rule);

    final ji = accumulatedYear;
    final gongIdx = ((ji - 1) % 36) ~/ 3;
    var nianShu = ji % 36 % 3;
    if (nianShu == 0) nianShu = 3;
    siShenGong = _deityToPalace(sishen12Gong[gongIdx]);
    siShenRuGongNianShu = nianShu;
    tianYiGong2 = _deityToPalace(tianYi12Gong[gongIdx]);
    tianYiRuGongNianShu = nianShu;
    diYiGong = _deityToPalace(diYi12Gong[gongIdx]);
    diYiRuGongNianShu = nianShu;
    zhiFuGong2 = _deityToPalace(zhiFu12Gong[gongIdx]);
    zhiFuRuGongNianShu = nianShu;
  }

  return TianPanModel(
    taiYiGong: taiYiPalace,
    hostGeneralGong: hostGeneralGong,
    guestGeneralGong: guestGeneralGong,
    hostDeputyGeneralGong: hostDeputyGeneralGong,
    guestDeputyGeneralGong: guestDeputyGeneralGong,
    dingGeneralGong: dingGeneralGong,
    dingDeputyGeneralGong: dingDeputyGeneralGong,
    junJiGong: junJiGong,
    chenJiGong: chenJiGong,
    minJiGong: minJiGong,
    wuFuGong: wuFuGong,
    daYouGong: daYouGong,
    xiaoYouGong: xiaoYouGong,
    feifFuGong: feiFuGong,
    siShenGong: siShenGong,
    tianYiGong2: tianYiGong2,
    diYiGong: diYiGong,
    zhiFuGong2: zhiFuGong2,
    siShenRuGongNianShu: siShenRuGongNianShu,
    tianYiRuGongNianShu: tianYiRuGongNianShu,
    diYiRuGongNianShu: diYiRuGongNianShu,
    zhiFuRuGongNianShu: zhiFuRuGongNianShu,
    methodNote: '主客大将参将已实现；三基五福大游小游为 MVP 近似',
  );
}

  ShenPanModel _buildShenPan({
    required int accumulatedYear,
    required DateTime dateTime,
    required EnumTaiYiGong taiYiPalace,
    required _RuleProfile rule,
  }) {
    final yearBranch = twelveBranches[_positiveModulo(dateTime.year - 4, 12)];
    final heShenBranch = _branchComplement(yearBranch);
    final taiSuiGong = branchPalace[yearBranch] ?? EnumTaiYiGong.Kan;
    final heShenGong = _deityToPalace(heShenBranch);
  final suiPoGongIndex = (taiYiPalaceOrder.indexOf(taiSuiGong) + 6) % 9;
  final suiPoGong = taiYiPalaceOrder[suiPoGongIndex];

  EnumTaiYiGong? qingLongQiGong;
  EnumTaiYiGong? heiQiGong;
  EnumTaiYiGong? chiQiGong;
  EnumTaiYiGong? guiShenZhiShiGong;
  int? heiQiRuGongNianShu;

  if (rule.school == TaiYiSchool.tongZong) {
    final ji = accumulatedYear;
    qingLongQiGong = taiSuiGong;

    final heiQiIdx = ((ji - 1) % 360) % 36 ~/ 3;
    heiQiGong = _deityToPalace(heiQi12Chen[heiQiIdx]);
    final heiQiNianShu = ji % 360 % 36 % 3;
    heiQiRuGongNianShu = heiQiNianShu == 0 ? 3 : heiQiNianShu;

    final chiQiIdx = ji % 40 % 4;
    chiQiGong = _deityToPalace(chiQi4Gong[chiQiIdx]);

    final zhiShiRaw = (ji % 360 % 60 + 3) % 9;
    final zhiShiIdx = zhiShiRaw == 0 ? 9 : zhiShiRaw;
    final guiShenNum = guiShenZhiShiMap[zhiShiIdx] ?? 1;
    final palaceNum = guiShenPalaceOrder[guiShenNum - 1];
    guiShenZhiShiGong = _gongNumberToPalace(palaceNum);
  }

  return ShenPanModel(
    taiSuiGong: taiSuiGong,
    suiPoGong: suiPoGong,
    zhiFuGong: gongClash[taiYiPalace] ?? taiYiPalace,
    heShenGong: heShenGong,
    qingLongQiGong: qingLongQiGong,
    heiQiGong: heiQiGong,
    chiQiGong: chiQiGong,
    guiShenZhiShiGong: guiShenZhiShiGong,
    heiQiRuGongNianShu: heiQiRuGongNianShu,
    methodNote: '神盘 MVP 近似',
  );
}

EnumTaiYiGong _gongNumberToPalace(int num) {
  return switch (num) {
    1 => EnumTaiYiGong.Qian,
    2 => EnumTaiYiGong.Li,
    3 => EnumTaiYiGong.Gen,
    4 => EnumTaiYiGong.Zhen,
    5 => EnumTaiYiGong.Center,
    6 => EnumTaiYiGong.Dui,
    7 => EnumTaiYiGong.Kun,
    8 => EnumTaiYiGong.Kan,
    9 => EnumTaiYiGong.Xun,
    _ => EnumTaiYiGong.Center,
  };
}

  GeJuResultModel _buildGeJu({
    required EnumTaiYiGong taiYiPalace,
    required EnumTaiYiGong wenChangPalace,
    required EnumTaiYiGong shiJiGong,
    required HostGuestDataModel hostGuest,
    required TianPanModel tianPan,
  }) {
    final patterns = <GeJuEntry>[];
    if (shiJiGong == taiYiPalace) {
      patterns.add(GeJuEntry(
          type: EnumGeJu.yan,
          description: '始击与太乙同宫',
          relatedGongs: [shiJiGong, taiYiPalace],
          relatedDeities: [EnumDeityKind.shiJi, EnumDeityKind.taiYi],
          severity: 5));
    }
    if (taiYiPalace == wenChangPalace) {
      patterns.add(GeJuEntry(
          type: EnumGeJu.qiu,
          description: '太乙文昌同宫',
          relatedGongs: [taiYiPalace],
          relatedDeities: [EnumDeityKind.taiYi, EnumDeityKind.tianMu],
          severity: 4));
    }
    final clash = gongClash[taiYiPalace];
    if (clash != null && clash == shiJiGong) {
      patterns.add(GeJuEntry(
          type: EnumGeJu.ji,
          description: '始击对冲太乙',
          relatedGongs: [taiYiPalace, shiJiGong],
          relatedDeities: [EnumDeityKind.shiJi, EnumDeityKind.taiYi],
          severity: 4));
    }
    final isJueYang = taiYiPalace.status == '绝阳';
    final isJueYin = taiYiPalace.status == '绝阴';
    if ((isJueYang || isJueYin) &&
        (wenChangPalace == taiYiPalace || clash == wenChangPalace)) {
      patterns.add(GeJuEntry(
          type: EnumGeJu.po,
          description: '天目入${taiYiPalace.status}宫',
          relatedGongs: [wenChangPalace, taiYiPalace],
          relatedDeities: [EnumDeityKind.tianMu, EnumDeityKind.taiYi],
          severity: 3));
    }
    if (taiYiPalace == shiJiGong) {
      patterns.add(GeJuEntry(
          type: EnumGeJu.ge,
          description: '太乙同宫始击',
          relatedGongs: [taiYiPalace],
          relatedDeities: [EnumDeityKind.taiYi, EnumDeityKind.shiJi],
          severity: 3));
    }
    if (hostGuest.hostCount + hostGuest.guestCount == 10) {
      patterns.add(GeJuEntry(
          type: EnumGeJu.dui,
          description: '主客算和为10',
          relatedDeities: [
            EnumDeityKind.hostGeneral,
            EnumDeityKind.guestGeneral
          ],
          severity: 2));
    }
    return GeJuResultModel(
      patterns: List.unmodifiable(patterns),
      methodNote: '已实现6大格局；小格局待后续补充',
    );
  }

  List<PalaceDataModel> _buildPalaces({required List<PanComputedItem> items}) {
    final Map<EnumTaiYiGong, List<PanComputedItem>> itemsByGong = {};
    for (final item in items) {
      if (item.gong != null) {
        itemsByGong.putIfAbsent(item.gong!, () => []).add(item);
      }
    }
    return createEmptyPalaces().map((palace) {
      final palaceItems = itemsByGong[palace.gong] ?? [];
      return palace.copyWith(items: List.unmodifiable(palaceItems));
    }).toList();
  }

  EnumTaiYiGong _calculateGeneralGong(int count, _RuleProfile rule) {
    return _generalNumberToGong(_normalizeCountToTen(count));
  }

  EnumTaiYiGong _calculateDeputyGeneralGong(
      int generalNumber, _RuleProfile rule) {
    final deputyNumber = _normalizeCountToTen(generalNumber * 3);
    return _generalNumberToGong(deputyNumber);
  }

  EnumTaiYiGong _calculateGuestOrDingDeputyGeneralGong(int generalNumber) {
    final deputyNumber = (generalNumber * 3) % 10;
    return _generalNumberToGong(deputyNumber == 0 ? 10 : deputyNumber);
  }

  EnumTaiYiGong? _calculateJunJi(int accumulatedYear, _RuleProfile rule) {
    return _palaceFromSteppedCycle(
      accumulatedYear: accumulatedYear,
      cycle: 360,
      stepYears: 30,
      startPosition: '\u5348',
    );
  }

  EnumTaiYiGong? _calculateChenJi(int accumulatedYear, _RuleProfile rule) {
    return _palaceFromSteppedCycle(
      accumulatedYear: accumulatedYear,
      cycle: 360,
      stepYears: 30,
      startPosition: '\u5348',
    );
  }

  EnumTaiYiGong? _calculateMinJi(int accumulatedYear, _RuleProfile rule) {
    return _palaceFromSteppedCycle(
      accumulatedYear: accumulatedYear,
      cycle: 270,
      stepYears: 30,
      startPosition: '\u620c',
    );
  }

  EnumTaiYiGong? _calculateWuFu(int accumulatedYear, _RuleProfile rule) {
    const sequence = [
      EnumTaiYiGong.Qian,
      EnumTaiYiGong.Gen,
      EnumTaiYiGong.Xun,
      EnumTaiYiGong.Kun,
      EnumTaiYiGong.Center,
    ];
    final remainder = _positiveModulo(accumulatedYear, 225, zeroAsMod: true);
    final index = (remainder - 1) ~/ 45;
    return sequence[index];
  }

  EnumTaiYiGong? _calculateDaYou(int accumulatedYear, _RuleProfile rule) {
    return _palaceFromSteppedCycle(
      accumulatedYear: accumulatedYear,
      cycle: 288,
      stepYears: 36,
      startPosition: '\u4ea5',
    );
  }

  EnumTaiYiGong? _calculateXiaoYou(int accumulatedYear, _RuleProfile rule) {
    return _palaceFromSteppedCycle(
      accumulatedYear: accumulatedYear,
      cycle: 24,
      stepYears: 1,
      startPosition: '\u5dfd',
    );
  }

  EnumTaiYiGong? _calculateFeiFu(EnumTaiYiGong taiYiPalace, _RuleProfile rule) {
    final index = taiYiPalaceOrder.indexOf(taiYiPalace);
    return taiYiPalaceOrder[
        _positiveModulo(index + 2, taiYiPalaceOrder.length)];
  }

  List<PanComputedItem> _calculateCustomItems({
    required List<CustomDeityDefinition> definitions,
    required PanInputModel input,
    required int juNumber,
    required DunType dunType,
    required List<PanComputedItem> builtInItems,
    required List<String> warnings,
  }) {
    return definitions.map((definition) {
      final gong = _evaluateCustomDeityGong(
        algorithm: definition.algorithm,
        input: input,
        juNumber: juNumber,
        dunType: dunType,
        builtInItems: builtInItems,
      );
      return PanComputedItem(
        id: 'custom:${definition.id}',
        name: definition.name,
        kind: PanComputedItemKind.customDeity,
        gong: gong,
        source: PanComputedItemSource.custom,
        priority: 50,
        metadata: {'definitionId': definition.id},
      );
    }).toList();
  }

  EnumTaiYiGong? _evaluateCustomDeityGong({
    required CustomDeityAlgorithmSpec algorithm,
    required PanInputModel input,
    required int juNumber,
    required DunType dunType,
    required List<PanComputedItem> builtInItems,
  }) {
    return null;
  }

  String? _readString(Object? value) {
    return value?.toString();
  }

  List<EnumTaiYiGong> _readGongOrder(Object? value) {
    if (value is List) {
      final order = value
          .map((item) => TaiYiGongId.tryFromId(item.toString()))
          .whereType<EnumTaiYiGong>()
          .toList();
      return order.isEmpty ? taiYiPalaceOrder : order;
    }
    return taiYiPalaceOrder;
  }

  int? _readInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  int _compareComputedItem(PanComputedItem a, PanComputedItem b) {
    final priority = a.priority.compareTo(b.priority);
    if (priority != 0) return priority;
    return a.id.compareTo(b.id);
  }

  int _chineseHourIndex(DateTime dateTime) =>
      ((dateTime.hour + 1) ~/ 2) % 12 + 1;

  int _dayOfYear(DateTime dateTime) =>
      dateTime.difference(DateTime(dateTime.year)).inDays + 1;

  int _cyclicDistance(EnumTaiYiGong fromPalace, EnumTaiYiGong toPalace) {
    final from = taiYiPalaceOrder.indexOf(fromPalace);
    final to = taiYiPalaceOrder.indexOf(toPalace);
    if (from == -1 || to == -1) return 0;
    return _positiveModulo(to - from, taiYiPalaceOrder.length);
  }

  String _nearestBranchFromSixteen(int index) {
    for (var offset = 0; offset < sixteenDeities.length; offset++) {
      final forward = sixteenDeities[
          _positiveModulo(index + offset, sixteenDeities.length)];
      if (branchPalace[forward] != null) return forward;
      final backward = sixteenDeities[
          _positiveModulo(index - offset, sixteenDeities.length)];
      if (branchPalace[backward] != null) return backward;
    }
    return '子';
  }

  EnumTaiYiGong _intercardinalPalace(String deity) {
    return switch (deity) {
      '乾' => EnumTaiYiGong.Qian,
      '艮' => EnumTaiYiGong.Gen,
      '坤' => EnumTaiYiGong.Kun,
      '巽' => EnumTaiYiGong.Xun,
      _ => EnumTaiYiGong.Center,
    };
  }

  int _positiveModulo(int value, int mod, {bool zeroAsMod = false}) {
    final result = value % mod;
    final positive = result < 0 ? result + mod : result;
    if (zeroAsMod && positive == 0) return mod;
    return positive;
  }

  EnumTaiYiGong? _passesTaiYiDoorConstraint(
      EnumTaiYiGong gong, Map<String, Object?> params) {
    final requiredDoor = params['requiredTaiYiDoorId']?.toString();
    if (requiredDoor == null) return gong;
    final door = TaiYiDoorId.tryFromId(requiredDoor);
    return door != null && gong.door == door ? gong : null;
  }
}

enum _TaiYiPalaceFormula {
  jingMirror,
  jiCheng,
}

class _RuleProfile {
  const _RuleProfile({
    required this.school,
    required this.isAncientSchool,
    required this.ancientBase,
    required this.ancientEpochYear,
    required this.contemporaryEpochYear,
    required this.taiYiPalaceFormula,
    required this.taiYiPalaceShift,
    required this.usesWenChangStayRule,
    required this.usesTwelveJiShen,
    required this.fixedEightDoors,
    required this.tropicalYear,
    required this.hostGuestBase,
    required this.methodNote,
    required this.warnings,
    this.zhangSui = 0,
    this.zhangYue = 0,
  });

  final TaiYiSchool school;
  final bool isAncientSchool;
  final int ancientBase;
  final int ancientEpochYear;
  final int contemporaryEpochYear;
  final _TaiYiPalaceFormula taiYiPalaceFormula;
  final int taiYiPalaceShift;
  final bool usesWenChangStayRule;
  final bool usesTwelveJiShen;
  final bool fixedEightDoors;
  final double tropicalYear;
  final int hostGuestBase;
  final String methodNote;
  final List<String> warnings;
  final int zhangSui;
  final int zhangYue;

  factory _RuleProfile.forSchool(TaiYiSchool school) {
    return switch (school) {
      TaiYiSchool.jingMirror => const _RuleProfile(
        school: TaiYiSchool.jingMirror,
        isAncientSchool: true,
        ancientBase: 1937281,
        ancientEpochYear: 724,
        contemporaryEpochYear: 0,
        taiYiPalaceFormula: _TaiYiPalaceFormula.jingMirror,
        taiYiPalaceShift: 0,
        usesWenChangStayRule: true,
        usesTwelveJiShen: false,
        fixedEightDoors: false,
        tropicalYear: 365.2425,
        hostGuestBase: 1,
        methodNote: '金镜古法',
        warnings: ['金镜派天目重留当前为 MVP 近似，后续需用典籍验盘校正。'],
        zhangSui: 657,
        zhangYue: 8726,
      ),
      TaiYiSchool.tongZong => const _RuleProfile(
          school: TaiYiSchool.tongZong,
          isAncientSchool: true,
          ancientBase: 10155219,
          ancientEpochYear: 1303,
          contemporaryEpochYear: 0,
          taiYiPalaceFormula: _TaiYiPalaceFormula.jingMirror,
          taiYiPalaceShift: 0,
          usesWenChangStayRule: true,
          usesTwelveJiShen: false,
          fixedEightDoors: false,
          tropicalYear: 365.2425,
          hostGuestBase: 1,
          methodNote: '统宗宝鉴法',
          warnings: ['统宗派节气分界、天目重留简化当前以规则配置表达，仍需验盘校正。'],
        ),
      TaiYiSchool.jiCheng => const _RuleProfile(
          school: TaiYiSchool.jiCheng,
          isAncientSchool: false,
          ancientBase: 0,
          ancientEpochYear: 0,
          contemporaryEpochYear: 1684,
          taiYiPalaceFormula: _TaiYiPalaceFormula.jiCheng,
          taiYiPalaceShift: 0,
          usesWenChangStayRule: false,
          usesTwelveJiShen: true,
          fixedEightDoors: true,
          tropicalYear: 365.2425,
          hostGuestBase: 1,
          methodNote: '集成简化法',
          warnings: ['集成派当代甲子元暂定为 1684 年，后续可做成用户可配置。'],
        ),
    };
  }
}
