# DISPATCH — 自主闭环执行手册 (taiyi-rule-engine)

本手册让执行型 AI agent **自我循环**完成本 change 的全部任务,直到 `tasks.md` 全勾且终态门通过才停。**不需要人逐个派发**。

## 0. 你是谁 / 总目标

你是执行 agent。目标:把 `openspec/changes/taiyi-rule-engine/` 这个 change 的 `tasks.md` 从头到尾做完——写 `lib/taiyi/rules/` 生产代码 + 测试,每步真实跑绿后才勾选,直到全部完成。

## 1. 每轮必读(顺序)

1. `tasks.md` —— 权威清单(找下一个未勾、门控已满足的任务)。
2. `design.md` —— 架构与规则语义。
3. `specs/taiyi-rule-engine/spec.md` —— **验收标准**(每条 Scenario 即一条 acceptance)。
4. `acts/CONTRACT-schema-rulevalue.md` —— **已冻结**的 School schema + RuleValue(下游一切形状以此为准)。
5. `acts/ACT-*.yaml` —— 已写好的逐任务规格(有就直接执行)。
6. `test/poc/taiyi_rule_engine_poc_test.dart` —— R1/R3 的 oracle 参考(断言值即正确值)。
7. 数理 oracle 经文:`docs/classes/5_in_one_classes_alg.md`(算法)、`core_diff.md`(五派开关)。

## 2. 执行顺序与门控(严格遵守)

| 阶段 | tasks.md | 前置门控 |
|---|---|---|
| A | §1 安全基线 | — |
| B | §2 三个 contract 测试(metaphysics_core / calculator API / no-runtime-execution) | 必须**先红后绿**;未过不得写 §6/§9 生产代码 |
| C | §3 School schema + validation(`school_document.dart` + 两测试) | 以 `CONTRACT-schema-rulevalue.md` 为唯一形状来源 |
| D | §4 核心引擎 R1–R3(`arithmetic_tree.dart`=ACT-001;`nine_palace.dart`=ACT-002;`rule_models.dart`;`rule_engine.dart`;测试) | §3 通过 |
| E | §5 R4–R7 + `rule_kinds_test.dart` | §3 通过 |
| F | §6 R8 dun_resolver + jiaZiDayAnchor + calibration | §2 的 metaphysics_core 合同**绿**或已记录 adapter 决策 |
| G | §7 五派官方资产 + 向量 | §3 schema 合同**绿** |
| H | §8 school_repository + CRUD 测试 | §3 通过 |
| I | §9 calculator 接线 | §2 的 calculator 合同已决策(同步兼容层 or 全异步,二选一并留证据) |
| J | §10 收尾 | 其余全绿 |

无对应 ACT 文件的任务:**自行按 ACT 纪律生成**——强类型签名 + 从 spec.md Scenario / 5_in_one 确定性公式 / contract 测试取**精确断言**,再实现。

## 3. 单任务循环

```
loop:
  task = tasks.md 中下一个未勾且门控满足的项
  if 无此 task: goto DONE
  实现 task(生产代码 + 测试);§2/§3 标注"先红"的先写失败测试
  跑验证(§4):必须真实绿
  仅当绿 → 在 tasks.md 勾选 [x],附一行证据(命令 + 结果)
  repeat
```

## 4. 验证命令(必须真实执行、贴真实输出)

- 单元:`flutter test <该任务相关测试文件>`
- 阶段汇总:`flutter test test/taiyi/rules/`
- 接线后:`flutter test test/taiyi/` + `flutter analyze`
- 规范:`openspec validate taiyi-rule-engine --strict --no-interactive`
- 就绪扫描:`rg -n "[T]BD|[T]ODO|[F]IXME|[p]laceholder" openspec/changes/taiyi-rule-engine`

## 5. 防造假铁律(违反即任务失败)

1. **不得**为了让测试过而修改/删除/弱化断言;断言值源自 PoC / spec / 5_in_one,是真值。
2. **不得**伪造孔令伟等权威盘例向量;无来源就标 `provenance: pending` 且**不**作为 release gate,而非编造数字。
3. 既有的预存在失败测试(本仓库现有 ~33 个 red)如实记录为 pre-existing,不得归咎本 change,也不得靠删它们"变绿"。
4. 只有真实绿输出才勾选;跑不动就把阻塞写进 tasks.md 该项下,跳到下一个未阻塞任务。
5. 改任何现有符号前先跑 GitNexus impact(§9);新建 `lib/taiyi/rules/` 文件无需。

## 6. 停机条件(满足才停,否则继续下一个未阻塞任务)

- `tasks.md` 全部 `[x]`;**且**
- `openspec validate taiyi-rule-engine --strict` 绿;**且**
- `flutter test test/taiyi/` 绿(或仅剩已记录的 pre-existing 无关失败);**且**
- 就绪扫描无命中。

满足 → 输出一行总结(完成项数 / 测试统计 / 剩余 provenance-pending 项)并停止。
不满足且仍有未阻塞任务 → 继续循环。全部剩余任务都被外部因素阻塞(如 metaphysics_core API 缺失、权威向量未到)→ 记录阻塞清单后停止并上报。

## 7. 启动话(给 orchestrator / 循环器)

> 读 `openspec/changes/taiyi-rule-engine/acts/DISPATCH.md` 并严格执行其循环:每轮取 `tasks.md` 下一个未勾且门控满足的任务,依 `design.md`+`spec.md`+`CONTRACT-schema-rulevalue.md`(+对应 `ACT-*.yaml`)写生产代码与测试,`flutter test` 与 `openspec validate` 真实全绿后才勾选,严禁改断言/删弱测试/编造向量,直到 §6 停机条件全部满足或剩余任务全被外部阻塞才停。
