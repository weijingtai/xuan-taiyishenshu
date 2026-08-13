import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/domain/pipeline/taiyi_chart_params.dart';
import 'package:taiyishenshu/domain/pipeline/taiyi_pipeline_executor.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';

ResolvedMoment _buildMoment({
  required DateTime nominalTime,
  required double latitude,
  required double longitude,
}) {
  final source = DivinationMoment(
    instantUtc: nominalTime.toUtc(),
    place: GeoPoint(latitude: latitude, longitude: longitude),
    reckoning: EnumDatetimeType.standard,
  );
  return ResolvedMoment(
    source: source,
    nominalTime: nominalTime,
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
}

void main() {
  group('TaiyiPipelineExecutor', () {
    late TaiyiPipelineExecutor executor;
    late ResolvedMoment moment;
    late TaiyiChartParams params;

    setUpAll(() {
      executor = TaiyiPipelineExecutor(momentResolver: _FixedMomentResolver());
      moment = _buildMoment(
        nominalTime: DateTime(2026, 5, 23, 8, 25),
        latitude: 31.2304,
        longitude: 121.4737,
      );
      params = const TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
        schoolId: 'jingMirror',
        chartType: TaiYiChartType.year,
      );
    });

    test('execute 跑通完整排盘并返回正确字段与具体数值', () async {
      final chart = await executor.execute(
        ChartRequest<TaiyiChartParams>(
          moment: moment.source,
          params: params,
        ),
      );

      expect(chart.question, '太乙神数排盘');
      expect(chart.schoolId, 'jingMirror');
      expect(chart.juNumber, 55);
      expect(chart.createdAt, DateTime(2026, 5, 23, 8, 25));
      expect(chart.datetimeJson, '2026-05-23T08:25:00.000');
    });

    test('产出 contract 满足 Chart 契约且支持 toJson/jsonDecode 往返', () async {
      final chart = await executor.execute(
        ChartRequest<TaiyiChartParams>(
          moment: moment.source,
          params: params,
        ),
      );

      expect(chart is Chart, true);
      final jsonMap = chart.toJson();
      expect(jsonMap.isNotEmpty, true);
      expect(jsonMap['question'], '太乙神数排盘');
      expect(jsonMap['schoolId'], 'jingMirror');
      expect(jsonMap['juNumber'], 55);

      final jsonString = jsonEncode(jsonMap);
      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decodedMap['schoolId'], 'jingMirror');
      expect(decodedMap['juNumber'], 55);
      expect(decodedMap['question'], '太乙神数排盘');
    });

    test('相同输入两次执行产出稳定一致的盘块数据', () async {
      final req = ChartRequest<TaiyiChartParams>(
        moment: moment.source,
        params: params,
      );
      final res1 = await executor.execute(req);
      final res2 = await executor.execute(req);

      expect(res1.juNumber, 55);
      expect(res2.juNumber, 55);
      expect(res1.juNumber, res2.juNumber);
      expect(res1.schoolId, res2.schoolId);
      expect(res1.taiYiPalaceJson, res2.taiYiPalaceJson);
      expect(res1.ninePalaceJson, res2.ninePalaceJson);
      expect(res1.paramsJson, res2.paramsJson);
      expect(res1.datetimeJson, res2.datetimeJson);
      expect(res1.createdAt, res2.createdAt);
      expect(res1.question, res2.question);
    });
  });
}

/// 固定 ResolvedMoment，隔离真实历法计算，专注验证接线与入参透传。
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
