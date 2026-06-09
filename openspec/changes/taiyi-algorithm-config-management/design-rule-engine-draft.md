# 草图:规则驱动的太乙流派引擎(替代当前 Layer 1 固定模板设计)

> ⛔ SUPERSEDED(2026-06-08):内容已并入正式 change `../taiyi-rule-engine/design.md`(及其 `acts/CONTRACT-schema-rulevalue.md`);本草图仅作 precursor 留存,不再维护。

> 状态:DRAFT / 待评审。目标是支撑「用户自建·编辑·保存·管理自己的流派(含星神与每派关键信息)」。
> 本草图取代当前 `design.md` 中「有限固定模板 + 官方不可变 + 只读选择 + 禁表达式」的 Layer 1 路线。
> 数理基准:太乙九宫 = 乾1·离2·艮3·震4·中5(不入)·兑6·坤7·坎8·巽9(非洛书)。

## 1. 目标与范围

- 用户能从零创建,或 fork 官方派后修改,一个**完整流派文档**:积年、四计范围、起神起将、三算、八将/十精/五福等星神、格局、时计阴阳遁。
- 官方派(金镜/统宗/淘金歌/福应经/集成)与用户派**走同一个引擎**,差异只在「数据」和「来源/可写权限」。
- 引擎是**原生 Dart 解释器**,跑**结构化规则数据**;算术叶子用一个**JSON 算术树求值器**(结构化 AST,白名单节点,无函数/无循环/无 IO)。**不引入 DSL 语言/字符串解析器,不嵌 JS 引擎**(AOT 安全、零重依赖)。

## 2. 设计原则

1. **数据驱动**:算法的「形状」是 JSON 规则数据,用户改数据,不改代码。
2. **原生解释 + JSON 算术树**:执行全是 Dart;算术叶子是**结构化 JSON 算术树(AST)**,不是字符串表达式——**没有任何语法解析器,也不嵌 JS/VM**。
3. **有限可组合**:约 7 种规则 + 算术树,即可覆盖五派全功能;新规则=新增一种规则种类(发版),但绝大多数新流派只靠组合现有种类。
4. **安全自带**:规则种类有限、AST 节点类型白名单、引用成 DAG(禁环)、AST 有深度上限 → 天然不可图灵完备、无 IO、无循环。
5. **官方=用户同构**:同一份 Schema;`owner: official|user` 决定可写性与是否随包发布。
6. **数据溯源**:有争议/有出处的取值(如重留位)必须带 `source` 字段标注来源经文,便于后续核对修改。

## 3. 规则种类清单(7 种 + 1 个上下文模块)

所有规则的输出是「一个整数」或「一个宫位/神位」。可被后续规则按 `id` 引用。

### R1 ScalarFormula — 标量公式(JSON 算术树)
- **用途**:积年、入局数、局数、各种「步数」。
- **节点类型(白名单,无字符串解析)**:
  - `{"int":n}` 整数字面量;`{"num":x}` 实数字面量(仅可作 `*` 的操作数,须由 `floor` 收成整数)
  - `{"var":"Y"}` 输入变量,或前序规则结果(按 id)
  - `{"op":"+|-|*|~/|%","a":<节点>,"b":<节点>}`(整除用 `~/`;**不提供 `/`** 以免浮点歧义)
  - `{"floor":<节点>}` 实数向下取整
- **变量**:`Y`(年) `M`(月) `D`(年内日序) `H`(时辰序) `J`(积年) `ruJu`(入局数) `ju`(局数),以及前序规则的整数结果(按 id)。
- **规则包装**:`{ "kind":"scalar", "tree":<节点>, "zeroAsCycle":<int?> }`(`zeroAsCycle` 后置:结果为 0 时取该周期值)。
- **约束**:AST 深度上限(如 ≤16),仅上述节点类型 → 天然安全、可序列化、可由「表达式树」结构化编辑器渲染。
- **例**:
  ```jsonc
  // 金镜积年 10153917 + (Y - 751)
  "accumulation": { "kind":"scalar",
    "tree":{"op":"+","a":{"int":10153917},
            "b":{"op":"-","a":{"var":"Y"},"b":{"int":751}}} }
  // 年计入局 J % 360 (余0取360)
  "ruJu": { "kind":"scalar", "tree":{"op":"%","a":{"var":"J"},"b":{"int":360}}, "zeroAsCycle":360 }
  // 日计入局 floor(J * 365.2425) + D
  "ruJuDay": { "kind":"scalar",
    "tree":{"op":"+","a":{"floor":{"op":"*","a":{"var":"J"},"b":{"num":365.2425}}},
            "b":{"var":"D"}}, "zeroAsCycle":360 }
  ```

