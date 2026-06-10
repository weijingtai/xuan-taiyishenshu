# REVIEW: taiyi_pan_calculator.dart 与规范文档差异清单

> 只读核查，未修改任何文件。
> 对照文件:
>   - lib/taiyi/taiyi_pan_calculator.dart (代码)
>   - lib/taiyi/pan_data_model.dart (代码)
>   - lib/taiyi/taiyi_constants.dart (代码)
>   - lib/enums/gong.dart (代码)
>   - docs/classes/金镜_统宗_四计_三算_alg.md (规范)
>   - docs/classes/5_in_one_classes_alg.md (规范)
> 日期: 2026-06-08

---

## 差异 1: 无算 S=0 缺失

| 项目 | 内容 |
|------|------|
| 文件:行号 | `taiyi_pan_calculator.dart:1076-1085` |
| 现状 | `_walkAndSumWithDetail` 中"同位"(startPos==taiYiPos) 返回宫数(如 8)，"同宫" 返回 10(年计) 或 1(其他) |
| 应然 | 金镜_统宗_四计_三算_alg.md §1.3: 起点与太乙同宫 → S=0 判定为"无算"；起点顺行一步即到太乙宫 → S=0 |
| 影响 | 主算/客算/定算均受影响，无算场景下返回值错误，导致大将/参将落宫全部错位 |

具体代码:
```dart
// 现状 (line 1076-1078)
if (startPos == taiYiPos) {
  final num = _hostGuestPalaceNumber(taiYiPalace);
  return (count: num, detail: '...同位($num)');  // ← 应返回 0
}
// 现状 (line 1082-1085)
if (startPalace == taiYiPalace) {
  final count = (chartType == TaiYiChartType.year) ? 10 : 1;
  return (count: count, detail: '...同宫取$count');  // ← 应返回 0
}
```

---

## 差异 2: 三算累加走 16 神地理序而非太乙九宫序

| 项目 | 内容 |
|------|------|
| 文件:行号 | `taiyi_pan_calculator.dart:887-915` (`_countingSequence` + `_countingPalaceNumbers`) |
| 现状 | `_calculateSharedYearCount` 和 `_walkAndSumWithDetail` 遍历 16 神地理序列(子丑艮寅卯辰巽巳午未坤申酉戌乾亥)，正神取宫本数、间神取 1 |
| 应然 | 金镜_统宗_四计_三算_alg.md §1.1: 八宫遍历队列为 `[乾,离,艮,震,兑,坤,坎,巽]`，累加途经宫本数(1,2,3,4,6,7,8,9)，跳过中五宫 |
| 影响 | 16 神遍历时间神贡献 1 而非宫本数，导致累加和 S 与规范不一致 |

差异分析:
- 16 神全遍历一圈累加: 8+1+3+1+4+1+9+1+2+1+7+1+6+1+1+1 = 48
- 8 宫全遍历一圈累加: 1+2+3+4+6+7+8+9 = 40
- 当起点/终点不同时，两种遍历方式的中间值分布不同

---

## 差异 3: 阴遁时家反向走盘 clockwise=false

| 项目 | 内容 |
|------|------|
| 文件:行号 | `taiyi_pan_calculator.dart:683-684` |
| 现状 | `final bool clockwise = (chartType == TaiYiChartType.hour) ? (dunType == DunType.yang) : true;` |
| 应然 | 金镜_统宗_四计_三算_alg.md §3.5 第1条: "行进方向：永久顺时针顺行（clockwise=true）"；§2.5 第1条: "行进方向：永久顺时针顺行，不分阴阳遁" |
| 影响 | 阴遁时家 clockwise=false 导致反向遍历，累加路径和结果完全错误 |

规范明确: 阴阳遁**仅改变起点神/终点宫偏移**，不改变行进方向。
- 统宗时计: 阳遁起点=武德、终点=前一宫；阴遁起点=吕申、终点=后一宫。方向始终顺行。
- 金镜时计: 永久文昌起点、永久前一宫终点、永久顺行。

---

## 差异 4: 硬编码 6·21 / 12·21

| 项目 | 内容 |
|------|------|
| 文件:行号 | `taiyi_pan_calculator.dart:480-482` + `taiyi_pan_calculator.dart:537` + `taiyi_pan_calculator.dart:541-542` |
| 现状 | `_dateOfSummerSolstice(int year) => DateTime(year, 6, 21)` 和 `_dateOfWinterSolstice(int year) => DateTime(year, 12, 21)` |
| 应然 | 金镜_统宗_四计_三算_alg.md §1.5: "以精确节气交节时刻为分界（弃用固定6.21/12.22）"；§4.3: "内置1900-2100高精度节气表（精确到分钟），替换原有固定6月21日、12月22日硬编码" |
| 影响 | 阴阳遁判定在交节日附近（±1天）可能错误；实际冬至在 12/21-12/23 间浮动，夏至在 6/20-6/22 间浮动 |

注: `DunResolver` (lib/taiyi/rules/dun_resolver.dart) 已实现精确版本，但 `_resolveDunType` 未使用它。

---

