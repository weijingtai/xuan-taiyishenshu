import 'school_document.dart';
import 'rule_models.dart';
import 'arithmetic_tree.dart';
import 'nine_palace.dart';
import 'package:metaphysics_core/enums.dart';
import '../../enums/god.dart';
import '../../enums/gong.dart';


class RuleEngine {
  final SchoolDocument school;
  final Map<String, num> contextVars;
  final bool isYang;

  final Map<String, RuleValue> _evaluatedCache = {};

  RuleEngine({
    required this.school,
    required this.contextVars,
    this.isYang = true,
  });

  RuleValue evaluateRuleById(String ruleId) {
    if (_evaluatedCache.containsKey(ruleId)) {
      return _evaluatedCache[ruleId]!;
    }

    final rule = school.rules.firstWhere(
      (r) => r.id == ruleId,
      orElse: () => throw ArgumentError('Rule not found: $ruleId'),
    );

    final result = _evaluateRule(rule);
    _evaluatedCache[ruleId] = result;
    return result;
  }

  RuleValue _evaluateRule(SchoolRule rule) {
    final kind = rule.kind;
    final json = rule.originalJson;
    switch (kind) {
      case 'scalar':
        return _evalScalar(json);
      case 'walk':
        return _evalWalk(json, rule);
      case 'walkSum':
        return _evalWalkSum(json, rule);
      case 'deriveCount':
        return _evalDeriveCount(json, rule);
      case 'relative':
        return _evalRelative(json, rule);
      case 'table':
        return _evalTable(json, rule);
      case 'predicate':
        return _evalPredicate(json, rule);
      case 'shiJi':
        return _evalShiJi(json, rule);
      case 'dingMu':
        return _evalDingMu(json, rule);
      default:
        throw ArgumentError('Unsupported rule kind: $kind');
    }
  }

  // R1: ScalarFormula
  RuleValue _evalScalar(Map<String, dynamic> json) {
    final tree = json['tree'];
    final vars = _buildVarsContext(tree);
    var val = evalArithmeticTree(tree, vars).toInt();
    final z = json['zeroAsCycle'];
    if (z != null && val == 0) {
      val = z as int;
    }
    return ScalarRuleValue(val);
  }

  // R2: PalaceWalk
  RuleValue _evalWalk(Map<String, dynamic> json, SchoolRule rule) {
    final sys = json['palaceSystem'] as String;

    // Resolve start
    final startVal = json['start'];
    String startStr = '';
    if (startVal is String) {
      startStr = startVal;
    } else if (startVal is Map) {
      startStr = (isYang ? startVal['yang'] : startVal['yin']) as String;
    }

    // Resolve direction
    final dirVal = json['direction'];
    String dirStr = 'forward';
    if (dirVal is String) {
      dirStr = dirVal;
    } else if (dirVal is Map) {
      dirStr = (isYang ? dirVal['yang'] : dirVal['yin']) as String;
    }

    // Evaluate steps
    final stepsTree = json['steps'];
    final vars = _buildVarsContext(stepsTree);
    final steps = evalArithmeticTree(stepsTree, vars).toInt();

    // Get base sequence and resolve restAt if sixteenGods
    List<String> baseSeq;
    if (sys == 'eight8') {
      baseSeq = List.from(kTaiYiPalaceOrder);
    } else if (sys == 'sixteenGods') {
      baseSeq = ['地主', '阳德', '和德', '吕申', '高丛', '太阳', '大炅', '大神', '大威', '天道', '大武', '武德', '太簇', '阴主', '阴德', '大义'];
    } else if (sys == 'twelveBranch') {
      baseSeq = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    } else {
      throw ArgumentError('Unsupported palaceSystem: $sys');
    }

    final restAt = json['restAt'];
    List<String> finalSeq = baseSeq;
    if (restAt != null && sys == 'sixteenGods') {
      final restValues = (restAt['values'] as List).map((e) => e.toString()).toSet();
      finalSeq = [];
      for (final name in baseSeq) {
        finalSeq.add(name);
        final god = EnumTaiYiSixteenGods.values.firstWhere((e) => e.name == name);
        final isZheng = god.type == EnumZhengJianType.Zheng;
        final matchesRest = isZheng && (
          restValues.contains(god.name) ||
          restValues.contains(god.singleName) ||
          restValues.contains(god.gong.gua.name)
        );
        if (matchesRest) {
          finalSeq.add(name); // Duplicate!
        }
      }
    }

    // Step walk
    final startIdx = finalSeq.indexOf(startStr);
    if (startIdx == -1) {
      throw ArgumentError('Start position $startStr not found in sequence $finalSeq');
    }

    final len = finalSeq.length;
    int endIdx;
    if (dirStr == 'forward') {
      endIdx = (startIdx + steps) % len;
    } else {
      endIdx = (startIdx - steps) % len;
      if (endIdx < 0) {
        endIdx = (endIdx + len) % len;
      }
    }

    final destination = finalSeq[endIdx];

    if (rule.output == 'palace') {
      if (sys == 'sixteenGods') {
        final god = EnumTaiYiSixteenGods.values.firstWhere((e) => e.name == destination);
        return PalaceRuleValue(god.gong.gua.name);
      } else if (sys == 'twelveBranch') {
        // Map 12 branches to 8 palaces
        final palace = _mapBranchToPalace(destination);
        return PalaceRuleValue(palace);
      } else {
        return PalaceRuleValue(destination);
      }
    } else {
      return DeityRuleValue(destination);
    }
  }

