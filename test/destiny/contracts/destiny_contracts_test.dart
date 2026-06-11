import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

void main() {
  group('ACT-007: Destiny Contracts', () {
    test('DestinyConfigContract fromJson roundtrip', () {
      final json = {
        'id': 'tongZong',
        'name': '统宗命法',
        'epoch': {
          'ancientBase': 10155219,
          'epochYear': 1303,
          'correction': 1,
        },
        'palaceMappings': [
          {
            'index': 1,
            'name': '命宫',
            'mappingRule': 'birthBranchPalace',
          },
        ],
        'source': 'official',
        'rules': <String, dynamic>{},
      };
      final c = DestinyConfigContract.fromJson(json);
      expect(c.id, 'tongZong');
      expect(c.palaceMappings.length, 1);
      expect(c.palaceMappings[0].name, '命宫');
    });

    test('DestinyResultContract fromJson', () {
      final json = {
        'accumulatedHour': 99999,
        'juNumber': 36,
        'dunType': 'yang',
        'taiYiPalace': '乾',
        'wenChangPalace': '离',
        'shiJiPalace': '坤',
        'hostCount': 5,
        'guestCount': 3,
        'twelvePalaces': [
          {
            'index': 1,
            'name': '命宫',
            'deities': ['太乙'],
            'interpretation': null,
          },
        ],
      };
      final r = DestinyResultContract.fromJson(json);
      expect(r.juNumber, 36);
      expect(r.twelvePalaces[0].deities, ['太乙']);
    });

    test('DestinyPalaceMappingContract default', () {
      final m = DestinyPalaceMappingContract(
        index: 1,
        name: '命宫',
        mappingRule: 'birthBranchPalace',
      );
      expect(m.index, 1);
      expect(m.mappingRule, 'birthBranchPalace');
    });
  });
}
