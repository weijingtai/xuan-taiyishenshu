import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/destiny/core/destiny_engine.dart';
import 'package:taiyishenshu/destiny/core/twelve_palaces.dart';

void main() {
  group('ACT-009: 太乙人道命法核心引擎', () {
    test('DestinyEngine 返回有效结果', () {
      final engine = DestinyEngine();
      final config = DestinyConfigContract(
        id: 'test',
        name: '测试',
        epoch: SchoolEpochConfigContract(
          ancientBase: 10155219,
          epochYear: 1303,
          correction: 1,
        ),
        palaceMappings: List.generate(
          12,
          (i) => DestinyPalaceMappingContract(
            index: i + 1,
            name: kTwelvePalaceNames[i],
            mappingRule: i == 0 ? 'birthBranchPalace' : 'sequentialNext($i)',
          ),
        ),
      );
      final result = engine.calculate(
        birthTime: DateTime(1990, 6, 15, 14, 30),
        config: config,
      );
      expect(result.juNumber, greaterThan(0));
      expect(result.juNumber, lessThanOrEqualTo(72));
      expect(result.twelvePalaces.length, 12);
    });

    test('DestinyEngine dunType 冬至后=阳', () {
      final engine = DestinyEngine();
      final config = DestinyConfigContract(
        id: 'test',
        name: '测试',
        epoch: SchoolEpochConfigContract(
          ancientBase: 10155219,
          epochYear: 1303,
          correction: 1,
        ),
        palaceMappings: [],
      );
      final result = engine.calculate(
        birthTime: DateTime(2026, 1, 15, 10, 0),
        config: config,
      );
      expect(result.dunType, 'yang');
    });

    test('DestinyEngine 十二宫结果有效', () {
      final engine = DestinyEngine();
      final config = DestinyConfigContract(
        id: 'test',
        name: '测试',
        epoch: SchoolEpochConfigContract(
          ancientBase: 10155219,
          epochYear: 1303,
          correction: 1,
        ),
        palaceMappings: List.generate(
          12,
          (i) => DestinyPalaceMappingContract(
            index: i + 1,
            name: kTwelvePalaceNames[i],
            mappingRule: i == 0 ? 'birthBranchPalace' : 'sequentialNext($i)',
          ),
        ),
      );
      final result = engine.calculate(
        birthTime: DateTime(1985, 3, 20, 8, 0),
        config: config,
      );
      expect(result.twelvePalaces[0].name, '命宫');
    });
  });
}
