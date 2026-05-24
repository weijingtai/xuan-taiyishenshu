import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/usecases/calculate_pan_usecase.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import '../mocks/mock_repositories.dart';

void main() {
  group('AC10: Deity Copy, Scope and Co-display Test', () {
    late MockOfficialRepository officialRepo;
    late MockUserRepository userRepo;
    late MockPreferenceRepository preferenceRepo;
    late MockCombinedRepository combinedRepo;
    late CalculatePanUseCase useCase;

    setUp(() {
      officialRepo = MockOfficialRepository(
        schools: [
          const TaiYiSchool(
            id: 'official_school',
            name: 'Official School',
            epoch: SchoolEpochConfig(ancientBase: 1000, epochYear: 1),
            deityIds: ['tai_yi', 'user_tai_yi_1'], 
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

    test('Official and User-derived Deities should be able to display together', () async {
      // 1. Create a derived deity
      final userTaiYi = const DeityDefinition(
        id: 'user_tai_yi_1',
        name: '我的太乙',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.fixedPosition,
          params: {'gong': '坤'},
        ),
        source: 'user',
      );
      await userRepo.saveDeity(userTaiYi);

      // 2. Execute UseCase
      final pan = await useCase.execute(
        dateTime: DateTime(2026, 5, 24),
        schoolId: 'official_school',
        chartType: TaiYiChartType.year,
      );

      // 3. Verify both exist in the final Palace models
      final allStars = pan.palaces.expand((p) => p.stars).toList();
      
      expect(allStars, contains('太乙'));
      expect(allStars, contains('我的太乙'));
    });
  });
}
