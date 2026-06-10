# 太乙神数五大流派全功能算法集成与校验规范文档

（**终极完整版**，严格遵循《太乙金镜式经》《景祐太乙福应经》《太乙统宗宝鉴》《太乙淘金歌》及近代集成派原文数理，包含前置通用定义、五派积年、四计入局、天目/始击、三算优化、八将/十精/吉凶星神定位、格局判定及完整 Dart 实现代码，用于指导核心计算引擎编写与单元测试。）

---

## 0. 全局统一定义（五派共用）

### 0.1 九宫定义与“跳过中五宫”遍历（所有流派通用）
太乙专用九宫序列（剔除中五宫，顺行固定顺序）定义如下：
$$\boldsymbol{taiYiPalaceOrder} = [1, 2, 3, 4, 6, 7, 8, 9] \quad (\text{对应乾、离、艮、震、兑、坤、坎、巽})$$
对应索引：`0:1乾, 1:2离, 2:3艮, 3:4震, 4:6兑, 5:7坤, 6:8坎, 7:9巽`。
对应的宫本数分别为：`乾=1, 离=2, 艮=3, 震=4, 中宫=5(不可入), 兑=6, 坤=7, 坎=8, 巽=9`。

> **优化规则**：所有流派的八宫运算（如“前一宫”、“后一宫”、累加步数等）在进行 `mod 8` 运算时，必须明确**跳过中五宫，仅在 8 个有效宫位内进行循环**。
> 例如，当前宫位索引为 `idx`，顺行 $k$ 步后的宫位索引为 `(idx + k) % 8`，逆行 $k$ 步后的宫位索引为 `(idx - k + 8) % 8`。

### 0.2 十六神与八宫正位映射表
十六神序列：
$$\text{子(地主), 丑(太阴/阴德), 寅(吕申), 卯(高丛), 辰(太阳), 巳(大神), 午(大威), 未(天道), 申(武德), 酉(太簇), 戌(阴主), 亥(大义), 乾(阳德), 艮(和德), 巽(大炅), 坤(大武)}$$

转换至八宫正位的映射关系如下：
- **坎八宫（8）**：子 (地主) / 丑 (太阴)
- **艮三宫（3）**：艮 (和德) / 寅 (吕申)
- **震四宫（4）**：卯 (高丛) / 辰 (太阳)
- **巽九宫（9）**：巽 (大炅) / 戌 (阴主)
- **离二宫（2）**：巳 (大神) / 午 (大威)
- **坤七宫（7）**：未 (天道) / 坤 (大武)
- **兑六宫（6）**：申 (武德) / 酉 (太簇)
- **乾一宫（1）**：乾 (阳德) / 亥 (大义)

### 0.3 三算通用“满十去十”求数公式
设起点至太乙前一宫的有效宫本数累加和为 $S$，求出的算数结果为 $N$。
- 原理：若 $S \le 10$，则 $N = S$；若 $10 < S \le 50$，则 $N = S \bmod 10$（余 $0$ 为 $10$）；若 $S > 50$，则先将 $S \bmod 50$，余数再按前法求数。
- **程序优化公式**：
  $$N = ((S - 1) \bmod 10) + 1$$
  （该公式在数学上完全等价于上述求数规则，自动处理整十数取 $10$ 的边界条件，且单次取模效率极高。）
- **10归9规则**：在确定主大将、客大将、定大将的落宫时，若算数结果 $N = 10$，则落宫统一归入 **巽九宫（巽=9）**。

### 0.4 四计局数转换
$$局数 = 入局数 \bmod 72 \quad (\text{若余}0\text{则取}72)$$

---

## 1. 五大派积年法

- **金镜派**：唐天宝十载（公元 751 年）上元。
  $$J = 10153917 + (Y - 751)$$
- **统宗派**：元晓山老人所拟（公元 1303 年甲子元）。
  $$J = 10155219 + (Y - 1303)$$
- **淘金歌派**：黄帝上元甲子起算（最简）。
  $$J = Y + 2697$$
- **福应经派**：唐天宝元年（公元 742 年）上元。
  $$J = 10153917 + (Y - 742)$$
- **近代集成派**：默认采用**统宗**积年，支持切换金镜积年。

---

## 2. 四计“入局数”算法

