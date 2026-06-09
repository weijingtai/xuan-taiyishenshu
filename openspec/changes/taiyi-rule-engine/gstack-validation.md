# gStack Validation: taiyi-rule-engine

## Source Skill Notes

- gStack 是发布就绪/QA 就绪/实现可应用性的验证证据层。
- 工程计划评审覆盖:架构、数据流、边界、测试、未决决策、实现就绪度。
- QA 报告模式要求结构化证据 + 健康/就绪摘要。

## Architecture Readiness Checklist

- [ ] School v1 schema + `RuleValue` 已冻结(`acts/CONTRACT-schema-rulevalue.md`)并有 contract 测试覆盖(tasks.md §3)。
- [ ] 规则种类 R1–R7 + R8 上下文足以表达五派(`docs/classes/5_in_one_classes_alg.md`)。
- [ ] 算术叶子为 JSON 算术树,无字符串解析/无 JS/无运行时 codegen。
- [ ] 官方派与用户派同构(同引擎,差别仅 owner)。
- [ ] 三算用太乙九宫序 + 满十去十(10归9) + 无算 S=0(修正现有代码缺陷)。
- [ ] 节气/阴阳遁/甲子日 anchor 复用 metaphysics_core,平气/定气可配(待 `acts/SPIKE-metaphysics-core-jieqi.md` 证实能力)。
- [ ] calculator 接线前先有 API 策略合同(同步兼容 vs 全异步)。

## QA Readiness Checklist

- [ ] OpenSpec 校验:`openspec validate taiyi-rule-engine --strict --no-interactive` 通过。
- [ ] 占位符扫描无命中:`rg -n "[T]BD|[T]ODO|[F]IXME|[p]laceholder" openspec/changes/taiyi-rule-engine`。
- [ ] PoC 绿:`flutter test test/poc/taiyi_rule_engine_poc_test.dart`(已 11/11)。
- [ ] 开工前基线红绿已记录(`acts/BASELINE.md`,区分 pre-existing 失败)。
- [ ] §2 三个 contract 测试先红后绿(metaphysics_core / calculator API / no-runtime-execution)。
- [ ] §3 schema contract 通过后才写五派官方资产。
- [ ] R1/R3 断言对齐已验证的 PoG oracle;不得改断言迁就实现。
- [ ] 接线后全量 `flutter test test/taiyi/` + `flutter analyze` 记录;GitNexus detect-changes 记录。
- [ ] 权威向量(暂定孔令伟)若未到,标 provenance-pending,**不**作为 release gate。

## Go / No-Go Recommendation Rule

- Go:CONTRACT 冻结 + PoC 绿 + 基线已记录 → 可按 `acts/DISPATCH.md` 自主推进 §1–§5/§8。
- No-Go:在 metaphysics_core 能力 spike 未结论前写 R8 生产代码。
- No-Go:在 schema contract 未过前写五派官方资产。
- No-Go:无证据直接改 `TaiYiPanCalculator.calculate*` 签名(须先有 calculator API 合同决策)。
- No-Go:编造权威盘例向量,或靠删/弱化既有测试"变绿"。

## Application Boundary

本 change 为 package-local(`xuan-taiyishenshu/openspec/changes`)。若 `xuan-migration` 根 OpenSpec registry 是实现 worker 的事实源,须在根仓注册或复制本 change 并从根校验后再开工(见 README「根级注册」决策项)。