  // R3: WalkAndSum
  RuleValue _evalWalkSum(Map<String, dynamic> json, SchoolRule rule) {
    final palaceSystem = json['palaceSystem'] as String? ?? 'eight8';
    final rawSum = json['rawSum'] as bool? ?? false;
    final chartType = json['chartType'] as String? ?? 'year';

    final startRef = json['startRef'] as String;
    final startVal = evaluateRuleById(startRef);

    final taiYiRef = school.foundation.taiYiRef;
    final taiYiVal = evaluateRuleById(taiYiRef) as PalaceRuleValue;
    final taiYiPalace = taiYiVal.palace;

    // 十六神地理序走盘
    if (palaceSystem == 'sixteenGods') {
      // 解析起点位置(1-indexed in sixteenGodSequence)
      int startPos;
      if (startVal is PalaceRuleValue) {
        startPos = kPalaceToZhengDeityPosition[startVal.palace] ?? 1;
      } else if (startVal is DeityRuleValue) {
        // 先尝试直接匹配
        var idx = kSixteenGodSequence.indexOf(startVal.name);
        // 再通过 EnumTaiYiSixteenGods 转 singleName
        if (idx == -1) {
          try {
            final god = EnumTaiYiSixteenGods.values.firstWhere(
                (e) => e.name == startVal.name || e.singleName == startVal.name);
            idx = kSixteenGodSequence.indexOf(god.singleName);
          } catch (_) {}
        }
        startPos = idx >= 0 ? idx + 1 : 1;
      } else {
        throw ArgumentError('startRef must evaluate to palace or deity');
      }

      // 太乙正位位置
      final taiYiPos = kPalaceToZhengDeityPosition[taiYiPalace] ?? 1;

      final sum = walkAndSum16(startPos, taiYiPos, chartType: chartType);
      return ScalarRuleValue(sum);
    }

    // 八宫太乙序走盘(原有逻辑)
    String startPalace = '';
    if (startVal is PalaceRuleValue) {
      startPalace = startVal.palace;
    } else if (startVal is DeityRuleValue) {
      final match = EnumTaiYiSixteenGods.values.where((e) =>
          e.name == startVal.name || e.singleName == startVal.name);
      if (match.isNotEmpty) {
        startPalace = match.first.gong.gua.name;
      } else {
        startPalace = _mapBranchToPalace(startVal.name);
      }
    } else {
      throw ArgumentError('startRef must evaluate to palace or deity');
    }

    if (startPalace == '中' || taiYiPalace == '中') {
      return ScalarRuleValue(0);
    }

    final ep = json['endpoint'];
    String endPalaceName;
    if (isYang) {
      final yangEp = (ep != null ? ep['yang'] : null) ?? 'taiYiPrev';
      endPalaceName = yangEp == 'taiYiPrev' ? prevPalace(taiYiPalace) : nextPalace(taiYiPalace);
    } else {
      final yinEp = (ep != null ? ep['yin'] : null) ?? 'taiYiPrev';
      endPalaceName = yinEp == 'taiYiPrev' ? prevPalace(taiYiPalace) : nextPalace(taiYiPalace);
    }

    final sum = walkAndSum(startPalace, taiYiPalace, endPalace: endPalaceName);
    return ScalarRuleValue(sum);
  }

