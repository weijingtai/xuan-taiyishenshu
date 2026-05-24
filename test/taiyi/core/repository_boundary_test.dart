import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/data/official_json_repository.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_spec.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';

void main() {
  group('AC2: OfficialJsonSchoolRepository Boundary', () {
    final repo = OfficialJsonSchoolRepository(schoolIds: [], deityIds: []);

    test('saveSchool should throw UnsupportedError', () {
      expect(
        () => repo.saveSchool(const TaiYiSchool(
          id: 'test',
          name: 'test',
          epoch: SchoolEpochConfig(ancientBase: 0, epochYear: 0),
        )),
        throwsUnsupportedError,
      );
    });

    test('saveDeity should throw UnsupportedError', () {
      expect(
        () => repo.saveDeity(const DeityDefinition(
          id: 'test',
          name: 'test',
          layer: EnumDeityLayer.tianPan,
          algorithm: DeityAlgorithmSpec(templateId: AlgorithmTemplateId.fixedPosition, params: {}),
        )),
        throwsUnsupportedError,
      );
    });

    test('deleteSchool should throw UnsupportedError', () {
      expect(
        () => repo.deleteSchool('test'),
        throwsUnsupportedError,
      );
    });
  });

  group('AC3 & AC4: Integrated Repository Placeholders', () {
    // 这些测试目前会失败，因为类可能尚未实现或集成。
    // 这符合 TDD 流程。
    test('DriftUserRepository 应该支持持久化 (待实现)', () {
      // TODO: 当 Gemini 实现 DriftUserRepository 后，添加集成测试。
      // 目前仅作为占位符提醒。
    }, skip: 'Waiting for Drift implementation');

    test('SharedPreferencesPreferenceRepository 应该支持持久化 (待实现)', () {
      // TODO: 当 Gemini 实现 PreferenceRepository 后，添加集成测试。
    }, skip: 'Waiting for Preference implementation');
  });
}
