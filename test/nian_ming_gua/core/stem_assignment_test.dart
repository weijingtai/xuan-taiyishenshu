import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/nian_ming_gua/core/stem_assignment.dart';

void main() {
  group('stem_assignment algorithm tests', () {
    test('Dry run assignStems for 乾 (startIndex = 0, repeatAtYao4 = false)', () {
      expect(
        assignStems(0, false),
        ['甲', '戊', '壬', '丙', '庚', '甲'],
      );
    });

    test('Dry run assignStems for 坤 (startIndex = 4, repeatAtYao4 = false)', () {
      expect(
        assignStems(4, false),
        ['庚', '甲', '戊', '壬', '丙', '庚'],
      );
    });

    test('Dry run assignStems for 否 (startIndex = 1, repeatAtYao4 = true)', () {
      expect(
        assignStems(1, true),
        ['戊', '壬', '丙', '壬', '戊', '甲'],
      );
    });

    test('Dry run assignStems for 泰 (startIndex = 4, repeatAtYao4 = true)', () {
      expect(
        assignStems(4, true),
        ['庚', '丙', '壬', '丙', '庚', '甲'],
      );
    });

    test('Out of bounds startIndex behavior', () {
      // 5 % 5 == 0, should behave like startIndex = 0
      expect(
        assignStems(5, false),
        ['甲', '戊', '壬', '丙', '庚', '甲'],
      );
      // 9 % 5 == 4, and 9 >= 3, dir = -1, starts at index 4 (same as 4, true)
      expect(
        assignStems(9, true),
        ['庚', '丙', '壬', '丙', '庚', '甲'],
      );

      // -1 % 5 in Dart's % operator behaves as -1 % 5 = 4
      // cursor starts at -1:
      // i=0: -1%5 = 4 -> 庚
      // i=1: 0%5 = 0 -> 甲
      // i=2: 1%5 = 1 -> 戊
      // i=3: 2%5 = 2 -> 壬
      // i=4: 3%5 = 3 -> 丙
      // i=5: 4%5 = 4 -> 庚
      expect(
        assignStems(-1, false),
        ['庚', '甲', '戊', '壬', '丙', '庚'],
      );
    });
  });
}