  // R3b: ShiJi (始击) — 旧算法: shiJiIdx = (wenChangIdx + stepsToGen) % 16
  RuleValue _evalShiJi(Map<String, dynamic> json, SchoolRule rule) {
    final wenChangRef = json['wenChangRef'] as String;
    final jiShenRef = json['jiShenRef'] as String;

    final wenChangVal = evaluateRuleById(wenChangRef);
    final jiShenVal = evaluateRuleById(jiShenRef);

    // 将神名转为十六神地理序中的名称(支名/卦名)
    String _toGeoName(RuleValue val) {
      if (val is DeityRuleValue) {
        // 先尝试直接匹配
        if (kSixteenGodSequence.contains(val.name)) return val.name;
        // 再通过 EnumTaiYiSixteenGods 转 singleName
        try {
          final god = EnumTaiYiSixteenGods.values.firstWhere(
              (e) => e.name == val.name || e.singleName == val.name);
          return god.singleName;
        } catch (_) {
          return val.name;
        }
      } else if (val is PalaceRuleValue) {
        return val.palace;
      }
      return '';
    }

    final wenChangName = _toGeoName(wenChangVal);
    final jiShenName = _toGeoName(jiShenVal);

    final wenChangIdx = kSixteenGodSequence.indexOf(wenChangName);
    final jiShenIdx = kSixteenGodSequence.indexOf(jiShenName);
    final genIdx = kSixteenGodSequence.indexOf('艮');

    if (wenChangIdx == -1 || jiShenIdx == -1) {
      return DeityRuleValue(wenChangName); // fallback
    }

    final stepsToGen = (genIdx - jiShenIdx + 16) % 16;
    final shiJiIdx = (wenChangIdx + stepsToGen) % 16;
    final shiJiName = kSixteenGodSequence[shiJiIdx];

    return DeityRuleValue(shiJiName);
  }

  // R3c: DingMu (定目) — 旧算法: 基于 currentBranch + wenChang + 合神偏移
  RuleValue _evalDingMu(Map<String, dynamic> json, SchoolRule rule) {
    final wenChangRef = json['wenChangRef'] as String;
    final wenChangVal = evaluateRuleById(wenChangRef);

    // 获取文昌神名(地理序名称)
    String wenChangName;
    if (wenChangVal is DeityRuleValue) {
      wenChangName = wenChangVal.name;
      // 转为 singleName(支名)
      if (!kSixteenGodSequence.contains(wenChangName)) {
        try {
          final god = EnumTaiYiSixteenGods.values.firstWhere(
              (e) => e.name == wenChangName || e.singleName == wenChangName);
          wenChangName = god.singleName;
        } catch (_) {}
      }
    } else if (wenChangVal is PalaceRuleValue) {
      wenChangName = wenChangVal.palace;
    } else {
      throw ArgumentError('wenChangRef must evaluate to deity or palace');
    }

    // 计算年支
    final twelveBranches = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'];
    final accYearVal = evaluateRuleById('accumulation.year') as ScalarRuleValue;
    final yearBranch = twelveBranches[(accYearVal.value - 1) % 12];

    final dingMuName = calculateDingMu(
      currentBranch: yearBranch,
      wenChangDeity: wenChangName,
    );

    return DeityRuleValue(dingMuName);
  }

