import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_engine.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_spec.dart';
import 'package:taiyishenshu/taiyi/core/calculation_context.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/enums/gong.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';

void main() {
  late DeityAlgorithmEngine engine;

  setUp(() {
    engine = DeityAlgorithmEngine();
  });

  group('fixedPosition', () {
    test('四神青龙定在艮宫', () {
      final deity = DeityDefinition(
        id: 'siShen_qingLong',
        name: '青龙',
        layer: EnumDeityLayer.shenPan,
        algorithm: const DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.fixedPosition,
          params: {'gong': '艮'},
        ),
      );
      final ctx = CalculationContext(
        ji: 10155219,
        year: 2024,
        juNumber: 1,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
      );
      final result = engine.execute(deity, ctx);
      expect(result.gong, EnumTaiYiGong.Gen);
    });
  });

  group('steppedCycle — 阳九三层取模', () {
    test('金镜 阳九 724年 开元十二年', () {
      final deity = DeityDefinition(
        id: 'yangJiu',
        name: '阳九',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.steppedCycle,
          params: SteppedCycleParams(
            correction: 0,
            steps: const [
              CycleStep(cycle: 4560, step: 456, label: '阳九'),
              CycleStep(cycle: 456, step: 38, label: '邦'),
            ],
            palaceSystem: PalaceSystem.sixteenZhengJian,
            direction: WalkDirection.forward,
            startPalace: '寅',
          ).toJson(),
        ),
      );
      final ctx = CalculationContext(
        ji: 13331,
        year: 724,
        juNumber: 1,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
      );
      final result = engine.execute(deity, ctx);
      // 13331%4560=4211, 4211~/456=9 → 第10阳九
      expect(result.steps[0].quotient, 9);
      expect(result.steps[0].remainder, 107);
      // 107~/38=2 → 第3邦, 107%38=31 → 入邦第31年
      expect(result.steps[1].quotient, 2);
      expect(result.steps[1].remainder, 31);
      // 寅顺行2步 → 辰 → 震宫
      expect(result.gong, EnumTaiYiGong.Zhen);
    });
  });

  group('steppedCycle — 单层', () {
    test('君基 360/30 步宫', () {
      final deity = DeityDefinition(
        id: 'junJi',
        name: '君基',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.steppedCycle,
          params: SteppedCycleParams(
            correction: 250,
            steps: const [
              CycleStep(cycle: 360, step: 30, label: '邦'),
            ],
            palaceSystem: PalaceSystem.sixteenZhengJian,
            direction: WalkDirection.forward,
            startPalace: '戌',
          ).toJson(),
        ),
      );
      // 统宗 2024年: ji = 10155219 + (2024-1303) = 10155940
      // 10155940 + 250 = 10156190
      // 10156190 % 360 = 230, 230 ~/ 30 = 7 → 第8邦
      final ctx = CalculationContext(
        ji: 10155940,
        year: 2024,
        juNumber: 1,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
      );
      final result = engine.execute(deity, ctx);
      expect(result.steps[0].quotient, 7);
      expect(result.steps[0].remainder, 20);
    });
  });

  group('relativeOffset', () {
    test('飞符 = 太乙 + 2', () {
      final deity = DeityDefinition(
        id: 'feiFu',
        name: '飞符',
        layer: EnumDeityLayer.tianPan,
        algorithm: const DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.relativeOffset,
          params: {'sourceDeityId': 'taiYi', 'offset': 2},
        ),
      );
      // 太乙在乾宫
      final ctx = CalculationContext(
        ji: 10155219,
        year: 2024,
        juNumber: 1,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
        computedDeities: {
          'taiYi': const DeityPlacementResult(gong: EnumTaiYiGong.Qian),
        },
      );
      final result = engine.execute(deity, ctx);
      // 乾(0) + 2 = 艮(2)
      expect(result.gong, EnumTaiYiGong.Gen);
    });
  });

  group('branchWalker', () {
    test('太岁 60周期', () {
      final deity = DeityDefinition(
        id: 'taiSui',
        name: '太岁',
        layer: EnumDeityLayer.shenPan,
        algorithm: const DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.branchWalker,
          params: {
            'cycle': 60,
            'startBranch': '子',
            'branches': [
              '子', '丑', '寅', '卯', '辰', '巳',
              '午', '未', '申', '酉', '戌', '亥',
            ],
          },
        ),
      );
      // ji=4: 4%60=4, 4%12=4 → index 4 = 辰 → 震
      final ctx = CalculationContext(
        ji: 4,
        year: 2024,
        juNumber: 1,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
      );
      final result = engine.execute(deity, ctx);
      expect(result.gong, EnumTaiYiGong.Zhen); // 辰 → 震
    });
  });

  group('cumulativeWalk', () {
    test('太乙行宫 (金镜公式)', () {
      final deity = DeityDefinition(
        id: 'taiYi_walk',
        name: '太乙行宫',
        layer: EnumDeityLayer.tianPan,
        algorithm: const DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.cumulativeWalk,
          params: {
            'cycle': 72,
            'step': 3,
            'startPalace': '乾',
          },
        ),
      );
      // ji=1: 1%72=1, 1~/3=0, 乾+0=乾
      final ctx = CalculationContext(
        ji: 1,
        year: 2024,
        juNumber: 1,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
      );
      final result = engine.execute(deity, ctx);
      expect(result.gong, EnumTaiYiGong.Qian);
    });
  });

  group('customFormula', () {
    test('简单表达式', () {
      final deity = DeityDefinition(
        id: 'custom_test',
        name: '自定义',
        layer: EnumDeityLayer.tianPan,
        algorithm: const DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.customFormula,
          params: {
            'formula': 'ji % 72 ~/ 3 + 1',
          },
        ),
      );
      final ctx = CalculationContext(
        ji: 1,
        year: 2024,
        juNumber: 1,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
      );
      final result = engine.execute(deity, ctx);
      // 1%72=1, 1~/3=0, 0+1=1 → 乾
      expect(result.gong, EnumTaiYiGong.Qian);
    });
  });
}
