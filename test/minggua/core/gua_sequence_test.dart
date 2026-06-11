import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/minggua/core/gua_sequence.dart';

void main() {
  group('ACT-001: 统宗六十四卦序常量数据', () {
    test('卦序长度=64', () {
      expect(kTaiYiGuaSequence.length, 64);
    });

    test('第1位=乾', () {
      expect(kTaiYiGuaSequence[0], '乾');
    });

    test('第2位=坤', () {
      expect(kTaiYiGuaSequence[1], '坤');
    });

    test('第43位(index42)=姤(非夬)', () {
      expect(kTaiYiGuaSequence[42], '姤');
    });

    test('第64位=未济', () {
      expect(kTaiYiGuaSequence[63], '未济');
    });

    test('第44位(index43)=夬(统宗:43姤44夬;通行:43夬44姤)', () {
      expect(kTaiYiGuaSequence[43], '夬');
    });

    test('无重复卦名', () {
      expect(kTaiYiGuaSequence.toSet().length, 64);
    });

    test('kGuaYaoMap有64条', () {
      expect(kGuaYaoMap.length, 64);
    });

    test('乾卦六爻全阳', () {
      expect(kGuaYaoMap['乾'], [true, true, true, true, true, true]);
    });

    test('坤卦六爻全阴', () {
      expect(kGuaYaoMap['坤'], [false, false, false, false, false, false]);
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
