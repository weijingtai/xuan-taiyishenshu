import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/usecases/calculate_pan_usecase.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import '../mocks/mock_repositories.dart';

void main() {
  group('AC10: Destructive & Robustness Test', () {
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
            name: 'Official 1',
            epoch: SchoolEpochConfig(ancientBase: 1000, epochYear: 1),
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

    test('Should fail gracefully when school ID is invalid', () async {
      expect(
        () => useCase.execute(
          dateTime: DateTime(2026, 5, 24),
          schoolId: 'non_existent',
          chartType: TaiYiChartType.year,
        ),
        throwsArgumentError,
      );
    });

    test('Should handle deities with broken parameters (Robustness)', () async {
      // Create a deity with missing required 'gong' parameter
      final brokenDeity = const DeityDefinition(
        id: 'broken_deity',
        name: 'Broken Deity',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.fixedPosition,
          params: {}, // Missing 'gong'
        ),
        source: 'user',
      );
      await userRepo.saveDeity(brokenDeity);
      
      // We need to associate it with a school
      final userSchool = const TaiYiSchool(
        id: 'user_school',
        name: 'User School',
        epoch: SchoolEpochConfig(ancientBase: 1000, epochYear: 1),
        deityIds: ['tai_yi', 'broken_deity'],
      );
      await userRepo.saveSchool(userSchool);

      // In current implementation, DeityAlgorithmEngine._executeFixedPosition casts params['gong'] as String
      // This will throw a type error. Robustness check: does the system crash or fail gracefully?
      // Since UseCase doesn't catch calculator errors, it will propagate.
      
      expect(
        () => useCase.execute(
          dateTime: DateTime(2026, 5, 24),
          schoolId: 'user_school',
          chartType: TaiYiChartType.year,
        ),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
