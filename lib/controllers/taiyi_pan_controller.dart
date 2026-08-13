import 'package:flutter/foundation.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

import '../taiyi/taiyi_assembly.dart';
import '../taiyi/viewmodels/school_view_model.dart';
import '../taiyi/viewmodels/deity_view_model.dart';
import '../taiyi/usecases/calculate_pan_usecase.dart';
import '../taiyi/taiyi.dart';
import '../domain/pipeline/taiyi_pipeline_executor.dart';
import '../domain/pipeline/taiyi_chart_params.dart';
import '../domain/pipeline/pipeline_evidence.dart';

class TaiYiPanController extends ChangeNotifier {
  final TaiYiDataAssembly assembly;

  /// Pipeline 统一入参排盘执行器（可选注入）。注入后 calculate 走新路径，
  /// 失败回退老路径，不打断 UI。
  final TaiyiPipelineExecutor? pipelineExecutor;

  /// 最后一次走统一入参排盘的 [ChartRequest]，供测试断言 executor 被真实调用。
  ChartRequest<TaiyiChartParams>? lastPipelineRequest;

  /// 最后一次统一入参排盘产出的 Record。
  TaiyiDivinationRecordContract? lastPipelineRecord;

  /// 本次排盘执行证据（供壳侧 E2E 测试断言 executor 真实执行）。
  /// 只读：不参与生产逻辑判断、不影响渲染。
  PipelineEvidence? _lastPipelineEvidence;
  int _pipelineCallCount = 0;

  /// 最后一次走统一入参排盘的执行证据；未走 pipeline 路径时为 null。
  @visibleForTesting
  PipelineEvidence? get lastPipelineEvidence => _lastPipelineEvidence;

  late final SchoolViewModel schoolViewModel;
  late final DeityViewModel deityViewModel;
  late final CalculatePanUseCase calculatePanUseCase;

  TaiYiPanController({
    required this.assembly,
    this.pipelineExecutor,
  }) {

    calculatePanUseCase = assembly.calculatePanUseCase;

    // 3. Initialize ViewModels
    schoolViewModel = SchoolViewModel(
      loadSchoolsUseCase: assembly.loadSchoolsUseCase,
      copySchoolUseCase: assembly.copySchoolUseCase,
      saveUserSchoolUseCase: assembly.saveUserSchoolUseCase,
    );

    deityViewModel = DeityViewModel(
      loadDeitiesUseCase: assembly.loadDeitiesUseCase,
      copyDeityUseCase: assembly.copyDeityUseCase,
      saveUserDeityUseCase: assembly.saveUserDeityUseCase,
      deleteUserDeityUseCase: assembly.deleteUserDeityUseCase,
      toggleDeityPreferenceUseCase: assembly.toggleDeityPreferenceUseCase,
      deityAvailabilityUseCase: assembly.deityAvailabilityUseCase,
      preferenceRepository: assembly.preferenceRepo,
    );

    // Forward notifications from ViewModels
    schoolViewModel.addListener(notifyListeners);
    deityViewModel.addListener(notifyListeners);
  }

  PanDataModel? _panData;
  bool _isCalculating = false;
  String? _error;

  PanDataModel? get panData => _panData;
  bool get isCalculating => _isCalculating;
  String? get error => _error;

  List<TaiYiSchool> get availableSchools => schoolViewModel.schools;
  List<DeityDefinition> get allDeities => deityViewModel.deities;
  List<DeityDefinition> get officialDeities => deityViewModel.deities.where((d) => !d.id.startsWith('user_')).toList();

  bool get showHiddenWarning {
    const coreDeities = ['taiYi', 'wenChang', 'shiJi', 'jiShen'];
    return coreDeities.any((id) => !isDeityVisible(id));
  }

  final Map<String, bool> _localVisibilityCache = {};

  bool isDeityVisible(String id) {
    // If not in cache, we assume visible for now, 
    // but the real source is the preference repo via CalculatePanUseCase.
    return _localVisibilityCache[id] ?? true;
  }

  Future<void> setDeityVisibility(String id, bool visible) async {
    _localVisibilityCache[id] = visible;
    // ZT-21 修复: 直接 setEnabled(id, visible), 不再 toggle, 防止重复调用脱钩。
    await deityViewModel.setDeityPreference(id, visible);

    // Immediately re-calculate to refresh UI with new visibility settings
    if (_panData != null) {
      await calculate(
        dateTime: _panData!.input.dateTime,
        schoolId: _panData!.input.schoolId,
        chartType: _panData!.input.chartType,
      );
    } else {
      notifyListeners();
    }
  }

