# SPIKE: xuan-metaphysics-core 节气时刻 / 平气定气 / 至后甲子日 能力核查

> 只读核查，未修改任何 lib/test/pubspec 文件。
> 日期: 2026-06-08

---

## 结论: 可行

metaphysics-core 已具备全部三项能力，且 xuan-taiyishenshu 内的 `DunResolver` 已经封装了完整调用链。

---

## 1. 冬至/夏至精确交节时刻

### API 签名

```dart
// package:tyme (metaphysics-core 的传递依赖)
SolarTerm term = SolarTerm.fromIndex(int year, int index);
JulianDay jd = term.getJulianDay();
SolarTime st = jd.getSolarTime();
// → st.getYear(), st.getMonth(), st.getDay(),
//   st.getHour(), st.getMinute(), st.getSecond()
```

### tyme 索引映射

| 节气 | tyme index | 备注 |
|------|-----------|------|
| 小寒 | 0 | tyme 从小寒起算 |
| 大寒 | 1 | |
| ... | ... | |
| 夏至 | 11 | DunResolver 用 index=12 对应夏至(见下方差异) |
| ... | ... | |
| 冬至 | 23 | four_zhu_engine.dart:306 映射 |

**差异**: `four_zhu_engine.dart` 映射 DONG_ZHI→index 23，但 `DunResolver` 用 index 0 取冬至、index 12 取夏至。两处 tyme 索引不一致，需确认 tyme 包的实际 index 语义（可能 tyme 内部从冬至=0 开始，与 four_zhu_engine 的注释矛盾）。

### 已有封装 (xuan-taiyishenshu)

```dart
// lib/taiyi/rules/dun_resolver.dart
static DateTime getWinterSolstice(int year, String termMode)
static DateTime getSummerSolstice(int year, String termMode)
// 返回 DateTime 精确到秒
```

### 现状

tyme 的 `SolarTerm.fromIndex()` 返回定气法下的精确天文交节时刻（基于 VSOP87/ELP2000 天文算法），精度到秒级。

---

## 2. 平气 (leveling) 与定气 (stabilizing) 选用

### 枚举定义

```dart
// metaphysics_core/lib/enums/datetime_strategy_enums.dart
enum JieQiType {
  leveling("平气法"),    // 以春分为锚点，等间隔 365.2422/24 天
  stabilizing("定气法"); // 以太阳黄经为基准，实际天文交节时刻
}
```

### DunResolver 的实现

```dart
// dun_resolver.dart
static DateTime getWinterSolstice(int year, String termMode) {
  if (termMode == 'leveling') {
    // 平气法: 春分 - 6个节气间隔
    final cf = _chunFenForYear(year);  // 用 tyme 取精确春分
    const double tropicalYearDays = 365.2422;
    final Duration levelingInterval = Duration(
      milliseconds: (tropicalYearDays / 24 * 24 * 60 * 60 * 1000).round(),
    );
    return cf.subtract(levelingInterval * 6);
  } else {
    // 定气法: 直接用 tyme SolarTerm
    final term = SolarTerm.fromIndex(year, 0);
    // ...
  }
}
```

### 选用规则

- `termMode` 参数传 `'leveling'` 或 `'stabilizing'`，由 `SchoolDocument.dun.termMode` 配置
- 平气法以春分为锚点，每个节气间隔 = 365.2422/24 ≈ 15.2184 天
- 定气法直接使用 tyme 天文算法，每个节气间隔不等

---

## 3. 至后首个甲子日

### API 签名

```dart
// dun_resolver.dart
static DateTime jiaZiDayAnchor(DateTime date, String termMode)
```

### 实现逻辑

1. 确定当前日期所在的遁周期起点（冬至或夏至）
2. 从该至日起逐日检查，用 tyme 的 `SolarTime.getLunarHour().getEightChar().getDay().getName()` 取日干支
3. 找到第一个 `dayGanzhiStr == '甲子'` 的日期返回
4. 最多搜索 65 天（甲子日必在至后 60 天内出现）

### 依赖链

```
DunResolver.jiaZiDayAnchor()
  → SolarTime.fromYmdHms()          // tyme
  → .getLunarHour().getEightChar()  // tyme
  → .getDay().getName()             // 返回 '甲子' 等干支字符串
```

全部在 metaphysics-core 的依赖范围内（tyme 包），无需额外依赖。

---

## 4. 综合评估

| 能力 | 可行性 | 现有 API | 需要新增 |
|------|--------|----------|----------|
| 冬至精确时刻 | ✅ | `SolarTerm.fromIndex(year, 23)` 或 DunResolver | 否 |
| 夏至精确时刻 | ✅ | `SolarTerm.fromIndex(year, 12)` 或 DunResolver | 否 |
| 平气/定气切换 | ✅ | `JieQiType.leveling/stabilizing` + DunResolver | 否 |
| 至后首个甲子日 | ✅ | `DunResolver.jiaZiDayAnchor()` | 否 |
| 阴阳遁判定 | ✅ | `DunResolver.isYangDun()` | 否 |

### Adapter 建议

如需在 taiyi_pan_calculator.dart 中使用，可直接复用 `DunResolver`：

```dart
// 替换硬编码 DateTime(year, 6, 21) / DateTime(year, 12, 21)
final ws = DunResolver.getWinterSolstice(dateTime.year, 'stabilizing');
final ss = DunResolver.getSummerSolstice(dateTime.year, 'stabilizing');
final isYang = DunResolver.isYangDun(dateTime, 'stabilizing');
```

### ⚠️ 待确认

1. tyme 的 `SolarTerm.fromIndex()` index=0 到底是小寒还是冬至？`four_zhu_engine.dart` 注释说 index 0=小寒，但 `DunResolver` 用 index 0 取冬至。
2. 平气法的锚点选择：当前用春分，是否需要支持其他锚点（如冬至）？

---

## 文件路径

- 枚举: `xuan-metaphysics-core/lib/enums/datetime_strategy_enums.dart`
- 节气枚举: `xuan-metaphysics-core/lib/enums/enum_twenty_four_jie_qi.dart`
- 四柱引擎(节气时刻): `xuan-metaphysics-core/lib/domain/calculators/four_zhu/four_zhu_engine.dart:276-344`
- 遁解析器: `xuan-taiyishenshu/lib/taiyi/rules/dun_resolver.dart`
- 甲子枚举: `xuan-metaphysics-core/lib/enums/enum_jia_zi.dart`
