import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/usecases/calculate_pan_usecase.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import '../mocks/mock_repositories.dart';

void main() {
  group('AC7 & AC14: MVVM State Sync & Async Race Test', () {
    late MockOfficialRepository officialRepo;
    late MockUserRepository userRepo;
    late MockPreferenceRepository preferenceRepo;
    late MockCombinedRepository combinedRepo;
    late CalculatePanUseCase useCase;

    setUp(() {
      officialRepo = MockOfficialRepository(
        schools: [
          const TaiYiSchool(
            id: 'school_1',
            name: 'School 1',
            epoch: SchoolEpochConfig(ancientBase: 1000, epochYear: 1),
            deityIds: ['tai_yi'],
          ),
          const TaiYiSchool(
            id: 'school_2',
            name: 'School 2',
            epoch: SchoolEpochConfig(ancientBase: 2000, epochYear: 1),
            deityIds: ['tai_yi'],
          ),
        ],
        deities: [
          const DeityDefinition(
            id: 'tai_yi',
            name: '太乙',
            layer: EnumDeityLayer.tianPan,
            algorithm: DeityAlgorithmSpec(
              templateId: AlgorithmTemplateId.fixedPosition,
              params: {'gong': '乾'},
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

    test('Should handle overlapping async requests and return consistent state', () async {
      final future1 = useCase.execute(
        dateTime: DateTime(2026, 5, 24),
        schoolId: 'school_1',
        chartType: TaiYiChartType.year,
      );
      
      final future2 = useCase.execute(
        dateTime: DateTime(2026, 5, 24),
        schoolId: 'school_2',
        chartType: TaiYiChartType.year,
      );

      final results = await Future.wait([future1, future2]);
      
      expect(results[0].input.schoolId, 'school_1');
      expect(results[1].input.schoolId, 'school_2');
      
      // Verification: The accumulated year should be different based on ancientBase
      // school_1: (2026 - 1) + 1000 = 3025
      // school_2: (2026 - 1) + 2000 = 4025
      expect(results[0].accumulatedYear, 3025);
      expect(results[1].accumulatedYear, 4025);
    });
  });
}
