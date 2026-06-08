import '../enums/deity_kind.dart';
import '../enums/eight_door.dart';
import '../enums/geju.dart';
import '../enums/god.dart';
import '../enums/gong.dart';
import '../enums/gui_shen.dart';
import '../enums/taiyi_enum_extensions.dart';
import '../models/custom_deity_definition.dart';
import '../models/geju_model.dart';
import '../models/gui_shen_model.dart';
import '../models/pan_computed_item.dart';
import '../models/ren_pan_model.dart';
import '../models/shen_pan_model.dart';
import '../models/tian_pan_model.dart';
import '../models/year_ji_model.dart';
import 'core/algorithm_engine.dart';
import 'core/algorithm_enums.dart';
import 'core/calculation_context.dart';
import 'core/chart_config.dart';
import 'core/deity_definition.dart';
import 'core/school_config.dart';
import 'pan_data_model.dart';
import 'pan_enums.dart';
import 'taiyi_constants.dart';

class TaiYiPanCalculator {
  const TaiYiPanCalculator();

  static const String algorithmVersion = 'taiyi-pan-mvp-0.2.0';

  static TaiYiSchool _defaultSchoolConfig(String schoolId) {
    return switch (schoolId) {
      'jingMirror' => const TaiYiSchool(
        id: 'jingMirror',
        name: '金镜派',
        epoch: SchoolEpochConfig(ancientBase: 1937281, epochYear: 724, correction: 0),
        wenChangStayRule: true,
        useTwelveJiShen: false,
        palaceFormula: 'jingMirror',
        eightDoorMode: 'dynamic',
        chartConfigs: {
          'day': ChartConfig(dayOffset: 4235),
          'hour': ChartConfig(hourOffset: 121847027),
        },
      ),
      'tongZong' => const TaiYiSchool(
        id: 'tongZong',
        name: '统宗派',
        epoch: SchoolEpochConfig(ancientBase: 10155219, epochYear: 1303, correction: 1),
        wenChangStayRule: true,
        useTwelveJiShen: false,
        palaceFormula: 'jingMirror',
        eightDoorMode: 'dynamic',
        chartConfigs: {
          'day': ChartConfig(dayOffset: 4420, dayBaseSchoolId: 'jingMirror'),
          'hour': ChartConfig(hourOffset: 2231, hourBaseSchoolId: 'jingMirror'),
        },
      ),
      'jiCheng' => const TaiYiSchool(
        id: 'jiCheng',
        name: '集成派',
        epoch: SchoolEpochConfig(ancientBase: 0, epochYear: 1684, correction: 1),
        wenChangStayRule: false,
        useTwelveJiShen: true,
        palaceFormula: 'jiCheng',
        eightDoorMode: 'fixed',
      ),
      _ => throw ArgumentError('Unknown school: $schoolId'),
    };
  }

  PanDataModel calculateWithConfig({
    required DateTime dateTime,
    required TaiYiSchool school,
    required List<DeityDefinition> definitions,
    required TaiYiChartType chartType,
    bool useTrueSolarTime = false,
    String? location,
    Set<String> hiddenDeityIds = const {},
  }) {
    return _calculate(
      dateTime: dateTime,
      school: school,
      schoolId: school.id,
      chartType: chartType,
      useTrueSolarTime: useTrueSolarTime,
      location: location,
      definitions: definitions,
      hiddenDeityIds: hiddenDeityIds,
    );
  }

  PanDataModel calculate({
    required DateTime dateTime,
    String schoolId = 'jingMirror',
    TaiYiChartType chartType = TaiYiChartType.year,
    bool useTrueSolarTime = false,
    String? location,
    List<DeityDefinition> definitions = const [],
  }) {
    final schoolConfig = _defaultSchoolConfig(schoolId);
    return _calculate(
      dateTime: dateTime,
      school: schoolConfig,
      schoolId: schoolId,
      chartType: chartType,
      useTrueSolarTime: useTrueSolarTime,
      location: location,
      definitions: definitions,
    );
  }

  Future<PanDataModel> calculateWithCustomDeities({
    required DateTime dateTime,
    required CustomDeityRepository customDeityRepository,
    String schoolId = 'jingMirror',
    TaiYiChartType chartType = TaiYiChartType.year,
    bool useTrueSolarTime = false,
    String? location,
  }) async {
    final schoolConfig = _defaultSchoolConfig(schoolId);
    final customDefinitions =
        await customDeityRepository.loadDefinitions(schoolId: schoolId);

    // Map legacy CustomDeityDefinition to new DeityDefinition for compatibility
    final mappedDefinitions = customDefinitions.map((d) {
      return DeityDefinition(
        id: d.id,
        name: d.name,
        layer: EnumDeityLayer.tianPan, // Default to tianPan
        priority: d.priority,
        source: 'user',
        algorithm: DeityAlgorithmSpec(
          templateId: _mapTemplateId(d.algorithm.templateId),
          params: d.algorithm.params,
        ),
      );
    }).toList();

    return _calculate(
      dateTime: dateTime,
      school: schoolConfig,
      schoolId: schoolId,
      chartType: chartType,
      useTrueSolarTime: useTrueSolarTime,
      location: location,
      definitions: mappedDefinitions,
    );
  }

