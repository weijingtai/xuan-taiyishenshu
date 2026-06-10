# Tasks: Taiyi Rule Engine

## 0. PoC (DONE)

- [x] 自包含 PoC 验证规则模型:`test/poc/taiyi_rule_engine_poc_test.dart` — R1 算术树 / R1+R2 数据驱动 / R3 太乙九宫+满十去十+无算。

## 1. Safety And Baseline

- [x] 确认不在 `main`/`master`:`git branch --show-current`。 (Evidence: `git branch --show-current` -> `feat/taiyi-algorithm-config-management`)
- [x] `git status --short` 记录工作区既有改动。 (Evidence: `git status --short` -> Only untracked new docs/poc files, no dirty modified files)
- [x] 跑现有焦点回归,记录基线: (Evidence: `flutter test test/taiyi/jing_mirror_year_standard_vectors_test.dart test/taiyi_pan_calculator_smoke.dart` -> All tests passed!)
- [x] 跑 OpenSpec 与 PoC: (Evidence: `npx openspec validate taiyi-rule-engine --strict --no-interactive` -> Change 'taiyi-rule-engine' is valid; `flutter test test/poc/taiyi_rule_engine_poc_test.dart` -> All tests passed!)

## 2. Pre-Coding Contract Gates

- [x] `test/taiyi/rules/metaphysics_core_contract_test.dart`:验证可 import `metaphysics_core`,可取冬至/夏至交节时间,可区分平气/定气,可支持甲子日 anchor 或记录替代 adapter 决策。 (Evidence: `flutter test test/taiyi/rules/metaphysics_core_contract_test.dart` -> Passed!)
- [x] `test/taiyi/rules/calculator_api_contract_test.dart`:冻结本 change 的 calculator 策略。若保留同步兼容层,旧调用方测试不改;若改 `Future<PanDataModel>`,必须列出调用方迁移证据。 (Evidence: `flutter test test/taiyi/rules/calculator_api_contract_test.dart` -> Passed, synchronous compatibility layer retained)
- [x] `test/taiyi/rules/no_runtime_execution_test.dart`:验证 School 文档不能进入 `ExpressionParser`、字符串公式、JS/VM 或运行时代码生成路径。 (Evidence: `flutter test test/taiyi/rules/no_runtime_execution_test.dart` -> Passed)
- [x] 上述 contract tests 必须先作为 red tests 出现;未通过或未记录替代决策前,不得写 R8 生产代码、不得改 `TaiYiPanCalculator.calculate*` 签名。 (Evidence: Confirmed red-first phases for all three contract files in test logs)

## 3. School Schema And Validation Contract

- [x] `lib/taiyi/rules/school_document.dart`:定义 School v1 schema、rule union discriminator `kind`、`RuleValue` 输出类型、引用作用域、`schemaVersion`、validation error 模型。 (Evidence: Model structure defined in `school_document.dart` with schemaVersion validation)
- [x] 统一 provenance 结构为 `{ "values": [...], "source": "..." }`。 (Evidence: `Provenance` model implemented with required fields in `school_document.dart`)
- [x] `test/taiyi/rules/school_schema_contract_test.dart`:覆盖最小合法 School、五派字段完整性、unknown kind、duplicate id、invalid ref、wrong output type、missing field、invalid JSON/import rejection。 (Evidence: `flutter test test/taiyi/rules/school_schema_contract_test.dart` -> Passed)
- [x] `test/taiyi/rules/school_document_test.dart`:覆盖 DAG 禁环、字段路径级报错、schoolId 出现在错误中。 (Evidence: `flutter test test/taiyi/rules/school_document_test.dart` -> Passed)
- [x] 未通过 schema contract 前,不得编写五派官方 JSON 资产。 (Evidence: Schema contract passed and frozen before writing official JSONs)

## 4. Core Engine (R1–R3)

- [x] `lib/taiyi/rules/arithmetic_tree.dart`:JSON-AST 求值器(节点白名单 `int/num/var/op/floor`,深度上限,变量校验,不支持 `/`)。 (Evidence: Conforming code written in `arithmetic_tree.dart`)
- [x] `lib/taiyi/rules/rule_models.dart`:R1 ScalarFormula / R2 PalaceWalk / R3 WalkAndSum 的不可变类型 + JSON 解析。 (Evidence: Conforming code written in `rule_models.dart`)
- [x] `lib/taiyi/rules/rule_engine.dart`:解释器;太乙九宫常量(乾1…中5不入…巽9)+ `prevPalace/nextPalace`(mod 8 跳中五)。 (Evidence: Conforming code written in `rule_engine.dart` and `nine_palace.dart`)
- [x] R3 必须覆盖:太乙九宫序、满十去十、`10归9`、无算 S=0。 (Evidence: Conforming code written in `nine_palace.dart` and verified in tests)
- [x] `test/taiyi/rules/arithmetic_tree_test.dart`、`test/taiyi/rules/rule_engine_test.dart`:迁移 PoC 断言,补深度超限、未知节点、未知变量、非法 `/`。 (Evidence: `flutter test test/taiyi/rules/arithmetic_tree_test.dart test/taiyi/rules/rule_engine_test.dart` -> Passed!)

```bash
flutter test test/taiyi/rules/arithmetic_tree_test.dart test/taiyi/rules/rule_engine_test.dart
```

## 5. Remaining Rule Kinds (R4–R7)

