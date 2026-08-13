import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart'
    hide DummyDeityPreferenceRepository;
import 'package:taiyishenshu/controllers/taiyi_pan_controller.dart';
import 'package:taiyishenshu/domain/pipeline/taiyi_chart_params.dart';
import 'package:taiyishenshu/domain/pipeline/taiyi_pipeline_executor.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/school_repository.dart'
    show DummyDeityPreferenceRepository;
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/taiyi/taiyi_assembly.dart';

import '../taiyi/fakes/memory_school_repository.dart';

void main() {
  late MemorySchoolRepository repo;
  late TaiYiDataAssembly assembly;
  late _InMemoryTaiyiRecordRepository recordRepo;

  setUp(() {
    repo = MemorySchoolRepository();
    repo.saveSchool(
      const TaiYiSchool(
        id: 'jingMirror',
        name: '金镜派',
        epoch: SchoolEpochConfig(ancientBase: 100, epochYear: 200),
      ),
    );
    recordRepo = _InMemoryTaiyiRecordRepository();
    assembly = TaiYiDataAssembly(
      officialRepo: repo,
      userRepo: repo,
      deityRepo: repo,
      preferenceRepo: DummyDeityPreferenceRepository(),
      recordRepo: recordRepo,
    );
  });

  group('TaiYiPanController pipeline 接线', () {
    test('A: 注入 executor 后 calculate 真实执行 Pipeline，落库走 Record，产出与直接调用 executor 逐字段一致', () async {
      final executor = TaiyiPipelineExecutor(
        momentResolver: _FixedMomentResolver(),
      );
      final controller = TaiYiPanController(
        assembly: assembly,
        pipelineExecutor: executor,
      );

      await controller.calculate(
        dateTime: DateTime(2026, 5, 23, 8, 25),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      expect(controller.panData, isNotNull, reason: '老路径照常产出盘面');
      expect(controller.error, isNull);

      // executor 真的被执行到：request 与 record 均已记录
      final request = controller.lastPipelineRequest;
      expect(request, isNotNull);
      expect(request!.params.schoolId, 'jingMirror');
      expect(request.params.chartType, TaiYiChartType.year);
      expect(request.params.uuid, isNotEmpty);

      final pipelineRecord = controller.lastPipelineRecord;
      expect(pipelineRecord, isNotNull);
      expect(pipelineRecord!.uuid, request.params.uuid);

      // 落库走 Record：内存 recordRepo 收到 1 条
      final saved = await recordRepo.getAllRecords();
      expect(saved, hasLength(1));
      expect(saved.single.uuid, pipelineRecord.uuid);

      // ── 执行证据：executor 真实执行 + 落库 uuid 同源 ──
      final evidence = controller.lastPipelineEvidence;
      expect(evidence, isNotNull, reason: 'pipeline 路径必须产出执行证据');
      expect(evidence!.callCount, 1, reason: 'executor 恰好执行一次');
      expect(evidence.requestId, pipelineRecord.uuid,
          reason: 'requestId 取 Record uuid');
      expect(evidence.resultUuid, pipelineRecord.uuid,
          reason: 'resultUuid 与落库 Record uuid 同源');
      expect(evidence.module, 'taiyishenshu');
      expect(evidence.error, isNull, reason: '成功执行无异常');
      expect(evidence.keyResult, isNotNull, reason: '局数是页面可观察结果');
      // 落库的 Record 就是 lastPipelineRecord（同 uuid）
      expect(saved.single.uuid, pipelineRecord.uuid,
          reason: '落库 Record uuid 与排盘 uuid 同源');

      // 与直接调用 executor 的产出逐字段一致
      final direct = await executor.execute(
        ChartRequest<TaiyiChartParams>(
          moment: request.moment,
          params: request.params,
        ),
      );
      expect(direct.uuid, pipelineRecord.uuid);
      expect(direct.question, pipelineRecord.question);
      expect(direct.juNumber, pipelineRecord.juNumber);
      expect(direct.taiYiPalaceJson, pipelineRecord.taiYiPalaceJson);
      expect(direct.ninePalaceJson, pipelineRecord.ninePalaceJson);
      expect(direct.paramsJson, pipelineRecord.paramsJson);
      expect(direct.datetimeJson, pipelineRecord.datetimeJson);
      expect(direct.createdAt, pipelineRecord.createdAt);
    });

    test('B: 未注入 executor 时不崩、Pipeline 不走、老路径照常落库', () async {
      final controller = TaiYiPanController(assembly: assembly);

      await controller.calculate(
        dateTime: DateTime(2026, 5, 23, 8, 25),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      expect(controller.panData, isNotNull);
      expect(controller.error, isNull);
      expect(controller.lastPipelineRequest, isNull);
      expect(controller.lastPipelineRecord, isNull);
      expect(await recordRepo.getAllRecords(), hasLength(1), reason: '老路径 SaveRecordUseCase 照常落库');
    });

    test('B2: 注入 executor 但 Pipeline 抛错时不崩、老路径照常产出', () async {
      final controller = TaiYiPanController(
        assembly: assembly,
        pipelineExecutor: TaiyiPipelineExecutor(
          momentResolver: _ThrowingMomentResolver(),
        ),
      );

      await controller.calculate(
        dateTime: DateTime(2026, 5, 23, 8, 25),
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );

      expect(controller.panData, isNotNull, reason: 'Pipeline 失败已回退，老路径照常');
      expect(controller.error, isNull);
      expect(controller.lastPipelineRecord, isNull);
      expect(await recordRepo.getAllRecords(), hasLength(1), reason: '老路径 SaveRecordUseCase 兜底落库');
    });

    test('C: TaiyiChartParams toJson/fromJson 互逆 round-trip', () {
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
        schoolId: 'tongZong',
        chartType: TaiYiChartType.month,
        uuid: 'taiyi-test-001',
      );
      final decoded = TaiyiChartParams.fromJson(params.toJson());
      expect(decoded, params);
    });

    test('C2: fromJson 缺字段套默认不抛', () {
      final decoded = TaiyiChartParams.fromJson(const {});
      expect(decoded.latitude, 0.0);
      expect(decoded.longitude, 0.0);
      expect(decoded.altitude, 0.0);
      expect(decoded.timezone, 'Asia/Shanghai');
      expect(decoded.isMale, false);
      expect(decoded.schoolId, 'jingMirror');
      expect(decoded.chartType, TaiYiChartType.year);
      expect(decoded.uuid, '');
    });

    test('C3: fromJson 类型不合法抛 FormatException，不静默兜底', () {
      expect(
        () => TaiyiChartParams.fromJson(const {'latitude': '39.9'}),
        throwsFormatException,
      );
      expect(
        () => TaiyiChartParams.fromJson(const {'timezone': 42}),
        throwsFormatException,
      );
      expect(
        () => TaiyiChartParams.fromJson(const {'isMale': 'yes'}),
        throwsFormatException,
      );
      expect(
        () => TaiyiChartParams.fromJson(const {'chartType': 'notARealType'}),
        throwsFormatException,
      );
      expect(
        () => TaiyiChartParams.fromJson(const {'chartType': 7}),
        throwsFormatException,
      );
      expect(
        () => TaiyiChartParams.fromJson(const {'uuid': 123}),
        throwsFormatException,
      );
    });
  });
}

class _InMemoryTaiyiRecordRepository implements TaiyiRecordRepository {
  final List<TaiyiDivinationRecordContract> _records = [];

  @override
  Future<String> saveRecord(TaiyiDivinationRecordContract record) async {
    _records.add(record);
    return record.uuid;
  }

  @override
  Future<List<TaiyiDivinationRecordContract>> getAllRecords() async {
    return List.of(_records);
  }

  @override
  Future<TaiyiDivinationRecordContract?> getRecordByUuid(String uuid) async {
    for (final r in _records) {
      if (r.uuid == uuid) return r;
    }
    return null;
  }

  @override
  Future<bool> softDeleteRecord(String uuid) async {
    _records.removeWhere((r) => r.uuid == uuid);
    return true;
  }

  @override
  Stream<List<TaiyiDivinationRecordContract>> watchAllRecords() async* {
    yield List.of(_records);
  }
}

/// 固定 ResolvedMoment，隔离真实历法计算。
class _FixedMomentResolver implements MomentResolver {
  const _FixedMomentResolver();

  @override
  ResolvedMoment resolve(DivinationMoment moment) => ResolvedMoment(
    source: moment,
    nominalTime: DateTime(2026, 5, 23, 8, 25),
    eightChars: EightChars(
      year: JiaZi.BING_YIN,
      month: JiaZi.GENG_CHEN,
      day: JiaZi.JIA_SHEN,
      time: JiaZi.WU_CHEN,
    ),
    lunar: const LunarDate(month: 4, day: 26, isLeapMonth: false),
    jieQi: JieQiInfo(
      jieQi: TwentyFourJieQi.XIAO_MAN,
      startAt: DateTime(2026, 5, 21),
      endAt: DateTime(2026, 6, 5),
    ),
  );

  @override
  List<ResolvedMoment> resolveCandidates(
    DivinationMoment moment,
    CandidateSpec spec,
  ) => [];
}

/// 模拟新路径失败，验证回退。
class _ThrowingMomentResolver implements MomentResolver {
  const _ThrowingMomentResolver();

  @override
  ResolvedMoment resolve(DivinationMoment moment) {
    throw StateError('模拟新路径失败');
  }

  @override
  List<ResolvedMoment> resolveCandidates(
    DivinationMoment moment,
    CandidateSpec spec,
  ) => [];
}
