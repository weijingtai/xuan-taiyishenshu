import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/data/codec/taiyi_record_module_codec.dart';
import 'package:taiyishenshu/domain/pipeline/taiyi_chart_calculator.dart';
import 'package:taiyishenshu/domain/pipeline/taiyi_chart_params.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';

ResolvedMoment _buildMoment() {
  final nominalTime = DateTime(2026, 5, 23, 8, 25);
  return ResolvedMoment(
    source: DivinationMoment(
      instantUtc: nominalTime.toUtc(),
      place: const GeoPoint(latitude: 31.2304, longitude: 121.4737),
      reckoning: EnumDatetimeType.standard,
    ),
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
  group('TaiyiRecordModuleCodec', () {
    late TaiyiRecordModuleCodec codec;

    setUp(() {
      codec = TaiyiRecordModuleCodec();
    });

    test('module 返回 taiyishenshu', () {
      expect(codec.module, 'taiyishenshu');
    });

    test('category 返回 divination', () {
      expect(codec.category, 'divination');
    });

    test('divinationType 返回 taiyi', () {
      expect(codec.divinationType, 'taiyi');
    });

    test('encode 提取公共列：latitude', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');

      expect(encoded.meta.latitude, 31.2304);
    });

    test('encode 提取公共列：longitude', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');

      expect(encoded.meta.longitude, 121.4737);
    });

    test('encode 提取公共列：timezoneStr', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');

      expect(encoded.meta.timezoneStr, 'Asia/Shanghai');
    });

    test('encode 提取公共列：gender（男性）', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');

      expect(encoded.meta.gender, 'M');
    });

    test('encode 提取公共列：gender（女性）', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: false,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');

      expect(encoded.meta.gender, 'F');
    });

    test('encode 提取 scopeUid', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'user-123');

      expect(encoded.meta.scopeUid, 'user-123');
    });

    test('encode 提取 module/category/divinationType', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');

      expect(encoded.meta.module, 'taiyishenshu');
      expect(encoded.meta.category, 'divination');
      expect(encoded.meta.divinationType, 'taiyi');
    });

    test('encode 提取 question', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');

      expect(encoded.meta.question, '太乙神数排盘');
    });

    test('encode 有 moduleData 包含 chartJson、chartResultJson', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');

      expect(encoded.moduleData, isNotNull);
      expect(encoded.moduleData!['chartJson'], isA<String>());
      expect(encoded.moduleData!['chartResultJson'], isA<String>());
    });

    test('decode 后 question 能回填', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');
      final decoded = codec.decode(encoded.meta, encoded.moduleData);

      expect(decoded.question, '太乙神数排盘');
    });

    test('decode 后 isMale 能回填（从 paramsJson 解析）', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');
      final decoded = codec.decode(encoded.meta, encoded.moduleData);

      final decodedParams =
          jsonDecode(decoded.paramsJson!) as Map<String, dynamic>;
      expect(decodedParams['isMale'], true);
    });

    test('decode 后 paramsJson 能回填（原 chartResultJson）', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');
      final decoded = codec.decode(encoded.meta, encoded.moduleData);

      expect(decoded.paramsJson, isNotNull);
      expect(decoded.paramsJson!.isNotEmpty, isTrue);
    });

    test('decode 后 uuid 以 meta.uuid 为准（SSOT）', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');
      final decoded = codec.decode(encoded.meta, encoded.moduleData);

      expect(decoded.uuid, '');
    });

    test('decode uuid 优先级：meta.uuid 优于 chartJson 中的 uuid', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');

      final chartMap =
          jsonDecode(encoded.moduleData!['chartJson']) as Map<String, dynamic>;
      final fakeJson = Map<String, dynamic>.from(chartMap);
      fakeJson['uuid'] = 'fake-uuid-from-chart-json';
      final tamperedModuleData =
          Map<String, dynamic>.from(encoded.moduleData!);
      tamperedModuleData['chartJson'] = jsonEncode(fakeJson);

      final decoded = codec.decode(encoded.meta, tamperedModuleData);

      expect(decoded.uuid, encoded.meta.uuid);
      expect(decoded.uuid, isNot('fake-uuid-from-chart-json'));
    });

    test('decode 错误 module 抛 RecordCodecMismatch', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');

      final badMeta = RecordMeta(
        uuid: encoded.meta.uuid,
        scopeUid: encoded.meta.scopeUid,
        module: 'ziwei',
        category: encoded.meta.category,
        divinationType: encoded.meta.divinationType,
        createdAt: encoded.meta.createdAt,
      );

      expect(
        () => codec.decode(badMeta, encoded.moduleData),
        throwsA(isA<RecordCodecMismatch>()),
      );
    });

    test('extractSearchTags 包含 gender、question、timezone、createdAt', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);
      final encoded = codec.encode(contract, scopeUid: 'test-scope');
      final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);

      final tagKeys = tags.map((t) => t.key).toSet();
      expect(tagKeys.contains('gender'), isTrue);
      expect(tagKeys.contains('question'), isTrue);
      expect(tagKeys.contains('timezone'), isTrue);
      expect(tagKeys.contains('createdAt'), isTrue);

      final genderTag = tags.firstWhere((t) => t.key == 'gender');
      expect(genderTag.value, 'M');
    });

    test('paramsJson 不含空壳 —— 有真实计算结果', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final contract = calculator.calculate(_buildMoment(), params);

      expect(contract.paramsJson, isNotNull, reason: 'paramsJson 不应为空壳');
      expect(contract.paramsJson!.length, greaterThan(100));
    });
  });

  group('TaiyiChartCalculator 纯函数约束', () {
    test('相同输入 => 相同 toJson', () {
      const calculator = TaiyiChartCalculator();
      const params = TaiyiChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 4.0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );

      final result1 = calculator.calculate(_buildMoment(), params);
      final result2 = calculator.calculate(_buildMoment(), params);

      expect(result1.toJson(), result2.toJson());
    });
  });
}
