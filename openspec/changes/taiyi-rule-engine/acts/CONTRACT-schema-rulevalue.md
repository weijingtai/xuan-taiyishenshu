# CONTRACT FREEZE — School v1 Schema + RuleValue (taiyi-rule-engine)

> 冻结决定(2026-06-08,由 Claude 代为拍板)。这是解锁 §4–§9 所有下游单元的总阀门。
> 一旦本文件被 `school_schema_contract_test.dart` 覆盖并通过,即视为冻结;改动须升 `schemaVersion`。
> 数理基准:太乙九宫 = 乾1·离2·艮3·震4·中5(不入)·兑6·坤7·坎8·巽9。

## 1. RuleValue(规则输出类型,typed union)

每条规则求值产出一个 `RuleValue`。引用方按 `output` 声明的类型校验,类型不匹配即报错。

| type | 载荷 | 用于 |
|---|---|---|
| `scalar` | `{ "type":"scalar", "value": int }` | 积年/入局/局数/算数/步数 |
| `palace` | `{ "type":"palace", "palace": "乾\|离\|艮\|震\|兑\|坤\|坎\|巽" }` | 落宫(八宫,不含中五) |
| `deity` | `{ "type":"deity", "name": String }` | 十六神/十二支神位名 |
| `predicate` | `{ "type":"predicate", "matched": bool, "name": String }` | 格局判定 |
| `record` | 仅引擎内部桥接 | **不得**写进 School JSON;落盘前必须拆成上面四类之一 |

## 2. School v1 文档结构

```jsonc
{
  "schemaVersion": 1,
  "meta": { "id": String, "name": String, "version": int, "source": String, "owner": "official"|"user" },
  "palace": "taiyi9",
  "rules": [ <Rule>, ... ],            // 见 §3
  "charts": {
    "year":  { "enabled": bool, "ruJuRef": <ruleId>, "appliesTo": ["year"] },
    "month": { "enabled": bool, "ruJuRef": <ruleId>, "appliesTo": ["month"] },
    "day":   { "enabled": bool, "ruJuRef": <ruleId>, "appliesTo": ["day"] },
    "hour":  { "enabled": bool, "ruJuRef": <ruleId>, "appliesTo": ["hour"] }
  },
  "dun":  { "resolver": "metaphysicsCoreJieQi", "termMode": "leveling"|"stabilizing", "calibration": "winterReset"? },
  "foundation": { "taiYiRef": <id>, "wenChangRef": <id>, "jiShenRef": <id>, "shiJiRef": <id> },
  "threeCalc":  { "hostRef": <id>, "guestRef": <id>, "dingRef": <id> },
  "generals":   { "hostMajorRef": <id>, "hostMinorRef": <id>, "guestMajorRef": <id>, "guestMinorRef": <id>, "dingMajorRef": <id>?, "dingMinorRef": <id>? },
  "deities": [ { "id": String, "name": String, "layer": "tian"|"ren"|"shen", "appliesTo": [chart...], "ruleRef": <id>, "visible": bool } ],
  "geJu": [ { "id": String, "ruleRef": <id> } ]
}
```

## 3. Rule(以 `kind` 为判别式,声明 `output`)

公共字段:`{ "id": String(文档内唯一), "kind": ..., "output": "scalar|palace|deity|predicate", ... }`

| kind | 专属字段 | output |
|---|---|---|
| `scalar` (R1) | `tree`(JSON 算术树), `zeroAsCycle`?: int | scalar |
| `walk` (R2) | `palaceSystem`: `eight8\|sixteenGods\|twelveBranch`;`start`: String 或 `{yang,yin}`;`direction`: `forward\|reverse` 或 `{yang,yin}`;`steps`: `{tree}`;`restAt`?: `{values:[...], source}`(重留) | palace 或 deity |
| `walkSum` (R3) | `startRef`;`endpoint`: `{yang:"taiYiPrev",yin:"taiYiNext"}`(缺省两者皆 prev);`normalize`:"满十去十";`tenTo`?:9;`wuSuan`:`{samePalace:0,oneStep:0,sameEnd:0}` | scalar |
| `deriveCount` (R4) | `countRef`;`daMap`(算数→宫,10→9宫);`minorTree`?(如 `(大将宫*3)%10`) | palace |
| `relative` (R5) | `baseRef`;`mode`:`opposition\|offset`;`offset`?: int;`palaceSystem` | palace 或 deity |
| `table` (R6) | `table`: [int...];`indexTree`: `{tree}`;`startPalace`?;`direction`? | palace |
| `predicate` (R7) | `when`: `{op:"eq\|adjacent\|coLocatedEqualCount", args:[<ref>...]}`;`name` | predicate |

## 4. 算术树变量域(R1 `tree` 的 `{var}`)

`Y`(公元年) `M`(月) `D`(年内日序) `H`(时辰序) `J`(积年=accumulation 结果) `ruJu`(入局数=chart.ruJuRef 结果) `ju`(局数) + 任意前序规则 id 的 scalar 结果。节点白名单与深度上限见 design.md §3 / ACT-001。

## 5. Validation 规则(保存/导入时强制)

1. `schemaVersion` 必填;未知版本拒绝。
2. rule `id` 文档内唯一;所有 `*Ref` 必须指向存在的 id,且被引用规则的 `output` 与消费方期望类型一致。
3. 规则引用图必须是 **DAG**(禁环)。
4. 未知 `kind` / `palaceSystem` / `op` / 算术节点 → 拒绝。
5. 争议字段 provenance 用对象 `{ "values":[...], "source": String }`,不得用裸字符串。
6. `record` 不得出现在 School JSON。
7. 报错对象:`{ "schoolId": String, "fieldPath": String, "message": String }`。

## 6. 冻结后解锁

本契约一经 contract 测试覆盖通过,§4 `rule_models`、§5 R4–R7、§7 五派资产、§8 repository 的"形状"即固定,可批量转 ACT 与并行实现。
