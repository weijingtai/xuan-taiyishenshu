import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/rules/foundation_result.dart';
import 'package:taiyishenshu/enums/gong.dart';

/// Task §9: Calculator Integration Test.
///
/// 验证 FoundationResult.fromSchoolId() (新规则引擎) 与现有
/// TaiYiPanCalculator.calculate() (遗留硬编码路径) 产生一致结果。
///
/// Decision recorded in calculator_api_contract_test.dart:
///   - 保留同步兼容层：public calculate() 签名不变。
///   - 新规则引擎通过 FoundationResult.fromSchoolId() 以同步方式桥接。
///   - 所有受影响调用方（smoke test, vector test）无需变更。
void main() {
  group('FoundationResult bridge — jingMirror year vectors', () {
    // These vectors match those in jing_mirror_year_standard_vectors_test.dart
    // and taiyi_pan_calculator_smoke.dart (source of truth = PoC + existing tests).
    final cases = <({
      int year,
      int expectedAccumulatedYear,
      int expectedJuNumber,
      String expectedRuGongLabel,
      int expectedWuZiYuanJu,
      int expectedYuanShu,
      String expectedYuanName,
      int expectedRuJiJiShu,
      int expectedHostCount,
      int expectedGuestCount,
      int expectedDingCount,
      // taiYi palace
      EnumTaiYiGong expectedTaiYiGong,
    })>[
      (
        year: 2026,
        expectedAccumulatedYear: 1938583,
        expectedJuNumber: 55,
        expectedRuGongLabel: '理天',
        expectedWuZiYuanJu: 343,
        expectedYuanShu: 5,
        expectedYuanName: '壬子元',
        expectedRuJiJiShu: 6,
        expectedHostCount: 16,
        expectedGuestCount: 3,
        expectedDingCount: 22,
        expectedTaiYiGong: EnumTaiYiGong.Gen,
      ),
      (
        year: 2027,
        expectedAccumulatedYear: 1938584,
        expectedJuNumber: 56,
        expectedRuGongLabel: '理地',
        expectedWuZiYuanJu: 344,
        expectedYuanShu: 5,
        expectedYuanName: '壬子元',
        expectedRuJiJiShu: 6,
        expectedHostCount: 15,
        expectedGuestCount: 34,
        expectedDingCount: 10,
        expectedTaiYiGong: EnumTaiYiGong.Gen,
      ),
      (
        year: 1949,
        expectedAccumulatedYear: 1938506,
        expectedJuNumber: 50,
        expectedRuGongLabel: '理地',
        expectedWuZiYuanJu: 266,
        expectedYuanShu: 4,
        expectedYuanName: '庚子元',
        expectedRuJiJiShu: 5,
        expectedHostCount: 16,
        expectedGuestCount: 15,
        expectedDingCount: 15,
        expectedTaiYiGong: EnumTaiYiGong.Qian,
      ),
    ];

    for (final c in cases) {
      test('jingMirror year ${c.year}: rule engine matches legacy vector', () {
        // Build via new rule engine path (synchronous, no Flutter asset needed)
        final result = FoundationResult.fromSchoolId(
          schoolId: 'jingMirror',
          year: c.year,
          isYang: true,
        );

        expect(result, isNotNull,
            reason: 'SchoolRepository must load jingMirror synchronously');
        expect(result!.accumulatedYear, c.expectedAccumulatedYear,
            reason: '积年');
        expect(result.juNumber, c.expectedJuNumber,
            reason: '局数');
        expect(result.ruGongLabel, c.expectedRuGongLabel,
            reason: '入宫标签');
        expect(result.wuZiYuanJu, c.expectedWuZiYuanJu,
            reason: '五子元局');
        expect(result.yuanShu, c.expectedYuanShu,
            reason: '元数');
        expect(result.yuanName, c.expectedYuanName,
            reason: '元名');
        expect(result.ruJiJiShu, c.expectedRuJiJiShu,
            reason: '入纪纪数');
        expect(result.hostCount, c.expectedHostCount,
            reason: '主算');
        expect(result.guestCount, c.expectedGuestCount,
            reason: '客算');
        expect(result.dingCount, c.expectedDingCount,
            reason: '定算');
        expect(result.taiYiGong, c.expectedTaiYiGong,
            reason: '太乙宫');
      });
    }
  });

  group('FoundationResult bridge — tongZong year vectors', () {
    // Vectors from taiyi_pan_calculator_smoke.dart tongZong expectations
    final tongZongCases = <({
      int year,
      int expectedHostCount,
      int expectedGuestCount,
      String expectedWenChangName, // deity name
      EnumTaiYiGong expectedWenChangGong,
    })>[
      (
        year: 2026,
        expectedHostCount: 16,
        expectedGuestCount: 3,
        expectedWenChangName: '申',
        expectedWenChangGong: EnumTaiYiGong.Kun,
      ),
      (
        year: 2024,
        expectedHostCount: 38,
        expectedGuestCount: 25,
        expectedWenChangName: '坤',
        expectedWenChangGong: EnumTaiYiGong.Kun,
      ),
    ];

    for (final c in tongZongCases) {
      test('tongZong year ${c.year}: rule engine host/guest counts match', () {
        final result = FoundationResult.fromSchoolId(
          schoolId: 'tongZong',
          year: c.year,
          isYang: true,
        );

        expect(result, isNotNull,
            reason: 'SchoolRepository must load tongZong synchronously');
        expect(result!.hostCount, c.expectedHostCount, reason: '主算');
        expect(result.guestCount, c.expectedGuestCount, reason: '客算');
      });
    }
  });

  group('FoundationResult synchronous compatibility', () {
    test('returns null for unknown school (no throw)', () {
      final result = FoundationResult.fromSchoolId(
        schoolId: 'unknownSchool',
        year: 2026,
      );
      expect(result, isNull);
    });

    test('accepts snake_case school id', () {
      final result = FoundationResult.fromSchoolId(
        schoolId: 'jing_mirror',
        year: 2026,
      );
      expect(result, isNotNull);
      expect(result!.accumulatedYear, 1938583);
    });

    test('tradition reflects school name', () {
      final result = FoundationResult.fromSchoolId(
        schoolId: 'jingMirror',
        year: 2026,
      );
      expect(result?.tradition, '金镜派');
    });

    test('profileId reflects school meta.id', () {
      final result = FoundationResult.fromSchoolId(
        schoolId: 'jingMirror',
        year: 2026,
      );
      // meta.id in JSON is 'jing_mirror'
      expect(result?.profileId, 'jing_mirror');
    });

    test('verificationStatus is engine-derived', () {
      final result = FoundationResult.fromSchoolId(
        schoolId: 'jingMirror',
        year: 2026,
      );
      expect(result?.verificationStatus, 'engine-derived');
    });
  });
}
