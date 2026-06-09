// ============================================================================
// POC — 规则驱动太乙引擎可行性验证 (NOT PRODUCTION CODE)
// ----------------------------------------------------------------------------
// 目的: 验证 `openspec/changes/taiyi-algorithm-config-management/
//        design-rule-engine-draft.md` 的规则模型站得住:
//   R1 JSON 算术树求值器 / R2 太乙宫定位 / R3 三算走盘(太乙九宫 + 满十去十 + 无算)
// 性质: 一次性、抛弃式验证。**自包含,不 import lib/**;模型验证通过后,
//        将由「计划 A(正式 OpenSpec change)」的生产实现取代本文件。
// 数理基准: 太乙九宫 = 乾1·离2·艮3·震4·中5(不入)·兑6·坤7·坎8·巽9 (非洛书)。
// 运行: flutter test test/poc/taiyi_rule_engine_poc_test.dart
// ============================================================================

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

// --- 太乙九宫(剔除中五的 8 宫遍历序 + 宫本数) -------------------------------
const List<String> kPalaceOrder = ['乾', '离', '艮', '震', '兑', '坤', '坎', '巽'];
const Map<String, int> kGongBenShu = {
  '乾': 1, '离': 2, '艮': 3, '震': 4, '兑': 6, '坤': 7, '坎': 8, '巽': 9, // 中=5 不入
};

// --- R1: JSON 算术树求值器(白名单节点,无字符串解析、无循环、无 IO) ----------
num evalTree(dynamic node, Map<String, num> vars) {
  if (node is Map) {
    if (node.containsKey('int')) return node['int'] as int;
    if (node.containsKey('num')) return node['num'] as num;
    if (node.containsKey('var')) {
      final name = node['var'] as String;
      if (!vars.containsKey(name)) throw ArgumentError('未声明变量: $name');
      return vars[name]!;
    }
    if (node.containsKey('floor')) return evalTree(node['floor'], vars).floor();
    if (node.containsKey('op')) {
      final a = evalTree(node['a'], vars);
      final b = evalTree(node['b'], vars);
      switch (node['op'] as String) {
        case '+': return a + b;
        case '-': return a - b;
        case '*': return a * b;
        case '~/': return a ~/ b;
        case '%': return a % b;
      }
    }
  }
  throw ArgumentError('非法 AST 节点: $node');
}

int scalar(Map rule, Map<String, num> vars) {
  var v = evalTree(rule['tree'], vars).toInt();
  final z = rule['zeroAsCycle'];
  if (z != null && v == 0) v = z as int;
  return v;
}

// --- R3: 满十去十(含 10 归 9)+ 无算 + 顺行累加 ------------------------------
int formatCount(int sum) {
  if (sum == 0) return 0; // 无算
  final r = ((sum - 1) % 10) + 1; // 满十去十 → [1,10]
  return r == 10 ? 9 : r; // 10 归 9
}

String prevPalace(String taiYi) {
  final i = kPalaceOrder.indexOf(taiYi);
  return kPalaceOrder[(i - 1 + 8) % 8];
}

/// 顺行从 start 累加宫本数到 end(end 本身不计),含无算边界。
/// (end 默认取太乙前一宫;统宗阴时计可传入太乙后一宫。)
int walkAndSum(String start, String taiYi, {String? endPalace}) {
  if (start == taiYi) return 0; // 无算①: 起点同太乙宫
  final si = kPalaceOrder.indexOf(start);
  if (kPalaceOrder[(si + 1) % 8] == taiYi) return 0; // 无算②: 一步即到太乙
  final end = endPalace ?? prevPalace(taiYi);
  if (start == end) return 0; // 无算延伸: 起点==终点
  final ei = kPalaceOrder.indexOf(end);
  int sum = 0, ci = si;
  while (ci != ei) {
    sum += kGongBenShu[kPalaceOrder[ci]]!;
    ci = (ci + 1) % 8;
  }
  return formatCount(sum);
}

// --- R1+R2 组合: 金镜年计基础层(完全由 School JSON 文档驱动) -----------------
Map<String, dynamic> foundationYear(Map school, int year) {
  final J = scalar(school['accumulation'] as Map, {'Y': year});
  final ruJu = scalar(
      (school['charts'] as Map)['year']['ruJu'] as Map, {'J': J}); // 五子元局 0→360
  final ju = ((ruJu - 1) % 72) + 1; // 局数 1..72 (0→72)
  final taiYi = kPalaceOrder[((ju - 1) ~/ 3) % 8]; // 5_in_one §3
  final ruGong = const ['理天', '理地', '理人'][(ju - 1) % 3];
  return {'J': J, 'wuzi': ruJu, 'ju': ju, 'taiYi': taiYi, 'ruGong': ruGong};
}