### R2 PalaceWalk — 走宫 / 起神起将
- **用途**:天目、计神、三基、八将、十精、五福、小游、地乙、飞符、四神……(最高频)
- **字段**:`palaceSystem`(`eight8|sixteenGods|twelveBranch`)、`start`(神名)、`direction`(`forward|reverse`)、`steps`(R1 引用或内联 expr)、可选 `restAt`(**重留**位列表)、可选 `dun`(阳/阴各自覆盖 start/direction)。
- **例**:
  ```jsonc
  // 君基(统宗): 午起·顺16神·周期24, 步=(ju-1)%24
  { "id":"junJi","kind":"walk","palaceSystem":"sixteenGods","start":"午","direction":"forward",
    "steps":{"tree":{"op":"%","a":{"op":"-","a":{"var":"ju"},"b":{"int":1}},"b":{"int":24}}} }
  // 天目(金镜): 武德起·顺16神·遇这些位重留一算
  { "id":"tianMu","kind":"walk","palaceSystem":"sixteenGods","start":"武德","direction":"forward",
    "steps":{"tree":{"op":"%","a":{"var":"ruJu"},"b":{"int":18}}},
    "restAt":["阴德","大武","乾","坤"], "source":"5_in_one_classes_alg.md §4.1" }
  // 计神: 阳起寅·阴起申·逆行, 步=ruJu%12
  { "id":"jiShen","kind":"walk","palaceSystem":"twelveBranch","direction":"reverse",
    "steps":{"tree":{"op":"%","a":{"var":"ruJu"},"b":{"int":12}}},
    "dun":{"yang":{"start":"寅"},"yin":{"start":"申"}} }
  ```

### R3 WalkAndSum — 三算(主/客/定算)
- **用途**:主算、客算、定算累加。
- **字段**:`startRef`(起点神位 id,如 `tianMu`/`shiJi`/`dingMu`)、`endpoint`(`{yang:"taiYiPrev",yin:"taiYiNext"}`,默认都 prev)、`sumOf:"宫本数"`、`normalize:"满十去十"`、`tenTo`(10 归 9 → 9 宫)、`wuSuan`(无算边界规则)。
- **必须修正(本会话已发现的两处缺陷)**:
  - 走**太乙九宫序**并跳过中五(当前代码走 16 神地理序,序不同);
  - 实现**无算 S=0**(起点==太乙宫,或一步即到 → 0;当前代码返回宫数/10/1,从不返 0)。
- **例**:
  ```jsonc
  { "id":"hostCalc","kind":"walkSum","startRef":"tianMu",
    "endpoint":{"yang":"taiYiPrev","yin":"taiYiNext"},
    "normalize":"满十去十","tenTo":9,
    "wuSuan":{"samePalace":0,"oneStepToTaiYi":0} }
  ```

### R4 DeriveFromCount — 由算数定将
- **用途**:大将、小将(参将)。
- **字段**:`countRef`、`map`(算数→宫,含 10→9 宫)、`minorExpr`(如 `(大将宫*3) % 10`,0→10→9 宫)。

### R5 Relative — 相对位 / 对冲
- **用途**:始击(计神对冲)、福应经定大将(主大将顺 1 宫)、relativeOffset 类星神。
- **字段**:`baseRef`、`mode`(`opposition|offset`)、`offset`、`palaceSystem`。

### R6 TableSequence — 序列表查
- **用途**:直符 `[5,6,12,8,9,10,7,15,16,2,4,5]`、大游 `[7,6,4,3,2,1,9,8]`、地支→九宫映射等固定表。
- **字段**:`table`(字面数组)、`indexExpr`(R1)、`startPalace`、`direction`。

### R7 Predicate — 格局判定
- **用途**:掩/迫/击/格/关/囚。
- **字段**:`name`、`when`(关系谓词:`eq` / `adjacent(±1)` / `coLocatedEqualCount`,操作数为前序位/算数的 id)。
- **例**:`{"geJu":"yan","when":{"eq":["shiJiPalace","taiYiPalace"]}}`(掩=始击同太乙)。

