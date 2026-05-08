import 'package:flutter_test/flutter_test.dart';

import 'package:taiyishenshu/enums/eight_door.dart';
import 'package:taiyishenshu/enums/gong.dart';
import 'package:taiyishenshu/enums/gui_shen.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart';

void main() {
  group('Year eye rules', () {
    const cases = <({
      int year,
      String tianMuName,
      String jiShenName,
      String shiJiName,
      EnumTaiYiGong tianMuGong,
      EnumTaiYiGong jiShenGong,
      EnumTaiYiGong shiJiGong,
    })>[
      (
        year: 2020,
        tianMuName: '巽',
        jiShenName: '寅',
        shiJiName: '辰',
        tianMuGong: EnumTaiYiGong.Xun,
        jiShenGong: EnumTaiYiGong.Gen,
        shiJiGong: EnumTaiYiGong.Xun,
      ),
      (
        year: 2024,
        tianMuName: '坤',
        jiShenName: '戌',
        shiJiName: '亥',
        tianMuGong: EnumTaiYiGong.Kun,
        jiShenGong: EnumTaiYiGong.Qian,
        shiJiGong: EnumTaiYiGong.Qian,
      ),
      (
        year: 2026,
        tianMuName: '申',
        jiShenName: '申',
        shiJiName: '艮',
        tianMuGong: EnumTaiYiGong.Kun,
        jiShenGong: EnumTaiYiGong.Kun,
        shiJiGong: EnumTaiYiGong.Gen,
      ),
    ];

    for (final school in [TaiYiSchool.jingMirror, TaiYiSchool.tongZong]) {
      for (final c in cases) {
        test('${school.name} ${c.year}', () {
          final pan = const TaiYiPanCalculator().calculate(
            dateTime: DateTime(c.year, 1, 1),
            school: school,
            chartType: TaiYiChartType.year,
          );

          expect(pan.renPan.tianMuName, c.tianMuName);
          expect(pan.renPan.jiShenName, c.jiShenName);
          expect(pan.renPan.shiJiName, c.shiJiName);

          expect(pan.renPan.tianMuGong, c.tianMuGong);
          expect(pan.renPan.jiShenGong, c.jiShenGong);
          expect(pan.renPan.shiJiGong, c.shiJiGong);
        });
      }
    }
  });

  group('Year host guest rules', () {
    test('jingMirror 2024 host/guest counts and generals', () {
      final pan = const TaiYiPanCalculator().calculate(
        dateTime: DateTime(2024, 1, 1),
        school: TaiYiSchool.jingMirror,
        chartType: TaiYiChartType.year,
      );

      expect(pan.renPan.tianMuName, '坤');
      expect(pan.renPan.shiJiName, '亥');
    expect(pan.hostGuest.hostCount, 38);
    expect(pan.hostGuest.guestCount, 25);
    expect(pan.hostGuest.dingCount, 14);
    expect(pan.hostGuest.hostPalace, EnumTaiYiGong.Kun);
    expect(pan.hostGuest.guestPalace, EnumTaiYiGong.Qian);

    expect(pan.tianPan.hostGeneralGong, EnumTaiYiGong.Kan);
    expect(pan.tianPan.hostDeputyGeneralGong, EnumTaiYiGong.Zhen);
    expect(pan.tianPan.guestGeneralGong, EnumTaiYiGong.Center);
    expect(pan.tianPan.guestDeputyGeneralGong, EnumTaiYiGong.Center);
  });

  test('tongZong 2024 host/guest counts and generals', () {
    final pan = const TaiYiPanCalculator().calculate(
      dateTime: DateTime(2024, 1, 1),
      school: TaiYiSchool.tongZong,
      chartType: TaiYiChartType.year,
    );

    expect(pan.renPan.tianMuName, '坤');
    expect(pan.renPan.shiJiName, '亥');
    expect(pan.hostGuest.hostCount, 38);
    expect(pan.hostGuest.guestCount, 25);
    expect(pan.hostGuest.dingCount, 14);
    expect(pan.hostGuest.hostPalace, EnumTaiYiGong.Kun);
    expect(pan.hostGuest.guestPalace, EnumTaiYiGong.Qian);

    expect(pan.tianPan.hostGeneralGong, EnumTaiYiGong.Kan);
    expect(pan.tianPan.hostDeputyGeneralGong, EnumTaiYiGong.Zhen);
    expect(pan.tianPan.guestGeneralGong, EnumTaiYiGong.Center);
    expect(pan.tianPan.guestDeputyGeneralGong, EnumTaiYiGong.Center);
  });

    test('jingMirror 2026 guest count', () {
      final pan = const TaiYiPanCalculator().calculate(
        dateTime: DateTime(2026, 1, 1),
        school: TaiYiSchool.jingMirror,
        chartType: TaiYiChartType.year,
      );

      expect(pan.renPan.shiJiName, '艮');
      expect(pan.hostGuest.guestCount, 3);
    });

  test('tongZong 2026 guest count', () {
    final pan = const TaiYiPanCalculator().calculate(
      dateTime: DateTime(2026, 1, 1),
      school: TaiYiSchool.tongZong,
      chartType: TaiYiChartType.year,
    );

    expect(pan.hostGuest.hostCount, 16);
    expect(pan.renPan.shiJiName, '艮');
    expect(pan.hostGuest.guestCount, 3);
    expect(pan.hostGuest.dingCount, 22);
  });

  test('tongZong 2026 three ji (jun/chen/min bases)', () {
    final pan = const TaiYiPanCalculator().calculate(
      dateTime: DateTime(2026, 1, 1),
      school: TaiYiSchool.tongZong,
      chartType: TaiYiChartType.year,
    );

    expect(pan.tianPan.junJiGong, EnumTaiYiGong.Xun);
    expect(pan.tianPan.junJiRuGongNianShu, 13);
    expect(pan.tianPan.chenJiGong, EnumTaiYiGong.Kan);
    expect(pan.tianPan.chenJiRuGongNianShu, 1);
    expect(pan.tianPan.minJiGong, EnumTaiYiGong.Xun);
  });

  test('tongZong 2004 siShen/tianYi/diYi/zhiFu', () {
    final pan = const TaiYiPanCalculator().calculate(
      dateTime: DateTime(2004, 1, 1),
      school: TaiYiSchool.tongZong,
      chartType: TaiYiChartType.year,
    );

    expect(pan.tianPan.siShenGong, EnumTaiYiGong.Kun);
    expect(pan.tianPan.siShenRuGongNianShu, 3);
    expect(pan.tianPan.tianYiGong2, EnumTaiYiGong.Zhen);
    expect(pan.tianPan.tianYiRuGongNianShu, 3);
    expect(pan.tianPan.diYiGong, EnumTaiYiGong.Kun);
    expect(pan.tianPan.diYiRuGongNianShu, 3);
    expect(pan.tianPan.zhiFuGong2, EnumTaiYiGong.Gen);
    expect(pan.tianPan.zhiFuRuGongNianShu, 3);
  });

  test('tongZong 2004 three qi and guiShen', () {
    final pan = const TaiYiPanCalculator().calculate(
      dateTime: DateTime(2004, 1, 1),
      school: TaiYiSchool.tongZong,
      chartType: TaiYiChartType.year,
    );

    expect(pan.shenPan.qingLongQiGong, EnumTaiYiGong.Kun);
    expect(pan.shenPan.heiQiGong, EnumTaiYiGong.Gen);
    expect(pan.shenPan.heiQiRuGongNianShu, 3);
    expect(pan.shenPan.chiQiGong, EnumTaiYiGong.Kun);
    expect(pan.shenPan.guiShenZhiShiGong, EnumTaiYiGong.Xun);
  });
  });

  test('tongZong 2004 three ji (jun/chen/min bases)', () {
    final pan = const TaiYiPanCalculator().calculate(
      dateTime: DateTime(2004, 1, 1),
      school: TaiYiSchool.tongZong,
      chartType: TaiYiChartType.year,
    );

    expect(pan.tianPan.junJiGong, EnumTaiYiGong.Xun);
    expect(pan.tianPan.junJiRuGongNianShu, 21);
    expect(pan.tianPan.chenJiGong, EnumTaiYiGong.Xun);
    expect(pan.tianPan.chenJiRuGongNianShu, 3);
    expect(pan.tianPan.minJiGong, EnumTaiYiGong.Li);
  });

  group('Year eight doors', () {
    test('jingMirror 2024 value door layout', () {
      final pan = const TaiYiPanCalculator().calculate(
        dateTime: DateTime(2024, 1, 1),
        school: TaiYiSchool.jingMirror,
        chartType: TaiYiChartType.year,
      );

      expect(pan.taiYiPalace, EnumTaiYiGong.Li);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Li], EnumEightDoor.Shang);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Kun], EnumEightDoor.Du);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Dui], EnumEightDoor.Jing);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Qian], EnumEightDoor.Si);
      expect(
          pan.eightDoorsByPalace[EnumTaiYiGong.Kan], EnumEightDoor.JingMen);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Gen], EnumEightDoor.Kai);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Zhen], EnumEightDoor.Xiu);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Xun], EnumEightDoor.Sheng);
    });

    test('tongZong 2024 value door layout', () {
      final pan = const TaiYiPanCalculator().calculate(
        dateTime: DateTime(2024, 1, 1),
        school: TaiYiSchool.tongZong,
        chartType: TaiYiChartType.year,
      );

      expect(pan.taiYiPalace, EnumTaiYiGong.Li);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Li], EnumEightDoor.Shang);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Kun], EnumEightDoor.Du);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Dui], EnumEightDoor.Jing);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Qian], EnumEightDoor.Si);
      expect(
          pan.eightDoorsByPalace[EnumTaiYiGong.Kan], EnumEightDoor.JingMen);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Gen], EnumEightDoor.Kai);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Zhen], EnumEightDoor.Xiu);
      expect(pan.eightDoorsByPalace[EnumTaiYiGong.Xun], EnumEightDoor.Sheng);
  });
});

