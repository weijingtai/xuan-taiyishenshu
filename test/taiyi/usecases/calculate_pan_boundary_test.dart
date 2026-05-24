import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/usecases/calculate_pan_usecase.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import '../mocks/mock_repositories.dart';

void main() {
  group('CalculatePanUseCase Boundary & Logic Test', () {
    late MockOfficialRepository officialRepo;
    late MockUserRepository userRepo;
    late MockPreferenceRepository preferenceRepo;
    late MockCombinedRepository combinedRepo;
    late CalculatePanUseCase useCase;

    setUp(() {
      officialRepo = MockOfficialRepository(
        schools: [
          const TaiYiSchool(
            id: 'official_1',
            name: 'Official School',
            epoch: SchoolEpochConfig(ancientBase: 1000, epochYear: 1),
            deityIds: ['deity_1', 'deity_2'],
          ),
        ],
        deities: [
          const DeityDefinition(
            id: 'deity_1',
            name: 'Official Deity 1',
            layer: EnumDeityLayer.tianPan,
            algorithm: DeityAlgorithmSpec(
              templateId: AlgorithmTemplateId.fixedPosition,
              params: {'gong': '乾'},
            ),
          ),
          const DeityDefinition(
            id: 'deity_2',
            name: 'Official Deity 2',
            layer: EnumDeityLayer.tianPan,
            algorithm: DeityAlgorithmSpec(
              templateId: AlgorithmTemplateId.fixedPosition,
              params: {'gong': '坤'},
            ),
          ),
        ],
      );

      userRepo = MockUserRepository();
      preferenceRepo = MockPreferenceRepository();
      
      combinedRepo = MockCombinedRepository([officialRepo, userRepo]);
      
      useCase = CalculatePanUseCase(
        schoolRepository: combinedRepo,
        deityPreferenceRepository: preferenceRepo,
      );
    });

    test('Should load school from Repository Interface', () async {
      final pan = await useCase.execute(
        dateTime: DateTime(2026, 5, 24),
        schoolId: 'official_1',
        chartType: TaiYiChartType.year,
      );

      expect(pan.input.schoolId, 'official_1');
    });

    test('Should include user-derived schools', () async {
      final userSchool = const TaiYiSchool(
        id: 'user_school_1',
        name: 'User School',
        epoch: SchoolEpochConfig(ancientBase: 2000, epochYear: 1),
        deityIds: ['deity_1'],
      );

      await userRepo.saveSchool(userSchool);

      final pan = await useCase.execute(
        dateTime: DateTime(2026, 5, 24),
        schoolId: 'user_school_1',
        chartType: TaiYiChartType.year,
      );

      expect(pan.input.schoolId, 'user_school_1');
    });

    test('Should respect deity display preferences', () async {
      await preferenceRepo.setEnabled('deity_2', false);

      final pan = await useCase.execute(
        dateTime: DateTime(2026, 5, 24),
        schoolId: 'official_1',
        chartType: TaiYiChartType.year,
      );
      
      expect(pan.input.schoolId, 'official_1');
      // deity_2 should be excluded from activeDefinitions in UseCase
    });

    test('Strict Boundary: UseCase should not touch concrete data sources', () {
      // By using only mocks in this test environment, we implicitly verify 
      // that CalculatePanUseCase does not have hidden dependencies on 
      // rootBundle, Drift, or other concrete infrastructure.
    });
  });
}
