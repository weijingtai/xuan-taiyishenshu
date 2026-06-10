# Design: Taiyi Rule Engine

> 数理基准:太乙九宫 = 乾1·离2·艮3·震4·中5(不入)·兑6·坤7·坎8·巽9(非洛书)。
> 状态:核心模型已由 PoC 验证(见 §8)。

## 1. Context

一个流派(School)= 五个开关(`core_diff.md`):①上元积年 ②四计范围 ③星神体系 ④起神起将 ⑤时计阴阳遁。要让用户自建流派,这五项都必须是**可编辑的数据**,而非硬编码代码路径。

本设计把一个流派表示为**结构化 JSON 规则文档**,由**原生 Dart 解释器**执行。官方派与用户派同构,差别仅 `owner`(可写性/是否随包)。

## 2. Design Principles

1. **数据驱动**:算法形状是 JSON 规则数据,用户改数据不改代码。
2. **原生解释 + JSON 算术树**:执行全是 Dart;算术叶子是白名单 JSON AST,**无语法解析器、不嵌 JS/VM、无运行时 Dart codegen**(AOT 安全、零重依赖)。
3. **有限可组合**:~7 种规则 + 算术树覆盖五派全功能;新规则=新增一种规则种类(发版),绝大多数新流派只靠组合。
4. **安全自带**:规则种类有限、AST 节点白名单、引用成 DAG(禁环)、AST 深度上限 → 天然非图灵完备、无 IO、无循环。
5. **官方=用户同构**:同一 Schema 与引擎;`owner: official|user` 决定可写性与是否随包发布。
6. **数据溯源**:有出处/有争议的取值(如重留位)必须带 `source` 字段。

## 3. Rule Taxonomy (R1–R7 + R8)

每条规则输出一个 typed `RuleValue`,可被后续规则按 `id` 引用。`RuleValue` 类型必须先冻结,再编写官方资产。

`RuleValue` v1:

- `scalar`:整数数值,用于积年/局数/步数/算数。
- `palace`:太乙九宫宫位。
- `deity`:神位或十六神名。
- `predicate`:格局判断结果,包含 `matched: bool` 与 `name`。
- `record`:少数复合结果,仅用于内部桥接;写入 School JSON 前必须拆成上面四类之一。

| 种类 | 管什么 | 关键字段 |
|---|---|---|
| **R1 ScalarFormula** | 积年/入局/局数/步数 | `tree`(JSON 算术树) `zeroAsCycle` |
| **R2 PalaceWalk** | 天目/计神/三基/八将/十精/五福…(最高频) | `palaceSystem` `start` `direction` `steps` `restAt`(重留) `dun` |
| **R3 WalkAndSum** | 主/客/定算 | `startRef` `endpoint{yang,yin}` `满十去十` `wuSuan` |
| **R4 DeriveFromCount** | 大将/小将 | `countRef` `map(10→9宫)` `minorTree` |
| **R5 Relative** | 始击(对冲)/福应经定大将(顺1宫) | `baseRef` `mode(opposition\|offset)` `offset` |
| **R6 TableSequence** | 直符/大游/地支映射 | `table` `indexTree` `startPalace` `direction` |
| **R7 Predicate** | 格局(掩迫击格关囚) | `name` `when(eq\|adjacent±1\|coLocatedEqualCount)` |
| **R8(上下文)** | 阴阳遁 / 节气校正 | `resolver` `termMode(平气\|定气)` `calibration` |

### R1 JSON 算术树(白名单节点)
- 节点:`{"int":n}` / `{"num":x}`(仅作 `*` 操作数,须 `floor`) / `{"var":"Y"}` / `{"op":"+|-|*|~/|%","a":..,"b":..}` / `{"floor":..}`。**不提供 `/`**(避免浮点歧义)。
- 变量:`Y M D H J ruJu ju` + 前序规则结果(按 id)。深度上限(如 ≤16)。
- 例(金镜积年 `10153917+(Y-751)`):
  ```jsonc
  {"op":"+","a":{"int":10153917},"b":{"op":"-","a":{"var":"Y"},"b":{"int":751}}}
  ```

### R2 走宫(含重留;阴阳遁起神)
```jsonc
// 天目(金镜): 武德起·顺16神·遇这些位重留一算
{ "id":"tianMu","kind":"walk","palaceSystem":"sixteenGods","start":"武德","direction":"forward",
  "steps":{"tree":{"op":"%","a":{"var":"ruJu"},"b":{"int":18}}},
  "restAt":{"values":["阴德","大武","乾","坤"],"source":"5_in_one_classes_alg.md §4.1"} }
```

### R3 三算(已焊入两处修正)
- 走**太乙九宫序**并跳过中五(纠正现有代码的 16 神地理序);
- 实现**无算 S=0**(起点同太乙宫 / 一步即到 → 0;现有代码从不返 0);
- `满十去十 = ((S-1)%10)+1`,`10 归 9`;`endpoint` 阳=太乙前一宫 / 阴=后一宫。

## 4. School 数据模型

School v1 contract:

