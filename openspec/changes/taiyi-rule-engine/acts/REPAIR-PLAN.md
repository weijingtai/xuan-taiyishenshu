# REPAIR PLAN — 三算正确性切换(rule_engine 取代旧 _walkAndSumWithDetail)

> 性质:修复+切换计划(不新建大模块)。基准:太乙九宫 = 乾1·离2·艮3·震4·中5(不入)·兑6·坤7·坎8·巽9。

## 现状(已核)

- 产品三算仍走**旧** `lib/taiyi/taiyi_pan_calculator.dart` 的 `_walkAndSumWithDetail`(调用于 :686/:693/:710,定义于 :1063),REVIEW 的 🔴 都在这条旧路径里。
- **新** `lib/taiyi/rules/rule_engine.dart` 已实现:`endpoint` 阳/阴 `prevPalace/nextPalace` 偏移(:189-196)、无算 `V==0`(:242)、`sixteenGods`+`restAt` 起神(:100-114)、**无 clockwise 反向**。`dun_resolver.dart` 的 `isYangDun` 已精确。calculator 已 import rules/ 但**未真正切过去**。

## 目标

审计新引擎正确性 → 把 calculator 的三算(主/客/定)切到新 `rule_engine` → 退役旧 `_walkAndSumWithDetail`。逐条以 REVIEW 为清单。

## 逐条(REVIEW # → 动作 → 验收 oracle)

| # | 严重 | 动作 | 验收 |
|---|---|---|---|
| 1 | 🔴 | 确认新引擎 walkSum 对 同宫/同位/一步即到 三种都返 0(:242 已处理 V==0,需补全分支) | `walkAndSum('震','震')=0`、`('乾','离')=0` |
| 2 | 🟡 | **确认 walkSum 累加按八宫序+宫本数**(乾1离2艮3震4兑6坤7坎8巽9),不是 16 神地理序 | `('乾','震')=3`、`('艮','乾')=8` |
| 3 | 🔴 | 新引擎用 endpoint 偏移、无方向翻转 → 已对;切过去后旧 clockwise=false 路径作废 | 阴遁时家终点取后一宫而非反向 |
| 4 | 🟡 | 删 calculator 硬编码 6·21/12·21,改调 `DunResolver`(已正确) | 阴阳遁用精确交节 |
| 5 | 🟡 | `pan_data_model.dart:78` 裸 `gong.order` → 改用修正宫本数(兑=6 非 5) | number(兑)=6、number(中)规则化 |
| 6 | 🟡 | `_generalNumberToGong(5)→中`:神将永不入中五;按 5_in_one §6.2 大小将落宫规则处理 N=5(**不照搬 skip**,确认规则并记录来源) | 大/小将不落中五 |
| 7 | 🔴 | 统宗时计起点神:阳=武德、阴=吕申,由 school doc 的 `walk.dun{yang,yin}` 提供并接通 | 统宗时家阳起武德、阴起吕申 |
| 8 | 🔴 | 统宗时计终点:阳=太乙前一宫、阴=后一宫;新引擎 endpoint 已支持,确认统宗 school doc 配 `yin:taiYiNext` | 同 #3 |
| 9 | 🟡 | 计神:阳起寅、阴起申、逆行(5_in_one §4.2),由 `walk.dun` 提供 | 计神阴阳起点正确 |

## 过程铁律

1. **先红后绿**:每条先写失败测试,再改。
2. oracle 来源:PoC(`test/poc/taiyi_rule_engine_poc_test.dart`)、`specs/taiyi-rule-engine/spec.md` 的 Scenario、`docs/classes/5_in_one_classes_alg.md` 的确定性公式。**不得改断言迁就实现**。
3. 切换后跑 `flutter test test/taiyi/` 全绿,且**不回归 BASELINE**(开工前 170 passed/3 failed;3 个 asset 失败是 pre-existing,可仍红;通过数不得低于 170)。
4. 不碰 `four_zhu`(那条单独走 `FIX-jieqi-fourzhu.md`)、不碰 UI、不编造向量。
5. 旧 `_walkAndSumWithDetail` 切换完成后退役(删除或标注 deprecated)。

## 完成门

`openspec validate taiyi-rule-engine --strict` 绿;在 `REVIEW-existing-vs-spec.md` 逐条标注"已修/已切换/已退役旧路径";回真实命令输出。