  // R4: DeriveFromCount
  RuleValue _evalDeriveCount(Map<String, dynamic> json, SchoolRule rule) {
    final countRef = json['countRef'] as String;
    final countVal = evaluateRuleById(countRef) as ScalarRuleValue;
    final C = countVal.value;

    if (C == 0) {
      return PalaceRuleValue('中');
    }

    final daMap = json['daMap'] as Map;
    final minorTree = json['minorTree'];

    if (minorTree != null) {
      // Evaluate Minor General
      // 1. Get Major General's palace name
      final majorRef = school.generals.hostMajorRef; // hostMajorRef is hostMajor
      // Wait, is it always hostMajorRef? Let's check which Major general corresponds to this Minor general.
      // If our rule ID is 'general.hostMinor', it depends on 'general.hostMajor'.
      // If guestMinor, it depends on guestMajor.
      // We can infer the Major general rule ID by checking the suffix or matching.
      String majorRuleId = school.generals.hostMajorRef;
      if (rule.id.contains('guest')) {
        majorRuleId = school.generals.guestMajorRef;
      } else if (rule.id.contains('ding')) {
        majorRuleId = school.generals.dingMajorRef ?? school.generals.hostMajorRef;
      }

      final majorVal = evaluateRuleById(majorRuleId) as PalaceRuleValue;
      if (majorVal.palace == '中') {
        return PalaceRuleValue('中');
      }

      final majorGongBen = kGongBenShu[majorVal.palace] ?? 0;
      final vars = _buildVarsContext(minorTree);
      vars[majorRuleId] = majorGongBen; // Bind MajorGeneral variable to its gong本数

      var V = evalArithmeticTree(minorTree, vars).toInt();
      // Apply 10 -> 9
      if (V == 10 || V == 0) {
        V = 9;
      }

      final dest = daMap[V.toString()] ?? daMap[V] ?? '中';
      return PalaceRuleValue(dest as String);
    } else {
      // Evaluate Major General
      var keyVal = C;
      final dest = daMap[keyVal.toString()] ?? daMap[keyVal] ?? '中';
      return PalaceRuleValue(dest as String);
    }
  }

  // R5: Relative
  RuleValue _evalRelative(Map<String, dynamic> json, SchoolRule rule) {
    final baseRef = json['baseRef'] as String;
    final baseVal = evaluateRuleById(baseRef);
    String baseStr = '';
    if (baseVal is PalaceRuleValue) {
      baseStr = baseVal.palace;
    } else if (baseVal is DeityRuleValue) {
      baseStr = baseVal.name;
    }

    if (baseStr == '中' || baseStr.isEmpty) {
      return rule.output == 'palace' ? PalaceRuleValue('中') : DeityRuleValue('中');
    }

    final sys = json['palaceSystem'] as String;
    final mode = json['mode'] as String;

    List<String> baseSeq;
    if (sys == 'eight8') {
      baseSeq = List.from(kTaiYiPalaceOrder);
    } else if (sys == 'sixteenGods') {
      baseSeq = ['地主', '阳德', '和德', '吕申', '高丛', '太阳', '大炅', '大神', '大威', '天道', '大武', '武德', '太簇', '阴主', '阴德', '大义'];
    } else if (sys == 'twelveBranch') {
      baseSeq = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    } else {
      throw ArgumentError('Unsupported palaceSystem: $sys');
    }

    final baseIdx = baseSeq.indexOf(baseStr);
    if (baseIdx == -1) {
      // Maybe map deity to palace if we are on eight8 system
      if (sys == 'eight8') {
        try {
          final god = EnumTaiYiSixteenGods.values.firstWhere((e) => e.name == baseStr);
          final palaceStr = god.gong.gua.name;
          final idx = baseSeq.indexOf(palaceStr);
          if (idx != -1) {
            return _evalRelativeWithIndex(idx, baseSeq, mode, json, rule);
          }
        } catch (_) {}
      }
      throw ArgumentError('Base position $baseStr not found in sequence $baseSeq');
    }

    return _evalRelativeWithIndex(baseIdx, baseSeq, mode, json, rule);
  }

  RuleValue _evalRelativeWithIndex(
      int index, List<String> sequence, String mode, Map<String, dynamic> json, SchoolRule rule) {
    final len = sequence.length;
    int destIdx;
    if (mode == 'opposition') {
      destIdx = (index + (len ~/ 2)) % len;
    } else {
      final offset = json['offset'] as int? ?? 0;
      destIdx = (index + offset) % len;
      if (destIdx < 0) {
        destIdx = (destIdx + len) % len;
      }
    }

    final destination = sequence[destIdx];
    if (rule.output == 'palace') {
      return PalaceRuleValue(destination);
    } else {
      return DeityRuleValue(destination);
    }
  }

