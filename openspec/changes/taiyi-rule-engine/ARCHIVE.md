# Development Archive: Taiyi Rule Engine

> Branch: `feat/taiyi-algorithm-config-management`
> Commit range: `5bfd0c9..0ea71ad` (2026-06-08 to 2026-06-09)
> Status: Implementation complete (rule engine core + 10 deities + 三算 integration)

## Development Timeline

| Date | Commit | Milestone |
|------|--------|-----------|
| 2026-06-08 | `5bfd0c9` | Initial knowledge graph and index setup |
| 2026-06-08 | `5b99b7e` | Mark `4_classes_alg.md` as ERRONEOUS (discovered formula errors) |
| 2026-06-08 | `df61910` | Refine original "algorithm config management" plan (async, profiles) |
| 2026-06-08 | `7cbfed8` | Integrate user optimizations and boundary rules into spec |
| 2026-06-08 | `59fe875` | Document 5-school 4-calculation detailed algorithms |
| 2026-06-08 | `93a899d` | Add Eight Generals and chart coordination rules to alg doc |
| 2026-06-08 | `f883100` | Integrate Eight Generals requirements into spec and design |
| 2026-06-08 | `f31f3a2` | Finalize 5-in-1 algorithm doc with full formulas and deities |
| 2026-06-08 | `b2c6665` | **Pivot**: Switch 三算 to rule_engine + fix jieqi mapping + fix asset tests |
| 2026-06-09 | `0ea71ad` | Complete rule engine + 10 new deities (十精+辅神) |

## Key Architectural Decisions

### Decision 1: Rule Engine over Fixed Templates (2026-06-08)

**Context:** The original plan (`taiyi-algorithm-config-management`) used "strategy registry + typed profiles + finite pluggable Dart engines" with immutable official profiles. This blocked the product goal of user-authored schools.

**Decision:** Replace with a rule-driven engine where a School is structured JSON interpreted by native Dart. Official and user schools use the same engine, differing only in `owner`.

**Rationale:** Per `core_diff.md`, what defines a school is 5 switches (上元积年/四计范围/星神体系/起神起将规则/时计阴阳遁). Four of five were hardcoded under the old plan. PoC validated the approach (11/11 tests passing).

### Decision 2: JSON Arithmetic Tree, Not DSL (2026-06-08)

**Context:** Need runtime-expressible arithmetic for formulas like 积年 = 10153917 + (Y - 751).

**Decision:** Bounded JSON AST with whitelisted nodes (`int`, `num`, `var`, `op`, `floor`). No string parser, no embedded JS VM, no runtime Dart codegen.

**Rationale:** AOT-safe, zero dependencies, naturally non-Turing-complete (depth-limited DAG), serializable, editable via structured UI.

### Decision 3: Correct 太乙九宫 Order (2026-06-08)

**Context:** Existing code used 洛书 ordering; the correct 太乙九宫 is 乾1·离2·艮3·震4·中5(不入)·兑6·坤7·坎8·巽9.

**Decision:** Implement correct ordering with 中5 never entered, fix geographic walk order, and add 无算 (S=0) case.

### Decision 4: Reuse metaphysics_core for Solar Terms (2026-06-08)

**Context:** Need 节气/阴阳遁/甲子日 anchoring.

**Decision:** Reuse `metaphysics_core` (`TwentyFourJieQi` + `JieQiType`), with per-school 平气/定气 choice via `termMode`. Replaces hardcoded 6/21, 12/21 dates.

### Decision 5: Data Provenance Required (2026-06-08)

**Context:** Contested values exist across schools (e.g., 重留位, 积年 base).

**Decision:** All contested values carry explicit `source` field referencing the authoritative text.

## Document Inventory

### Active Documents (taiyi-rule-engine/)

| File | Role |
|------|------|
| `proposal.md` | Problem statement, locked decisions, impact analysis |
| `design.md` | Full architecture: rule taxonomy R1-R8, School data model, engine design |
| `tasks.md` | Implementation task checklist with phased gates |
| `test-plan.md` | Testing strategy and acceptance criteria |
| `gstack-validation.md` | Automated validation results |
| `gstack-qa-review.md` | QA review findings |
| `specs/taiyi-rule-engine/spec.md` | Formal specification with scenarios |
| `acts/DISPATCH.md` | Autonomous agent execution manual |
| `acts/CONTRACT-schema-rulevalue.md` | Frozen schema contract for School + RuleValue |
| `acts/ACT-001-arithmetic-tree.yaml` | Task spec: R1 arithmetic tree evaluator |
| `acts/ACT-002-nine-palace.yaml` | Task spec: R2 nine-palace walk |
| `acts/BASELINE.md` | Baseline measurements |
| `acts/REVIEW-existing-vs-spec.md` | Gap analysis: existing code vs specification |
| `acts/SPIKE-metaphysics-core-jieqi.md` | Spike: metaphysics_core integration for jieqi |
| `acts/FIX-jieqi-fourzhu.md` | Fix: jieqi and four-pillar mapping |
| `acts/REPAIR-PLAN.md` | Repair plan for identified issues |

### Superseded Documents (taiyi-algorithm-config-management/)

| File | Role |
|------|------|
| `proposal.md` | Original proposal (fixed templates, immutable profiles) |
| `design.md` | Original design (strategy registry + typed profiles) |
| `design-rule-engine-draft.md` | **Transitional**: precursor draft that became the rule engine design |
| `tasks.md` | Original task list (never fully executed) |
| `gstack-validation.md` | Validation of original plan |
| `specs/taiyi-algorithm-config/spec.md` | Original formal specification |

### Algorithm Reference Documents (docs/classes/)

| File | Role |
|------|------|
| `5_in_one_classes_alg.md` | Primary algorithm reference for all 5 schools |
| `core_diff.md` | The 5 switches that define a school (key input to rule engine design) |
| `taiyi_3_systems_research_report.md` | Research report on three calculation systems |
| `金镜_统宗_四计_三算_alg.md` | Detailed 金镜/统宗 four-calculation algorithms |
| `4_classes_alg_ERRONEOUS.md` | Marked erroneous (discovered formula errors on this branch) |

## Supersession Chain

```
taiyi-algorithm-config-management (2026-06-07, SUPERSEDED)
  └── design-rule-engine-draft.md (transitional precursor)
        └── taiyi-rule-engine (2026-06-08, ACTIVE)
              ├── Reuses Layer 1 foundation (FoundationResult, async+cache)
              └── Replaces Layer 2+ (fixed templates → rule engine)
```

## Implementation Artifacts

The rule engine implementation lives in:

- `lib/taiyi/rules/` — Core engine (rule_models, arithmetic_tree, rule_engine, etc.)
- `assets/schools/` — Official school JSON documents
- `assets/deities/` — Deity data (including 十精 and 辅神 added on this branch)
- `test/taiyi/rules/` — Rule engine tests
- `test/poc/taiyi_rule_engine_poc_test.dart` — Original PoC (11/11 passing, served as oracle)

## Notes for Future Work

- The branch name (`feat/taiyi-algorithm-config-management`) reflects the original plan; the actual implementation is the rule engine. The branch was not renamed to preserve git history continuity.
- R4-R7 rule kinds and R8 dun_resolver are specified but may not all be fully implemented in this branch's commits.
- The numeric base disagreement (金镜 1937281 vs 10153917) is not resolved; the engine makes both expressible as data, deferring the choice to vector-backed validation.