  AlgorithmTemplateId _mapTemplateId(String legacyId) {
    return switch (legacyId) {
      'juOffset' => AlgorithmTemplateId.steppedCycle,
      'branchMapping' => AlgorithmTemplateId.branchWalker,
      _ => AlgorithmTemplateId.fixedPosition,
    };
  }

  PanDataModel _calculate({
    required DateTime dateTime,
    required TaiYiSchool school,
    required String schoolId,
    required TaiYiChartType chartType,
    required bool useTrueSolarTime,
    required String? location,
    required List<DeityDefinition> definitions,
    Set<String> hiddenDeityIds = const {},
  }) {
    final input = PanInputModel(
      dateTime: dateTime,
      schoolId: schoolId,
      schoolName: school.name,
      chartType: chartType,
      useTrueSolarTime: useTrueSolarTime,
      location: location,
    );

    final rule = _RuleProfile.fromConfig(school);
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

    final ctx = CalculationContext(
      ji: accumulatedSeqValue,
      year: dateTime.year,
      juNumber: juNumber,
      dun: dunType,
      chartType: chartType,
    );

    final engineResults = _calculateDeitiesWithEngine(
      definitions: definitions,
      context: ctx,
      school: school,
    );

    final taiYiPalace = engineResults['taiYi']?.gong ??
        _calculateTaiYiPalace(juNumber, rule);
    final wenChangPalace = engineResults['wenChang']?.gong ??
        _calculateWenChangPalace(
          juNumber: juNumber,
          dunType: dunType,
          rule: rule,
        );
    final jiShenPalace = engineResults['jiShen']?.gong ??
        _calculateJiShenPalace(
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
    final currentBranch = _getCurrentBranch(dateTime, chartType, accumulatedSeqValue);
    final hostGuest = _calculateHostGuest(
      juNumber: juNumber,
      taiYiPalace: taiYiPalace,
      wenChangPalace: wenChangPalace,
      currentBranch: currentBranch,
      rule: rule,
      dunType: dunType,
      chartType: chartType,
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
      engineResults: engineResults,
    );
    final tianPan = _buildTianPan(
      accumulatedYear: accumulatedYear,
      taiYiPalace: taiYiPalace,
      wenChangPalace: wenChangPalace,
      hostGuest: hostGuest,
      rule: rule,
      engineResults: engineResults,
    );
    final shenPan = _buildShenPan(
      accumulatedYear: accumulatedYear,
      dateTime: dateTime,
      taiYiPalace: taiYiPalace,
      rule: rule,
      engineResults: engineResults,
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

    // Add items from engine that are not in builtInItems
    final engineItems = engineResults.entries.map((e) {
      final def = definitions.firstWhere((d) => d.id == e.key,
          orElse: () => throw StateError('Definition not found for ${e.key}'));
      return PanComputedItem(
        id: 'engine:${e.key}',
        name: def.name,
        kind: _mapLayerToKind(def.layer),
        gong: e.value.gong,
        source: PanComputedItemSource.builtIn,
        priority: def.priority,
        metadata: {
          'formula': e.value.formula,
          'note': e.value.note,
        },
      );
    }).toList();

    final placedItems = [
      ...builtInItems,
      ...engineItems.where((item) =>
          item.gong != null &&
          !builtInItems.any((bi) => bi.name == item.name)),
    ];

    // 按用户偏好过滤可隐藏的内置星神与引擎星神。
    // builtIn 中只过滤 4 个明确支持的核心 ID (太乙/文昌/计神/始击),
    // 其余项 (八门/主算/客算/天盘其它) 不在 SPEC AC9 范围内, 不受偏好控制。
    final filteredPlacedItems = hiddenDeityIds.isEmpty
        ? placedItems
        : placedItems
            .where((item) => !_isItemHiddenByPreference(item, hiddenDeityIds))
            .toList();

    final palaces = _buildPalaces(items: filteredPlacedItems);

    final guiShen = _buildGuiShen(accumulatedSeqValue);

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
          ? '${rule.school.name}基数: ${rule.ancientBase}'
          : '${rule.school.name}起算年: ${rule.contemporaryEpochYear}',
      palaces: palaces,
      eightDoorsByPalace: eightDoorsByPalace,
      unplacedItems: const [],
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
      guiShen: guiShen,
    );
  }

  Map<String, DeityPlacementResult> _calculateDeitiesWithEngine({
    required List<DeityDefinition> definitions,
    required CalculationContext context,
    required TaiYiSchool school,
  }) {
    final engine = DeityAlgorithmEngine();
    // Apply overrides from school
    final effectiveDefinitions = definitions.map((d) {
      final override = school.deityConfigs[d.id];
      if (override != null && override.active) {
        return d.copyWith(
          algorithm: override.algorithm ?? d.algorithm,
        );
      }
      return d;
    }).toList();

    return engine.executeAll(effectiveDefinitions, context);
  }

  PanComputedItemKind _mapLayerToKind(EnumDeityLayer layer) {
    return switch (layer) {
      EnumDeityLayer.tianPan => PanComputedItemKind.deity,
      EnumDeityLayer.renPan => PanComputedItemKind.eye,
      EnumDeityLayer.shenPan => PanComputedItemKind.deity,
      EnumDeityLayer.diPan => PanComputedItemKind.deity,
      EnumDeityLayer.mingPan => PanComputedItemKind.deity,
    };
  }

  /// 按指定流派 ID 计算积年（用于日计/时计需要跨流派取基准积年）。
  int _calculateAccumulatedYearForSchool(DateTime dateTime, String schoolId) {
    final config = _defaultSchoolConfig(schoolId);
    return _calculateAccumulatedYear(dateTime, _RuleProfile.fromConfig(config));
  }

  int _calculateAccumulatedYear(DateTime dateTime, _RuleProfile rule) {
    return rule.school.epoch.calculateAccumulatedYear(dateTime.year);
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

  int _accumulatedMonth(
      int accumulatedYear, DateTime dateTime, _RuleProfile rule) {
    final tianZhengMonth = _toTianZhengMonth(dateTime.month);
    if (rule.zhangSui > 0 && rule.zhangYue > 0) {
      final jiYue = (accumulatedYear * rule.zhangYue) ~/ rule.zhangSui;
      return jiYue + tianZhengMonth;
    }
    return (accumulatedYear - 1) * 12 + tianZhengMonth;
  }

  /// 天正月换算：以子月（12月）为天正1月。
  ///
  /// 公历 12月→天正1, 1月→天正2, 2月→天正3, ..., 11月→天正12。
  int _toTianZhengMonth(int solarMonth) {
    return switch (solarMonth) {
      1 => 2,
      2 => 3,
      3 => 4,
      4 => 5,
      5 => 6,
      6 => 7,
      7 => 8,
      8 => 9,
      9 => 10,
      10 => 11,
      11 => 12,
      12 => 1,
      _ => 1,
    };
  }

  /// 日计积日数计算。
  ///
  /// 公式：floor((基准积年 - 1) * 回归年) + 日序 + 流派偏移
  int _accumulatedDay(
      int accumulatedYear, DateTime dateTime, _RuleProfile rule) {
    final baseSchoolId = rule.dayBaseSchoolId ?? rule.school.id;
    final baseYear = (baseSchoolId == rule.school.id)
        ? accumulatedYear
        : _calculateAccumulatedYearForSchool(dateTime, baseSchoolId);

    final base = (baseYear - 1) * rule.tropicalYear;
    final dayOfYear = _dayOfYear(dateTime);
    return base.floor() + dayOfYear + rule.dayOffset;
  }

  /// 时计积时数计算。
  ///
  /// 公式：积日 * 12 + 时辰索引 - 流派偏移
  int _accumulatedHour(
      int accumulatedYear, DateTime dateTime, _RuleProfile rule) {
    final accDay = _accumulatedDay(accumulatedYear, dateTime, rule);
    final hourIdx = ((dateTime.hour + 1) ~/ 2) % 12;
    return accDay * 12 + hourIdx - rule.hourOffset;
  }

  DateTime _dateOfSummerSolstice(int year) {
    return DateTime(year, 6, 21);
  }

  int _computeJuNumberFromAccumulatedValue(int seqValue) {
    return (seqValue - 1) % 72 + 1;
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
    final taiYiRuGongNianShu = (juShuFixed - 1) % 3;
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
        result[eightDoorClockwisePalaces[_positiveModulo(
                startPalaceIndex + i, eightDoorClockwisePalaces.length)]] =
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

  String _getCurrentBranch(DateTime dateTime, TaiYiChartType chartType, int accumulatedSeqValue) {
    switch (chartType) {
      case TaiYiChartType.year:
        return twelveBranches[(accumulatedSeqValue - 1) % 12];
      case TaiYiChartType.month:
        return twelveBranches[(accumulatedSeqValue - 1) % 12];
      case TaiYiChartType.day:
        return twelveBranches[(accumulatedSeqValue - 1) % 12];
      case TaiYiChartType.hour:
      case TaiYiChartType.ke:
        return twelveBranches[((dateTime.hour + 1) ~/ 2) % 12];
    }
  }

  HostGuestDataModel _calculateHostGuest({
    required int juNumber,
    required EnumTaiYiGong taiYiPalace,
    required EnumTaiYiGong wenChangPalace,
    required String currentBranch,
    required _RuleProfile rule,
    required DunType dunType,
    required TaiYiChartType chartType,
  }) {
    final wenChangDeity = _findWenChangDeity(juNumber);
    final wenChangPos = _sixteenGodPosition(wenChangDeity);
    final taiYiPos = _palaceToZhengDeityPosition(taiYiPalace);
    final shiJiDeity = _findShiJiDeity(juNumber);
    final shiJiPos = _sixteenGodPosition(shiJiDeity);

    // 时计分阴阳顺逆，其他暂定顺行
    final bool clockwise =
        (chartType == TaiYiChartType.hour) ? (dunType == DunType.yang) : true;

    final hostResult = _walkAndSumWithDetail(
      wenChangPos,
      taiYiPos,
      rule.school.name,
      clockwise: clockwise,
      chartType: chartType,
    );
    final guestResult = _walkAndSumWithDetail(
      shiJiPos,
      taiYiPos,
      rule.school.name,
      clockwise: clockwise,
      chartType: chartType,
    );

    final bool useShift = true;

    final dingMuName = _calculateDingMuPosition(
      currentBranch: currentBranch,
      wenChangDeity: wenChangDeity,
      useShift: useShift,
    );
    final dingMuPos = _sixteenGodPosition(dingMuName);
    final dingMuPalace = _deityToPalace(dingMuName);
    final dingResult = _walkAndSumWithDetail(
      dingMuPos,
      taiYiPos,
      rule.school.name,
      clockwise: clockwise,
      chartType: chartType,
    );
    final dingCount = dingResult.count;
    final dingPalace = dingMuPalace;

    final schoolBase = rule.isAncientSchool
        ? '${rule.school.name}基数: ${rule.ancientBase}'
        : '${rule.school.name}起算年: ${rule.contemporaryEpochYear}';

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
        ));
  }
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
  return rule.school.id == 'jingMirror' ||
      rule.school.id == 'tongZong';
}

const _countingSequence = [
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

const _countingPalaceNumbers = {
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

const _taiSuiHeShen = {
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

const _jianShenDeities = {'寅', '申', '巳', '亥', '辰', '戌', '丑', '未'};

bool _isJianShen(String deity) => _jianShenDeities.contains(deity);

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

const List<int> _zhengDeityPositions = [1, 3, 5, 7, 9, 11, 13, 15];

bool _isZhengDeity(int pos) => _zhengDeityPositions.contains(pos);

int _hostGuestPalaceNumber(EnumTaiYiGong palace) {
  return palace.order >= 5 ? palace.order + 1 : palace.order;
}

({int count, String detail}) _walkAndSumWithDetail(
    int startPos,
    int taiYiPos,
    String schoolLabel, {
    bool clockwise = true,
    required TaiYiChartType chartType,
  }) {
  final startDeity = _sixteenGodByPosition(startPos);
  final taiYiDeity = _sixteenGodByPosition(taiYiPos);
  final startPalace = _deityToPalace(startDeity);
  final taiYiPalace = _deityToPalace(taiYiDeity);

  // 1. 同位情况 (Same Position)
  if (startPos == taiYiPos) {
    final num = _hostGuestPalaceNumber(taiYiPalace);
    return (count: num, detail: '$schoolLabel: $startDeity同位($num)');
  }

  // 2. 同宫情况 (Same Palace Different Position)
  if (startPalace == taiYiPalace) {
    final count = (chartType == TaiYiChartType.year) ? 10 : 1;
    return (count: count, detail: '$schoolLabel: $startDeity同宫取$count');
  }

  // 3. 正常巡行累加 (Normal Walk)
  int sum = 0;
  final steps = <String>[];
  if (_isZhengDeity(startPos)) {
    final num = _hostGuestPalaceNumber(startPalace);
    sum += num;
    steps.add('$startDeity($num)');
  } else {
    sum += 1;
    steps.add('$startDeity(1)');
  }

  int cur = clockwise ? (startPos % 16 + 1) : ((startPos - 2 + 16) % 16 + 1);
  for (var i = 0; i < 16; i++) {
    if (cur == taiYiPos) break;
    if (_isZhengDeity(cur)) {
      final deity = _sixteenGodByPosition(cur);
      final palace = _deityToPalace(deity);
      final num = _hostGuestPalaceNumber(palace);
      sum += num;
      steps.add('$deity($num)');
    }
    cur = clockwise ? (cur % 16 + 1) : ((cur - 2 + 16) % 16 + 1);
  }
  return (count: sum, detail: '$schoolLabel: ${steps.join(" + ")} = $sum');
}

String _calculateDingMuPosition({
  required String currentBranch,
  required String wenChangDeity,
  bool useShift = true,
}) {
  if (!useShift) return wenChangDeity;
  final heShenBranch = _branchComplement(currentBranch);
  final taiSuiPos = _sixteenGodPosition(currentBranch);
  final heShenPos = _sixteenGodPosition(heShenBranch);
  final wenChangPos = _sixteenGodPosition(wenChangDeity);
  final shift = taiSuiPos - heShenPos;
  final dingMuPos = _positiveModulo(wenChangPos + shift - 1, 16) + 1;
  final result = _sixteenGodByPosition(dingMuPos);
  print('DEBUG DINGMU: currentBranch=$currentBranch, wenChangDeity=$wenChangDeity, shift=$shift, dingMuPos=$dingMuPos, result=$result');
  return result;
}
const _sixteenGodSequence = [
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

/// 用户偏好可隐藏的内置星神 ID 白名单 (built-in 直接占位项)。
///
/// 仅这 4 个核心 ID 由 `_buildBuiltInItems` 直接产生 `builtIn:<id>` 形式的 PanComputedItem,
/// 它们独立于 deity definitions 列表, 必须显式过滤。
const Set<String> _filterableBuiltInDeityIds = {
  'taiYi',
  'wenChang',
  'jiShen',
  'shiJi',
};

/// 判定单个 PanComputedItem 是否应被用户偏好过滤。
///
/// 适用 ID 模式 (与 _buildBuiltInItems / engine 输出一致):
/// - `builtIn:<deityId>`           (太乙/文昌/计神/始击 4 核心, 白名单)
/// - `builtIn:tian:<kind>`         (天盘小游/飞符/君基/臣基/民基 等; kind 与 deity ID 同名)
/// - `builtIn:shen:<kind>`         (神盘太岁/岁破/青龙/朱雀/白虎/玄武 等; kind 与 deity ID 同名)
/// - `engine:<deityId>`            (引擎对自定义/扩展 deity 算出来的项)
///
/// 不过滤:
/// - `builtIn:eightDoor:*`         (八门, SPEC AC9 不在偏好范围)
/// - `builtIn:hostCount` / `builtIn:guestCount` (主算 / 客算)
bool _isItemHiddenByPreference(
  PanComputedItem item,
  Set<String> hiddenDeityIds,
) {
  if (hiddenDeityIds.isEmpty) return false;
  final parts = item.id.split(':');
  if (parts.length < 2) return false;
  final prefix = parts[0];

  if (prefix == 'engine') {
    final deityId = parts[1];
    return hiddenDeityIds.contains(deityId);
  }

  if (prefix == 'builtIn') {
    // builtIn:<deityId> 形式 (4 核心)
    if (parts.length == 2) {
      final deityId = parts[1];
      return _filterableBuiltInDeityIds.contains(deityId) &&
          hiddenDeityIds.contains(deityId);
    }
    // builtIn:tian:<kind> / builtIn:shen:<kind>
    if (parts.length >= 3 && (parts[1] == 'tian' || parts[1] == 'shen')) {
      final kind = parts[2];
      return hiddenDeityIds.contains(kind);
    }
  }

  return false;
}

RenPanModel _buildRenPan({
  required int juNumber,
  required TaiYiChartType chartType,
  required DunType dunType,
  required EnumTaiYiGong taiYiPalace,
  required EnumTaiYiGong wenChangPalace,
  required EnumTaiYiGong jiShenPalace,
  required _RuleProfile rule,
  Map<String, DeityPlacementResult> engineResults = const {},
}) {
  if (_usesSharedYearEyeRules(rule, chartType)) {
    final tianMuPosition = engineResults['wenChang']?.formula != null
        ? _gongToName(engineResults['wenChang']?.gong)
        : _calculateTongZongTianMuPosition(juNumber);
    final jiShenPosition = engineResults['jiShen']?.formula != null
        ? _gongToName(engineResults['jiShen']?.gong)
        : _calculateTongZongJiShenPosition(juNumber);
    final shiJiPosition = engineResults['shiJi']?.formula != null
        ? _gongToName(engineResults['shiJi']?.gong)
        : _calculateTongZongShiJiPosition(
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
      tianMuGong: engineResults['wenChang']?.gong ?? _positionToPalace(tianMuPosition),
      shiJiGong: engineResults['shiJi']?.gong ?? _positionToPalace(shiJiPosition),
      jiShenGong: engineResults['jiShen']?.gong ?? _positionToPalace(jiShenPosition),
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
      wenChangIndex + (rule.school.id == 'jingMirror' ? 8 : 3),
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
    tianMuGong: engineResults['wenChang']?.gong ?? _deityGongForSequence(sequence[tianMuIndex]),
    shiJiGong: engineResults['shiJi']?.gong ?? _deityGongForSequence(sequence[shiJiIndex]),
    jiShenGong: engineResults['jiShen']?.gong ?? jiShenPalace,
    tianMuName: engineResults['wenChang']?.formula != null ? _gongToName(engineResults['wenChang']?.gong) : _deityNameForSequence(sequence[tianMuIndex]),
    shiJiName: engineResults['shiJi']?.formula != null ? _gongToName(engineResults['shiJi']?.gong) : _deityNameForSequence(sequence[shiJiIndex]),
    jiShenName: engineResults['jiShen']?.formula != null ? '计神' : '计神',
    methodNote: rule.methodNote,
  );
}

String _gongToName(EnumTaiYiGong? gong) {
  return switch (gong) {
    EnumTaiYiGong.Qian => '乾',
    EnumTaiYiGong.Li => '离',
    EnumTaiYiGong.Gen => '艮',
    EnumTaiYiGong.Zhen => '震',
    EnumTaiYiGong.Center => '中',
    EnumTaiYiGong.Dui => '兑',
    EnumTaiYiGong.Kun => '坤',
    EnumTaiYiGong.Kan => '坎',
    EnumTaiYiGong.Xun => '巽',
    null => '中',
  };
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
  Map<String, DeityPlacementResult> engineResults = const {},
}) {
  final hostGeneralNumber = _normalizeCountToTen(hostGuest.hostCount);
  final guestGeneralNumber = _normalizeCountToTen(hostGuest.guestCount);

  final hostGeneralGong = engineResults['zhuDaJiang']?.gong ??
      _calculateGeneralGong(hostGeneralNumber, rule);
  final guestGeneralGong = engineResults['keDaJiang']?.gong ??
      _calculateGeneralGong(guestGeneralNumber, rule);
  final hostDeputyGeneralGong = engineResults['zhuCanJiang']?.gong ??
      _calculateDeputyGeneralGong(hostGeneralNumber, rule);
  final guestDeputyGeneralGong = engineResults['keCanJiang']?.gong ??
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
  int? junJiRuGongNianShu;
  int? chenJiRuGongNianShu;

  final dingGeneralNumber = _guestOrDingGeneralNumber(hostGuest.dingCount);
  dingGeneralGong = engineResults['dingDaJiang']?.gong ??
      _calculateGeneralGong(dingGeneralNumber, rule);
  dingDeputyGeneralGong = engineResults['dingCanJiang']?.gong ??
      _calculateGuestOrDingDeputyGeneralGong(dingGeneralNumber);

  if (engineResults.containsKey('junJi')) {
    junJiGong = engineResults['junJi']?.gong;
    junJiRuGongNianShu = engineResults['junJi']?.steps.last.remainder;
  } else if (rule.school.id == 'jingMirror') {
    junJiGong = _calculateJunJi(accumulatedYear, rule);
  } else if (rule.school.id == 'tongZong') {
    junJiGong = _calculateJunJiTongZong(accumulatedYear);
    junJiRuGongNianShu = _calculateJunJiRuGongNianShu(accumulatedYear);
  }

  if (engineResults.containsKey('chenJi')) {
    chenJiGong = engineResults['chenJi']?.gong;
    chenJiRuGongNianShu = engineResults['chenJi']?.steps.last.remainder;
  } else if (rule.school.id == 'jingMirror') {
    chenJiGong = _calculateChenJi(accumulatedYear, rule);
  } else if (rule.school.id == 'tongZong') {
    chenJiGong = _calculateChenJiTongZong(accumulatedYear);
    chenJiRuGongNianShu = _calculateChenJiRuGongNianShu(accumulatedYear);
  }

  minJiGong = engineResults['minJi']?.gong ??
      (rule.school.id == 'jingMirror'
          ? _calculateMinJi(accumulatedYear, rule)
          : rule.school.id == 'tongZong'
              ? _calculateMinJiTongZong(accumulatedYear)
              : null);
  wuFuGong = engineResults['wuFu']?.gong ?? _calculateWuFu(accumulatedYear, rule);
  daYouGong = engineResults['daYou']?.gong ?? _calculateDaYou(accumulatedYear, rule);
  xiaoYouGong =
      engineResults['xiaoYou']?.gong ?? _calculateXiaoYou(accumulatedYear, rule);
  feiFuGong = engineResults['feiFu']?.gong ??
      (rule.school.id == 'jingMirror' ? _calculateFeiFu(taiYiPalace, rule) : null);

  siShenGong = engineResults['siShen']?.gong;
  tianYiGong2 = engineResults['tianYiStar']?.gong;
  diYiGong = engineResults['diYi']?.gong;
  zhiFuGong2 = engineResults['zhiFuStar']?.gong;

  if (rule.school.id == 'tongZong') {
    final ji = accumulatedYear;
    final nianShu = ji % 36 % 3 == 0 ? 3 : ji % 36 % 3;
    final gongIdx = ((ji - 1) % 36) ~/ 3;

    if (siShenGong == null) {
      siShenGong = _deityToPalace(sishen12Gong[gongIdx]);
      siShenRuGongNianShu = nianShu;
    } else {
      siShenRuGongNianShu = engineResults['siShen']?.steps.last.remainder;
    }

    if (tianYiGong2 == null) {
      tianYiGong2 = _deityToPalace(tianYi12Gong[gongIdx]);
      tianYiRuGongNianShu = nianShu;
    } else {
      tianYiRuGongNianShu = engineResults['tianYiStar']?.steps.last.remainder;
    }

    if (diYiGong == null) {
      diYiGong = _deityToPalace(diYi12Gong[gongIdx]);
      diYiRuGongNianShu = nianShu;
    } else {
      diYiRuGongNianShu = engineResults['diYi']?.steps.last.remainder;
    }

    if (zhiFuGong2 == null) {
      zhiFuGong2 = _deityToPalace(zhiFu12Gong[gongIdx]);
      zhiFuRuGongNianShu = nianShu;
    } else {
      zhiFuRuGongNianShu = engineResults['zhiFuStar']?.steps.last.remainder;
    }
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
    junJiRuGongNianShu: junJiRuGongNianShu,
    chenJiRuGongNianShu: chenJiRuGongNianShu,
    methodNote: '主客大将参将已实现；三基五福大游小游支持引擎配置',
  );
}

ShenPanModel _buildShenPan({
  required int accumulatedYear,
  required DateTime dateTime,
  required EnumTaiYiGong taiYiPalace,
  required _RuleProfile rule,
  Map<String, DeityPlacementResult> engineResults = const {},
}) {
  final yearBranch = twelveBranches[_positiveModulo(dateTime.year - 4, 12)];
  final heShenBranch = _branchComplement(yearBranch);
  final taiSuiGong = engineResults['taiSui']?.gong ??
      branchPalace[yearBranch] ??
      EnumTaiYiGong.Kan;
  final heShenGong = engineResults['heShen']?.gong ?? _deityToPalace(heShenBranch);
  final suiPoGong = engineResults['suiPo']?.gong ??
      gongClash[taiSuiGong] ??
      taiYiPalaceOrder[_positiveModulo(
          taiYiPalaceOrder.indexOf(taiSuiGong) + 4, taiYiPalaceOrder.length)];

  EnumTaiYiGong? qingLongQiGong = engineResults['qingLongQi']?.gong;
  EnumTaiYiGong? heiQiGong = engineResults['heiQi']?.gong;
  EnumTaiYiGong? chiQiGong = engineResults['chiQi']?.gong;
  EnumTaiYiGong? guiShenZhiShiGong = engineResults['guiShenZhiShi']?.gong;
  int? heiQiRuGongNianShu = engineResults['heiQi']?.steps.last.remainder;

  if (rule.school.id == 'tongZong') {
    final ji = accumulatedYear;
    qingLongQiGong ??= taiSuiGong;

    if (heiQiGong == null) {
      final heiQiIdx = ((ji - 1) % 360) % 36 ~/ 3;
      heiQiGong = _deityToPalace(heiQi12Chen[heiQiIdx]);
      final heiQiNianShu = ji % 360 % 36 % 3;
      heiQiRuGongNianShu = heiQiNianShu == 0 ? 3 : heiQiNianShu;
    }

    if (chiQiGong == null) {
      final chiQiIdx = ji % 40 % 4;
      chiQiGong = _deityToPalace(chiQi4Gong[chiQiIdx]);
    }

    if (guiShenZhiShiGong == null) {
      final zhiShiRaw = (ji % 360 % 60 + 3) % 9;
      final zhiShiIdx = zhiShiRaw == 0 ? 9 : zhiShiRaw;
      final guiShenNum = guiShenZhiShiMap[zhiShiIdx] ?? 1;
      final palaceNum = guiShenPalaceOrder[guiShenNum - 1];
      guiShenZhiShiGong = _gongNumberToPalace(palaceNum);
    }
  }

  return ShenPanModel(
    taiSuiGong: taiSuiGong,
    suiPoGong: suiPoGong,
    zhiFuGong: engineResults['zhiFu']?.gong ?? (gongClash[taiYiPalace] ?? taiYiPalace),
    heShenGong: heShenGong,
    qingLongQiGong: qingLongQiGong,
    heiQiGong: heiQiGong,
    chiQiGong: chiQiGong,
    guiShenZhiShiGong: guiShenZhiShiGong,
    heiQiRuGongNianShu: heiQiRuGongNianShu,
    methodNote: '神盘已支持引擎配置',
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
        relatedDeities: [EnumDeityKind.hostGeneral, EnumDeityKind.guestGeneral],
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

EnumTaiYiGong _calculateJunJiTongZong(int ji) {
  final steps = ((ji - 1) % 360) ~/ 30;
  final startIdx = twelveBranches.indexOf('\u5348');
  final chen = twelveBranches[(startIdx + steps) % 12];
  return branchPalace[chen] ?? EnumTaiYiGong.Center;
}

int _calculateJunJiRuGongNianShu(int ji) {
  var n = ji % 360 % 30;
  if (n == 0) n = 30;
  return n;
}

EnumTaiYiGong _calculateChenJiTongZong(int ji) {
  final steps = ((ji - 1) % 360 % 36) ~/ 3;
  final startIdx = twelveBranches.indexOf('\u5348');
  final chen = twelveBranches[(startIdx + steps) % 12];
  return branchPalace[chen] ?? EnumTaiYiGong.Center;
}

int _calculateChenJiRuGongNianShu(int ji) {
  var n = ji % 360 % 36 % 3;
  if (n == 0) n = 3;
  return n;
}

EnumTaiYiGong _calculateMinJiTongZong(int ji) {
  final steps = (ji - 1) % 360 % 12;
  final startIdx = twelveBranches.indexOf('\u620c');
  final chen = twelveBranches[(startIdx + steps) % 12];
  return branchPalace[chen] ?? EnumTaiYiGong.Center;
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
  // 五福起乾，按乾→艮→巽→坤→中宮，45年一移宮，225年一周。
  // 公式：(积数 - 136) % 225 ÷ 45 = 所走宫数
  const sequence = [
    EnumTaiYiGong.Qian,
    EnumTaiYiGong.Gen,
    EnumTaiYiGong.Xun,
    EnumTaiYiGong.Kun,
    EnumTaiYiGong.Center,
  ];
  final cyclePos = _positiveModulo(accumulatedYear - 136, 225);
  final index = cyclePos ~/ 45;
  return sequence[index];
}

EnumTaiYiGong? _calculateDaYou(int accumulatedYear, _RuleProfile rule) {
  // 大游起七宫坤，按七→八→九→一→二→三→四→六顺行，不入中五宫，36年一移宫，288年一周。
  // 公式：(积数 - 145) % 288 ÷ 36 = 所走宫数
  const daYouOrder = [
    EnumTaiYiGong.Kun, // 七
    EnumTaiYiGong.Kan, // 八
    EnumTaiYiGong.Xun, // 九
    EnumTaiYiGong.Qian, // 一
    EnumTaiYiGong.Li, // 二
    EnumTaiYiGong.Gen, // 三
    EnumTaiYiGong.Zhen, // 四
    EnumTaiYiGong.Dui, // 六
  ];
  final cyclePos = _positiveModulo(accumulatedYear - 145, 288);
  final steps = cyclePos ~/ 36;
  return daYouOrder[steps % daYouOrder.length];
}

EnumTaiYiGong? _calculateXiaoYou(int accumulatedYear, _RuleProfile rule) {
  // 小游起一宫乾，按一→二→三→四→六→七→八→九顺行，不入中五宫，3年一移宫，24年一周。
  // 公式：(积数 - 1) % 24 ÷ 3 = 所走宫数
  final cyclePos = (accumulatedYear - 1) % 24;
  final steps = cyclePos ~/ 3;
  return taiYiPalaceOrder[steps % taiYiPalaceOrder.length];
}

EnumTaiYiGong? _calculateFeiFu(EnumTaiYiGong taiYiPalace, _RuleProfile rule) {
  final index = taiYiPalaceOrder.indexOf(taiYiPalace);
  return taiYiPalaceOrder[_positiveModulo(index + 2, taiYiPalaceOrder.length)];
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

int _chineseHourIndex(DateTime dateTime) => ((dateTime.hour + 1) ~/ 2) % 12 + 1;

int _dayOfYear(DateTime dateTime) {
  final yearStart = dateTime.isUtc ? DateTime.utc(dateTime.year) : DateTime(dateTime.year);
  return dateTime.difference(yearStart).inDays + 1;
}

int _cyclicDistance(EnumTaiYiGong fromPalace, EnumTaiYiGong toPalace) {
  final from = taiYiPalaceOrder.indexOf(fromPalace);
  final to = taiYiPalaceOrder.indexOf(toPalace);
  if (from == -1 || to == -1) return 0;
  return _positiveModulo(to - from, taiYiPalaceOrder.length);
}

String _nearestBranchFromSixteen(int index) {
  for (var offset = 0; offset < sixteenDeities.length; offset++) {
    final forward =
        sixteenDeities[_positiveModulo(index + offset, sixteenDeities.length)];
    if (branchPalace[forward] != null) return forward;
    final backward =
        sixteenDeities[_positiveModulo(index - offset, sixteenDeities.length)];
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

GuiShenModel _buildGuiShen(int ji) {
  var zhiShiIdx = (ji % 360 % 60 + 3) % 9;
  if (zhiShiIdx == 0) zhiShiIdx = 9;
  final zhiShiGuiShen = EnumGuiShen.reverseOrder[zhiShiIdx - 1];
  final forwardOrder = EnumGuiShen.forwardOrder;
  final startIndex = forwardOrder.indexOf(zhiShiGuiShen);
  const palaceWalkOrder = [5, 6, 7, 8, 9, 1, 2, 3, 4];
  final palaceMap = <EnumTaiYiGong, EnumGuiShen>{};
  for (var i = 0; i < 9; i++) {
    final guiShen = forwardOrder[(startIndex + i) % 9];
    final palaceNum = palaceWalkOrder[i];
    palaceMap[_gongNumberToPalace(palaceNum)] = guiShen;
  }
  return GuiShenModel(
    zhiShiGuiShen: zhiShiGuiShen,
    palaceMap: palaceMap,
    zhiShiIndex: zhiShiIdx,
  );
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
    this.dayOffset = 0,
    this.hourOffset = 0,
    this.dayBaseSchoolId,
    this.hourBaseSchoolId,
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
  final int dayOffset;
  final int hourOffset;
  final String? dayBaseSchoolId;
  final String? hourBaseSchoolId;

  factory _RuleProfile.fromConfig(TaiYiSchool config) {
    final dayConfig = config.chartConfigs['day'] ?? const ChartConfig();
    final hourConfig = config.chartConfigs['hour'] ?? const ChartConfig();
    final monthConfig = config.chartConfigs['month'] ?? const ChartConfig();

    return _RuleProfile(
      school: config,
      isAncientSchool: config.epoch.ancientBase != 0,
      ancientBase: config.epoch.ancientBase,
      ancientEpochYear: config.epoch.epochYear,
      contemporaryEpochYear:
          config.epoch.ancientBase == 0 ? config.epoch.epochYear : 0,
      taiYiPalaceFormula: config.palaceFormula == 'jiCheng'
          ? _TaiYiPalaceFormula.jiCheng
          : _TaiYiPalaceFormula.jingMirror,
      taiYiPalaceShift: 0,
      usesWenChangStayRule: config.wenChangStayRule,
      usesTwelveJiShen: config.useTwelveJiShen,
      fixedEightDoors: config.eightDoorMode == 'fixed',
      tropicalYear: config.epoch.tropicalYear,
      hostGuestBase: 1,
      methodNote: config.id == 'jingMirror'
          ? '金镜古法'
          : config.id == 'tongZong'
              ? '统宗宝鉴法'
              : '集成简化法',
      warnings: {
        'jingMirror': ['金镜派天目重留当前为 MVP 近似，后续需用典籍验盘校正。'],
        'tongZong': ['统宗派节气分界、天目重留简化当前以规则配置表达，仍需验盘校正。'],
        'jiCheng': ['集成派当代甲子元暂定为 1684 年，后续可做成用户可配置。'],
      }[config.id] ??
          [],
      zhangSui: monthConfig.zhangSui,
      zhangYue: monthConfig.zhangYue,
      dayOffset: dayConfig.dayOffset,
      hourOffset: hourConfig.hourOffset,
      dayBaseSchoolId: dayConfig.dayBaseSchoolId,
      hourBaseSchoolId: hourConfig.hourBaseSchoolId,
    );
  }
}
