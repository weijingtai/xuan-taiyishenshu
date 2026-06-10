import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/rules/school_document.dart';
import 'package:taiyishenshu/taiyi/rules/rule_models.dart';
import 'package:taiyishenshu/taiyi/rules/rule_engine.dart';

void main() {
  group('Remaining Rule Kinds (R4-R7) Tests', () {
    test('R4 - DeriveFromCount (Major / Minor Generals)', () {
      final school = SchoolDocument(
        schemaVersion: 1,
        meta: SchoolMeta(id: 'r4_school', name: 'R4 School', version: 1, source: 'test', owner: 'user'),
        palace: 'taiyi9',
        rules: [
          SchoolRule(id: 'hostCount', kind: 'scalar', output: 'scalar', originalJson: {
            'id': 'hostCount',
            'kind': 'scalar',
            'output': 'scalar',
            'tree': {'int': 8}
          }),
          SchoolRule(id: 'general.hostMajor', kind: 'deriveCount', output: 'palace', originalJson: {
            'id': 'general.hostMajor',
            'kind': 'deriveCount',
            'output': 'palace',
            'countRef': 'hostCount',
            'daMap': {
              '8': '坎',
              '9': '巽',
              '10': '巽'
            }
          }),
          SchoolRule(id: 'general.hostMinor', kind: 'deriveCount', output: 'palace', originalJson: {
            'id': 'general.hostMinor',
            'kind': 'deriveCount',
            'output': 'palace',
            'countRef': 'hostCount',
            'daMap': {
              '4': '震',
              '9': '巽'
            },
            'minorTree': {
              'op': '%',
              'a': {
                'op': '*',
                'a': {'var': 'general.hostMajor'},
                'b': {'int': 3}
              },
              'b': {'int': 10}
            }
          })
        ],
        charts: SchoolCharts(),
        dun: SchoolDun(resolver: 'resolver', termMode: 'leveling'),
        foundation: SchoolFoundation(taiYiRef: 'general.hostMajor', wenChangRef: 'general.hostMajor', jiShenRef: 'general.hostMajor', shiJiRef: 'general.hostMajor'),
        threeCalc: SchoolThreeCalc(hostRef: 'hostCount', guestRef: 'hostCount', dingRef: 'hostCount'),
        generals: SchoolGenerals(
          hostMajorRef: 'general.hostMajor',
          hostMinorRef: 'general.hostMinor',
          guestMajorRef: 'general.hostMajor',
          guestMinorRef: 'general.hostMinor',
        ),
        deities: [],
        geJu: [],
      );

      final engine2 = RuleEngine(
        school: school,
        contextVars: {},
      );
      
      final hostMajor = engine2.evaluateRuleById('general.hostMajor') as PalaceRuleValue;
      expect(hostMajor.palace, '坎'); // 8 -> 坎

      final hostMinor = engine2.evaluateRuleById('general.hostMinor') as PalaceRuleValue;
      expect(hostMinor.palace, '震');
    });

    test('R4 - DeriveFromCount no-count', () {
      final school = SchoolDocument(
        schemaVersion: 1,
        meta: SchoolMeta(id: 'r4_nc', name: 'R4 NC', version: 1, source: 'test', owner: 'user'),
        palace: 'taiyi9',
        rules: [
          SchoolRule(id: 'hostCount', kind: 'scalar', output: 'scalar', originalJson: {
            'id': 'hostCount', 'kind': 'scalar', 'output': 'scalar', 'tree': {'int': 0}
          }),
          SchoolRule(id: 'general.hostMajor', kind: 'deriveCount', output: 'palace', originalJson: {
            'id': 'general.hostMajor', 'kind': 'deriveCount', 'output': 'palace',
            'countRef': 'hostCount', 'daMap': {'8': '坎'}
          })
        ],
        charts: SchoolCharts(),
        dun: SchoolDun(resolver: 'resolver', termMode: 'leveling'),
        foundation: SchoolFoundation(taiYiRef: 'general.hostMajor', wenChangRef: 'general.hostMajor', jiShenRef: 'general.hostMajor', shiJiRef: 'general.hostMajor'),
        threeCalc: SchoolThreeCalc(hostRef: 'hostCount', guestRef: 'hostCount', dingRef: 'hostCount'),
        generals: SchoolGenerals(
          hostMajorRef: 'general.hostMajor',
          hostMinorRef: 'general.hostMajor',
          guestMajorRef: 'general.hostMajor',
          guestMinorRef: 'general.hostMajor',
        ),
        deities: [],
        geJu: [],
      );

      final engine = RuleEngine(school: school, contextVars: {});
      final hostMajor = engine.evaluateRuleById('general.hostMajor') as PalaceRuleValue;
      expect(hostMajor.palace, '中'); // C=0 -> 中
    });

    test('R5 - Relative (opposition / offset)', () {
      final school = SchoolDocument(
        schemaVersion: 1,
        meta: SchoolMeta(id: 'r5_school', name: 'R5 School', version: 1, source: 'test', owner: 'user'),
        palace: 'taiyi9',
        rules: [
          SchoolRule(id: 'base', kind: 'walk', output: 'palace', originalJson: {
            'id': 'base', 'kind': 'walk', 'output': 'palace', 'palaceSystem': 'eight8',
            'start': '离', 'direction': 'forward', 'steps': {'int': 0}
          }),
          SchoolRule(id: 'opp', kind: 'relative', output: 'palace', originalJson: {
            'id': 'opp', 'kind': 'relative', 'output': 'palace', 'baseRef': 'base',
            'mode': 'opposition', 'palaceSystem': 'eight8'
          }),
          SchoolRule(id: 'off', kind: 'relative', output: 'palace', originalJson: {
            'id': 'off', 'kind': 'relative', 'output': 'palace', 'baseRef': 'base',
            'mode': 'offset', 'offset': 1, 'palaceSystem': 'eight8'
          })
        ],
        charts: SchoolCharts(),
        dun: SchoolDun(resolver: 'resolver', termMode: 'leveling'),
        foundation: SchoolFoundation(taiYiRef: 'base', wenChangRef: 'base', jiShenRef: 'base', shiJiRef: 'base'),
        threeCalc: SchoolThreeCalc(hostRef: 'base', guestRef: 'base', dingRef: 'base'),
        generals: SchoolGenerals(
          hostMajorRef: 'base',
          hostMinorRef: 'base',
          guestMajorRef: 'base',
          guestMinorRef: 'base',
        ),
        deities: [],
        geJu: [],
      );

      final engine = RuleEngine(school: school, contextVars: {});
      final opp = engine.evaluateRuleById('opp') as PalaceRuleValue;
      expect(opp.palace, '坤');

      final off = engine.evaluateRuleById('off') as PalaceRuleValue;
      expect(off.palace, '艮');
    });

    test('R7 - Predicate (eq, adjacent, coLocatedEqualCount)', () {
      final school = SchoolDocument(
        schemaVersion: 1,
        meta: SchoolMeta(id: 'r7_school', name: 'R7 School', version: 1, source: 'test', owner: 'user'),
        palace: 'taiyi9',
        rules: [
          SchoolRule(id: 'p1', kind: 'walk', output: 'palace', originalJson: {
            'id': 'p1', 'kind': 'walk', 'output': 'palace', 'palaceSystem': 'eight8', 'start': '离', 'direction': 'forward', 'steps': {'int': 0}
          }),
          SchoolRule(id: 'p2', kind: 'walk', output: 'palace', originalJson: {
            'id': 'p2', 'kind': 'walk', 'output': 'palace', 'palaceSystem': 'eight8', 'start': '艮', 'direction': 'forward', 'steps': {'int': 0}
          }),
          SchoolRule(id: 'p3', kind: 'walk', output: 'palace', originalJson: {
            'id': 'p3', 'kind': 'walk', 'output': 'palace', 'palaceSystem': 'eight8', 'start': '离', 'direction': 'forward', 'steps': {'int': 0}
          }),
          SchoolRule(id: 'c1', kind: 'scalar', output: 'scalar', originalJson: {'id': 'c1', 'kind': 'scalar', 'output': 'scalar', 'tree': {'int': 5}}),
          SchoolRule(id: 'c2', kind: 'scalar', output: 'scalar', originalJson: {'id': 'c2', 'kind': 'scalar', 'output': 'scalar', 'tree': {'int': 5}}),
          SchoolRule(id: 'predEq', kind: 'predicate', output: 'predicate', originalJson: {
            'id': 'predEq', 'kind': 'predicate', 'output': 'predicate', 'name': 'EqualPlace',
            'when': {'op': 'eq', 'args': ['p1', 'p3']}
          }),
          SchoolRule(id: 'predAdj', kind: 'predicate', output: 'predicate', originalJson: {
            'id': 'predAdj', 'kind': 'predicate', 'output': 'predicate', 'name': 'AdjacentPlace',
            'when': {'op': 'adjacent', 'args': ['p1', 'p2']}
          }),
          SchoolRule(id: 'predCo', kind: 'predicate', output: 'predicate', originalJson: {
            'id': 'predCo', 'kind': 'predicate', 'output': 'predicate', 'name': 'CoLocatedEqual',
            'when': {'op': 'coLocatedEqualCount', 'args': ['p1', 'p3', 'c1', 'c2']}
          })
        ],
        charts: SchoolCharts(),
        dun: SchoolDun(resolver: 'resolver', termMode: 'leveling'),
        foundation: SchoolFoundation(taiYiRef: 'p1', wenChangRef: 'p1', jiShenRef: 'p1', shiJiRef: 'p1'),
        threeCalc: SchoolThreeCalc(hostRef: 'c1', guestRef: 'c1', dingRef: 'c1'),
        generals: SchoolGenerals(
          hostMajorRef: 'p1',
          hostMinorRef: 'p1',
          guestMajorRef: 'p1',
          guestMinorRef: 'p1',
        ),
        deities: [],
        geJu: [],
      );

      final engine = RuleEngine(school: school, contextVars: {});

      final eq = engine.evaluateRuleById('predEq') as PredicateRuleValue;
      expect(eq.matched, true);
      expect(eq.name, 'EqualPlace');

      final adj = engine.evaluateRuleById('predAdj') as PredicateRuleValue;
      expect(adj.matched, true);

      final co = engine.evaluateRuleById('predCo') as PredicateRuleValue;
      expect(co.matched, true);
    });
  });
}
