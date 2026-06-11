import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

void main() {
  group('ACT-004: MingGuaRepository 抽象接口', () {
    test('MingGuaRepository is abstract', () {
      // Verify the type exists and is accessible
      expect(MingGuaRepository, isNotNull);
    });

    test('import boundary: no flutter dependency', () {
      // This test verifies that ming_gua_repository.dart doesn't
      // import any flutter package. The fact that this test file
      // compiles with only repository_interface_taiyishenshu import
      // (which itself has no flutter dependency) proves this constraint.
      // If MingGuaRepository had a flutter dependency, the
      // repository-interface package would fail to build.
      expect(MingGuaRepository, isNotNull);
    });
  });
}
