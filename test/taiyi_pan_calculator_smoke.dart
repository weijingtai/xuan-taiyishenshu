// ignore_for_file: avoid_relative_lib_imports

import '../lib/enums/gong.dart';
import '../lib/taiyi/taiyi.dart';

/// 不依赖 flutter_test 的轻量起盘验证。
///
/// 这个文件用于在包解析不完整或 Flutter 测试环境不可用时，仍可通过
/// `dart --enable-asserts` 验证核心起盘模型与计算入口。
Future<void> main() async {
  final calculator = TaiYiPanCalculator();
  // final time = DateTime(2026, 4, 30, 15);

  void expectYearRenPan_tongZong(
    int year, {
    required String expectedTianMuName,
    required String expectedJiShenName,
    required String expectedShiJiName,
    required EnumTaiYiGong expectedTianMu,
    required EnumTaiYiGong expectedJiShen,
    required EnumTaiYiGong expectedShiJi,
  }) {
    final pan = calculator.calculate(
      dateTime: DateTime(year, 1, 1),
      school: TaiYiSchool.tongZong,
      chartType: TaiYiChartType.year,
    );
    assert(pan.renPan.tianMuName == expectedTianMuName);
    assert(pan.renPan.jiShenName == expectedJiShenName);
    assert(pan.renPan.shiJiName == expectedShiJiName);
    assert(pan.renPan.tianMuGong == expectedTianMu);
    assert(pan.renPan.jiShenGong == expectedJiShen);
    assert(pan.renPan.shiJiGong == expectedShiJi);
  }

  // assert(EnumTaiYiGong.Qian.id == 'Qian');
  // assert(TaiYiGongId.fromId('Qian') == EnumTaiYiGong.Qian);

  // final jingMirror = calculator.calculate(dateTime: time);
  // assert(jingMirror.input.school == TaiYiSchool.jingMirror);
  // assert(jingMirror.input.chartType == TaiYiChartType.year);
  // assert(jingMirror.accumulatedYear == 10155943);
  // assert(jingMirror.juNumber >= 1 && jingMirror.juNumber <= 72);
  // assert(jingMirror.palaces.length == 9);
  // assert(jingMirror.eightDoorsByPalace.length == 8);
  // assert(EnumTaiYiGong.values.contains(jingMirror.taiYiPalace));
  // assert(
  //   jingMirror.palaces.any(
  //     (palace) => palace.items.any((item) => item.name == '太乙'),
  //   ),
  // );
  // assert(
  //   jingMirror.palaces.any(
  //     (palace) => palace.items.any(
  //       (item) => item.kind == PanComputedItemKind.eightDoor,
  //     ),
  //   ),
  // );
  // assert(jingMirror.toJson()['taiYiPalace'] is String);

  // final tongZong = calculator.calculate(
  //   dateTime: time,
  //   school: TaiYiSchool.tongZong,
  // );
  // assert(tongZong.accumulatedYear == jingMirror.accumulatedYear + 250);

  // final jiCheng = calculator.calculate(
  //   dateTime: time,
  //   school: TaiYiSchool.jiCheng,
  // );
  // assert(jiCheng.accumulatedYear == 343);
  // assert(jiCheng.eightDoorsByPalace[EnumTaiYiGong.Qian] == EnumEightDoor.Kai);

  // final customPan = await calculator.calculateWithCustomDeities(
  //   dateTime: time,
  //   customDeityRepository: InMemoryCustomDeityRepository([
  //     const CustomDeityDefinition(
  //       id: 'custom:test:ju-offset',
  //       name: '试神',
  //       school: TaiYiSchool.jingMirror,
  //       enabled: true,
  //       priority: 300,
  //       algorithm: CustomDeityAlgorithmSpec(
  //         templateId: 'juOffset',
  //         version: 1,
  //         params: {
  //           'startGongId': 'Qian',
  //           'step': 1,
  //           'offset': 0,
  //         },
  //       ),
  //     ),
  //     const CustomDeityDefinition(
  //       id: 'custom:test:unplaced',
  //       name: '未落神',
  //       school: TaiYiSchool.jingMirror,
  //       enabled: true,
  //       priority: 301,
  //       algorithm: CustomDeityAlgorithmSpec(
  //         templateId: 'unknown',
  //         version: 1,
  //         params: {},
  //       ),
  //     ),
  //   ]),
  // );
  // assert(
  //   customPan.palaces.any(
  //     (palace) =>
  //         palace.items.any((item) => item.id == 'custom:test:ju-offset'),
  //   ),
  // );
  // assert(
  //   customPan.unplacedItems.any((item) => item.id == 'custom:test:unplaced'),
  // );

  // final hourPan = calculator.calculate(
  //   dateTime: DateTime(2026, 7, 1, 10),
  //   chartType: TaiYiChartType.hour,
  // );
  // assert(hourPan.dunType == DunType.yin);

  expectYearRenPan_tongZong(
    2020,
    expectedTianMuName: '巽',
    expectedJiShenName: '寅',
    expectedShiJiName: '辰',
    expectedTianMu: EnumTaiYiGong.Xun,
    expectedJiShen: EnumTaiYiGong.Gen,
    expectedShiJi: EnumTaiYiGong.Xun,
  );
  expectYearRenPan_tongZong(
    2026,
    expectedTianMuName: '申',
    expectedJiShenName: '申',
    expectedShiJiName: '艮',
    expectedTianMu: EnumTaiYiGong.Kun,
    expectedJiShen: EnumTaiYiGong.Kun,
    expectedShiJi: EnumTaiYiGong.Gen,
  );
  expectYearRenPan_tongZong(
    2024,
    expectedTianMuName: '坤',
    expectedJiShenName: '戌',
    expectedShiJiName: '亥',
    expectedTianMu: EnumTaiYiGong.Kun,
    expectedJiShen: EnumTaiYiGong.Qian,
    expectedShiJi: EnumTaiYiGong.Qian,
  );

  // var threwUnsupportedError = false;
  // try {
  //   calculator.calculate(
  //     dateTime: time,
  //     chartType: TaiYiChartType.ke,
  //   );
  // } on UnsupportedError {
  //   threwUnsupportedError = true;
  // }
  // assert(threwUnsupportedError);
}
