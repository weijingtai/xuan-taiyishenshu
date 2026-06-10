/// 直符太乙计算器
///
/// 定义: 天帝之使者，巡察天下，掌水旱、蝗灾、兵革、疾疫、饥馑、流亡
/// 五行: 火
/// 周期: 3年移一宫，36年一周（12宫×3年）
/// 行序: 5(中宫)→6→7→8→9→绛宫→明堂→玉堂→1→2→3→4
///
/// 算法（金镜/统宗/福应经 同法，仅积年不同）:
/// 1. R360 = J % 360 (入局数)
/// 2. R36 = R360 % 36 (直符小周余数)
/// 3. n = R36 / 3 (宫数), t = R36 % 3 (入宫年数)
/// 4. 查十二宫行序表得直符宫
class ZhiFuCalculator {
  /// 十二宫行序 (n=0~11)
  /// 古歌: 五六七八九，绛明玉一二三四
  static const List<String> palaceOrder = [
    '中',    // n=0, 宫本数5
    '兑',    // n=1, 宫本数6
    '坤',    // n=2, 宫本数7
    '坎',    // n=3, 宫本数8
    '巽',    // n=4, 宫本数9
    '绛宫',  // n=5, 寄宫
    '明堂',  // n=6, 寄宫
    '玉堂',  // n=7, 寄宫
    '乾',    // n=8, 宫本数1
    '离',    // n=9, 宫本数2
    '艮',    // n=10, 宫本数3
    '震',    // n=11, 宫本数4
  ];

  /// 计算直符宫位
  ///
  /// [accumulatedYear] 积年数（已按派别计算好的 J）
  /// 返回: (宫名, 入宫年数 t: 0=初入, 1=中, 2=末)
  static ({String palace, int yearInPalace}) calculate(int accumulatedYear) {
    // 步骤1: 入局数 (大周360)
    final r360 = accumulatedYear % 360;

    // 步骤2: 直符小周余数 (36年一周)
    final r36 = r360 % 36;

    // 步骤3: 宫数 n 与入宫年数 t (每宫3年)
    final n = r36 ~/ 3;
    final t = r36 % 3;

    // 步骤4: 查宫
    final palace = palaceOrder[n];

    return (palace: palace, yearInPalace: t);
  }

  /// 计算直符宫位（简化版，只返回宫名）
  static String calculatePalace(int accumulatedYear) {
    return calculate(accumulatedYear).palace;
  }
}