group('Year guiShen (tongZong)', () {
  test('tongZong 2005 guiShen layout', () {
    final pan = const TaiYiPanCalculator().calculate(
      dateTime: DateTime(2005, 1, 1),
      school: TaiYiSchool.tongZong,
      chartType: TaiYiChartType.year,
    );

    final gs = pan.guiShen;
    expect(gs, isNotNull);
    expect(gs!.zhiShiGuiShen, EnumGuiShen.zhaoYao);
    expect(gs.zhiShiIndex, 7);
    expect(gs.of(EnumTaiYiGong.Center), EnumGuiShen.zhaoYao);
    expect(gs.of(EnumTaiYiGong.Dui), EnumGuiShen.tianFu);
    expect(gs.of(EnumTaiYiGong.Kun), EnumGuiShen.qingLong);
    expect(gs.of(EnumTaiYiGong.Kan), EnumGuiShen.xianChi);
    expect(gs.of(EnumTaiYiGong.Xun), EnumGuiShen.taiYin);
    expect(gs.of(EnumTaiYiGong.Qian), EnumGuiShen.tianYi);
    expect(gs.of(EnumTaiYiGong.Li), EnumGuiShen.taiYi);
    expect(gs.of(EnumTaiYiGong.Gen), EnumGuiShen.shetiTi);
    expect(gs.of(EnumTaiYiGong.Zhen), EnumGuiShen.xuanYuan);
  });
});
}
