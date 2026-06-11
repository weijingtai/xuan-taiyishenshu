import 'package:flutter_test/flutter_test.dart';
import 'package:xuan_gua_core/xuan_gua_core.dart';
import 'package:taiyishenshu/gua_core/gua_sequence.dart';

void main() {
  group('ACT-001: 统宗六十四卦序常量数据', () {
    test('卦序长度=64', () {
      expect(kTaiYiGuaSequence.length, 64);
    });

    test('第1位=乾', () {
      expect(kTaiYiGuaSequence[0], Enum64Gua.qian_wei_tian);
      expect(kTaiYiGuaSequence[0].name, '乾');
    });

    test('第2位=坤', () {
      expect(kTaiYiGuaSequence[1], Enum64Gua.kun_wei_di);
    });

    test('第43位(index42)=姤(非夬)', () {
      expect(kTaiYiGuaSequence[42], Enum64Gua.tian_feng_gou);
    });

    test('第64位=未济', () {
      expect(kTaiYiGuaSequence[63], Enum64Gua.huo_shui_wei_ji);
    });

    test('第44位(index43)=夬(统宗:43姤44夬;通行:43夬44姤)', () {
      expect(kTaiYiGuaSequence[43], Enum64Gua.ze_tian_guai);
    });

    test('无重复卦', () {
      expect(kTaiYiGuaSequence.toSet().length, 64);
    });

    test('乾卦六爻全阳 via Enum64Gua', () {
      final yao = Enum64Gua.qian_wei_tian.yaoBoolList;
      expect(yao, [true, true, true, true, true, true]);
    });

    test('坤卦六爻全阴 via Enum64Gua', () {
      final yao = Enum64Gua.kun_wei_di.yaoBoolList;
      expect(yao, [false, false, false, false, false, false]);
    });

    test('findGuaNameByYao 乾', () {
      expect(findGuaNameByYao([true, true, true, true, true, true]), '乾');
    });

    test('findGuaNameByYao 翻转初爻=姤(天风姤:巽下乾上)', () {
      expect(findGuaNameByYao([false, true, true, true, true, true]), '姤');
    });

    test('findGuaNameByYao 无效返null', () {
      expect(findGuaNameByYao([true, true, true, true, true, true, true]), null);
    });
  });
}