## 差异 5: pan_data_model.dart:78 裸 gong.order

| 项目 | 内容 |
|------|------|
| 文件:行号 | `pan_data_model.dart:78` |
| 现状 | `int get number => gong.order;` |
| 应然 | 返回太乙宫本数(乾=1,离=2,艮=3,震=4,兑=6,坤=7,坎=8,巽=9)而非枚举顺序号 |
| 影响 | `EnumTaiYiGong` 的 order 字段是 1-9 连续序号: Qian=1,Li=2,Gen=3,Zhen=4,**Dui=5**,Kun=6,Kan=7,Xun=8,Center=9。但太乙宫本数是: 乾=1,离=2,艮=3,震=4,**兑=6**,坤=7,坎=8,巽=9。Dui 的 order=5 而宫本数=6，以此类推 |

枚举定义 (gong.dart):
```dart
Qian(1, ...),   // order=1, 宫本数=1 ✅
Li(2, ...),     // order=2, 宫本数=2 ✅
Gen(3, ...),    // order=3, 宫本数=3 ✅
Zhen(4, ...),   // order=4, 宫本数=4 ✅
Dui(5, ...),    // order=5, 宫本数=6 ❌
Kun(6, ...),    // order=6, 宫本数=7 ❌
Kan(7, ...),    // order=7, 宫本数=8 ❌
Xun(8, ...),    // order=8, 宫本数=9 ❌
Center(9, ...), // order=9, 不入中宫
```

注: `_hostGuestPalaceNumber` (line 1059-1061) 用 `palace.order >= 5 ? palace.order + 1 : palace.order` 做了补偿，但这是局部 workaround，`PalaceDataModel.number` 仍返回错误值。

---

## 差异 6: _generalNumberToGong 包含中宫

| 项目 | 内容 |
|------|------|
| 文件:行号 | `taiyi_pan_calculator.dart:1001-1014` |
| 现状 | `_generalNumberToGong(5)` 返回 `EnumTaiYiGong.Center` |
| 应然 | 5_in_one_classes_alg.md §0.1: "中宫=5(不可入)，遍历时直接跳过"；§0.3: "10归9规则"——N=10 时归入巽九宫 |
| 影响 | 当算数结果为 5 时，大将落入中宫，违反"永不入中五"规则 |

---

## 差异 7: 统宗时计起点神实现不完整

| 项目 | 内容 |
|------|------|
| 文件:行号 | `taiyi_pan_calculator.dart:560-575` (`_calculateWenChangPalace`) |
| 现状 | 文昌(天目)统一从申起顺行，不区分阴阳遁起点 |
| 应然 | 金镜_统宗_四计_三算_alg.md §3.5.1: 统宗时计阳遁起点=武德(申)、阴遁起点=吕申(寅)；5_in_one_classes_alg.md §4.1: "统宗时计下区分阴阳遁：阳局起武德，阴局起吕申" |
| 影响 | 阴遁时家的主算起点错误 |

---

## 差异 8: 统宗时计终点宫偏移未实现

| 项目 | 内容 |
|------|------|
| 文件:行号 | `taiyi_pan_calculator.dart:667-746` (`_calculateHostGuest`) |
| 现状 | 终点统一为"太乙前一宫"(通过 `_palaceToZhengDeityPosition` 隐式取前一宫) |
| 应然 | 金镜_统宗_四计_三算_alg.md §3.5.2: 统宗时计阳遁终点=太乙前一宫、阴遁终点=太乙后一宫 |
| 影响 | 阴遁时家的客算/定算累加终点错误 |

---

## 差异 9: 计神实现差异

| 项目 | 内容 |
|------|------|
| 文件:行号 | `taiyi_pan_calculator.dart:577-602` (`_calculateJiShenPalace`) |
| 现状 | 计神定位用年支在十六神/十二神序列中查找，不区分阴阳遁的起始位 |
| 应然 | 5_in_one_classes_alg.md §4.2: "阳局(冬至后): 起寅，逆行十二辰；阴局(夏至后): 起申，逆行十二辰" |
| 影响 | 计神落宫可能在阴遁场景下错误 |

---

## 差异汇总

| # | 差异 | 严重度 | 影响范围 |
|---|------|--------|----------|
| 1 | 无算 S=0 缺失 | 🔴 高 | 主算/客算/定算全部 |
| 2 | 三算走 16 神序非 8 宫序 | 🟡 中 | 累加和数值 |
| 3 | 阴遁时家 clockwise=false | 🔴 高 | 阴遁时家全部三算 |
| 4 | 硬编码 6·21/12·21 | 🟡 中 | 阴阳遁判定边界日 |
| 5 | 裸 gong.order | 🟡 中 | UI 展示宫数 |
| 6 | _generalNumberToGong 含中宫 | 🟡 中 | 大将落宫 |
| 7 | 统宗时计起点神不区分阴阳 | 🔴 高 | 统宗阴遁主算 |
| 8 | 统宗时计终点偏移未实现 | 🔴 高 | 统宗阴遁客算/定算 |
| 9 | 计神不区分阴阳遁起始位 | 🟡 中 | 计神落宫 |