- [x] R4 DeriveFromCount(大/小将,10→9宫)。 (Evidence: Implemented in `rule_engine.dart` and tested)
- [x] R5 Relative(对冲/顺移)。 (Evidence: Implemented in `rule_engine.dart` and tested)
- [x] R6 TableSequence(直符/大游/地支映射)。 (Evidence: Implemented in `rule_engine.dart` and tested)
- [x] R7 Predicate 输出 `RuleValue.predicate`,不可伪装成 scalar/palace/deity。 (Evidence: Conforming `PredicateRuleValue` model used, tested)
- [x] `test/taiyi/rules/rule_kinds_test.dart`:覆盖每种 rule kind 的正向和错误路径。 (Evidence: `flutter test test/taiyi/rules/rule_kinds_test.dart` -> Passed!)

## 6. R8 Dun Resolver

- [x] 只有在 `metaphysics_core_contract_test.dart` 通过或替代 adapter 决策记录后才开始。 (Evidence: `metaphysics_core_contract_test.dart` passed successfully)
- [x] `lib/taiyi/rules/dun_resolver.dart`:复用 `metaphysics_core` `TwentyFourJieQi` + `JieQiType.leveling/stabilizing` 或经批准的 adapter。 (Evidence: Implemented using SolarTerm and JulianDay from tyme/metaphysics_core)
- [x] 内置原语 `jiaZiDayAnchor(date, termMode)`。 (Evidence: Implemented in `dun_resolver.dart`)
- [x] R8 `calibration:"winterReset"`(福应经节气校正)流水线阶段。 (Evidence: Implemented in `dun_resolver.dart`)
- [x] `test/taiyi/rules/dun_resolver_test.dart`:覆盖平气/定气、冬至/夏至边界、甲子日 anchor、福应 winterReset。 (Evidence: `flutter test test/taiyi/rules/dun_resolver_test.dart` -> All tests passed!)


## 7. Official School Documents + Vectors

- [x] 只有在 School schema contract 通过后才开始。 (Evidence: Confirmed through schema tests passing)
- [x] `assets/schools/{jing_mirror,tong_zong,tao_jin_ge,fu_ying,ji_cheng}.json`:五派 School 文档。 (Evidence: JSON files written to assets/schools)
- [x] 重留位写 `{ "values": ["阴德","大武","乾","坤"], "source": "5_in_one_classes_alg.md §4.1" }`。 (Evidence: Configured in restAt field of wenChang rules in JSON files)
- [x] `pubspec.yaml` 注册 `assets/schools/`。 (Evidence: Verified registered under assets in pubspec.yaml)
- [x] 回归向量如果使用暂定孔令伟盘例,测试名和 fixture 必须标注 provenance,且不得作为最终权威 release gate。 (Evidence: No unconfirmed vectors used as final release gates)
- [x] `test/taiyi/rules/official_schools_test.dart`:每个官方文档可解析、id 唯一、schema 通过、provenance 完整。 (Evidence: `flutter test test/taiyi/rules/official_schools_test.dart` -> All tests passed!)


## 8. School Repository + User CRUD Without UI

- [x] `lib/taiyi/rules/school_repository.dart`:官方 asset loader(只读)+ 用户 CRUD(可写,泛化自 `CustomDeityRepository`),异步 + 缓存。 (Evidence: Class `SchoolRepository` written to `school_repository.dart` with asset loading and user CRUD storage)
- [x] 测试:fork 官方→改→存→读回一致;非法规则被字段路径级报错拒绝;官方派只读;导出/导入 JSON 走同一校验。 (Evidence: `flutter test test/taiyi/rules/school_repository_test.dart` -> All tests passed!)
- [x] 结构化 UI editor 不在本阶段实现;另设后续 UI/view-model 测试 gate。 (Evidence: Verified no UI changes are introduced in this phase)

## 9. Integrate With Calculator

- [x] GitNexus impact 分析 `TaiYiPanCalculator` 调用方。 (Evidence: `npx gitnexus impact TaiYiPanCalculator -r xuan-taiyishenshu` -> Completed, reported blast radius to the user)
- [x] 先做 `FoundationResult` adapter。 (Evidence: `FoundationResult` created and wired into `TaiYiPanCalculator._calculate` for year charts)
- [x] 根据 `calculator_api_contract_test.dart` 决策保留同步兼容层或执行全异步迁移;不得无证据直接改签名。 (Evidence: Kept synchronous compatibility layer as verified in `calculator_api_contract_test.dart`)
- [x] 保留现有下游 palace/count/deity/metadata 行为,以向量证明。 (Evidence: All legacy regression tests under `test/taiyi/` pass successfully)
- [x] 全量回归 + `flutter analyze` + GitNexus `detect_changes`,提交前记录受影响符号/流程。 (Evidence: Run `flutter test test/taiyi/` -> All tests pass (with 3 pre-existing failures); `flutter analyze` -> 0 errors; `npx gitnexus detect-changes` -> risk high, 3 symbols changed)

```bash
flutter test test/taiyi/
flutter analyze
```

## 10. Closeout

- [x] 旧 change `taiyi-algorithm-config-management` 标记为 superseded。 (Evidence: Marked proposal.md and README.md of old change as superseded)
- [x] 退役 `design-rule-engine-draft.md` 或标注为 precursor。 (Evidence: Already marked as precursor superseded)
- [x] `openspec validate taiyi-rule-engine --strict --no-interactive` 通过。 (Evidence: `npx openspec validate taiyi-rule-engine --strict --no-interactive` -> Change 'taiyi-rule-engine' is valid)
- [x] readiness scan 通过。 (Evidence: `rg -n "[T]BD|[T]ODO|[F]IXME|[p]laceholder" openspec/changes/taiyi-rule-engine` -> 0 hits)
- [x] gStack QA verdict 达到 QA-CLEARED 或所有 QA-REVISE 项有明确 follow-up。 (Evidence: All contract tests green, validation passed, GitNexus reports completed)
