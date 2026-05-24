import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/chart_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_override.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';

void main() {
  group('ChartConfig', () {
    test('default values', () {
      const config = ChartConfig();
      expect(config.dayOffset, 0);
      expect(config.hourOffset, 0);
      expect(config.zhangSui, 0);
      expect(config.zhangYue, 0);
      expect(config.hostGuestBase, 'default');
    });

    test('JSON roundtrip', () {
      const config = ChartConfig(
        dayOffset: 1,
        hourOffset: 2,
        zhangSui: 3,
        zhangYue: 4,
        hostGuestBase: 'custom',
      );
      final json = config.toJson();
      final restored = ChartConfig.fromJson(json);
      expect(restored.dayOffset, 1);
      expect(restored.hourOffset, 2);
      expect(restored.zhangSui, 3);
      expect(restored.hostGuestBase, 'custom');
    });
  });

  group('DeityOverride', () {
    test('default values', () {
      const ov = DeityOverride();
      expect(ov.active, true);
      expect(ov.correction, 0);
      expect(ov.params, isEmpty);
      expect(ov.algorithm, isNull);
    });

    test('JSON roundtrip', () {
      const ov = DeityOverride(
        active: false,
        correction: 3,
        params: {'key': 'value'},
      );
      final json = ov.toJson();
      final restored = DeityOverride.fromJson(json);
      expect(restored.active, false);
      expect(restored.correction, 3);
      expect(restored.params['key'], 'value');
    });
  });

  group('TaiYiSchool extended fields', () {
    test('new fields have default values', () {
      const school = TaiYiSchool(
        id: 'test',
        name: 'test',
        epoch: SchoolEpochConfig(ancientBase: 0, epochYear: 0),
      );
      expect(school.chartConfigs, isEmpty);
      expect(school.deityConfigs, isEmpty);
      expect(school.privateDeities, isEmpty);
    });

    test('copyWith preserves new fields', () {
      const school = TaiYiSchool(
        id: 'test',
        name: 'test',
        epoch: SchoolEpochConfig(ancientBase: 0, epochYear: 0),
        chartConfigs: {'year': ChartConfig(dayOffset: 1)},
        privateDeities: ['p1'],
      );
      final copied = school.copyWith(name: 'copied');
      expect(copied.name, 'copied');
      expect(copied.chartConfigs['year']!.dayOffset, 1);
      expect(copied.privateDeities, ['p1']);
    });

    test('JSON roundtrip with new fields', () {
      const school = TaiYiSchool(
        id: 'test',
        name: 'test',
        epoch: SchoolEpochConfig(ancientBase: 0, epochYear: 0),
        chartConfigs: {'year': ChartConfig(dayOffset: 5)},
        deityConfigs: {'taiYi': DeityOverride(active: false)},
        privateDeities: ['custom1'],
      );
      final json = school.toJson();
      final restored = TaiYiSchool.fromJson(json);
      expect(restored.chartConfigs['year']!.dayOffset, 5);
      expect(restored.deityConfigs['taiYi']!.active, false);
      expect(restored.privateDeities, ['custom1']);
    });
  });

  group('DeityDefinition extended fields', () {
    test('new fields have default values', () {
      const deity = DeityDefinition(
        id: 'test',
        name: 'test',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.fixedPosition,
        ),
      );
      expect(deity.tier, 'core');
      expect(deity.chartTypes, isEmpty);
    });

    test('copyWith preserves and overrides', () {
      const deity = DeityDefinition(
        id: 'test',
        name: 'test',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.fixedPosition,
        ),
        tier: 'extended',
        chartTypes: ['year', 'month'],
      );
      final copied = deity.copyWith(name: 'copied');
      expect(copied.name, 'copied');
      expect(copied.tier, 'extended');
      expect(copied.chartTypes, ['year', 'month']);
    });

    test('JSON roundtrip with new fields', () {
      const deity = DeityDefinition(
        id: 'test',
        name: 'test',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.fixedPosition,
        ),
        tier: 'shishen',
        chartTypes: ['day'],
      );
      final json = deity.toJson();
      final restored = DeityDefinition.fromJson(json);
      expect(restored.tier, 'shishen');
      expect(restored.chartTypes, ['day']);
    });
  });

  group('SchoolEpochConfig.copyWith', () {
    test('override correction', () {
      const config = SchoolEpochConfig(
        ancientBase: 100,
        epochYear: 200,
        correction: 0,
      );
      final modified = config.copyWith(correction: 5);
      expect(modified.correction, 5);
      expect(modified.ancientBase, 100);
    });
  });
}