// --- School 文档(纯数据;切换流派 = 换 JSON,不改代码) -----------------------
// 金镜派(现行代码基数 1937281@724)—— 目标 = 现有通过的回归向量
const String kJingMirrorExisting = '''
{
  "meta": {"id": "jingMirror.existing", "name": "金镜派(现行基数)", "owner": "official"},
  "accumulation": {"kind": "scalar",
    "tree": {"op": "+", "a": {"int": 1937281},
             "b": {"op": "-", "a": {"var": "Y"}, "b": {"int": 724}}}},
  "charts": {"year": {"enabled": true,
    "ruJu": {"kind": "scalar", "tree": {"op": "%", "a": {"var": "J"}, "b": {"int": 360}}, "zeroAsCycle": 360}}}
}''';

// 金镜派(古法上元 751:J = 10153917 + (Y-751))—— 同引擎,仅换积年树
const String kJingMirrorClassical = '''
{
  "meta": {"id": "jingMirror.classical", "name": "金镜派(古法751)", "owner": "official"},
  "accumulation": {"kind": "scalar",
    "tree": {"op": "+", "a": {"int": 10153917},
             "b": {"op": "-", "a": {"var": "Y"}, "b": {"int": 751}}}},
  "charts": {"year": {"enabled": true,
    "ruJu": {"kind": "scalar", "tree": {"op": "%", "a": {"var": "J"}, "b": {"int": 360}}, "zeroAsCycle": 360}}}
}''';

void main() {
  group('R1 — JSON 算术树求值器', () {
    test('金镜现行积年 1937281+(Y-724) @2026 = 1938583', () {
      final s = jsonDecode(kJingMirrorExisting) as Map;
      expect(scalar(s['accumulation'] as Map, {'Y': 2026}), 1938583);
    });
    test('金镜古法积年 10153917+(Y-751) @2026 = 10155192', () {
      final s = jsonDecode(kJingMirrorClassical) as Map;
      expect(scalar(s['accumulation'] as Map, {'Y': 2026}), 10155192);
    });
    test('floor(J * 365.2425) @J=10 = 3652', () {
      final tree = {
        'floor': {'op': '*', 'a': {'num': 365.2425}, 'b': {'var': 'J'}}
      };
      expect(evalTree(tree, {'J': 10}).toInt(), 3652);
    });
    test('未声明变量报错(字段路径式安全)', () {
      expect(() => evalTree({'var': 'Z'}, {'Y': 1}), throwsArgumentError);
    });
  });

  group('R1+R2 — 金镜年计基础层(数据驱动)', () {
    test('现行基数 @2026 复现现有回归向量', () {
      final f = foundationYear(jsonDecode(kJingMirrorExisting) as Map, 2026);
      expect(f['J'], 1938583);
      expect(f['wuzi'], 343); // 五子元局
      expect(f['ju'], 55); // 局数
      expect(f['taiYi'], '艮');
      expect(f['ruGong'], '理天');
    });
    test('只换积年 JSON 树 → 同引擎产出古法盘(证明数据驱动)', () {
      final f = foundationYear(jsonDecode(kJingMirrorClassical) as Map, 2026);
      expect(f['J'], 10155192);
      expect(f['wuzi'], 312);
      expect(f['ju'], 24);
      expect(f['taiYi'], '巽');
      expect(f['ruGong'], '理人');
    });
  });

  group('R3 — 三算走盘(太乙九宫序 + 满十去十 + 无算)', () {
    test('正常累加: 文昌乾→太乙震 = 乾(1)+离(2) = 3', () {
      expect(walkAndSum('乾', '震'), 3);
    });
    test('满十去十: 文昌艮→太乙乾, 累加28 → 8', () {
      expect(walkAndSum('艮', '乾'), 8);
    });
    test('无算①: 起点同太乙宫 → 0', () {
      expect(walkAndSum('震', '震'), 0);
    });
    test('无算②: 一步即到太乙(乾→离, 离为乾下一宫) → 0', () {
      expect(walkAndSum('乾', '离'), 0);
    });
    test('满十去十 / 10 归 9 / 无算 边界', () {
      expect(formatCount(3), 3);
      expect(formatCount(10), 9); // 10 归 9
      expect(formatCount(20), 9); // 满二十去二十后为10 → 9
      expect(formatCount(0), 0); // 无算
    });
  });
}
