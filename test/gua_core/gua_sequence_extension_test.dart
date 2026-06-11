import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/gua_core/gua_sequence.dart';

void main() {
  group('gua_core extension helper tests', () {
    test('yangYaoCount should return correct count of yang yao', () {
      // 乾: 6 yang yao
      expect(yangYaoCount('乾'), 6);
      // 坤: 0 yang yao
      expect(yangYaoCount('坤'), 0);
      // 否 (乾下坤上, [true, true, true, false, false, false]): 3 yang yao
      expect(yangYaoCount('否'), 3);
      // 泰 (坤下乾上, [false, false, false, true, true, true]): 3 yang yao
      expect(yangYaoCount('泰'), 3);
    });

    test('ceCount should return correct count of ce (Yang*36 + Yin*24)', () {
      // 乾: 6 yang yao, 0 yin yao -> 6 * 36 + 0 * 24 = 216
      expect(ceCount('乾'), 216);
      // 坤: 0 yang yao, 6 yin yao -> 0 * 36 + 6 * 24 = 144
      expect(ceCount('坤'), 144);
      // 否: 3 yang yao, 3 yin yao -> 3 * 36 + 3 * 24 = 180
      expect(ceCount('否'), 180);
      // 泰: 3 yang yao, 3 yin yao -> 3 * 36 + 3 * 24 = 180
      expect(ceCount('泰'), 180);
    });

    test('unknown gua name should throw ArgumentError', () {
      expect(() => yangYaoCount('UnknownGua'), throwsArgumentError);
      expect(() => ceCount('UnknownGua'), throwsArgumentError);
    });
  });
}