### R8(上下文模块)DunResolver + Calibration — 阴阳遁 / 节气校正
- **用途**:由**精确节气交节时刻**判阳/阴遁(替换现有硬编码 6/21、12/21);福应经「节气校正(冬至重置)」作为一个**流水线变换阶段**。
- **数据源:复用 `metaphysics_core`**(不另造节气表):
  - `TwentyFourJieQi`(24 节气枚举,如 `DONG_ZHI` 冬至、`XIA_ZHI` 夏至)
  - `JieQiType.leveling`(平气法)/ `JieQiType.stabilizing`(定气法)——**每个流派可配 `termMode: "平气"|"定气"`**(古法多平气,1645 时宪历后定气;由流派文档指定)
  - 交节时刻取自 `metaphysics_core` 的 solar_time / jieqi_entry_strategy
- **字段**:`resolver:"metaphysicsCoreJieQi"`、`termMode:"平气"|"定气"`、可选 `calibration:"winterReset"`(福应经)。
- **阴阳遁**:阳遁 = 冬至(`DONG_ZHI`)交节 → 夏至(`XIA_ZHI`)交节;阴遁反之。

## 4. 覆盖核对(5_in_one 全功能 → 规则种类)

| 5_in_one 功能 | 规则种类 |
|---|---|
| 积年(5 派,皆线性,含淘金歌 Y+2697) | R1 |
| 入局 年/月/时 | R1(链式 + mod + 零取整) |
| 局数 / 太乙宫索引 | R1(+ 宫序取下标) |
| 天目(含重留)、计神(阴阳起+逆行) | R2 |
| 始击(对冲) | R5 |
| 主/客/定算 | R3;福应经定大将 R5 |
| 大/小将 | R4 |
| 三基/八将/地乙/飞符/四神/十精/五福/小游/三宫 | R2 |
| 大游 / 直符 | R6 |
| 格局(掩迫击格关囚) | R7 |
| 阴阳遁 / 四计范围开关 / 某派不排某神 | R8 + 各规则 `appliesTo` 字段 |

**三个需要特别处理的硬骨头(已定):**
1. **统宗日计「独立起局」**(冬/夏至后首个**甲子日**起算)——需要内置原语 `jiaZiDayAnchor(date)`:用 `metaphysics_core` 取冬至/夏至(`DONG_ZHI`/`XIA_ZHI`,按流派 `termMode` 平气/定气)交节时刻,再向后找首个甲子日。由引擎提供,**不**开放给用户写。
2. **福应经节气校正(冬至重置)**——横切,放在 R8 当**流水线阶段**,数据源同样是 `metaphysics_core` 节气。
3. **重留位:已定用 `5_in_one_classes_alg.md §4.1`**(阴德 / 大武 / 乾 / 坤),并在数据里以 `source` 字段显式标注(见 R2 天目例),便于后续修改;**不**采用 core_diff 的(阴德/和德/大炅/大武)。

## 5. 数据模型(School 文档)

```jsonc
School {
  meta: { id, name, version, source/provenance, owner: "official"|"user" },
  palace: "taiyi9",                 // 固定引用:乾1离2艮3震4中5兑6坤7坎8巽9
  accumulation: ScalarFormula,      // 含「可切换基准」(集成派) 用变体
  charts: {                         // 四计范围开关 + 各计入局公式
    year:  { enabled:true,  ruJu:ScalarFormula },
    month: { enabled:true,  ruJu:ScalarFormula|"独立起局变体" },
    day:   { enabled:true,  ruJu:ScalarFormula|"甲子日anchor" },
    hour:  { enabled:true,  ruJu:ScalarFormula }
  },
  dun: { resolver:"preciseSolarTerm", calibration?:"winterReset" },
  foundation: { taiYi:R1/R2, wenChang:R2, jiShen:R2, shiJi:R5 },
  threeCalc:  { host:R3, guest:R3, ding:R3|R5 },
  generals:   { hostMajor:R4, hostMinor:R4, guestMajor:R4, ... },
  deities: [ DeityDef{ id, name, layer:天/人/神盘, appliesTo:[charts], rule:R2|R5|R6, visible } ],  // ← 用户主要在这里增删改
  geJu: [ R7, ... ]
}
```

- **每个规则带 `appliesTo`**(哪些计法用)→ 表达「淘金歌只年计」「时计不排三基」这类范围开关。
- **DeityDef 列表**就是用户「编辑星神」的落点;增删一条即增删一个星神。

