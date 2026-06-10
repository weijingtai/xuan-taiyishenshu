# OpenSpec Change: taiyi-rule-engine

规则驱动的太乙流派引擎。目标:用户可自建/编辑/保存/管理自己的流派(含星神与各派关键信息),官方派与用户派走同一个原生 Dart 解释器。

## 与既有 change 的关系

- **取代** `taiyi-algorithm-config-management` 的「固定模板 + 官方不可变 + 只读选择 + 禁表达式」路线(该路线无法支撑用户自建)。
- 旧 change 的 Layer 1(积年/入局抽取、FoundationResult、异步+缓存、向量测试)**降级为打底**,其成果在本 change 中作为 R1/基础层复用。

## 设计来源与验证

- 设计草图:`../taiyi-algorithm-config-management/design-rule-engine-draft.md`(precursor,本 change 的 `design.md` 为正式版)。
- 可行性 PoC:`test/poc/taiyi_rule_engine_poc_test.dart` —— **11/11 通过**,验证 R1 JSON 算术树 / R1+R2 数据驱动基础层 / R3 三算(太乙九宫 + 满十去十 + 无算)。

## 数理基准

太乙九宫 = 乾1·离2·艮3·震4·中5(不入)·兑6·坤7·坎8·巽9(**非洛书**)。

## Validation

```bash
openspec validate taiyi-rule-engine --strict --no-interactive
flutter test test/poc/taiyi_rule_engine_poc_test.dart
```
