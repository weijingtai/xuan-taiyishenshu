import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:xuan_gua_core/xuan_gua_core.dart';
import 'package:taiyishenshu/gua_core/gua_sequence.dart';

/// 太乙命卦核心引擎。
/// [guaSequence]: 64卦序(默认统宗卷十三序)。
/// [epochBase]: 积年基数(统宗=10153917)。
class MingGuaEngine {
  final List<Enum64Gua> guaSequence;
  final int epochBase;

  MingGuaEngine({
    List<Enum64Gua>? guaSequence,
    this.epochBase = 10153917,
  }) : guaSequence = guaSequence ?? kTaiYiGuaSequence;

  /// 计算命卦。[year]=公元年份(正数为公元后)。
  MingGuaResultContract calculate({required int year}) {
    final accYear = year + epochBase;
    final rawRemainder = accYear % 64;
    final remainder = rawRemainder == 0 ? 64 : rawRemainder;
    final guaIndex = rawRemainder == 0 ? 64 : rawRemainder;

    // 卦序:统宗卷十三64卦序索引 0..63,序号 1..64
    final benGua = guaSequence[guaIndex - 1];
    final benGuaYao = benGua.yaoBoolList;

    // 干支序:积年 mod 60,偶=阳辰
    final ganZhiIndex = (accYear - 1) % 60;
    final isYangChen = ganZhiIndex.isEven;

    // 动爻计算
    final yaoNum = rawRemainder == 0 ? 64 : rawRemainder;
    final int dongYaoPosition;
    if (isYangChen) {
      // 阳辰:从初爻向上数
      dongYaoPosition = ((yaoNum - 1) % 6) + 1;
    } else {
      // 阴辰:从上爻向下数
      dongYaoPosition = 6 - ((yaoNum - 1) % 6);
    }

    // 变卦:翻转动爻位的阴阳
    final bianGuaYao = List<bool>.from(benGuaYao);
    bianGuaYao[dongYaoPosition - 1] = !bianGuaYao[dongYaoPosition - 1];
    final bianGuaName = findGuaNameByYao(bianGuaYao) ?? '未知';

    return MingGuaResultContract(
      accumulatedYear: accYear,
      remainder: remainder,
      guaIndex: guaIndex,
      benGuaName: benGua.name,
      benGuaYao: benGuaYao,
      dongYaoPosition: dongYaoPosition,
      isYangChen: isYangChen,
      bianGuaName: bianGuaName,
      bianGuaYao: bianGuaYao,
    );
  }
}
