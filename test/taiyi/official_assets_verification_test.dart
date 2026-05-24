import 'dart:convert';
import 'dart:io' as import_io;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_engine.dart';
import 'package:taiyishenshu/taiyi/core/calculation_context.dart';
import 'package:taiyishenshu/taiyi/data/official_json_repository.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/enums/gong.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OfficialJsonSchoolRepository repository;
  late DeityAlgorithmEngine engine;

  // Mock AssetBundle to load local files during test
  final mockAssets = <String, String>{};

  setUpAll(() {
    engine = DeityAlgorithmEngine();
    repository = OfficialJsonSchoolRepository(
      schoolIds: ['jingMirror', 'tongZong', 'jiCheng'],
      deityIds: ['taiYi', 'wenChang'],
    );

    // Populate mockAssets from real local files
    mockAssets['assets/schools/jingMirror.json'] =
        _readFile('assets/schools/jing-mirror.json');
    mockAssets['assets/schools/tongZong.json'] =
        _readFile('assets/schools/tong-zong.json');
    mockAssets['assets/schools/jiCheng.json'] =
        _readFile('assets/schools/ji-cheng.json');
    mockAssets['assets/deities/taiYi.json'] =
        _readFile('assets/deities/tai-yi.json');
    mockAssets['assets/deities/wenChang.json'] =
        _readFile('assets/deities/wen-chang.json');

    ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async {
        final Uint8List encoded = utf8.encoder.convert(message.toString());
        final String assetPath = utf8.decode(encoded); // This is not quite right but let's see
        // Actually rootBundle.loadString(path) sends path as message
        final String key = message != null ? utf8.decode(message.buffer.asUint8List()) : '';
        if (mockAssets.containsKey(key)) {
          return utf8.encoder.convert(mockAssets[key]!).buffer.asByteData();
        }
        return null;
      },
    );
  });

  group('Official Assets Verification', () {
    test('太乙在金镜派2026年位置验证', () async {
      final school = await repository.loadSchool('jingMirror');
      final deity = await repository.loadDeity('taiYi');

      expect(school, isNotNull);
      expect(deity, isNotNull);

      final accumulatedYear = school!.epoch.calculateAccumulatedYear(2026);
      expect(accumulatedYear, 1938583);

      final ctx = CalculationContext(
        ji: accumulatedYear,
        year: 2026,
        juNumber: (accumulatedYear - 1) % 60 + 1,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
      );

      final result = engine.execute(deity!, ctx);
      // 1938583 % 72 = 7, 7 ~/ 3 = 2, 乾(0) + 2 = 艮(2)? 
      // Wait, 1938583 % 72 = 7 is WRONG. 
      // 1938583 / 72 = 26924.76...
      // 26924 * 72 = 1938528
      // 1938583 - 1938528 = 55. 
      // 55 ~/ 3 = 18. 
      // 18 % 8 = 2. 0(乾), 1(离), 2(艮). Correct.
      expect(result.gong, EnumTaiYiGong.Gen);
    });

    test('文昌在金镜派2026年位置验证', () async {
      final school = await repository.loadSchool('jingMirror');
      final deity = await repository.loadDeity('wenChang');

      final accumulatedYear = school!.epoch.calculateAccumulatedYear(2026);
      final juNumber = (accumulatedYear - 1) % 60 + 1; // 55

      final ctx = CalculationContext(
        ji: accumulatedYear,
        year: 2026,
        juNumber: juNumber,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
      );

      final result = engine.execute(deity!, ctx);
      // juNumber = 55. 55 % 18 = 1.
      // 申(0) + 0 = 申.
      expect(result.gong, EnumTaiYiGong.Kun); // 申位属于坤宫
    });
  });
}

String _readFile(String path) {
  return import_io.File(path).readAsStringSync();
}