  // R6: TableSequence
  RuleValue _evalTable(Map<String, dynamic> json, SchoolRule rule) {
    final table = json['table'] as List;
    final indexTree = json['indexTree'];
    final vars = _buildVarsContext(indexTree);
    final idx = evalArithmeticTree(indexTree, vars).toInt();

    int actualIdx = (idx - 1) % table.length;

    final val = table[actualIdx];
    if (val is int) {
      // Map to palace
      final palace = kTaiYiPalaceOrder.firstWhere((p) => kGongBenShu[p] == val, orElse: () => '中');
      return PalaceRuleValue(palace);
    } else {
      return PalaceRuleValue(val.toString());
    }
  }

  // R7: Predicate
  RuleValue _evalPredicate(Map<String, dynamic> json, SchoolRule rule) {
    final when = json['when'] as Map;
    final op = when['op'] as String;
    final args = when['args'] as List;
    final name = json['name'] as String? ?? rule.id;

    if (op == 'eq') {
      final vals = args.map((ref) => evaluateRuleById(ref as String)).toList();
      if (vals.isEmpty) return PredicateRuleValue(false, name);
      final first = vals[0].toJson().toString();
      final matched = vals.every((v) => v.toJson().toString() == first);
      return PredicateRuleValue(matched, name);
    } else if (op == 'adjacent') {
      final vals = args.map((ref) => evaluateRuleById(ref as String)).toList();
      if (vals.length < 2) return PredicateRuleValue(false, name);
      final v1 = vals[0];
      final v2 = vals[1];
      if (v1 is PalaceRuleValue && v2 is PalaceRuleValue) {
        final idx1 = kTaiYiPalaceOrder.indexOf(v1.palace);
        final idx2 = kTaiYiPalaceOrder.indexOf(v2.palace);
        if (idx1 == -1 || idx2 == -1) return PredicateRuleValue(false, name);
        final diff = (idx1 - idx2).abs();
        final matched = diff == 1 || diff == 7;
        return PredicateRuleValue(matched, name);
      }
      return PredicateRuleValue(false, name);
    } else if (op == 'coLocatedEqualCount') {
      if (args.length < 4) return PredicateRuleValue(false, name);
      final p1 = evaluateRuleById(args[0] as String);
      final p2 = evaluateRuleById(args[1] as String);
      final c1 = evaluateRuleById(args[2] as String);
      final c2 = evaluateRuleById(args[3] as String);
      final matched = p1.toJson().toString() == p2.toJson().toString() &&
                      c1.toJson().toString() == c2.toJson().toString();
      return PredicateRuleValue(matched, name);
    }

    return PredicateRuleValue(false, name);
  }

  Map<String, num> _buildVarsContext(dynamic node) {
    final Map<String, num> vars = Map.from(contextVars);
    _resolveAstVars(node, vars);
    return vars;
  }

  void _resolveAstVars(dynamic node, Map<String, num> vars) {
    if (node is! Map) return;
    if (node.containsKey('var')) {
      final name = node['var'] as String;
      if (!vars.containsKey(name)) {
        try {
          final val = evaluateRuleById(name);
          if (val is ScalarRuleValue) {
            vars[name] = val.value;
          } else if (val is PalaceRuleValue) {
            vars[name] = val.palace == '中' ? 0 : (kGongBenShu[val.palace] ?? 0);
          } else if (val is DeityRuleValue) {
            final god = EnumTaiYiSixteenGods.values.firstWhere((e) => e.name == val.name);
            vars[name] = god.seq;
          }
        } catch (_) {}
      }
    } else if (node.containsKey('floor')) {
      _resolveAstVars(node['floor'], vars);
    } else if (node.containsKey('op')) {
      _resolveAstVars(node['a'], vars);
      _resolveAstVars(node['b'], vars);
    }
  }

  String _mapBranchToPalace(String branch) {
    switch (branch) {
      case '子':
        return '坎';
      case '丑':
      case '寅':
        return '艮';
      case '卯':
        return '震';
      case '辰':
      case '巳':
        return '巽';
      case '午':
        return '离';
      case '未':
      case '申':
        return '坤';
      case '酉':
        return '兑';
      case '戌':
      case '亥':
        return '乾';
      default:
        return '中';
    }
  }
}