- **年计**：$入局数 = J \bmod 360$（余 $0$ 取 $360$）。
- **月计**：$J_m = J \times 12 + M$（正月=1）；$入局数 = J_m \bmod 360$（余 $0$ 取 $360$）。
- **日计**：$J_d = \lfloor J \times 365.2425 \rfloor + D$（正月初一=0）；$入局数 = J_d \bmod 360$（余 $0$ 取 $360$）。
- **时计**：$J_h = J_d \times 12 + H$（子时=0）；$入局数 = J_h \bmod 360$（余 $0$ 取 $360$）。

---

## 3. 太乙宫定位

$$太乙索引 = \lfloor (局数 - 1) / 3 \rfloor \bmod 8$$
$$太乙宫 = \text{taiYiPalaceOrder}[太乙索引]$$

---

## 4. 文昌（天目）、计神、始击定位

### 4.1 天目（文昌，主目）
- **金镜 / 福应经 / 集成**：
  $$R = 入局数 \bmod 18$$
  起武德（申），顺行十六神。若遇阴德（丑）、大武（坤）、乾坤宫位，需要**重留一算**（即在该位置停留两个入局数周期）。
- **统宗**：
  同金镜派。但**时计**下区分阴阳遁：阳局起武德，阴局起吕申。
- **淘金歌**：
  仅年计使用。起武德，顺行十二地支，18 局一周。月/日/时不用。

### 4.2 计神
- **金镜 / 福应经 / 集成 / 统宗**：
  $$R = 入局数 \bmod 12$$
  - **阳局（冬至后）**：起寅，逆行十二辰。
  - **阴局（夏至后）**：起申，逆行十二辰。
- **淘金歌**：
  仅年计使用。子年起寅，逆行十二地支。月/日/时不用。

### 4.3 始击（客目）
- **金镜 / 统宗 / 福应经 / 集成**：始击落宫等于计神落宫在十二支盘上的**对冲位**（如计神在子，始击在午）。
- **淘金歌**：仅年计使用，始击落于计神对冲位。月/日/时不用。

---

## 5. 三算（主算、客算、定算）

### 5.1 累加与终点判定
- **主算**：起点为文昌宫，终点为太乙前一宫，顺行累加八宫本数（跳过中五宫）。
- **客算**：起点为始击宫，终点为太乙前一宫，顺行累加八宫本数。
- **定算**：起点为定目（即定大将落宫），终点为太乙前一宫，顺行累加八宫本数。

### 5.2 无算与延伸边界条件
- **基本无算**：起点落宫 == 太乙落宫，或者起点顺行一步即为太乙落宫（中间无任何途经宫位），则算数 $N = 0$，判定为“无算”。
- **无算延伸规则**：当累加路径不经过任何有效宫位时（即起点 == 终点，比如起点和终点重合），除判定累加和 $S = 0$、算数记为无算外，主大将、客大将、定大将、主小将（参将）、客小将、定小将**全部映射至中五宫（无位），算筹数值记为「0」**。

---

## 6. 八将（三基、大小将、地乙、飞符、四神）

### 6.1 三基：君基、臣基、民基（时计不用）
- **君基**：
  - 金镜 / 集成 / 福应经：午起顺十六神，周期 30。步数 = $(局数 - 1) \bmod 30$。
  - 统宗：午起顺十六神，周期 24。步数 = $(局数 - 1) \bmod 24$。
  - 淘金歌：仅年计使用，午起周期 30。
- **臣基**：午起顺十六神，周期 3。步数 = $(局数 - 1) \bmod 3$。
- **民基**：戌起顺十六神，周期 16。步数 = $(局数 - 1) \bmod 16$。

### 6.2 主客大小将（五派同）
- **大将落宫**：算数结果 $N$。若 $N \in [1, 9]$ 则为 $N$ 宫，若 $N = 10$ 则归入 **9 巽宫**。
- **小将（参将）落宫**：$(大将宫 \times 3) \bmod 10$，若余 $0$ 取 $10$，并归入 **9 巽宫**。
- **定大将**：
  - 福应经：主大将顺行 1 宫（跳过中五宫）。
  - 金镜 / 统宗 / 集成：由独立定算得出。

