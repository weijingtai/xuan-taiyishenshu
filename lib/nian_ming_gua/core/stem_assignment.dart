/// 五阳干循环配爻算法 — 太乙年命卦"天地否泰之运"体系核心。
///
/// 五阳干序列: G = [甲, 戊, 壬, 丙, 庚]（固定循环）
/// 地支: 全爻固定 = 子

/// 五阳干序列（固定）。
const kYangStems = ['甲', '戊', '壬', '丙', '庚'];

/// 六爻地支（固定"子"）。
const kFixedBranch = '子';

/// 按五阳干循环为六爻分配天干。
///
/// [startIndex]: 起始天干在 kYangStems 中的索引 (0=甲,1=戊,2=壬,3=丙,4=庚)。
/// [repeatAtYao4]: 是否在第4爻重复（天地否泰之运专用）。
///
/// 当 [repeatAtYao4] 为 false 时，从 startIndex 开始顺序循环赋值六爻。
///
/// 当 [repeatAtYao4] 为 true 时，使用"反射"模式:
/// - 起始方向由 startIndex 决定: <3 → 正向(+1), >=3 → 反向(-1)
/// - 前三爻按方向循环，后三爻对称反射（第4=第2, 第5=第1, 第6=甲）
///
/// 验证:
/// - 乾(start=0, repeat=false): [甲,戊,壬,丙,庚,甲]
/// - 坤(start=4, repeat=false): [庚,甲,戊,壬,丙,庚]
/// - 否(start=1, repeat=true):  [戊,壬,丙,壬,戊,甲]
/// - 泰(start=4, repeat=true):  [庚,丙,壬,丙,庚,甲]
List<String> assignStems(int startIndex, bool repeatAtYao4) {
  final stems = <String>[];

  if (!repeatAtYao4) {
    // 简单正向循环
    int cursor = startIndex;
    for (int i = 0; i < 6; i++) {
      stems.add(kYangStems[cursor % 5]);
      cursor++;
    }
  } else {
    // 反射模式: startIndex < 3 → 正向, >= 3 → 反向
    final dir = startIndex < 3 ? 1 : -1;
    // 前三爻按方向循环
    for (int i = 0; i < 3; i++) {
      final idx = ((startIndex + i * dir) % 5 + 5) % 5;
      stems.add(kYangStems[idx]);
    }
    // 后三爻对称反射: 第4=第2, 第5=第1, 第6=甲
    stems.add(stems[1]);
    stems.add(stems[0]);
    stems.add(kYangStems[0]); // 甲
  }
  return stems;
}
