# Proposal: Taiyi Rule Engine

## Why

The product goal is that **users can autonomously create, edit, save, and manage their own Taiyi schools (流派)** — including each school's star-deities (星神) and key algorithm parameters.

The existing change `taiyi-algorithm-config-management` is built on four principles that directly block this goal: official profiles are *immutable* assets, user metadata may only *select* a profile, formulas must be *finite hardcoded templates*, and *no expressions / runtime execution* are allowed. Under those principles a user can only tweak an accumulated-year constant — not author a school.

Per `docs/classes/core_diff.md`, what actually *defines* a school is five switches: 上元积年 / 四计范围 / 星神体系 / 起神起将规则 / 时计阴阳遁. Four of those five are exactly the parts the old plan leaves hardcoded.

A rule-driven alternative was validated by PoC (`test/poc/taiyi_rule_engine_poc_test.dart`, 11/11 passing): a school is **structured JSON rule data interpreted by native Dart**, with arithmetic expressed as a **bounded JSON tree** (no DSL parser, no embedded JS VM, AOT-safe).

## What Changes

- Introduce a **rule taxonomy** (R1–R7) plus a dun/solar-term context module (R8) that expresses the full five-school feature set from `docs/classes/5_in_one_classes_alg.md`.
- A **School** is a single structured document interpreted by a native Dart engine. **Official and user schools use the same engine**; they differ only in `owner` (write permission / bundling).
- Arithmetic leaves SHALL be a **JSON arithmetic tree (AST)** with a whitelisted node set — NOT a string DSL, NOT JavaScript.
- **Users SHALL be able to author schools via full CRUD** (from scratch, or fork an official school), through a structured editor; official schools remain read-only bundled assets.
- The three-calculation (主/客/定算) SHALL use the correct **太乙九宫** order, **满十去十 (10 归 9)**, and **无算 (S=0)** rules — fixing two defects found in current code (geographic walk order; missing 无算).
- Solar terms / 阴阳遁 / 甲子日 anchoring SHALL reuse **`metaphysics_core`** (`TwentyFourJieQi` + `JieQiType.leveling/stabilizing`), with a per-school 平气/定气 (`termMode`) choice — replacing the hardcoded 6/21, 12/21 dates.
- Contested provenance values (e.g. 重留位) SHALL carry an explicit `source` field.

## Locked Decisions (2026-06-08)

- Arithmetic leaves → **JSON arithmetic tree** (no string parser; not dart2JS — that is a web build-time compiler, irrelevant to runtime authoring; not an embedded JS engine).
- 天目 重留位 → **`5_in_one_classes_alg.md §4.1`** (阴德/大武/乾/坤), annotated with `source`.
- 节气/阴阳遁/甲子日 anchor → reuse **`metaphysics_core`**, per-school 平气/定气.
- Official regression vectors → **tentatively 孔令伟** until an authoritative source is confirmed.

## Impact

Planned implementation files:

- `lib/taiyi/rules/rule_models.dart` (R1–R7 typed models)
- `lib/taiyi/rules/arithmetic_tree.dart` (JSON-AST evaluator)
- `lib/taiyi/rules/rule_engine.dart` (interpreter)
- `lib/taiyi/rules/dun_resolver.dart` (R8, `metaphysics_core` solar terms)
- `lib/taiyi/rules/school_document.dart` (School schema + validation)
- `lib/taiyi/rules/school_repository.dart` (official asset loader + user CRUD)
- `assets/schools/*.json` (5 official school documents)
- `test/taiyi/rules/**` (rule, engine, school, vector tests)

Integration:

- `lib/taiyi/taiyi_pan_calculator.dart` (consume engine via `FoundationResult`)
- `pubspec.yaml` (assets)

Reuse / generalize:

- `DeityAlgorithmEngine` templates → R1/R2/R5/R6.
- `CustomDeityRepository` → `SchoolRepository`.
- `FoundationResult` (from the old change) → kept as the foundation bridge.

## Non-Goals

- No general-purpose DSL language, scripting engine, embedded JS VM, or runtime Dart codegen.
- v1 does not require every 神煞 of all five schools; rule kinds land in phases.
- Does not change the authoritative numeric base disagreement (金镜 1937281 vs 10153917); the engine makes both expressible as data, and the choice is a separate vector-backed decision.
