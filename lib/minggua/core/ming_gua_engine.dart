import 'package:taiyishenshu/minggua/core/gua_sequence.dart';

/// 太乙命卦计算结果(内部模型)。
class MingGuaResult {
  final int accumulatedYear;
  final int remainder;
  final int guaIndex;
  final String benGuaName;
  final List<bool> benGuaYao;
  final int dongYaoPosition;
  final bool isYangChen;
  final String bianGuaName;
  final List<bool> bianGuaYao;

  const MingGuaResult({
    required this.accumulatedYear,
    required this.remainder,
    required this.guaIndex,
    required this.benGuaName,
    required this.benGuaYao,
    required this.dongYaoPosition,
    required this.isYangChen,
    required this.bianGuaName,
    required this.bianGuaYao,
  });
}

/// 太乙命卦核心引擎。
/// [guaSequence]: 64卦序(默认统宗卷十三序)。
/// [epochBase]: 积年基数(统宗=10153917)。
class MingGuaEngine {
  final List<String> guaSequence;
  final int epochBase;

  const MingGuaEngine({
    this.guaSequence = kTaiYiGuaSequence,
    this.epochBase = 10153917,
  });

  /// 计算命卦。[year]=公元年份(正数为公元后)。
  MingGuaResult calculate({required int year}) {
    final accYear = year + epochBase;
    final rawRemainder = accYear % 64;
    final remainder = rawRemainder == 0 ? 64 : rawRemainder;
    final guaIndex = rawRemainder == 0 ? 64 : rawRemainder;

    // 卦序:统宗卷十三64卦序索引 0..63,序号 1..64
    final benGuaName = guaSequence[guaIndex - 1];
    final benGuaYao = kGuaYaoMap[benGuaName]!;

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

    return MingGuaResult(
      accumulatedYear: accYear,
      remainder: remainder,
      guaIndex: guaIndex,
      benGuaName: benGuaName,
      benGuaYao: benGuaYao,
      dongYaoPosition: dongYaoPosition,
      isYangChen: isYangChen,
      bianGuaName: bianGuaName,
      bianGuaYao: bianGuaYao,
    );
  }
}
