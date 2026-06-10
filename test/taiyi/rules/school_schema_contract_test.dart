import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/rules/school_document.dart';

void main() {
  group('School Schema Validation Contract', () {
    final validMeta = {
      'id': 'testSchool',
      'name': '测试流派',
      'version': 1,
      'source': 'manual',
      'owner': 'user'
    };

    final minimalValidSchool = {
      'schemaVersion': 1,
      'meta': validMeta,
      'palace': 'taiyi9',
      'rules': [
        {
          'id': 'rule1',
          'kind': 'scalar',
          'output': 'scalar',
          'tree': {'int': 100}
        }
      ],
      'charts': {
        'year': {'enabled': true, 'ruJuRef': 'rule1', 'appliesTo': ['year']}
      },
      'dun': {
        'resolver': 'metaphysicsCoreJieQi',
        'termMode': 'leveling'
      },
      'foundation': {
        'taiYiRef': 'rule1', // Wait, expected output for taiYiRef is palace, but let's make a palace rule to be precise
        'wenChangRef': 'rule1',
        'jiShenRef': 'rule1',
        'shiJiRef': 'rule1'
      },
      'threeCalc': {
        'hostRef': 'rule1',
        'guestRef': 'rule1',
        'dingRef': 'rule1'
      },
      'generals': {
        'hostMajorRef': 'rule1',
        'hostMinorRef': 'rule1',
        'guestMajorRef': 'rule1',
        'guestMinorRef': 'rule1'
      },
      'deities': [],
      'geJu': []
    };

    test('validates minimal valid school without errors', () {
      // Fix types to match expected outputs to make it fully valid
      final school = Map<String, dynamic>.from(minimalValidSchool);
      school['rules'] = [
        {'id': 'rule_acc', 'kind': 'scalar', 'output': 'scalar', 'tree': {'int': 100}},
        {'id': 'rule_pal', 'kind': 'walk', 'output': 'palace', 'steps': {'int': 1}, 'palaceSystem': 'eight8', 'start': '乾', 'direction': 'forward'},
        {'id': 'rule_deity', 'kind': 'walk', 'output': 'deity', 'steps': {'int': 1}, 'palaceSystem': 'sixteenGods', 'start': '武德', 'direction': 'forward'},
      ];
      school['charts'] = {
        'year': {'enabled': true, 'ruJuRef': 'rule_acc', 'appliesTo': ['year']}
      };
      school['foundation'] = {
        'taiYiRef': 'rule_pal',
        'wenChangRef': 'rule_deity',
        'jiShenRef': 'rule_deity',
        'shiJiRef': 'rule_deity'
      };
      school['threeCalc'] = {
        'hostRef': 'rule_acc',
        'guestRef': 'rule_acc',
        'dingRef': 'rule_acc'
      };
      school['generals'] = {
        'hostMajorRef': 'rule_pal',
        'hostMinorRef': 'rule_pal',
        'guestMajorRef': 'rule_pal',
        'guestMinorRef': 'rule_pal'
      };

      final errors = validateSchoolJson(school);
      expect(errors.isEmpty, true, reason: 'Expected no validation errors, got: $errors');
    });

    test('rejects missing schemaVersion', () {
      final school = Map<String, dynamic>.from(minimalValidSchool);
      school.remove('schemaVersion');
      final errors = validateSchoolJson(school);
      expect(errors.any((e) => e.fieldPath == 'schemaVersion' && e.message.contains('required')), true);
    });

    test('rejects unknown schemaVersion', () {
      final school = Map<String, dynamic>.from(minimalValidSchool)..['schemaVersion'] = 999;
      final errors = validateSchoolJson(school);
      expect(errors.any((e) => e.fieldPath == 'schemaVersion' && e.message.contains('unknown')), true);
    });

    test('rejects unknown kind', () {
      final school = Map<String, dynamic>.from(minimalValidSchool);
      school['rules'] = [
        {'id': 'r1', 'kind': 'unknownKind', 'output': 'scalar', 'tree': {'int': 10}}
      ];
      final errors = validateSchoolJson(school);
      expect(errors.any((e) => e.fieldPath == 'rules[0].kind' && e.message.contains('unknown kind')), true);
    });

    test('rejects duplicate rule id', () {
      final school = Map<String, dynamic>.from(minimalValidSchool);
      school['rules'] = [
        {'id': 'dup', 'kind': 'scalar', 'output': 'scalar', 'tree': {'int': 1}},
        {'id': 'dup', 'kind': 'scalar', 'output': 'scalar', 'tree': {'int': 2}}
      ];
      final errors = validateSchoolJson(school);
      expect(errors.any((e) => e.fieldPath == 'rules[1].id' && e.message.contains('duplicate')), true);
    });

    test('rejects invalid reference', () {
      final school = Map<String, dynamic>.from(minimalValidSchool);
      school['charts'] = {
        'year': {'enabled': true, 'ruJuRef': 'non_existent', 'appliesTo': ['year']}
      };
      final errors = validateSchoolJson(school);
      expect(errors.any((e) => e.fieldPath == 'rules.non_existent' || e.message.contains('referenced rule not found')), true);
    });

    test('rejects wrong output type', () {
      final school = Map<String, dynamic>.from(minimalValidSchool);
      school['rules'] = [
        {'id': 'rule1', 'kind': 'scalar', 'output': 'scalar', 'tree': {'int': 100}}
      ];
      // generals.hostMajorRef expects palace, but we point to rule1 which outputs scalar
      school['generals'] = {
        'hostMajorRef': 'rule1',
        'hostMinorRef': 'rule1',
        'guestMajorRef': 'rule1',
        'guestMinorRef': 'rule1'
      };
      final errors = validateSchoolJson(school);
      expect(errors.any((e) => e.fieldPath == 'generals.hostMajorRef' && e.message.contains('type mismatch')), true);
    });

    test('rejects record output in rules list', () {
      final school = Map<String, dynamic>.from(minimalValidSchool);
      school['rules'] = [
        {'id': 'r1', 'kind': 'scalar', 'output': 'record', 'tree': {'int': 1}}
      ];
      final errors = validateSchoolJson(school);
      expect(errors.any((e) => e.message.contains('record is not allowed')), true);
    });
  });
}
