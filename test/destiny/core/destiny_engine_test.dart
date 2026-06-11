import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/destiny/core/destiny_engine.dart';
import 'package:taiyishenshu/destiny/core/twelve_palaces.dart';

void main() {
  group('ACT-009: 太乙人道命法核心引擎', () {
    test('DestinyEngine 1990-06-15 14:30', () {
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
      
      expect(result.juNumber, 68);
      expect(result.accumulatedHour, 8496525452);
      expect(result.dunType, 'yang');
      expect(result.taiYiPalace, '坎');
      expect(result.hostCount, 17);
      expect(result.guestCount, 8);
      expect(result.wenChangPalace, '乾');
      expect(result.shiJiPalace, '离');
      expect(result.twelvePalaces[0].name, '命宫');
      expect(result.twelvePalaces[0].deities, contains('主大将'));
      expect(result.twelvePalaces[1].name, '相貌');
      expect(result.twelvePalaces[1].deities, contains('太乙'));
      expect(result.twelvePalaces[2].name, '父母');
      expect(result.twelvePalaces[2].deities, contains('君基'));
    });
  });
}
