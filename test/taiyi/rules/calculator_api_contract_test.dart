import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/taiyi_pan_calculator.dart';

void main() {
  group('calculator API contract gate', () {
    test('verify synchronous compatibility layer decision', () {
      // Decision: Retain synchronous compatibility layer.
      // Reasons:
      // 1. Existing caller tests (e.g., test/taiyi_pan_calculator_smoke.dart) call calculate synchronously.
      // 2. We can load official schools synchronously using pre-compiled string constants or synchronous asset decoding.
      // 3. User schools from SQLite/SharedPreferences can be read from a synchronous in-memory cache pre-loaded at startup.
      // 4. This avoids cascading Future/async/await changes to all downstream UI and calculation logic.

      final calculator = const TaiYiPanCalculator();
      final result = calculator.calculate(
        dateTime: DateTime(2026, 6, 8, 12, 0, 0),
        schoolId: 'jingMirror',
      );
      expect(result, isNotNull);
    });
  });
}
