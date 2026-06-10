import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/rules/school_document.dart';

void main() {
  group('School Document validation and DAG Check', () {
    final validMeta = {
      'id': 'mySchool',
      'name': 'My School',
      'version': 1,
      'source': 'manual',
      'owner': 'user'
    };

    test('detects DAG cycle in rules list', () {
      final school = {
        'schemaVersion': 1,
        'meta': validMeta,
        'palace': 'taiyi9',
        'rules': [
          {
            'id': 'ruleA',
            'kind': 'scalar',
            'output': 'scalar',
            'tree': {
              'op': '+',
              'a': {'int': 1},
              'b': {'var': 'ruleB'}
            }
          },
          {
            'id': 'ruleB',
            'kind': 'scalar',
            'output': 'scalar',
            'tree': {
              'op': '+',
              'a': {'int': 2},
              'b': {'var': 'ruleA'}
            }
          }
        ],
        'charts': {
          'year': {'enabled': true, 'ruJuRef': 'ruleA', 'appliesTo': ['year']}
        },
        'dun': {'resolver': 'resolver', 'termMode': 'leveling'},
        'foundation': {
          'taiYiRef': 'ruleA',
          'wenChangRef': 'ruleA',
          'jiShenRef': 'ruleA',
          'shiJiRef': 'ruleA'
        },
        'threeCalc': {
          'hostRef': 'ruleA',
          'guestRef': 'ruleA',
          'dingRef': 'ruleA'
        },
        'generals': {
          'hostMajorRef': 'ruleA',
          'hostMinorRef': 'ruleA',
          'guestMajorRef': 'ruleA',
          'guestMinorRef': 'ruleA'
        },
        'deities': [],
        'geJu': []
      };

      final errors = validateSchoolJson(school);
      expect(errors.any((e) => e.fieldPath == 'rules' && e.message.contains('cycle')), true,
          reason: 'Expected DAG cycle detection error, got: $errors');
    });

    test('error reporting has path level fields and schoolId', () {
      final school = {
        'schemaVersion': 1,
        'meta': {
          'id': 'offbeatSchool',
          'name': 'Offbeat School',
          'version': 1,
          'source': 'manual',
          'owner': 'invalidOwner' // Invalid owner
        },
        'palace': 'taiyi9',
        'rules': [
          {
            'id': 'r1',
            'kind': 'scalar',
            'output': 'scalar',
            'tree': {'op': '/'} // Illegal op
          }
        ],
        'charts': {},
        'dun': {'resolver': 'resolver', 'termMode': 'leveling'},
        'foundation': {
          'taiYiRef': 'r1',
          'wenChangRef': 'r1',
          'jiShenRef': 'r1',
          'shiJiRef': 'r1'
        },
        'threeCalc': {
          'hostRef': 'r1',
          'guestRef': 'r1',
          'dingRef': 'r1'
        },
        'generals': {
          'hostMajorRef': 'r1',
          'hostMinorRef': 'r1',
          'guestMajorRef': 'r1',
          'guestMinorRef': 'r1'
        },
        'deities': [],
        'geJu': []
      };

      final errors = validateSchoolJson(school);
      
      // We expect at least one error from owner, one from illegal op
      expect(errors.isNotEmpty, true);
      
      final ownerError = errors.firstWhere((e) => e.fieldPath == 'meta.owner');
      expect(ownerError.schoolId, 'offbeatSchool');
      expect(ownerError.message.contains('owner must be official or user'), true);
      
      final opError = errors.firstWhere((e) => e.fieldPath == 'rules[0].tree.op');
      expect(opError.schoolId, 'offbeatSchool');
      expect(opError.message.contains('illegal operator'), true);
    });
  });
}