```jsonc
{
  "schemaVersion": 1,
  "meta": {"id":"jingMirror","name":"金镜派","version":1,"source":"...","owner":"official"},
  "palace": "taiyi9",
  "rules": [
    {"id":"accumulation.year","kind":"scalar","output":"scalar","tree":{}},
    {"id":"foundation.tianMu","kind":"walk","output":"deity","palaceSystem":"sixteenGods","start":"武德"}
  ],
  "charts": {
    "year": {"enabled":true,"ruJuRef":"accumulation.year","appliesTo":["year"]},
    "month": {"enabled":true,"ruJuRef":"accumulation.month","appliesTo":["month"]},
    "day": {"enabled":true,"ruJuRef":"accumulation.day","appliesTo":["day"]},
    "hour": {"enabled":true,"ruJuRef":"accumulation.hour","appliesTo":["hour"]}
  },
  "dun": {"resolver":"metaphysicsCoreJieQi","termMode":"leveling"},
  "foundation": {"taiYiRef":"foundation.taiYi","wenChangRef":"foundation.tianMu","jiShenRef":"foundation.jiShen","shiJiRef":"foundation.shiJi"},
  "threeCalc": {"hostRef":"calc.host","guestRef":"calc.guest","dingRef":"calc.ding"},
  "generals": {"hostMajorRef":"general.hostMajor"},
  "deities": [{"id":"custom.star","name":"自定义星","layer":"tian","appliesTo":["year"],"ruleRef":"deity.custom","visible":true}],
  "geJu": [{"id":"geju.yan","ruleRef":"predicate.yan"}]
}
```

Contract rules:

- `kind` is the rule union discriminator.
- `output` must match the `RuleValue` emitted by the rule kind.
- Rule ids are scoped to the school document and must be unique.
- References use `*Ref` fields and must point to existing rule ids with compatible output type.
- Validation errors must include `schoolId` and `fieldPath`.
- `schemaVersion` is required to support later migrations.
- Provenance for contested fields uses an object shape `{ "values": [...], "source": "..." }`, not a loose top-level string.

Official assets must not be written until this contract has tests and passes validation.
- 每条规则带 `appliesTo` → 表达「淘金歌仅年计」「时计不排三基」等范围开关。
- `deities[]` 增删 = 星神增删。

## 5. 编辑器 / 存储边界

| | 官方派 | 用户派 |
|---|---|---|
| 存储 | 随包 JSON assets,**只读**,版本化,向量背书 | 用户可写仓库(本地 DB/文件),**全 CRUD** |
| 来源 | 5 部经典 | 从零建,或 fork 官方后改 |
| 引擎 | 同一解释器,**不分来源** | 同左 |
| 编辑 | 不可改(可 fork) | 结构化表单;算术叶子=带校验的「表达式树」输入 |

- 保存校验:规则种类已知、宫制已知、AST 过白名单+深度、引用成 DAG 无环、必填齐全 → 失败给「字段路径 + schoolId」级报错。
- 用户派可导出/导入 JSON,走同一校验。
- v1 先完成 repository/import/export 与 schema validation。结构化 UI editor 另设后续 gate,避免 UI 牵动 schema 反复重写。

## 6. R8 阴阳遁 / 节气(复用 metaphysics_core)

- `TwentyFourJieQi`(`DONG_ZHI` 冬至 / `XIA_ZHI` 夏至 等);`JieQiType.leveling`(平气)/`stabilizing`(定气)。
- 阴阳遁:阳遁=冬至交节→夏至交节;阴遁反之。**每派可配 `termMode`**(古法多平气,1645 后定气)。
- 甲子日 anchor(统宗日计独立起局):引擎内置原语 `jiaZiDayAnchor(date, termMode)`,用 `metaphysics_core` 取冬/夏至交节后首个甲子日;不开放给用户写。
- 福应经节气校正(冬至重置):R8 的 `calibration` 流水线阶段。
- R8 实现前必须通过 `metaphysics_core` contract spike:实际 import、冬至/夏至交节时间、平气/定气模式、甲子日 anchor 均可验证。若失败,先实现 adapter/stub 并记录替代设计,不得直接写五派资产。

## 7. 与现有代码的映射(扩展,不重写)

| 现有 | 去向 |
|---|---|
| `DeityAlgorithmEngine`(steppedCycle/cumulativeWalk/branchWalker/relativeOffset/fixedPosition) | 收敛为 R2/R5/R1/R6 |
| `_executeCustomFormula` + `ExpressionParser`(字符串解析) | **弃用字符串解析**,改 R1 JSON 算术树求值器 |
| `CustomDeityRepository`(已异步、用户可写) | 泛化为 `SchoolRepository` |
| `FoundationResult`(旧 change) | 保留为基础层桥接 |
| `_walkAndSumWithDetail` | 重写为 R3(修无算缺失 + 太乙九宫序) |
| `TaiYiSchool/SchoolEpochConfig` | 并入 School 文档 `meta + accumulation` |

## 8. PoC 验证结果

`test/poc/taiyi_rule_engine_poc_test.dart` —— **11/11 通过**:
- **R1**:金镜现行积年(1938583)、古法积年(10155192)、`floor(J*365.2425)`、未声明变量报错。
- **R1+R2 数据驱动**:现行基数 @2026 复现现有向量(`J 1938583 / 五子 343 / 局 55 / 太乙 艮 / 入宫 理天`);**仅替换积年 JSON 树**→古法盘(`10155192 / 312 / 24 / 巽 / 理人`),引擎代码零改动。
- **R3**:太乙九宫序累加(乾→震=3)、满十去十(28→8)、10 归 9、无算①②(返 0)。

结论:结构化规则 + 原生解释 + JSON 算术树模型成立,可承载五派。

## 9. Risks

- JSON 算术树比字符串冗长 → 由结构化「表达式树」编辑器缓解。
- 三硬骨头:甲子日 anchor / 节气校正 / 重留位(已定 5_in_one §4.1)。
- 用户派版本迁移(新增规则种类后老文档兼容)。
- 官方向量权威性(暂定孔令伟)。
