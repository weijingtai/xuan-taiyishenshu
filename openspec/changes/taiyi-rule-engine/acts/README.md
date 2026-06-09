# ACT 任务调度索引 — taiyi-rule-engine

供较便宜的执行型 AI agent 逐个完成。每个 `ACT-*.yaml` 是自包含任务:钉死签名 + 可直接跑的断言。

## 入口(从这里开始)

- **`DISPATCH.md`** —— 自主闭环执行手册:agent 自我循环跑完整个 `tasks.md`,带门控/自检/防造假/停机条件。**先读它。**
- **`CONTRACT-schema-rulevalue.md`** —— 已冻结的 School v1 schema + RuleValue,下游一切形状以此为准(总阀门已开)。
- `ACT-001/002` —— 已写好的种子任务;无对应 ACT 的任务由 DISPATCH 指引按 CONTRACT+spec 现场生成并执行。

## 执行方House Rules(所有任务通用)

- 语言锁定 **Dart 3.10.7 (stable) / Flutter 3.38.6**;包名 `taiyishenshu`(`lib/` ↔ `package:taiyishenshu/`)。
- `PROTOCOL.MODE: FULL_FILE` → 产出 `TARGET_FILE` 整文件;`NO_PROSE` → 只返代码、包在 ``` 内。
- **不得新增第三方依赖**(`EXTERNAL_LIBS: []`);只用 `IMPORTS` 列出的包。
- 验收:把 `ASSERTIONS.CASES` 落进一个 import 了 `TARGET_FILE` 的测试文件,`flutter test` 全绿即通过。断言值源自已验证的 PoC(`test/poc/taiyi_rule_engine_poc_test.dart`),不得改断言来迁就实现。
- 数理基准:太乙九宫 = 乾1·离2·艮3·震4·中5(不入)·兑6·坤7·坎8·巽9(**非洛书**)。

## 可立即派发(纯净、PoC 有精确 oracle、不依赖未冻结 schema)

| 顺序 | 文件 | TARGET_FILE | 依赖 |
|---|---|---|---|
| 1 | ACT-001 | `lib/taiyi/rules/arithmetic_tree.dart` | 无 |
| 2 | ACT-002 | `lib/taiyi/rules/nine_palace.dart` | 无 |

两者互不依赖,可并行。它们是 R1/R3 的纯函数底座,通过 `tasks.md` §2/§3 的合同门控(不碰 metaphysics_core、不碰 calculator 签名、不进字符串/JS/运行时执行路径、不预设 School schema)。

## 暂不派发(被 tasks.md §2 / §3 合同门控)

以下单元必须等 **`RuleValue` 类型 + School v1 schema(`rules[]` + `*Ref` + discriminator `kind`/`output`)冻结**、且 §2 三个合同测试(metaphysics_core / calculator API / no-runtime-execution)落地后,才能写成 ACT:

- `rule_models.dart`(R1/R2/R3 typed 模型 + JSON 解析)——形状依赖 School schema。
- foundation 组合(R1+R2 经 `*Ref` 取 ruJu)——旧 PoC 的内联 `charts.year.ruJu.tree` 形状已被 schema 改为 `ruJuRef`,现在派发会焊死过时结构。
- R4–R7、R8 dun_resolver(metaphysics_core)、五派官方资产、school_repository、calculator 接线。

> School schema 已由 `CONTRACT-schema-rulevalue.md` **冻结**,总阀门已开;上面这些单元的形状已固定,由 `DISPATCH.md` 循环驱动(有 ACT 用 ACT,没有则按 CONTRACT+spec 现场生成),不再需要人逐个派发。
