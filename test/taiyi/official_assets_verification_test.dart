import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_engine.dart';
import 'package:taiyishenshu/taiyi/core/calculation_context.dart';
import 'package:taiyishenshu/taiyi/core/school_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'package:taiyishenshu/enums/gong.dart';

void main() {
  late DeityAlgorithmEngine engine;

  setUpAll(() {
    engine = DeityAlgorithmEngine();
  });

  /// 从文件直接加载 TaiYiSchool
  TaiYiSchool loadSchool(String id) {
    final filename = id.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (m) => '${m.group(1)}-${m.group(2)!.toLowerCase()}',
    ).toLowerCase();
    final file = io.File('assets/schools/$filename.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return TaiYiSchool.fromJson(json);
  }

  /// 从文件直接加载 DeityDefinition
  DeityDefinition loadDeity(String id) {
    final filename = id.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (m) => '${m.group(1)}-${m.group(2)!.toLowerCase()}',
    ).toLowerCase();
    final file = io.File('assets/deities/$filename.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return DeityDefinition.fromJson(json);
  }

  group('Official Assets Verification', () {
    test('太乙在金镜派2026年位置验证', () {
      final school = loadSchool('jingMirror');
      final deity = loadDeity('taiYi');

      final accumulatedYear = school.epoch.calculateAccumulatedYear(2026);
      expect(accumulatedYear, 1938583);

      final ctx = CalculationContext(
        ji: accumulatedYear,
        year: 2026,
        juNumber: (accumulatedYear - 1) % 60 + 1,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
      );

      final result = engine.execute(deity, ctx);
      expect(result.gong, EnumTaiYiGong.Gen);
    });

    test('文昌在金镜派2026年位置验证', () {
      final school = loadSchool('jingMirror');
      final deity = loadDeity('wenChang');

      final accumulatedYear = school.epoch.calculateAccumulatedYear(2026);
      final juNumber = (accumulatedYear - 1) % 60 + 1;

      final ctx = CalculationContext(
        ji: accumulatedYear,
        year: 2026,
        juNumber: juNumber,
        dun: DunType.yang,
        chartType: TaiYiChartType.year,
      );

      final result = engine.execute(deity, ctx);
      expect(result.gong, EnumTaiYiGong.Kun);
    });

    group('Regression - Official File Paths', () {
      test('kebab-case 文件存在且可加载', () {
        final school = loadSchool('jingMirror');
        final deity = loadDeity('taiYi');

        expect(school.id, isNotEmpty);
        expect(deity.id, isNotEmpty);
      });
    });
  });
}