  Future<void> loadSchools() async {
    await schoolViewModel.loadSchools();
    await deityViewModel.loadDeities();
    
    // Initialize local visibility cache from preference repository
    final prefs = await assembly.preferenceRepo.loadEnabledMap();
    _localVisibilityCache.addAll(prefs);
    notifyListeners();
  }


  Future<void> saveUserSchool(TaiYiSchool school) async {
    await schoolViewModel.saveSchool(school);
  }

  /// 切换当前流派并重新排盘。
  ///
  /// 内部直接调用 [calculate]，复用上次 [PanDataModel.input] 的 dateTime
  /// 与 chartType（若已有 panData）；否则回退到当前时间与 year 盘。
  ///
  /// 该方法是流派管理页面在用户点击列表行后触发"切换流派"动作的入口。
  /// 切换后 panData.accumulatedYear / juNumber / 主算落宫等参数会随流派
  /// epoch 与算法开关而变化，UI 监听 [notifyListeners] 即自动刷新。
  Future<void> switchSchool(String schoolId) async {
    final last = _panData?.input;
    await calculate(
      dateTime: last?.dateTime ?? DateTime.now(),
      schoolId: schoolId,
      chartType: last?.chartType ?? TaiYiChartType.year,
    );
  }

  Future<void> calculate({
    required DateTime dateTime,
    String schoolId = 'jingMirror',
    TaiYiChartType chartType = TaiYiChartType.year,
  }) async {
    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      _panData = await calculatePanUseCase(
        dateTime: dateTime,
        schoolId: schoolId,
        chartType: chartType,
      );
      _error = null;

      // ── 新路径：Pipeline 统一入参排盘 + 落库走 Record ──
      // 注入 executor 时走统一入参排盘，产出 Record 落库；
      // 失败只记日志回退老路径，不打断 UI。
      final executor = pipelineExecutor;
      if (executor != null) {
        try {
          _pipelineCallCount++;
          final record = await _runPipeline(executor, dateTime, schoolId, chartType);
          lastPipelineRecord = record;
          _lastPipelineEvidence = PipelineEvidence(
            callCount: _pipelineCallCount,
            requestId: record.uuid,
            resultUuid: record.uuid,
            module: 'taiyishenshu',
            keyResult: _keyResultOf(record),
            error: null,
          );
          await assembly.recordRepo.saveRecord(record);
        } catch (error, stack) {
          _lastPipelineEvidence = PipelineEvidence(
            callCount: _pipelineCallCount,
            requestId: null,
            resultUuid: null,
            module: 'taiyishenshu',
            keyResult: null,
            error: error,
          );
          debugPrint('Pipeline 排盘失败，已回退老路径: $error\n$stack');
        }
      }

      // ── 老路径落库：仅在未注入 executor（或新路径未产出）时执行，避免重复落库 ──
      if (lastPipelineRecord == null) {
        try {
          await assembly.saveRecordUseCase(_panData!);
        } catch (error, stack) {
          debugPrint('老路径落库失败: $error\n$stack');
        }
      }
    } catch (e) {
      _error = e.toString();
      _panData = null;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  /// 构建统一入参并调用 Pipeline executor 排盘，返回落库用的 Record。
  Future<TaiyiDivinationRecordContract> _runPipeline(
    TaiyiPipelineExecutor executor,
    DateTime dateTime,
    String schoolId,
    TaiYiChartType chartType,
  ) async {
    final params = TaiyiChartParams(
      timezone: 'Asia/Shanghai',
      schoolId: schoolId,
      chartType: chartType,
      uuid: 'taiyi-${dateTime.millisecondsSinceEpoch}',
    );
    final request = ChartRequest<TaiyiChartParams>(
      moment: DivinationMoment(
        instantUtc: dateTime.toUtc(),
        place: GeoPoint(
          latitude: params.latitude,
          longitude: params.longitude,
          timeZoneId: params.timezone,
        ),
        reckoning: EnumDatetimeType.standard,
      ),
      params: params,
    );
    lastPipelineRequest = request;
    return executor.execute(request);
  }

  /// 提取页面可观察的关键结果（局数 juNumber + 太乙所在宫），
  /// 作为执行证据的 keyResult。
  ///
  /// 局数由本次排盘决定（calculator 计算产出），且直接显示在盘面顶部，
  /// 因此能代表「这次执行真的发生了」。
  Object? _keyResultOf(TaiyiDivinationRecordContract record) {
    final ju = record.juNumber;
    if (ju == null) {
      return null;
    }
    return {
      'juNumber': ju,
      'taiYiPalace': record.taiYiPalaceJson,
    };
  }

  @override
  void dispose() {
    schoolViewModel.removeListener(notifyListeners);
    deityViewModel.removeListener(notifyListeners);
    super.dispose();
  }
}



