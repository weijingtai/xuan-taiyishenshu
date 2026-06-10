import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/rules/school_document.dart';
import 'package:taiyishenshu/taiyi/rules/rule_models.dart';
import 'package:taiyishenshu/taiyi/rules/rule_engine.dart';
import 'package:taiyishenshu/taiyi/rules/nine_palace.dart';

void main() {
  group('RuleEngine Core (R1-R3) Tests', () {
    const String kJingMirrorExisting = '''
    {
      "schemaVersion": 1,
      "meta": {"id": "jingMirror.existing", "name": "金镜派(现行基数)", "version": 1, "source": "poc", "owner": "official"},
      "palace": "taiyi9",
      "rules": [
        {
          "id": "accumulation.year",
          "kind": "scalar",
          "output": "scalar",
          "tree": {
            "op": "+",
            "a": {"int": 1937281},
            "b": {
              "op": "-",
              "a": {"var": "Y"},
              "b": {"int": 724}
            }
          }
        },
        {
          "id": "ruJu.year",
          "kind": "scalar",
          "output": "scalar",
          "tree": {
            "op": "%",
            "a": {"var": "accumulation.year"},
            "b": {"int": 360}
          },
          "zeroAsCycle": 360
        },
        {
          "id": "foundation.taiYi",
          "kind": "table",
          "output": "palace",
          "table": [1, 2, 3, 4, 6, 7, 8, 9],
          "indexTree": {
            "op": "+",
            "a": {
              "op": "~/",
              "a": {
                "op": "-",
                "a": {"var": "ruJu.year"},
                "b": {"int": 1}
              },
              "b": {"int": 3}
            },
            "b": {"int": 1}
          }
        },
        {
          "id": "foundation.tianMu",
          "kind": "walk",
          "output": "deity",
          "palaceSystem": "sixteenGods",
          "start": "武德",
          "direction": "forward",
          "steps": {
            "op": "%",
            "a": {"var": "ruJu.year"},
            "b": {"int": 18}
          },
          "restAt": {
            "values": ["阴德", "大武", "乾", "坤"],
            "source": "5_in_one_classes_alg.md §4.1"
          }
        },
        {
          "id": "calc.host",
          "kind": "walkSum",
          "output": "scalar",
          "startRef": "foundation.tianMu",
          "endpoint": {"yang": "taiYiPrev", "yin": "taiYiPrev"},
          "normalize": "满十去十",
          "wuSuan": {"samePalace": 0, "oneStep": 0, "sameEnd": 0}
        }
      ],
      "charts": {
        "year": {"enabled": true, "ruJuRef": "accumulation.year", "appliesTo": ["year"]}
      },
      "dun": {"resolver": "resolver", "termMode": "leveling"},
      "foundation": {
        "taiYiRef": "foundation.taiYi",
        "wenChangRef": "foundation.tianMu",
        "jiShenRef": "foundation.tianMu",
        "shiJiRef": "foundation.tianMu"
      },
      "threeCalc": {
        "hostRef": "calc.host",
        "guestRef": "calc.host",
        "dingRef": "calc.host"
      },
      "generals": {
        "hostMajorRef": "foundation.taiYi",
        "hostMinorRef": "foundation.taiYi",
        "guestMajorRef": "foundation.taiYi",
        "guestMinorRef": "foundation.taiYi"
      },
      "deities": [],
      "geJu": []
    }''';

    test('R1 - ScalarFormula evaluation', () {
      final doc = SchoolDocument.fromJson(jsonDecode(kJingMirrorExisting) as Map<String, dynamic>);
      final engine = RuleEngine(school: doc, contextVars: {'Y': 2026});
      
      final acc = engine.evaluateRuleById('accumulation.year') as ScalarRuleValue;
      expect(acc.value, 1938583);
      
      final ruJu = engine.evaluateRuleById('ruJu.year') as ScalarRuleValue;
      expect(ruJu.value, 343);
    });

    test('R2 - Walk with restAt (TianMu / WenChang)', () {
      final doc = SchoolDocument.fromJson(jsonDecode(kJingMirrorExisting) as Map<String, dynamic>);
      final engine = RuleEngine(school: doc, contextVars: {'Y': 2026});
      
      final tianMu = engine.evaluateRuleById('foundation.tianMu') as DeityRuleValue;
      // ruJu = 343. steps = 343 % 18 = 1.
      // Base sixteenGods: 武德, 太簇, 阴主, 阳德, 大义, 地主, 阴德, 和德, 吕申, 高丛, 太阳, 大炅, 大神, 大威, 天道, 大武, 阴主 ...
      // With duplication: 武德, 太簇, 阴主, 阳德, 阳德, 大义, 地主, 阴德 ...
      // Start is 武德 (idx 0). Steps = 1.
      // 1 step from 武德 is 太簇.
      expect(tianMu.name, '太簇');
    });

    test('R3 - WalkAndSum (host calc)', () {
      final doc = SchoolDocument.fromJson(jsonDecode(kJingMirrorExisting) as Map<String, dynamic>);
      
      // Let's test with a case where steps are known.
      // Under Y=2026:
      // ruJu = 343.
      // taiYi = index = ((343 - 1) ~/ 3) % 8 = 114 % 8 = 2 (艮).
      // tianMu = '太簇' (maps to palace '兑').
      // taiYiPrev(艮) is '离'.
      // walkAndSum('兑', '艮', endPalace: '离') ->
      // Order: 兑(6) -> 坤(7) -> 坎(8) -> 巽(9) -> 乾(1) -> 离(2) -> 艮(3) ...
      // start='兑', taiYi='艮'. endPalace='离'.
      // walk: 兑(6) + 坤(7) + 坎(8) + 巽(9) + 乾(1) = 31.
      // formatCount(31) = 1.
      final engine = RuleEngine(school: doc, contextVars: {'Y': 2026});
      final host = engine.evaluateRuleById('calc.host') as ScalarRuleValue;
      expect(host.value, 1);
    });

    test('nine_palace walkAndSum no-count conditions', () {
      // 起点同太乙宫
      expect(walkAndSum('震', '震'), 0);
      // 顺行一步即抵太乙
      expect(walkAndSum('乾', '离'), 0);
      // 起点等于终点
      expect(walkAndSum('巽', '乾', endPalace: '巽'), 0);
    });

    test('nine_palace formatCount limits', () {
      expect(formatCount(3), 3);
      expect(formatCount(10), 9);
      expect(formatCount(20), 9);
      expect(formatCount(0), 0);
    });
  });
}
