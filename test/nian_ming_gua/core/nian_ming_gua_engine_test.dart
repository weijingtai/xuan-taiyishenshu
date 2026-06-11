import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/nian_ming_gua/core/nian_ming_gua_engine.dart';

void main() {
  group('NianMingGuaEngine integration tests', () {
    late List<NianMingGuaConfigContract> configs;

    setUpAll(() {
      final file = File('assets/nian_ming_gua/sixty_four_gua_stems.json');
      final jsonList = jsonDecode(file.readAsStringSync()) as List;
      configs = jsonList
          .map((e) => NianMingGuaConfigContract.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    test('year=1 with default epochBase=10153917 (Mathematical correct remainder=62)', () {
      final engine = NianMingGuaEngine(configs: configs);
      final r = engine.calculate(year: 1);

      // 1 + 10153917 = 10153918
      // 10153918 % 64 == 62 -> 小过
      expect(r.accumulatedYear, 10153918);
      expect(r.guaIndex, 62);
      expect(r.guaName, '小过');
      expect(r.yao, [false, false, true, true, false, false]); // 小过=震上艮下
      expect(r.yangYaoCount, 2);
      expect(r.yinYaoCount, 4);
      expect(r.ceCount, 168);
      expect(r.stems, ['戊', '壬', '丙', '庚', '甲', '戊']);
      expect(r.branch, '子');
      expect(r.yunIndex, 11);
      expect(r.yunName, '运十一');
    });

    test('year=1 with custom epochBase=10153885 (resulting in remainder=30 to verify 离)', () {
      // 1 + 10153885 = 10153886
      // 10153886 % 64 == 30 -> 离
      final engine = NianMingGuaEngine(epochBase: 10153885, configs: configs);
      final r = engine.calculate(year: 1);

      expect(r.accumulatedYear, 10153886);
      expect(r.guaIndex, 30);
      expect(r.guaName, '离');
      expect(r.yao, [true, false, true, true, false, true]);
      expect(r.yangYaoCount, 4);
      expect(r.yinYaoCount, 2);
      expect(r.ceCount, 192);
      expect(r.stems, ['庚', '甲', '戊', '壬', '丙', '庚']);
      expect(r.branch, '子');
      expect(r.yunIndex, 5);
      expect(r.yunName, '资育还本之运');
    });

    test('year=2026 integration test', () {
      final engine = NianMingGuaEngine(configs: configs);
      final r = engine.calculate(year: 2026);

      // 2026 + 10153917 = 10155943
      // 10155943 % 64 = 39 -> 蹇
      expect(r.accumulatedYear, 10155943);
      expect(r.guaIndex, 39);
      expect(r.guaName, '蹇');
      expect(r.yao, [false, false, true, false, true, false]);
      expect(r.yangYaoCount, 2);
      expect(r.yinYaoCount, 4);
      expect(r.ceCount, 168);
      expect(r.stems, ['丙', '庚', '甲', '戊', '壬', '丙']);
      expect(r.branch, '子');
      expect(r.yunIndex, 6);
      expect(r.yunName, '造化符天之运');
    });

    test('year=4 makes remainder=1 (乾卦年份验证)', () {
      final engine = NianMingGuaEngine(configs: configs);
      final r = engine.calculate(year: 4);

      // 4 + 10153917 = 10153921
      // 10153921 % 64 = 1 -> 乾
      expect(r.accumulatedYear, 10153921);
      expect(r.guaIndex, 1);
      expect(r.guaName, '乾');
      expect(r.yao, [true, true, true, true, true, true]);
      expect(r.yangYaoCount, 6);
      expect(r.yinYaoCount, 0);
      expect(r.ceCount, 216);
      expect(r.stems, ['甲', '戊', '壬', '丙', '庚', '甲']);
      expect(r.branch, '子');
      expect(r.yunIndex, 1);
      expect(r.yunName, '天地否泰之运');
    });

    test('StateError is thrown when config is missing', () {
      final incompleteConfigs = configs.where((c) => c.guaName != '乾').toList();
      final engine = NianMingGuaEngine(configs: incompleteConfigs);
      expect(() => engine.calculate(year: 4), throwsStateError);
    });
  });
}
