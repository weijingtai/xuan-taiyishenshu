import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

void main() {
  group('ACT-003: MingGua Contracts', () {
    test('MingGuaConfigContract fromJson roundtrip', () {
      final json = {
        'id': 'tongZong',
        'name': '统宗',
        'epochBase': 10153917,
        'guaSequence': List.generate(64, (i) => '卦$i'),
        'dongYaoRule': 'standard',
        'source': 'official',
      };
      final c = MingGuaConfigContract.fromJson(json);
      expect(c.id, 'tongZong');
      expect(c.epochBase, 10153917);
      expect(c.guaSequence.length, 64);
      expect(c.toJson(), json);
    });

    test('MingGuaResultContract fromJson roundtrip', () {
      final json = {
        'accumulatedYear': 10155943,
        'remainder': 55,
        'guaIndex': 55,
        'benGuaName': '丰',
        'benGuaYao': [true, false, true, false, false, true],
        'dongYaoPosition': 1,
        'isYangChen': true,
        'bianGuaName': '噤嗑',
        'bianGuaYao': [false, false, true, false, false, true],
        'yunIndex': null,
      };
      final r = MingGuaResultContract.fromJson(json);
      expect(r.accumulatedYear, 10155943);
      expect(r.dongYaoPosition, 1);
    });

    test('MingGuaConfigContract default values', () {
      final c = MingGuaConfigContract(
        id: 't',
        name: 't',
        epochBase: 0,
        guaSequence: [],
      );
      expect(c.dongYaoRule, 'standard');
      expect(c.source, 'official');
    });
  });
}
