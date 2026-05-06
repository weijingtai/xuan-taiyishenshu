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
      taiYiPalace: taiYiPalace,
      wenChangPalace: wenChangPalace,
      hostGuest: hostGuest,
      rule: rule,
    );
    final shenPan = _buildShenPan(
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
        return accumulatedYear * 12 + dateTime.month;
      case TaiYiChartType.day:
        final winterSolstice = _dateOfWinterSolstice(dateTime.year);
        final winterSolsticeDoy =
            winterSolstice.difference(DateTime(dateTime.year)).inDays + 1;
        final dayOffset = _dayOfYear(dateTime) - winterSolsticeDoy;
        final winterAccumulatedDays =
            (accumulatedYear * rule.tropicalYear).round();
        return winterAccumulatedDays +
            (dayOffset < 0
                ? dayOffset + (rule.tropicalYear * 12).round()
                : dayOffset);
      case TaiYiChartType.hour:
        final ws = _dateOfWinterSolstice(dateTime.year);
        final wsDoy = ws.difference(DateTime(dateTime.year)).inDays + 1;
        final offset = _dayOfYear(dateTime) - wsDoy;
        final winterDays = (accumulatedYear * rule.tropicalYear).round();
        final accDays = winterDays +
            (offset < 0 ? offset + (rule.tropicalYear * 12).round() : offset);
        return accDays * 12 + _chineseHourIndex(dateTime);
      case TaiYiChartType.ke:
        throw UnsupportedError('刻家暂未实现。');
    }
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
    final taiYiPos = _palaceToDeityPosition(taiYiPalace);
    final stopPos = _findStopPosition(taiYiPos);

    final hostCount = _walkAndSum(wenChangPos, stopPos);
    final guestCount = _calculateGuestCount(wenChangDeity, taiYiPos, stopPos, rule, juNumber);

    final dingRemainder = _positiveModulo(hostCount, 10);
    final dingCount = dingRemainder == 0 ? 10 : dingRemainder;
    final dingPalace = _calculateGeneralGong(dingCount, rule);
    final (dingMuPalace, dingMuName) = _calculateDingMuPalace(
      yearBranch: yearBranch,
      taiYiPalace: taiYiPalace,
      rule: rule,
    );
    return HostGuestDataModel(
      hostCount: hostCount,
      guestCount: guestCount,
      dingCount: dingCount,
      hostPalace: taiYiPalace,
      guestPalace: wenChangPalace,
      dingPalace: dingPalace,
      dingMuPalace: dingMuPalace,
      dingMuName: dingMuName,
      method: rule.methodNote,
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

  static const _jianShenDeities = {'寅', '申', '巳', '亥', '辰', '戌', '丑', '未'};

  static bool _isJianShen(String deity) => _jianShenDeities.contains(deity);

  String _deityAtPosition(int pos) {
    return _sixteenGodSequence[(pos - 1) % 16];
  }

  int _palaceToDeityPosition(EnumTaiYiGong palace) {
    for (var i = 0; i < sixteenDeities.length; i++) {
      if (branchPalace[sixteenDeities[i]] == palace) {
        return i + 1;
      }
    }
    return 1;
  }

  int _palaceOrderForDeity(String deity) {
    final palace = branchPalace[deity];
    return palace?.order ?? 0;
  }

  int _findStopPosition(int taiYiPos) {
    int pos = taiYiPos - 1;
    if (pos < 1) pos = 16;
    while (_isJianShen(_deityAtPosition(pos))) {
      pos -= 1;
      if (pos < 1) pos = 16;
    }
    return pos;
  }

  int _walkAndSum(int startPos, int stopPos) {
    int sum = 0;
    int startStep = startPos >= 9 ? 1 : 0;
    int cur = startPos >= 9 ? 1 : startPos;
    for (var i = 0; i < 16; i++) {
      if (cur == stopPos) break;
      final deity = _deityAtPosition(cur);
      if (!_isJianShen(deity)) {
        final num = _palaceOrderForDeity(deity);
        sum += (num == 0) ? 8 : num;
      } else if (i == 0 && startStep == 1) {
        sum += 1;
      }
      cur += 1;
      if (cur > 16) cur = 1;
    }
    return sum;
  }

  int _calculateGuestCount(
      String wenChangDeity, int taiYiPos, int stopPos, _RuleProfile rule, int juNumber) {
    final shiJiDeity = _findShiJiDeity(juNumber);
    final shiJiPos = _sixteenGodPosition(shiJiDeity);
    return _walkAndSum(shiJiPos, stopPos);
  }

  (EnumTaiYiGong, String?) _calculateDingMuPalace({
    required String yearBranch,
    required EnumTaiYiGong taiYiPalace,
    required _RuleProfile rule,
  }) {
    final taiSuiPos = _sixteenGodPosition(yearBranch);
    final heShenBranch = _branchComplement(yearBranch);
    final heShenPos = _sixteenGodPosition(heShenBranch);
    final dingMuPos = _positiveModulo(taiSuiPos + heShenPos - 2, 16) + 1;
    final deityName = _sixteenGodByPosition(dingMuPos);
    final gong = _deityToPalace(deityName);
    return (gong, deityName);
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
    return switch (deity) {
      '子' => EnumTaiYiGong.Kan,
      '丑' => EnumTaiYiGong.Gen,
      '艮' => EnumTaiYiGong.Gen,
      '寅' => EnumTaiYiGong.Gen,
      '卯' => EnumTaiYiGong.Zhen,
      '辰' => EnumTaiYiGong.Xun,
      '巽' => EnumTaiYiGong.Xun,
      '巳' => EnumTaiYiGong.Xun,
      '午' => EnumTaiYiGong.Li,
      '未' => EnumTaiYiGong.Kun,
      '坤' => EnumTaiYiGong.Kun,
      '申' => EnumTaiYiGong.Kun,
      '酉' => EnumTaiYiGong.Dui,
      '戌' => EnumTaiYiGong.Qian,
      '乾' => EnumTaiYiGong.Qian,
      '亥' => EnumTaiYiGong.Qian,
      _ => EnumTaiYiGong.Center,
    };
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
    final startIndex = sequence.indexOf(rule.usesTwelveJiShen ? '寅' : '艮');
    final wenChangIndex =
        sequence.indexOf(sixteenDeities.contains('申') ? '申' : '寅');
    final jiShenIndex = sequence
        .indexOf(twelveBranches[_positiveModulo(jiShenPalace.index - 4, 12)]);
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
    required EnumTaiYiGong taiYiPalace,
    required EnumTaiYiGong wenChangPalace,
    required HostGuestDataModel hostGuest,
    required _RuleProfile rule,
  }) {
    final hostGeneralGong = _calculateGeneralGong(hostGuest.hostCount, rule);
    final guestGeneralGong = _calculateGeneralGong(hostGuest.guestCount, rule);
    final hostDeputyGeneralGong =
        _calculateDeputyGeneralGong(hostGeneralGong, rule);
    final guestDeputyGeneralGong =
        _calculateDeputyGeneralGong(guestGeneralGong, rule);

    EnumTaiYiGong? dingGeneralGong;
    EnumTaiYiGong? dingDeputyGeneralGong;
    EnumTaiYiGong? junJiGong;
    EnumTaiYiGong? chenJiGong;
    EnumTaiYiGong? minJiGong;
    EnumTaiYiGong? wuFuGong;
    EnumTaiYiGong? daYouGong;
    EnumTaiYiGong? xiaoYouGong;
    EnumTaiYiGong? feiFuGong;

    final dingCount = _positiveModulo(hostGuest.hostCount, 10);
    dingGeneralGong = dingCount == 0
        ? EnumTaiYiGong.Center
        : _calculateGeneralGong(dingCount == 0 ? 10 : dingCount, rule);
    dingDeputyGeneralGong = _calculateDeputyGeneralGong(dingGeneralGong, rule);

    if (rule.school == TaiYiSchool.jingMirror) {
      junJiGong = _calculateJunJi(rule);
      chenJiGong = _calculateChenJi(rule);
      minJiGong = _calculateMinJi(rule);
      wuFuGong = _calculateWuFu(rule);
      daYouGong = taiYiPalace;
      xiaoYouGong = _calculateXiaoYou(rule);
      feiFuGong = _calculateFeiFu(taiYiPalace, rule);
    } else if (rule.school == TaiYiSchool.tongZong) {
      junJiGong = _calculateJunJi(rule);
      chenJiGong = _calculateChenJi(rule);
      minJiGong = _calculateMinJi(rule);
      wuFuGong = _calculateWuFu(rule);
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
      methodNote: '主客大将参将已实现；三基五福大游小游为 MVP 近似',
    );
  }

  ShenPanModel _buildShenPan({
    required DateTime dateTime,
    required EnumTaiYiGong taiYiPalace,
    required _RuleProfile rule,
  }) {
    final yearBranch = twelveBranches[_positiveModulo(dateTime.year - 4, 12)];
    final taiSuiGong = branchPalace[yearBranch] ?? EnumTaiYiGong.Kan;
    final suiPoGongIndex = (taiYiPalaceOrder.indexOf(taiSuiGong) + 6) % 9;
    final suiPoGong = taiYiPalaceOrder[suiPoGongIndex];
    return ShenPanModel(
      taiSuiGong: taiSuiGong,
      suiPoGong: suiPoGong,
      zhiFuGong: taiYiPalace,
      methodNote: '神盘 MVP 近似',
    );
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
    final digit = _positiveModulo(count, 10);
    if (digit == 1 || digit == 9) return EnumTaiYiGong.Qian;
    if (digit == 2 || digit == 8) return EnumTaiYiGong.Kan;
    if (digit == 3 || digit == 7) return EnumTaiYiGong.Gen;
    if (digit == 4 || digit == 6) return EnumTaiYiGong.Zhen;
    if (digit == 5) return EnumTaiYiGong.Li;
    return EnumTaiYiGong.Center;
  }

  EnumTaiYiGong _calculateDeputyGeneralGong(
      EnumTaiYiGong generalGong, _RuleProfile rule) {
    final index = taiYiPalaceOrder.indexOf(generalGong);
    return taiYiPalaceOrder[
        _positiveModulo(index + 1, taiYiPalaceOrder.length)];
  }

  EnumTaiYiGong? _calculateJunJi(_RuleProfile rule) {
    return EnumTaiYiGong.Kan;
  }

  EnumTaiYiGong? _calculateChenJi(_RuleProfile rule) {
    return EnumTaiYiGong.Kun;
  }

  EnumTaiYiGong? _calculateMinJi(_RuleProfile rule) {
    return EnumTaiYiGong.Dui;
  }

  EnumTaiYiGong? _calculateWuFu(_RuleProfile rule) {
    return EnumTaiYiGong.Qian;
  }

  EnumTaiYiGong? _calculateXiaoYou(_RuleProfile rule) {
    final index = taiYiPalaceOrder.indexOf(EnumTaiYiGong.Qian);
    return taiYiPalaceOrder[
        _positiveModulo(index - 1, taiYiPalaceOrder.length)];
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
          tropicalYear: 365.25,
          hostGuestBase: 1,
          methodNote: '金镜古法',
          warnings: ['金镜派天目重留当前为 MVP 近似，后续需用典籍验盘校正。'],
        ),
      TaiYiSchool.tongZong => const _RuleProfile(
          school: TaiYiSchool.tongZong,
          isAncientSchool: true,
          ancientBase: 10155219,
          ancientEpochYear: 1303,
          contemporaryEpochYear: 0,
          taiYiPalaceFormula: _TaiYiPalaceFormula.jingMirror,
          taiYiPalaceShift: 1,
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