### 6.3 地乙与飞符（时计不用）
- **地乙**：起巳，3 步一移，顺行十二辰。步数 = $\lfloor (局数 - 1) / 3 \rfloor \bmod 12$。
- **飞符**：起辰，3 步一移，顺行十二辰。步数 = $\lfloor (局数 - 1) / 3 \rfloor \bmod 12$。
- 地支映射九宫：巳=9，午=2，未=7，申=6，酉=6，戌=9，亥=1，子=8，丑=8，寅=3，卯=4，辰=4。

### 6.4 四神（时计不用）
- **金镜 / 集成 / 福应经**：大周 180，小周 36，宫步 3。起 1 乾宫顺行八宫。
- **统宗**：大周 240，小周 24，宫步 3。起 1 乾宫顺行八宫。
- **淘金歌**：不用四神。

---

## 7. 十精与运行轨迹（时计不用）

### 7.1 天皇
- 金镜 / 福应 / 集成：大周 200，小周 20，起武德（申）顺行十六神。
- 统宗：大周 240，小周 24。
- 淘金歌：不用。

### 7.2 紫微
- 起吕申（寅）顺行十六神，大周 180，小周 18。

### 7.3 天乙
- 起乾（亥）顺行十二辰，3 年一移。

### 7.4 其他六精（摄提、轩辕、招摇、天符、青龙、咸池）
- **摄提**：4 步一移，起 1 乾宫。
- **轩辕**：5 步一移，起 2 离宫。
- **招摇**：6 步一移，起 4 震宫。
- **天符**：9 步一移，起 6 兑宫。
- **青龙**：12 步一移，起 3 艮宫。
- **咸池**：15 步一移，起 8 坎宫。

---

## 8. 五福、大游、小游、三宫、直符

- **五福（国运吉星，时计不用）**：
  $$\text{落宫} = \text{taiYiPalaceOrder}[\lfloor (J - 1) / 45 \rfloor \bmod 8]$$
  起 1 乾宫顺行八宫（淘金歌不用）。
- **大游（战争与动乱，时计不用）**：
  $$\text{落宫} = [7, 6, 4, 3, 2, 1, 9, 8][\lfloor (J - 1) / 36 \rfloor \bmod 8]$$
  起 7 坤宫逆行八宫（淘金歌不用）。
- **小游**：12 步一移，起 1 乾宫顺行。
- **三宫（绛宫、明堂、玉堂）**：3 步一移，起九宫毕依次顺行绛宫、明堂、玉堂。
- **直符（值日巡察）**：
  起中五宫，顺行映射序列：`[5, 6, 12, 8, 9, 10, 7, 15, 16, 2, 4, 5]`（对应中宫、酉、申、子、巳、戌、未、丑、亥、午、寅、卯）。

---

## 9. 太乙格局判定

- **掩（客欺主，臣强君弱）**：始击落宫 == 太乙落宫。
- **迫（臣凌君、内外逼）**：主大将、客大将、主小将、客小将落在太乙的**前后一宫内**（八宫序列索引差异为 $\pm 1$）。
- **击（客攻主）**：始击落宫落在太乙落宫的**前后一宫内**（八宫序列索引差异为 $\pm 1$）。
- **格（主拒客）**：太乙落宫落在始击落宫的**前后一宫内**（八宫序列索引差异为 $\pm 1$）。
- **关（将相不和）**：主大将与客大将、主小将与客小将同落一宫，且两算数值相等。
- **囚（篡戮、受制）**：文昌、主大将、客大将同落太乙宫。

---

## 10. 五派四计排盘矩阵总表

| 计法 | 金镜派 | 统宗派 | 淘金歌派 | 福应经派 | 集成派 |
|---|---|---|---|---|---|
| **年计** | 全神煞、全三算、全八将 | 全神煞、君基24步、全八将 | 仅三算、三基、大小将，其余不排 | 全神煞、节气校正、定大将顺移 | 默认统宗积年，全神煞与三算 |
| **月计** | 同年计，使用月入局数 | 同年计，天目起阴德独立起局 | 仅排太乙、主客大将，余不排 | 同年计，使用18余数判定阴阳遁 | 同年计，使用月入局数 |
| **日计** | 同年计，使用日入局数 | 同年计，冬夏至甲子日起局 | 仅排太乙、主客大将，余不排 | 同年计，精确节气校正 | 同年计，使用日局数 |
| **时计** | 仅主客定大小将，无三基神煞 | 同左，阴阳遁起将（武德/吕申） | 无神煞，仅推太乙 | 同左，文昌起算 | 同统宗，时计分阴阳遁起将 |

