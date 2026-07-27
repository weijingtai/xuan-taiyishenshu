import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/domain/pipeline/taiyi_chart_calculator.dart';
import 'package:taiyishenshu/domain/pipeline/taiyi_chart_params.dart';
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
  group('TaiyiChartCalculator', () {
    late TaiyiChartCalculator calculator;
    late ResolvedMoment moment;
    late TaiyiChartParams params;

    setUpAll(() {
      calculator = const TaiyiChartCalculator();
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

    test('module 返回 taiyishenshu', () {
      expect(calculator.module, 'taiyishenshu');
    });

    test('返回 TaiyiDivinationRecordContract 且实现 Chart 接口', () {
      final chart = calculator.calculate(moment, params);
      expect(chart, isA<TaiyiDivinationRecordContract>());
      expect(chart, isA<Chart>());
    });

    test('createdAt 取自 moment.nominalTime', () {
      final chart = calculator.calculate(moment, params);
      expect(chart.createdAt, moment.nominalTime);
    });

    test('isMale 在 paramsJson 中为 true', () {
      final chart = calculator.calculate(moment, params);
      expect(chart.paramsJson, isNotNull);
      final decoded = jsonDecode(chart.paramsJson!) as Map<String, dynamic>;
      expect(decoded['isMale'], true);
    });

    test('question 为固定值', () {
      final chart = calculator.calculate(moment, params);
      expect(chart.question, '太乙神数排盘');
    });

    test('juNumber 为 int', () {
      final chart = calculator.calculate(moment, params);
      expect(chart.juNumber, isA<int>());
    });

    test('paramsJson 包含 accumulatedYear 且为 int', () {
      final chart = calculator.calculate(moment, params);
      expect(chart.paramsJson, isNotNull);
      final decoded = jsonDecode(chart.paramsJson!) as Map<String, dynamic>;
      final panResult = decoded['panResult'] as Map<String, dynamic>;
      expect(panResult['accumulatedYear'], isA<int>());
    });

    test('schoolId 取自 params', () {
      final chart = calculator.calculate(moment, params);
      expect(chart.schoolId, 'jingMirror');
    });

    test('paramsJson 包含 chartType', () {
      final chart = calculator.calculate(moment, params);
      expect(chart.paramsJson, isNotNull);
      final decoded = jsonDecode(chart.paramsJson!) as Map<String, dynamic>;
      expect(decoded['chartType'], 'year');
    });

    test('核心字段完整：uuid、datetimeJson、taiYiPalaceJson、ninePalaceJson', () {
      final chart = calculator.calculate(moment, params);
      expect(chart.uuid, '');
      expect(chart.datetimeJson, isNotNull);
      expect(chart.taiYiPalaceJson, isNotNull);
      expect(chart.ninePalaceJson, isNotNull);
      expect(chart.createdAt, isNotNull);
      expect(chart.question, isNotNull);
    });

    test('金镜派 2026 年计 积年与局数正确', () {
      final chart = calculator.calculate(moment, params);
      expect(chart.juNumber, 55);
      final decoded = jsonDecode(chart.paramsJson!) as Map<String, dynamic>;
      final panResult = decoded['panResult'] as Map<String, dynamic>;
      expect(panResult['accumulatedYear'], 1938583);
    });

    test('统宗派 2026 年计 积年正确', () {
      final tongZongParams = const TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: false,
        schoolId: 'tongZong',
        chartType: TaiYiChartType.year,
      );
      final chart = calculator.calculate(moment, tongZongParams);
      final decoded = jsonDecode(chart.paramsJson!) as Map<String, dynamic>;
      final panResult = decoded['panResult'] as Map<String, dynamic>;
      expect(panResult['accumulatedYear'], 10155943);
    });

    test('纯函数：相同输入两次产出相同 Contract', () {
      final a = calculator.calculate(moment, params);
      final b = calculator.calculate(moment, params);
      expect(a.juNumber, b.juNumber);
      expect(a.schoolId, b.schoolId);
      expect(a.taiYiPalaceJson, b.taiYiPalaceJson);
      expect(a.ninePalaceJson, b.ninePalaceJson);
      expect(a.paramsJson, b.paramsJson);
      expect(a.createdAt, b.createdAt);
      expect(a.question, b.question);
      expect(a.datetimeJson, b.datetimeJson);
    });

    test('paramsJson 中的 panResult.juNumber 与 Contract.juNumber 一致', () {
      final chart = calculator.calculate(moment, params);
      final decoded = jsonDecode(chart.paramsJson!) as Map<String, dynamic>;
      final panResult = decoded['panResult'] as Map<String, dynamic>;
      expect(panResult['juNumber'], chart.juNumber);
    });
  });
}
