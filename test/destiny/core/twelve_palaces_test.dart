import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/destiny/core/twelve_palaces.dart';

void main() {
  group('ACT-008: 十二人身宫模型独立测试', () {
    test('kBranchToPalace 映射正确: 寅→艮, 午→离', () {
      expect(kBranchToPalace['寅'], '艮');
      expect(kBranchToPalace['午'], '离');
    });

    test('resolveMappingRule - birthBranchPalace', () {
      expect(
        resolveMappingRule('birthBranchPalace', birthBranch: '寅', context: {}),
        '艮',
      );
    });

    test('resolveMappingRule - sequentialNext', () {
      expect(
        resolveMappingRule('sequentialNext(1)', birthBranch: '子', context: {1: '坎'}),
        '巽',
      );
    });

    test('resolveMappingRule - fixedPalace', () {
      expect(
        resolveMappingRule('fixedPalace(离)', birthBranch: '子', context: {}),
        '离',
      );
    });

    test('TwelvePalaceMapper 星神分配逻辑', () {
      final mappings = [
        DestinyPalaceMappingContract(index: 1, name: '命宫', mappingRule: 'birthBranchPalace'),
        DestinyPalaceMappingContract(index: 2, name: '相貌', mappingRule: 'sequentialNext(1)'),
      ];
      final mapper = TwelvePalaceMapper(mappings);
      
      final slots = mapper.map(
        birthBranch: '寅', // 寅 -> 艮
        deityPlacements: {
          '太乙': '震', // 落入相貌宫 (艮的下一个)
          '文昌': '艮', // 落入命宫
        },
      );

      expect(slots[0].name, '命宫');
      expect(slots[0].palace, '艮');
      expect(slots[0].deities, ['文昌']);

      expect(slots[1].name, '相貌');
      expect(slots[1].palace, '震');
      expect(slots[1].deities, ['太乙']);
    });
  });
}
