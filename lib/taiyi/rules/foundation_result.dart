import 'rule_engine.dart';
import 'rule_models.dart';
import 'school_document.dart';
import 'school_repository.dart';
import 'nine_palace.dart';
import '../../enums/gong.dart';
import '../../enums/god.dart';

/// 基础层桥接结果：从 SchoolDocument + RuleEngine 提取的核心积年/入局/太乙宫参数。
///
/// 设计目标：保持与现有 TaiYiPanCalculator 同步兼容（无 Future 调用），
/// 桥接新规则引擎输出至遗留 PanDataModel 构建流程。
class FoundationResult {
  final String profileId;
  final String tradition;
  final String chartType;
  final DateTime dateTime;
  final int accumulatedYear;
  final int sequenceIndex;
  final int juNumber;
  final int wuZiYuanJu;
  final int yuanShu;
  final String yuanName;
  final int ruJiJiShu;
  final int ruJiNianShu;
  final String ruGongLabel;
  final String verificationStatus;
  // Derived from rule engine
  final String? taiYiPalaceName;   // palace name from foundation.taiYiRef e.g. '艮'
  final String? wenChangName;      // deity name from foundation.wenChangRef
  final String? jiShenName;        // deity name from foundation.jiShenRef
  final String? shiJiName;         // deity name from foundation.shiJiRef
  final int? hostCount;            // from threeCalc.hostRef
  final int? guestCount;           // from threeCalc.guestRef
  final int? dingCount;            // from threeCalc.dingRef

  FoundationResult({
    required this.profileId,
    required this.tradition,
    required this.chartType,
    required this.dateTime,
    required this.accumulatedYear,
    required this.sequenceIndex,
    required this.juNumber,
    required this.wuZiYuanJu,
    required this.yuanShu,
    required this.yuanName,
    required this.ruJiJiShu,
    required this.ruJiNianShu,
    required this.ruGongLabel,
    required this.verificationStatus,
    this.taiYiPalaceName,
    this.wenChangName,
    this.jiShenName,
    this.shiJiName,
    this.hostCount,
    this.guestCount,
    this.dingCount,
  });

  /// 从官方 SchoolDocument + RuleEngine 构建 FoundationResult。
  ///
  /// [schoolId] 可以是 camelCase ('jingMirror') 或 snake_case ('jing_mirror')。
  /// [year] 是公历年份（用作规则引擎变量 Y）。
  /// [isYang] 决定阴阳遁（年计默认阳遁）。
  ///
  /// 同步：使用 [SchoolRepository.loadOfficialSchoolSync] 不触发 Flutter asset 加载。
  static FoundationResult? fromSchoolId({
    required String schoolId,
    required int year,
    bool isYang = true,
  }) {
    final doc = SchoolRepository.loadOfficialSchoolSync(schoolId);
    if (doc == null) return null;
    return fromSchoolDocument(doc: doc, year: year, isYang: isYang);
  }

