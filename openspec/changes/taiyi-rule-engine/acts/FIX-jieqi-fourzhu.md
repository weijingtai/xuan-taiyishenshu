# FIX — four_zhu_engine 节气 index 映射(节气 bug)

> 性质:bug 修复任务。**方向澄清**:tyme 的 index 0 本来就是冬至(已证),错的是 four_zhu_engine,**不是** DunResolver。

## 根因(已证)

tyme 源码 `~/.pub-cache/.../tyme-1.4.2/lib/src/solar/solar_term.dart:10`:
```
names = ["冬至","小寒","大寒","立春","雨水","惊蛰","春分"(6),...,"夏至"(12),...,"大雪"(23)]
```
即 `SolarTerm.fromIndex(year, 0)` = 冬至,`6` = 春分,`12` = 夏至。

## 错在哪

`xuan-metaphysics-core/lib/domain/calculators/four_zhu/four_zhu_engine.dart:281`:
```
// In tyme, index 0 is 小寒, 1 is 大寒, ..., 23 是 冬至   ← 错误前提
final termIndexMap = { TwentyFourJieQi.XIAO_HAN: 0, TwentyFourJieQi.DA_HAN: 1, ... };
```
基于错误前提建的映射 → 四柱取每个节气时偏一整个节气(约15天),节气边界处月柱会错。

## 应然(正确映射)

每个 `TwentyFourJieQi` 的 tyme index = 它在 tyme `names` 里的位置 = 它枚举自己的 0 基序号(`DONG_ZHI=0, XIAO_HAN=1, DA_HAN=2, …, DA_XUE=23`)。
最简修法:`SolarTerm.fromIndex(year, jieqi.<enum 自身的0基index>)`,或重建 `termIndexMap` 让其与 tyme `names` 同序。

## 不要动

- `lib/taiyi/rules/dun_resolver.dart`(`0//冬至, 12//夏至` 已正确)。
- `xuan-metaphysics-core/.../solar_lunar_datetime_helper.dart:37`(`6//春分` 在 0=冬至 下正确)。
- **只动 `four_zhu_engine.dart`。**

## 护栏

1. 先实证:打印 `SolarTerm.fromIndex(2026, 0).getName()`,必须 = "冬至";`6`="春分";`12`="夏至"。
2. 修前/修后各跑四柱(BaZi/four_zhu)现有测试。**若原本是靠"双重错位"自洽、修映射后反而变红 → 停并报告**,不要硬改。
3. 回真实命令输出 + 改动文件清单。
