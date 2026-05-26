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

  final mockAssets = <String, String>{};

  setUpAll(() {
    engine = DeityAlgorithmEngine();
    repository = OfficialJsonSchoolRepository(
      schoolIds: ['jingMirror', 'tongZong', 'jiCheng'],
      deityIds: ['taiYi', 'wenChang'],
    );

    mockAssets['assets/schools/jing-mirror.json'] =
        _readFile('assets/schools/jing-mirror.json');
    mockAssets['assets/schools/tong-zong.json'] =
        _readFile('assets/schools/tong-zong.json');
    mockAssets['assets/schools/ji-cheng.json'] =
        _readFile('assets/schools/ji-cheng.json');
    mockAssets['assets/deities/tai-yi.json'] =
        _readFile('assets/deities/tai-yi.json');
    mockAssets['assets/deities/wen-chang.json'] =
        _readFile('assets/deities/wen-chang.json');

    ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async {
        if (message == null) return null;
        final String key = utf8.decode(message.buffer.asUint8List());
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
      expect(result.gong, EnumTaiYiGong.Gen);
    });

    test('文昌在金镜派2026年位置验证', () async {
      final school = await repository.loadSchool('jingMirror');
      final deity = await repository.loadDeity('wenChang');

      final accumulatedYear = school!.epoch.calculateAccumulatedYear(2026);
      final juNumber = (accumulatedYear - 1) % 60 + 1;

      final ctx = CalculationContext(
        ji: accumulatedYear,
        year: 2026,
        juNumber: juNumber,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
      );

      final result = engine.execute(deity!, ctx);
      expect(result.gong, EnumTaiYiGong.Kun);
    });

   group('Regression - Official File Paths', () {
    test('OfficialJsonSchoolRepository follows kebab-case convention', () async {
      final repo = OfficialJsonSchoolRepository(
        schoolIds: ['jingMirror'],
        deityIds: ['taiYi'],
      );
      
      final school = await repo.loadSchool('jingMirror');
      final deity = await repo.loadDeity('taiYi');
      
      expect(school, isNotNull, reason: 'Should load jingMirror from assets/schools/jing-mirror.json');
      expect(deity, isNotNull, reason: 'Should load taiYi from assets/deities/tai-yi.json');
    });
  });
  });
}

String _readFile(String path) {
  return import_io.File(path).readAsStringSync();
}