## 6. 编辑器 / 存储边界

| | 官方派 | 用户派 |
|---|---|---|
| 存储 | 随包 JSON assets,**只读**,版本化,向量背书 | 用户可写仓库(本地 DB/文件),**全 CRUD** |
| 来源 | 5 部经典 | 从零建,或 fork 官方后改 |
| 引擎 | 同一个解释器,**不区分来源** | 同左 |
| 编辑 | 不可改(可 fork) | **结构化编辑器**(表单:起神/周期/步进/顺逆/重留位…),算术叶子=带校验的小输入框,**非自由文本代码** |

- **校验(保存时)**:规则种类已知、宫制已知、表达式过白名单+深度上限+变量已声明、引用成 DAG 无环、必填齐全 → 失败给「字段路径 + profileId」级报错(沿用现 OpenSpec 的报错要求)。
- **导出/导入**:用户派可导出为 JSON 分享;导入走同一套校验。

## 7. 与现有代码的映射(扩展,不重写)

| 现有 | 去向 |
|---|---|
| `DeityAlgorithmEngine` 的 `steppedCycle/cumulativeWalk/branchWalker/relativeOffset/fixedPosition` | 收敛为 R2/R5/R1/R6 |
| `_executeCustomFormula` + `ExpressionParser`(字符串解析) | **弃用字符串解析**,改为 R1 的 **JSON 算术树求值器**(递归遍历 AST);现有 `replaceAll` 子串撞车 / 无括号问题随之消失 |
| `CustomDeityRepository`(已异步、用户可写) | 泛化为 `SchoolRepository`(官方 asset loader + 用户 CRUD) |
| `FoundationResult`(当前 OpenSpec 概念) | 保留为基础层桥接对象,由 R1 产出 |
| `_walkAndSumWithDetail` | 重写为 R3 解释器,**修无算缺失 + 改用太乙九宫序** |
| `TaiYiSchool/SchoolEpochConfig` | 并入 School 文档的 `meta + accumulation` |

## 8. 与当前 OpenSpec 的差异(要改写的原则)

- ❌「official profiles are immutable / 用户只能 select」→ ✅ 官方只读但用户派全 CRUD,同构。
- ❌「no expressions / no runtime execution」→ ✅ 用 **JSON 算术树**(结构化 AST,非字符串、非语言、非 VM;天然安全)。
- ❌「Layer 1 = 超具体模板(tianZhengMonth/tropicalDay…)」→ ✅ 通用规则种类(R1–R7)。
- 保留:类型化引擎、FoundationResult、异步加载+缓存、向量测试、分层思想(但**重排优先级**:先做高变异的起神/星神/三算,而非只做积年)。
- 体量上这已超出当前 change → 建议**另立一个 OpenSpec change**(或对本 change 做大改版),旧的 Layer 1 仅作低风险打底保留。

## 9. 分期落地(重排后)

1. **引擎 + 规则种类 R1–R3 + JSON 算术树求值器** + 太乙九宫 + 无算修正;先用金镜年计跑通向量。
2. **5 官方派落成 School 文档 + 全量回归向量**(年/月/日/时)。
3. **SchoolRepository(官方 asset + 用户 CRUD)+ 结构化编辑器 + 校验/导入导出**。
4. **R4–R7 + 八将/十精/五福/格局**;补三硬骨头(甲子日 anchor、节气校正、重留数据)。
5. 全功能回归 + analyzer + GitNexus detect-changes。

## 10. 决策记录 / 剩余风险

**已定(2026-06-08):**
- 算术叶子 → **JSON 算术树**(不用字符串解析器、不嵌 JS)。
- 重留位 → **`5_in_one_classes_alg.md §4.1`**(阴德/大武/乾/坤),数据带 `source` 字段显式标注。
- 节气 / 阴阳遁 / 甲子日 anchor → 复用 **`metaphysics_core`**(`TwentyFourJieQi` + `JieQiType.leveling/stabilizing`),流派可配 **平气/定气**。
- 官方派向量 → **暂定孔令伟**(权威源未找到,先用此跑通回归)。

**剩余:**
- 用户派的版本/兼容策略(新增规则种类后,老用户派如何迁移)。
- 各官方派 `termMode` 默认值(平气 vs 定气)逐派确认。
- 孔令伟向量的具体盘例清单(年/月/日/时)需落成测试数据。