  /// 从已有 [SchoolDocument] 构建 FoundationResult。
  static FoundationResult fromSchoolDocument({
    required SchoolDocument doc,
    required int year,
    bool isYang = true,
  }) {
    final engine = RuleEngine(
      school: doc,
      contextVars: {'Y': year},
      isYang: isYang,
    );

    // Evaluate core accumulation / ju / foundation rules
    int accumulatedYear = 0;
    int ruJu = 0;
    int ju = 0;
    String taiYiPalaceName = '';
    String wenChangName = '';
    String jiShenName = '';
    String shiJiName = '';
    int hostCount = 0;
    int guestCount = 0;
    int dingCount = 0;

    // Accumulation year (first scalar rule with id containing 'accumulation.year')
    try {
      final accVal = engine.evaluateRuleById('accumulation.year') as ScalarRuleValue;
      accumulatedYear = accVal.value;
    } catch (_) {}

    // ruJu (五子元局)
    try {
      final ruJuVal = engine.evaluateRuleById('ruJu.year') as ScalarRuleValue;
      ruJu = ruJuVal.value;
    } catch (_) {}

    // ju (局数)
    try {
      final juVal = engine.evaluateRuleById('ju.year') as ScalarRuleValue;
      ju = juVal.value;
    } catch (_) {}

    // taiYi palace
    if (doc.foundation.taiYiRef.isNotEmpty) {
      try {
        final val = engine.evaluateRuleById(doc.foundation.taiYiRef) as PalaceRuleValue;
        taiYiPalaceName = val.palace;
      } catch (_) {}
    }

    // wenChang deity
    if (doc.foundation.wenChangRef.isNotEmpty) {
      try {
        final val = engine.evaluateRuleById(doc.foundation.wenChangRef);
        if (val is DeityRuleValue) {
          wenChangName = val.name;
        } else if (val is PalaceRuleValue) {
          wenChangName = val.palace;
        }
      } catch (_) {}
    }

    // jiShen deity
    if (doc.foundation.jiShenRef.isNotEmpty) {
      try {
        final val = engine.evaluateRuleById(doc.foundation.jiShenRef);
        if (val is DeityRuleValue) {
          jiShenName = val.name;
        } else if (val is PalaceRuleValue) {
          jiShenName = val.palace;
        }
      } catch (_) {}
    }

    // shiJi deity
    if (doc.foundation.shiJiRef.isNotEmpty) {
      try {
        final val = engine.evaluateRuleById(doc.foundation.shiJiRef);
        if (val is DeityRuleValue) {
          shiJiName = val.name;
        } else if (val is PalaceRuleValue) {
          shiJiName = val.palace;
        }
      } catch (_) {}
    }

    // Three calcs: host / guest / ding
    if (doc.threeCalc.hostRef.isNotEmpty) {
      try {
        final val = engine.evaluateRuleById(doc.threeCalc.hostRef) as ScalarRuleValue;
        hostCount = val.value;
      } catch (_) {}
    }
    if (doc.threeCalc.guestRef.isNotEmpty) {
      try {
        final val = engine.evaluateRuleById(doc.threeCalc.guestRef) as ScalarRuleValue;
        guestCount = val.value;
      } catch (_) {}
    }
    if (doc.threeCalc.dingRef.isNotEmpty) {
      try {
        final val = engine.evaluateRuleById(doc.threeCalc.dingRef) as ScalarRuleValue;
        dingCount = val.value;
      } catch (_) {}
    }

    // Derive wuZiYuanJu, yuanShu, yuanName, ruJiJiShu, ruJiNianShu, ruGongLabel from accumulatedYear
    // (mirrors TaiYiPanCalculator._computeYearJi logic)
    final wuZiYuanJu = accumulatedYear % 360;
    final yuanShu = wuZiYuanJu ~/ 72 + 1;
    final yuanNames = ['甲子元', '丙子元', '戊子元', '庚子元', '壬子元'];
    final yuanName = yuanNames[(yuanShu - 1).clamp(0, 4)];
    final juShu = wuZiYuanJu % 72;
    final juShuFixed = juShu == 0 ? 72 : juShu;
    final ruJiJiShu = wuZiYuanJu ~/ 60 + 1;
    final ruJiNianShu = wuZiYuanJu % 60;
    final taiYiRuGongNianShu = (juShuFixed - 1) % 3;
    final ruGongLabel = switch (taiYiRuGongNianShu) {
      0 => '理天',
      1 => '理地',
      2 => '理人',
      _ => '理天',
    };

    return FoundationResult(
      profileId: doc.meta.id,
      tradition: doc.meta.name,
      chartType: 'year',
      dateTime: DateTime(year),
      accumulatedYear: accumulatedYear,
      sequenceIndex: accumulatedYear,
      juNumber: ju,
      wuZiYuanJu: wuZiYuanJu,
      yuanShu: yuanShu,
      yuanName: yuanName,
      ruJiJiShu: ruJiJiShu,
      ruJiNianShu: ruJiNianShu,
      ruGongLabel: ruGongLabel,
      verificationStatus: 'engine-derived',
      taiYiPalaceName: taiYiPalaceName.isNotEmpty ? taiYiPalaceName : null,
      wenChangName: wenChangName.isNotEmpty ? wenChangName : null,
      jiShenName: jiShenName.isNotEmpty ? jiShenName : null,
      shiJiName: shiJiName.isNotEmpty ? shiJiName : null,
      hostCount: hostCount,
      guestCount: guestCount,
      dingCount: dingCount,
    );
  }

  /// Map palace name (Chinese) to EnumTaiYiGong.
  EnumTaiYiGong? get taiYiGong {
    if (taiYiPalaceName == null) return null;
    return _palaceNameToGong(taiYiPalaceName!);
  }

  static EnumTaiYiGong? _palaceNameToGong(String name) {
    return switch (name) {
      '乾' => EnumTaiYiGong.Qian,
      '离' => EnumTaiYiGong.Li,
      '艮' => EnumTaiYiGong.Gen,
      '震' => EnumTaiYiGong.Zhen,
      '兑' => EnumTaiYiGong.Dui,
      '坤' => EnumTaiYiGong.Kun,
      '坎' => EnumTaiYiGong.Kan,
      '巽' => EnumTaiYiGong.Xun,
      _ => null,
    };
  }

  /// Map deity name to its associated EnumTaiYiGong via the sixteen-god sequence.
  static EnumTaiYiGong? _deityToGong(String name) {
    try {
      final god = EnumTaiYiSixteenGods.values.firstWhere((e) =>
          e.name == name || e.singleName == name);
      return _palaceNameToGong(god.gong.gua.name);
    } catch (_) {
      return _palaceNameToGong(name);
    }
  }

  /// wenChang as EnumTaiYiGong (via deity→palace mapping).
  EnumTaiYiGong? get wenChangGong {
    if (wenChangName == null) return null;
    return _deityToGong(wenChangName!);
  }

  /// jiShen as EnumTaiYiGong.
  EnumTaiYiGong? get jiShenGong {
    if (jiShenName == null) return null;
    return _deityToGong(jiShenName!);
  }

  /// shiJi as EnumTaiYiGong.
  EnumTaiYiGong? get shiJiGong {
    if (shiJiName == null) return null;
    return _deityToGong(shiJiName!);
  }
}
