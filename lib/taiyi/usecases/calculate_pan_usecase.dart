import '../core/school_config.dart';
import '../core/deity_definition.dart';
import '../core/school_repository.dart';
import '../taiyi_pan_calculator.dart';
import '../pan_data_model.dart';
import '../pan_enums.dart';

/// 排盘核心用例。
/// 
class CalculatePanUseCase {
  final SchoolRepository schoolRepository;
  final DeityPreferenceRepository deityPreferenceRepository;
  final TaiYiPanCalculator calculator;

  const CalculatePanUseCase({
    required this.schoolRepository,
    required this.deityPreferenceRepository,
    this.calculator = const TaiYiPanCalculator(),
  });

  Future<PanDataModel> call({
    required DateTime dateTime,
    required String schoolId,
    required TaiYiChartType chartType,
    bool useTrueSolarTime = false,
    String? location,
  }) async {
    return execute(
      dateTime: dateTime,
      schoolId: schoolId,
      chartType: chartType,
      useTrueSolarTime: useTrueSolarTime,
      location: location,
    );
  }

  Future<PanDataModel> execute({
    required DateTime dateTime,
    required String schoolId,
    required TaiYiChartType chartType,
    bool useTrueSolarTime = false,
    String? location,
  }) async {
    // 1. 加载流派配置
    final schools = await schoolRepository.loadAllSchools();
    final school = schools.firstWhere(
      (s) => s.id == schoolId,
      orElse: () => throw ArgumentError('未找到流派: $schoolId'),
    );

    // 2. 加载所有星神定义
    final allDeities = await schoolRepository.loadAllDeities();

    // 3. 加载用户显示偏好
    final preferenceMap = await deityPreferenceRepository.loadEnabledMap();

    // 4. 按偏好进一步筛选
    final activeDefinitions = allDeities.where((d) {
      return preferenceMap[d.id] ?? true; // 默认启用
    }).toList();

    // 5. 执行计算
    return calculator.calculateWithConfig(
      dateTime: dateTime,
      school: school,
      definitions: activeDefinitions,
      chartType: chartType,
      useTrueSolarTime: useTrueSolarTime,
      location: location,
    );
  }
}

