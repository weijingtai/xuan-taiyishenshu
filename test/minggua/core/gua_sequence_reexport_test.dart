import 'package:flutter_test/flutter_test.dart';
import 'package:xuan_gua_core/xuan_gua_core.dart';
import 'package:taiyishenshu/minggua/core/gua_sequence.dart';

void main() {
  group('Gua sequence re-export compatibility tests', () {
    test('Verify kTaiYiGuaSequence is re-exported correctly', () {
      expect(kTaiYiGuaSequence.length, 64);
      expect(kTaiYiGuaSequence[0], Enum64Gua.qian_wei_tian);
      expect(kTaiYiGuaSequence[1], Enum64Gua.kun_wei_di);
      expect(kTaiYiGuaSequence[10], Enum64Gua.di_tian_tai);
      expect(kTaiYiGuaSequence[11], Enum64Gua.tian_di_pi);
      expect(kTaiYiGuaSequence[63], Enum64Gua.huo_shui_wei_ji);
    });

    test('Verify Enum64Gua yaoBoolList via extension', () {
      expect(Enum64Gua.qian_wei_tian.yaoBoolList,
          [true, true, true, true, true, true]);
    });

    test('Verify findGuaNameByYao is re-exported correctly', () {
      expect(findGuaNameByYao([true, true, true, true, true, true]), '乾');
    });

    test('Verify yangYaoCount is re-exported correctly', () {
      expect(yangYaoCount('乾'), 6);
      expect(yangYaoCount('否'), 3);
    });

    test('Verify ceCount is re-exported correctly', () {
      expect(ceCount('乾'), 216);
      expect(ceCount('否'), 180);
    });
  });
}
