import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/minggua/core/gua_sequence.dart';
import 'package:taiyishenshu/minggua/core/ming_gua_engine.dart';

void main() {
  group('ACT-002: 命卦核心计算引擎', () {
    test('2026年统宗命卦: accYear=10155943, remainder=10155943%64, guaIndex',
        () {
      final e = MingGuaEngine();
      final r = e.calculate(year: 2026);
      expect(r.accumulatedYear, 10155943);
      expect(r.remainder, 10155943 % 64 == 0 ? 64 : 10155943 % 64);
      expect(r.guaIndex, 10155943 % 64 == 0 ? 64 : 10155943 % 64);
    });

    test('余数=0时guaIndex=64=未济', () {
      final e = MingGuaEngine();
      // Find a year where (year + epochBase) % 64 == 0.
      // epochBase = 10153917; we need year such that (year + 10153917) % 64 == 0.
      // 10153917 % 64 == ?  -> solve: 64 - (10153917 % 64) gives the offset.
      final testYear = 64 - 10153917 % 64;
      final acc = testYear + 10153917;
      expect(acc % 64, 0);
      final r = e.calculate(year: testYear);
      expect(r.guaIndex, 64);
      expect(r.benGuaName, '未济');
    });

    test('阳辰从初爻向上数', () {
      final e = MingGuaEngine();
      final r = e.calculate(year: 2026);
      if (r.isYangChen) {
        expect(
          r.dongYaoPosition,
          ((r.remainder == 0 ? 64 : r.remainder) - 1) % 6 + 1,
        );
      }
    });

    test('阴辰从上爻向下数', () {
      final e = MingGuaEngine();
      final r = e.calculate(year: 2027);
      if (!r.isYangChen) {
        final yaoNum = r.remainder == 0 ? 64 : r.remainder;
        expect(r.dongYaoPosition, 6 - ((yaoNum - 1) % 6));
      }
    });

    test('变卦仅动爻位翻转', () {
      final e = MingGuaEngine();
      final r = e.calculate(year: 2026);
      for (int i = 0; i < 6; i++) {
        if (i == r.dongYaoPosition - 1) {
          expect(r.bianGuaYao[i], !r.benGuaYao[i]);
        } else {
          expect(r.bianGuaYao[i], r.benGuaYao[i]);
        }
      }
    });

    test('变卦名有效(能在卦序中找到)', () {
      final e = MingGuaEngine();
      final r = e.calculate(year: 2026);
      expect(
        kTaiYiGuaSequence.contains(r.bianGuaName) ||
            findGuaNameByYao(r.bianGuaYao) != null,
        true,
      );
    });

    test('自定义卦序生效', () {
      final custom = List<String>.from(kTaiYiGuaSequence);
      custom[0] = '遁';
      final e = MingGuaEngine(guaSequence: custom, epochBase: 0);
      final r = e.calculate(year: 1);
      expect(r.benGuaName, '遁');
    });
  });
}
