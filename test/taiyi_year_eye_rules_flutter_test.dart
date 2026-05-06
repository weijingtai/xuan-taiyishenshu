import 'package:flutter_test/flutter_test.dart';

import 'package:taiyishenshu/enums/gong.dart';
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
}