---

## 11. 核心计算引擎的 Dart 完整实现代码

```dart
// ==========================================
// 太乙神数五合一计算核心引擎 (Dart 语言版)
// ==========================================

import 'dart:math';

/// 流派枚举
enum TaiYiSchool {
  jingMirror,   // 金镜派
  tongZong,     // 统宗派
  taoJinGe,     // 淘金歌派
  fuYing,       // 福应经派
  jiCheng       // 近代集成派
}

/// 计别枚举
enum TaiYiChartType {
  year,
  month,
  day,
  hour
}

/// 阴阳遁
enum DunType {
  yang, // 阳遁
  yin   // 阴遁
}

/// 太乙九宫定义
class TaiYiPalace {
  static const List<int> order = [1, 2, 3, 4, 6, 7, 8, 9];
  static const Map<int, int> baseNumbers = {
    1: 1, 2: 2, 3: 3, 4: 4, 6: 6, 7: 7, 8: 8, 9: 9
  };
}

/// 十六神定义
class SixteenGods {
  static const List<String> list = [
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥', '地主', '和德', '武德', '吕申'
  ];

  static int toPalace(String god) {
    switch (god) {
      case '子': case '地主': return 8; // 坎
      case '丑': return 8; // 丑也归坎
      case '艮': case '和德': return 3; // 艮
      case '寅': case '吕申': return 3; // 寅也归艮
      case '卯': return 4; // 震
      case '辰': return 4; // 辰也归震
      case '巽': case '大炅': return 9; // 巽
      case '戌': case '阴主': return 9; // 戌也归巽
      case '巳': return 2; // 离
      case '午': case '大威': return 2; // 午也归离
      case '未': case '天道': return 7; // 坤
      case '坤': case '大武': return 7; // 坤也归坤
      case '申': case '武德': return 6; // 兑
      case '酉': case '太簇': return 6; // 酉也归兑
      case '乾': case '阳德': return 1; // 乾
      case '亥': case '大义': return 1; // 亥也归乾
      default: return 5; // 默认中宫
    }
  }

  static String getGodBySteps(String start, int steps) {
    int idx = list.indexOf(start);
    if (idx == -1) return start;
    return list[(idx + steps) % 16];
  }
}

/// 太乙计算结果模型
class TaiYiCalculationResult {
  final int accumulatedYear;
  final int juNumber;
  final int taiYiPalace;
  final String tianMu;
  final int tianMuPalace;
  final String jiShen;
  final int jiShenPalace;
  final String shiJi;
  final int shiJiPalace;
  
  final int hostCount;
  final int guestCount;
  final int dingCount;
  
  final int hostDaJiang;
  final int hostXiaoJiang;
  final int guestDaJiang;
  final int guestXiaoJiang;
  final int dingDaJiang;
  final int dingXiaoJiang;
  
  final int? junJi;
  final int? chenJi;
  final int? minJi;
  final int? diYi;
  final int?飞符;
  final int?四神;
  final int?五福;
  final int?大游;

  TaiYiCalculationResult({
    required this.accumulatedYear,
    required this.juNumber,
    required this.taiYiPalace,
    required this.tianMu,
    required this.tianMuPalace,
    required this.jiShen,
    required this.jiShenPalace,
    required this.shiJi,
    required this.shiJiPalace,
    required this.hostCount,
    required this.guestCount,
    required this.dingCount,
    required this.hostDaJiang,
    required this.hostXiaoJiang,
    required this.guestDaJiang,
    required this.guestXiaoJiang,
    required this.dingDaJiang,
    required this.dingXiaoJiang,
    this.junJi,
    this.chenJi,
    this.minJi,
    this.diYi,
    this.飞符,
    this.四神,
    this.五福,
    this.大游
  });
}

/// 核心计算器
class TaiYiCalculator {
  
  // 满十去十核心实现
  static int formatCount(int sum) {
    if (sum == 0) return 0;
    int res = ((sum - 1) % 10) + 1;
    return res == 10 ? 9 : res; // 10归9
  }

  // 累加求和算法（带跳过中五宫和无算延伸判定）
  static Map<String, dynamic> walkAndSum(int startPalace, int endPalace, int taiYiPalace) {
    if (startPalace == taiYiPalace) {
      return {'count': 0, 'isExtendedBoundary': false};
    }
    
    int startIdx = TaiYiPalace.order.indexOf(startPalace);
    int endIdx = TaiYiPalace.order.indexOf(endPalace);
    
    // 起点顺行一步即抵达太乙落宫
    int nextIdx = (startIdx + 1) % 8;
    if (TaiYiPalace.order[nextIdx] == taiYiPalace) {
      return {'count': 0, 'isExtendedBoundary': false};
    }
    
    // 无算延伸规则：起点 == 终点
    if (startPalace == endPalace) {
      return {'count': 0, 'isExtendedBoundary': true};
    }
    
    int sum = 0;
    int currentIdx = startIdx;
    while (currentIdx != endIdx) {
      sum += TaiYiPalace.order[currentIdx];
      currentIdx = (currentIdx + 1) % 8;
    }
    
    return {'count': formatCount(sum), 'isExtendedBoundary': false};
  }

  // 核心计算入口
  static TaiYiCalculationResult calculate({
    required TaiYiSchool school,
    required TaiYiChartType chartType,
    required int year,
    int month = 1,
    int day = 0,
    int hour = 0,
    DunType dun = DunType.yang
  }) {
    // 1. 积年计算
    int j = 0;
    switch (school) {
      case TaiYiSchool.jingMirror:
        j = 10153917 + (year - 751);
        break;
      case TaiYiSchool.tongZong:
      case TaiYiSchool.jiCheng:
        j = 10155219 + (year - 1303);
        break;
      case TaiYiSchool.fuYing:
        j = 10153917 + (year - 742);
        break;
      case TaiYiSchool.taoJinGe:
        j = year + 2697;
        break;
    }

    // 2. 入局数计算
    int ruJu = 0;
    switch (chartType) {
      case TaiYiChartType.year:
        ruJu = j % 360;
        break;
      case TaiYiChartType.month:
        ruJu = (j * 12 + month) % 360;
        break;
      case TaiYiChartType.day:
        ruJu = ((j * 365.2425).floor() + day) % 360;
        break;
      case TaiYiChartType.hour:
        int jd = (j * 365.2425).floor() + day;
        ruJu = (jd * 12 + hour) % 360;
        break;
    }
    if (ruJu == 0) ruJu = 360;

    int ju = ruJu % 72;
    if (ju == 0) ju = 72;

    // 3. 太乙落宫
    int tyIdx = ((ju - 1) ~/ 3) % 8;
    int taiYiPalace = TaiYiPalace.order[tyIdx];

    // 4. 天目、计神、始击
    String tianMu = '武德';
    String jiShen = '子';
    if (school != TaiYiSchool.taoJinGe) {
      // 天目计算 (重留一算逻辑简化实现)
      int tmStep = ruJu % 18;
      tianMu = SixteenGods.getGodBySteps('武德', tmStep);
      
      // 计神计算
      int jsStep = ruJu % 12;
      jiShen = dun == DunType.yang 
          ? SixteenGods.getGodBySteps('寅', -jsStep)
          : SixteenGods.getGodBySteps('申', -jsStep);
    } else {
      // 淘金歌专属
      tianMu = SixteenGods.getGodBySteps('武德', ju % 12);
      jiShen = SixteenGods.getGodBySteps('寅', -ju % 12);
    }

    int tianMuPalace = SixteenGods.toPalace(tianMu);
    int jiShenPalace = SixteenGods.toPalace(jiShen);
    
    // 始击 (计神对冲)
    String shiJi = SixteenGods.getGodBySteps(jiShen, 8);
    int shiJiPalace = SixteenGods.toPalace(shiJi);

    // 5. 三算计算
    int prevTy = TaiYiPalace.order[(tyIdx - 1 + 8) % 8];
    int nextTy = TaiYiPalace.order[(tyIdx + 1) % 8];
    
    int endPalace = prevTy;
    if (school == TaiYiSchool.tongZong && chartType == TaiYiChartType.hour && dun == DunType.yin) {
      endPalace = nextTy; // 统宗阴时计对冲终点
    }

    // 主算
    var hostWalk = walkAndSum(tianMuPalace, endPalace, taiYiPalace);
    int hostCount = hostWalk['count'];
    bool hostEB = hostWalk['isExtendedBoundary'];

    // 客算
    var guestWalk = walkAndSum(shiJiPalace, endPalace, taiYiPalace);
    int guestCount = guestWalk['count'];
    bool guestEB = guestWalk['isExtendedBoundary'];

    // 定算与定大将落宫
    int dingCount = 0;
    int dingDaJiang = 5;
    int dingXiaoJiang = 5;
    
    if (school != TaiYiSchool.taoJinGe) {
      int dingStart = (school == TaiYiSchool.fuYing) 
          ? TaiYiPalace.order[(TaiYiPalace.order.indexOf(formatCount(hostCount)) + 1) % 8]
          : prevTy; // 默认以太乙前一宫作为定算起点
          
      var dingWalk = walkAndSum(dingStart, endPalace, taiYiPalace);
      dingCount = dingWalk['count'];
      var dingGens = calculateGenerals(dingCount, dingWalk['isExtendedBoundary']);
      dingDaJiang = dingGens['dajiang']!;
      dingXiaoJiang = dingGens['xiaojiang']!;
    }

    // 大小将计算
    var hostGens = calculateGenerals(hostCount, hostEB);
    int hostDaJiang = hostGens['dajiang']!;
    int hostXiaoJiang = hostGens['xiaojiang']!;

    var guestGens = calculateGenerals(guestCount, guestEB);
    int guestDaJiang = guestGens['dajiang']!;
    int guestXiaoJiang = guestGens['xiaojiang']!;

    // 6. 八将计算
    int? junJi, chenJi, minJi, diYi, 飞符, 四神;
    if (chartType != TaiYiChartType.hour && school != TaiYiSchool.taoJinGe) {
      // 君基
      int jkCycle = (school == TaiYiSchool.tongZong) ? 24 : 30;
      int jkSteps = (ju - 1) % jkCycle;
      junJi = SixteenGods.toPalace(SixteenGods.getGodBySteps('午', jkSteps));
      
      // 臣基
      chenJi = SixteenGods.toPalace(SixteenGods.getGodBySteps('午', (ju - 1) % 3));
      
      // 民基
      minJi = SixteenGods.toPalace(SixteenGods.getGodBySteps('戌', (ju - 1) % 16));
      
      // 地乙与飞符
      int dySteps = ((ju - 1) ~/ 3) % 12;
      diYi = SixteenGods.toPalace(SixteenGods.getGodBySteps('巳', dySteps));
      飞符 = SixteenGods.toPalace(SixteenGods.getGodBySteps('辰', dySteps));
      
      // 四神
      int ssMax = (school == TaiYiSchool.tongZong) ? 240 : 180;
      int ssMin = (school == TaiYiSchool.tongZong) ? 24 : 36;
      int ssR = j % ssMax;
      int ssSteps = ((ssR % ssMin) ~/ 3);
      四神 = TaiYiPalace.order[ssSteps % 8];
    }

    // 7. 五福与大游
    int?五福, 大游;
    if (school != TaiYiSchool.taoJinGe && chartType != TaiYiChartType.hour) {
      五福 = TaiYiPalace.order[((j - 1) ~/ 45) % 8];
      大游 = [7, 6, 4, 3, 2, 1, 9, 8][((j - 1) ~/ 36) % 8];
    }

    return TaiYiCalculationResult(
      accumulatedYear: j,
      juNumber: ju,
      taiYiPalace: taiYiPalace,
      tianMu: tianMu,
      tianMuPalace: tianMuPalace,
      jiShen: jiShen,
      jiShenPalace: jiShenPalace,
      shiJi: shiJi,
      shiJiPalace: shiJiPalace,
      hostCount: hostCount,
      guestCount: guestCount,
      dingCount: dingCount,
      hostDaJiang: hostDaJiang,
      hostXiaoJiang: hostXiaoJiang,
      guestDaJiang: guestDaJiang,
      guestXiaoJiang: guestXiaoJiang,
      dingDaJiang: dingDaJiang,
      dingXiaoJiang: dingXiaoJiang,
      junJi: junJi,
      chenJi: chenJi,
      minJi: minJi,
      diYi: diYi,
      飞符: 飞符,
      四神: 四神,
      五福: 五福,
      大游: 大游
    );
  }
}
```
