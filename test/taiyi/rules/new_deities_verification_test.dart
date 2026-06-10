import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/enums/gong.dart';
import '../test_harness.dart';

void main() {
  setUpAll(() async {
    await TaiYiTestHarness.setup();
  });

  group('New Deities Configurations Verification', () {
    final newDeities = [
      'tian-huang', 'zi-wei', 'she-ti', 'xuan-yuan', 'zhao-yao',
      'tian-fu', 'xian-chi', 'jiang-gong', 'ming-tang', 'yu-tang',
    ];

    test('All 10 new deity JSON configs can be parsed correctly', () async {
      final bundle = TaiYiTestHarness.createMockBundle();
      for (final id in newDeities) {
        final path = 'assets/deities/$id.json';
        final jsonStr = await bundle.loadString(path);
        final json = jsonDecode(jsonStr);
        final deity = DeityDefinition.fromJson(json);
        expect(deity.id, isNotNull);
        expect(deity.name, isNotNull);
        expect(deity.algorithm.templateId, isNotNull);
      }
    });

    test('JingMirror 2026 places all 10 new deities in correct palaces', () async {
      final assembly = await TaiYiTestHarness.createAssembly();
      final useCase = assembly.calculatePanUseCase;

      final pan = await useCase.execute(
        dateTime: DateTime(2026, 5, 1),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      final expectations = {
        '天皇': EnumTaiYiGong.Dui,
        '紫微': EnumTaiYiGong.Gen,
        '摄提': EnumTaiYiGong.Kun,
        '轩辕': EnumTaiYiGong.Kun,
        '招摇': EnumTaiYiGong.Dui,
        '天符': EnumTaiYiGong.Gen,
        '咸池': EnumTaiYiGong.Dui,
        '绛宫': EnumTaiYiGong.Li,
        '明堂': EnumTaiYiGong.Gen,
        '玉堂': EnumTaiYiGong.Zhen,
      };

      expectations.forEach((deityName, expectedGong) {
        final palace = pan.palaces.firstWhere((p) => p.gong == expectedGong);
        expect(palace.stars, contains(deityName),
            reason: 'Deity $deityName must be placed in $expectedGong');
      });
    });

    test('TongZong 2026 places tianHuang in Zhen (震) due to 240-yr cycle stay-rules override', () async {
      final assembly = await TaiYiTestHarness.createAssembly();
      final useCase = assembly.calculatePanUseCase;

      final pan = await useCase.execute(
        dateTime: DateTime(2026, 5, 1),
        schoolId: 'tongZong',
        chartType: TaiYiChartType.year,
      );

      // Under TongZong, tianHuang is placed in Zhen (震)
      final zhenPalace = pan.palaces.firstWhere((p) => p.gong == EnumTaiYiGong.Zhen);
      expect(zhenPalace.stars, contains('天皇'),
          reason: 'Under tongZong in 2026, 天皇 must be placed in Zhen (震)宫');

      // Under JingMirror, tianHuang is in Dui (兑)
      final duiPalace = pan.palaces.firstWhere((p) => p.gong == EnumTaiYiGong.Dui);
      expect(duiPalace.stars, isNot(contains('天皇')),
          reason: 'Under tongZong, 天皇 should not be in Dui');
    });
  });
}
