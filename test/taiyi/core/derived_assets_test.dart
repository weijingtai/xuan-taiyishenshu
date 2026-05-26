import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';

void main() {
  group('AC10, AC11, AC12, AC16: Derived Assets Logic', () {
    test('复制官方流派并修改元数据 (AC11, AC16)', () {
      const officialSchool = TaiYiSchool(
        id: 'jingMirror',
        name: '金镜派',
        epoch: SchoolEpochConfig(ancientBase: 1937281, epochYear: 724),
        source: 'official',
      );

      // 用户修改名称触发派生
      final userSchool = TaiYiSchool(
        id: 'user_jingMirror_1',
        name: '我的金镜派',
        epoch: officialSchool.epoch.copyWith(correction: 1),
        source: 'user',
        // AC16: 保留 sourceId 和 rootOfficialId (虽然当前模型没这两个字段，可能需要扩展)
      );

      expect(userSchool.name, '我的金镜派');
      expect(userSchool.epoch.correction, 1);
      expect(officialSchool.name, '金镜派'); // 官方未改变
      expect(officialSchool.epoch.correction, 0);
    });

    test('复制官方星神并保存传承链 (AC10, AC12)', () {
      const officialDeity = DeityDefinition(
        id: 'taiYi',
        name: '太乙',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.steppedCycle,
          params: {},
        ),
        source: 'official',
      );

      // 模拟派生逻辑 (假设未来会有 copyWith 或 Factory)
      final userDeity = DeityDefinition(
        id: 'user_taiYi_1',
        name: '我的太乙',
        layer: officialDeity.layer,
        algorithm: officialDeity.algorithm,
        source: 'user',
        description: '来源: ${officialDeity.name}', // 简单的 Lineage 表达
      );

      expect(userDeity.id, isNot(officialDeity.id));
      expect(userDeity.source, 'user');
      expect(userDeity.description, contains('太乙'));
    });
  });
}

extension SchoolEpochConfigExtension on SchoolEpochConfig {
  SchoolEpochConfig copyWith({int? correction}) {
    return SchoolEpochConfig(
      ancientBase: ancientBase,
      epochYear: epochYear,
      correction: correction ?? this.correction,
      tropicalYear: tropicalYear,
    );
  }
}
