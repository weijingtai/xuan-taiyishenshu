import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/usecases/calculate_pan_usecase.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';

class MockSchoolRepository implements SchoolRepository {
  final List<TaiYiSchool> schools;
  final List<DeityDefinition> deities;

  MockSchoolRepository({required this.schools, required this.deities});

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async => schools;
  @override
  Future<List<DeityDefinition>> loadAllDeities() async => deities;

  @override
  Future<TaiYiSchool?> loadSchool(String id) async =>
      schools.firstWhere((s) => s.id == id);
  @override
  Future<DeityDefinition?> loadDeity(String id) async =>
      deities.firstWhere((d) => d.id == id);

  @override
  Future<void> saveSchool(TaiYiSchool school) async {}
  @override
  Future<void> saveDeity(DeityDefinition deity) async {}
  @override
  Future<void> deleteSchool(String id) async {}
  @override
  Future<void> deleteDeity(String id) async {}
}

class MockDeityPreferenceRepository implements DeityPreferenceRepository {
  final Map<String, bool> enabledMap;
  MockDeityPreferenceRepository(this.enabledMap);

  @override
  Future<bool> isEnabled(String deityId) async => enabledMap[deityId] ?? true;
  @override
  Future<void> setEnabled(String deityId, bool enabled) async {}
  @override
  Future<Map<String, bool>> loadEnabledMap() async => enabledMap;
}

void main() {
  group('CalculatePanUseCase', () {
    test('execute loads and calculates correctly', () async {
      final repo = MockSchoolRepository(
        schools: [
          const TaiYiSchool(
            id: 'test_school',
            name: 'Test School',
            epoch: SchoolEpochConfig(ancientBase: 100, epochYear: 2000),
            deityIds: ['taiYi'],
          ),
        ],
        deities: [
          const DeityDefinition(
            id: 'taiYi',
            name: '太乙',
            layer: EnumDeityLayer.tianPan,
            algorithm: DeityAlgorithmSpec(
              templateId: AlgorithmTemplateId.fixedPosition,
              params: {'gong': '乾'},
            ),
          ),
        ],
      );
      final prefRepo = MockDeityPreferenceRepository({});

      final useCase = CalculatePanUseCase(
        schoolRepository: repo,
        deityPreferenceRepository: prefRepo,
      );

      final result = await useCase.execute(
        dateTime: DateTime(2026, 1, 1),
        schoolId: 'test_school',
        chartType: TaiYiChartType.year,
      );

      expect(result.input.schoolName, 'Test School');
      expect(result.accumulatedYear, 126);
      expect(
          result.palaces.any((p) => p.items.any((i) => i.name == '太乙')), true);
    });

    test('execute respects deity preference', () async {
      final repo = MockSchoolRepository(
        schools: [
          const TaiYiSchool(
            id: 'test_school',
            name: 'Test School',
            epoch: SchoolEpochConfig(ancientBase: 100, epochYear: 2000),
            deityIds: ['taiYi', 'customDeity'],
          ),
        ],
        deities: [
          const DeityDefinition(
            id: 'taiYi',
            name: '太乙',
            layer: EnumDeityLayer.tianPan,
            algorithm: DeityAlgorithmSpec(
              templateId: AlgorithmTemplateId.fixedPosition,
              params: {'gong': '乾'},
            ),
          ),
          const DeityDefinition(
            id: 'customDeity',
            name: '自定义神',
            layer: EnumDeityLayer.tianPan,
            algorithm: DeityAlgorithmSpec(
              templateId: AlgorithmTemplateId.fixedPosition,
              params: {'gong': '坤'},
            ),
          ),
        ],
      );
      final prefRepo = MockDeityPreferenceRepository({
        'customDeity': false,
      });

      final useCase = CalculatePanUseCase(
        schoolRepository: repo,
        deityPreferenceRepository: prefRepo,
      );

      final result = await useCase.execute(
        dateTime: DateTime(2026, 1, 1),
        schoolId: 'test_school',
        chartType: TaiYiChartType.year,
      );

      expect(
          result.palaces.any((p) => p.items.any((i) => i.name == '太乙')), true);
      expect(result.palaces.any((p) => p.items.any((i) => i.name == '自定义神')),
          false);
    });
  });
}
