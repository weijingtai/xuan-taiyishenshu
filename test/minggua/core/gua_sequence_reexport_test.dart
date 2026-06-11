import 'package:flutter_test/flutter_test.dart';
// Import from the re-exporting file (minggua/core/gua_sequence.dart)
import 'package:taiyishenshu/minggua/core/gua_sequence.dart';

void main() {
  group('Gua sequence re-export compatibility tests', () {
    test('Verify kTaiYiGuaSequence is re-exported correctly', () {
      expect(kTaiYiGuaSequence.length, 64);
      expect(kTaiYiGuaSequence[0], '乾');
      expect(kTaiYiGuaSequence[1], '坤');
      expect(kTaiYiGuaSequence[10], '泰');
      expect(kTaiYiGuaSequence[11], '否');
      expect(kTaiYiGuaSequence[63], '未济');
    });

    test('Verify kGuaYaoMap is re-exported correctly', () {
      expect(kGuaYaoMap.containsKey('乾'), true);
      expect(kGuaYaoMap['乾'], [true, true, true, true, true, true]);
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
