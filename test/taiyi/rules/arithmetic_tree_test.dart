import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/rules/arithmetic_tree.dart';

void main() {
  group('evalArithmeticTree tests', () {
    test('金镜古法积年 10153917+(Y-751)@2026=10155192', () {
      expect(
        evalArithmeticTree({
          'op': '+',
          'a': {'int': 10153917},
          'b': {
            'op': '-',
            'a': {'var': 'Y'},
            'b': {'int': 751}
          }
        }, {'Y': 2026}),
        10155192,
      );
    });

    test('金镜现行积年 1937281+(Y-724)@2026=1938583', () {
      expect(
        evalArithmeticTree({
          'op': '+',
          'a': {'int': 1937281},
          'b': {
            'op': '-',
            'a': {'var': 'Y'},
            'b': {'int': 724}
          }
        }, {'Y': 2026}),
        1938583,
      );
    });

    test('floor(365.2425*J)@J=10=3652', () {
      expect(
        evalArithmeticTree({
          'floor': {
            'op': '*',
            'a': {'num': 365.2425},
            'b': {'var': 'J'}
          }
        }, {'J': 10}),
        3652,
      );
    });

    test('取模 J%360 @1938583=343', () {
      expect(
        evalArithmeticTree({
          'op': '%',
          'a': {'var': 'J'},
          'b': {'int': 360}
        }, {'J': 1938583}),
        343,
      );
    });

    test('整除 23 ~/ 3 = 7', () {
      expect(
        evalArithmeticTree({
          'op': '~/',
          'a': {'int': 23},
          'b': {'int': 3}
        }, {}),
        7,
      );
    });

    test('未声明变量抛 ArgumentError', () {
      expect(() => evalArithmeticTree({'var': 'Z'}, {'Y': 1}), throwsArgumentError);
    });

    test('未知节点抛 ArgumentError', () {
      expect(() => evalArithmeticTree({'bogus': 1}, {}), throwsArgumentError);
    });

    test('禁用 / 抛 ArgumentError', () {
      expect(
        () => evalArithmeticTree({
          'op': '/',
          'a': {'int': 6},
          'b': {'int': 2}
        }, {}),
        throwsArgumentError,
      );
    });

    test('超过 maxDepth 抛 ArgumentError', () {
      Object n = {'int': 1};
      for (var i = 0; i < 20; i++) {
        n = {'op': '+', 'a': n, 'b': {'int': 1}};
      }
      expect(() => evalArithmeticTree(n, {}, maxDepth: 16), throwsArgumentError);
    });
  });
}
