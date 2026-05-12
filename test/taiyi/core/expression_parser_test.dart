import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/expression_parser.dart';

void main() {
  group('ExpressionParser', () {
    test('加法', () {
      expect(ExpressionParser.evaluate('1 + 2', {}), 3);
    });
    test('减法', () {
      expect(ExpressionParser.evaluate('5 - 3', {}), 2);
    });
    test('乘法', () {
      expect(ExpressionParser.evaluate('3 * 4', {}), 12);
    });
    test('整除 ~/', () {
      expect(ExpressionParser.evaluate('10 ~/ 3', {}), 3);
    });
    test('取模 %', () {
      expect(ExpressionParser.evaluate('10 % 3', {}), 1);
    });
    test('混合运算', () {
      expect(ExpressionParser.evaluate('2 + 3 * 4', {}), 14);
    });
    test('变量替换', () {
      expect(
        ExpressionParser.evaluate('ji + correction', {'ji': 100, 'correction': 250}),
        350,
      );
    });
    test('阳九公式: ji % 4560 ~/ 456', () {
      expect(ExpressionParser.evaluate('ji % 4560 ~/ 456', {'ji': 13331}), 9);
    });
    test('负号运算', () {
      expect(ExpressionParser.evaluate('10 - 20', {}), -10);
    });
  });
}
