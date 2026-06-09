# Test Plan: Taiyi Rule Engine

## Scope

This test plan validates the `taiyi-rule-engine` change as a rule-driven Taiyi school engine.

Primary risks:

- JSON arithmetic trees must be safe, bounded, and deterministic.
- Official and user schools must use the same native Dart interpreter.
- Three-calculation rules must use the Taiyi nine-palace order, no center palace, no-count, and the documented normalization rule.
- Solar-term and dun resolution must come from `metaphysics_core`, not fixed calendar dates.
- User-authored school CRUD must validate rule documents before saving.
- Calculator integration must preserve existing public behavior where compatibility is required.

## Test Layers

| Layer | Target | Test Files |
| --- | --- | --- |
| PoC baseline | Existing proof stays green until production tests replace it | `test/poc/taiyi_rule_engine_poc_test.dart` |
| R1 AST | JSON arithmetic tree evaluator and validator | `test/taiyi/rules/arithmetic_tree_test.dart` |
| R2-R3 core | Palace walking and three-calculation engine | `test/taiyi/rules/rule_engine_test.dart` |
| R4-R7 rules | Derived generals, relative rules, tables, predicates | `test/taiyi/rules/rule_kinds_test.dart` |
| R8 context | Dun, solar terms, Jia Zi anchor, calibration | `test/taiyi/rules/dun_resolver_test.dart` |
| School schema | Rule document validation, DAG, provenance | `test/taiyi/rules/school_document_test.dart` |
| Repository/CRUD | Official read-only assets and user schools | `test/taiyi/rules/school_repository_test.dart` |
| Official assets | Five bundled school documents parse and validate | `test/taiyi/rules/official_schools_test.dart` |
| Calculator integration | `TaiYiPanCalculator` consumes rule engine safely | `test/taiyi/rules/calculator_rule_engine_integration_test.dart` |
| Regression | Existing product behavior remains covered | existing `test/taiyi/*metadata*`, smoke tests |

## Pre-Coding Gates

These gates are `BLOCKED_UNTIL` checks. Production implementation must not start in the dependent area until the gate passes or an explicit alternative decision is recorded in the change docs.

| Gate | Blocks | Required Test |
| --- | --- | --- |
| Gate A: Schema Contract Freeze | official assets, repository, editor, import/export | `test/taiyi/rules/school_schema_contract_test.dart` |
| Gate B: R8 Dependency Spike | `dun_resolver.dart`, official five-school assets | `test/taiyi/rules/metaphysics_core_contract_test.dart` |
| Gate C: Runtime Safety | any School JSON import path | `test/taiyi/rules/no_runtime_execution_test.dart` |
| Gate D: Calculator API Decision | calculator integration and call-site changes | `test/taiyi/rules/calculator_api_contract_test.dart` |
| Gate E: PoC Preservation | production R1-R3 migration | `test/poc/taiyi_rule_engine_poc_test.dart` |

Gate B must verify the real `metaphysics_core` API can provide winter/summer solstice boundaries, distinguish 平气 and 定气, and support or be adapted for post-solstice Jia Zi day anchoring. If it cannot, record an adapter/stub decision before writing R8 production code.

Gate D must choose exactly one calculator strategy:

- keep synchronous public methods and add an internal async/cache adapter, or
- intentionally migrate `calculate*` to `Future<PanDataModel>` with call-site migration evidence.

## BDD Scenarios

### Rule Documents

#### Scenario: Same engine, different accumulated-year tree
- Given two official school documents differ only in the accumulated-year JSON tree
- When the same rule engine calculates the same year chart
- Then the two charts use different accumulated years
- And no executable Dart code changes are required

#### Scenario: No runtime code execution
- Given a school document contains only supported JSON fields
- When it is loaded
- Then the engine interprets it as data
- And no string expression parser, script runtime, JS engine, or runtime Dart code generation is invoked

### R1 Arithmetic Tree

#### Scenario: Whitelisted arithmetic evaluates
- Given an AST for `floor(J * 365.2425) + D`
- When `J=10` and `D=3`
- Then evaluation returns `3655`

#### Scenario: Division is rejected
- Given an AST node with operator `/`
- When validation runs
- Then validation fails with school id and field path

#### Scenario: Unknown variable is rejected
- Given an AST references `Z`
- When `Z` is not declared by context or prior rules
- Then evaluation fails with an explicit field-path error

#### Scenario: Depth is bounded
- Given an AST deeper than the configured maximum depth
- When validation runs
- Then validation rejects the AST before evaluation

#### Scenario: Invalid numeric import is rejected
- Given an imported school JSON contains a numeric value that cannot be represented by valid JSON
- When import validation runs
- Then import fails before a School document is persisted

### R2 Palace Walk

#### Scenario: Rest-at positions carry provenance
- Given a palace-walk rule has 重留 positions
- When the school document is validated
- Then the rule contains `restAt.values`
- And `restAt.source` equals `"5_in_one_classes_alg.md §4.1"` or another explicit source

#### Scenario: Unknown palace system is rejected
- Given a palace-walk rule references an unsupported palace system
- When validation runs
- Then validation fails with school id and field path

#### Scenario: Chart range is data
- Given a school only supports year charts
- When month/day/hour chart rules are disabled
- Then disabled charts are represented by `enabled: false` or `appliesTo`
- And no school-specific code branch is needed

### R3 Three Calculation

#### Scenario: Taiyi nine-palace order is used
- Given host count starts at `乾`
- And Taiyi is at `震`
- When the engine walks to Taiyi previous palace
- Then it accumulates `乾(1)+离(2)=3`
- And it does not use geographic sixteen-god order

#### Scenario: Middle palace is excluded
- Given a walk crosses the abstract fifth position
- When the engine traverses palaces
- Then `中` is never included in the sequence or sum

#### Scenario: No-count returns zero
- Given the start palace equals the Taiyi palace
- When the count is calculated
- Then the result is `0`
- And the detail marks it as `无算`

#### Scenario: One-step no-count returns zero
- Given the start palace is immediately before Taiyi in Taiyi palace order
- When the count is calculated
- Then the result is `0`

#### Scenario: Ten normalizes according to rule-engine decision
- Given the accumulated sum normalizes to ten
- When R3 formats the result
- Then the result is `9`
- And the test name records that this follows `taiyi-rule-engine` locked decision `10归9`

### R4-R7 Extended Rules

#### Scenario: Major general derives from count
- Given a count resolves to `10`
- When R4 maps it to a palace
- Then it follows the configured `10→9宫` mapping

#### Scenario: Relative opposition derives Shi Ji
- Given a base eye palace
- When an R5 opposition rule is evaluated
- Then the result is the configured opposing palace

#### Scenario: Table sequence is deterministic
- Given an R6 table and an index tree
- When variables are identical across two runs
- Then the same palace is returned

#### Scenario: Predicate identifies co-location
- Given an R7 predicate for co-located deities
- When both referenced outputs share a palace
- Then the predicate returns a `RuleValue.predicate`
- And the value contains `matched: true` with the configured geju name

### R8 Dun And Solar Terms

#### Scenario: Dun uses metaphysics_core
- Given an hour chart near winter or summer solstice
- When dun type is resolved
- Then `metaphysics_core` solar term data is used
- And fixed June 21 / December 21 dates are not used as final truth

#### Scenario: Mean and apparent term modes differ by configuration
- Given two schools differ only by `termMode`
- When a boundary chart is calculated
- Then the resolver uses `JieQiType.leveling` for 平气
- And `JieQiType.stabilizing` for 定气

#### Scenario: Jia Zi day anchor is built in
- Given a Tong Zong day chart
- When the engine finds the post-solstice Jia Zi anchor
- Then the anchor comes from the built-in primitive
- And user JSON cannot replace it with executable code

#### Scenario: Fu Ying winter reset calibration is selected by data
- Given a Fu Ying school document declares `calibration: "winterReset"`
- When the R8 pipeline runs
- Then the correction is applied as a named engine primitive
- And the result records calibration provenance

### School Document Validation

#### Scenario: School schema contract is frozen
- Given the minimal valid School v1 fixture
- When validation runs
- Then it accepts known rule discriminators
- And it rejects unknown `kind`, duplicate ids, invalid refs, wrong output type, missing fields, and schema version omissions
- And every failure includes `schoolId` and `fieldPath`

#### Scenario: Rule graph is acyclic
- Given rule A references rule B
- And rule B references rule A
- When validation runs
- Then the document is rejected with a field-path error

#### Scenario: Required fields are enforced
- Given an R3 rule is missing `startRef`
- When validation runs
- Then save fails with school id and field path

#### Scenario: User deity is data-only
- Given a user adds a star-deity
- When the school is saved
- Then the deity appears in `deities[]`
- And its rule kind is known
- And no code deployment is required

#### Scenario: Runtime expression strings are rejected
- Given an imported School document contains a string formula or legacy custom-formula template
- When validation runs
- Then validation rejects the document
- And the import path never calls `ExpressionParser` or `_executeCustomFormula`

### Repository And CRUD

#### Scenario: Official schools are read-only
- Given an official school asset is loaded
- When a caller attempts to save changes to the official record
- Then the repository rejects the write

#### Scenario: User forks official school
- Given a user forks `jingMirror`
- When they edit a deity rule and save
- Then the user school reads back identically
- And the official asset remains unchanged

#### Scenario: Invalid import is rejected
- Given a user imports a malformed school JSON document
- When repository validation runs
- Then the import fails
- And no partial school is persisted

### Official Schools And Vectors

#### Scenario: Five official documents parse
- Given assets for `jing_mirror`, `tong_zong`, `tao_jin_ge`, `fu_ying`, and `ji_cheng`
- When official asset tests run
- Then all ids are unique
- And all documents pass schema validation

#### Scenario: Contested vector provenance is visible
- Given an official regression vector is based on tentative 孔令伟 examples
- When the test runs
- Then the test name or fixture includes provenance
- And no vector is presented as final authoritative unless confirmed

#### Scenario: Existing Jing Mirror year vectors stay covered
- Given existing vectors for 1949, 2026, and 2027
- When the rule engine is integrated
- Then the compatible profile reproduces the expected current outputs

### Calculator Integration

#### Scenario: Calculator can consume rule engine
- Given a valid official school document
- When `TaiYiPanCalculator` calculates a supported chart
- Then it consumes rule-engine foundation outputs through `FoundationResult`
- And downstream pan assembly remains compatible

#### Scenario: Async migration is explicit
- Given the implementation changes `calculate*` to return `Future<PanDataModel>`
- When integration tests are updated
- Then all call sites are updated deliberately
- And pre-change synchronous tests are either migrated or kept behind a compatibility adapter

#### Scenario: Synchronous compatibility is preserved
- Given the implementation chooses a synchronous compatibility adapter
- When existing smoke tests call `TaiYiPanCalculator.calculate`
- Then those call sites continue to compile without adding `await`

## Test Commands

### OpenSpec And Readiness

```bash
openspec validate taiyi-rule-engine --strict --no-interactive
rg -n "[T]BD|[T]ODO|[F]IXME|[p]laceholder|[i]mplement later|[f]ill in|[s]kip:|@[S]kip|[F]akeRepository|[F]akeViewModel|[f]akeAsync" openspec/changes/taiyi-rule-engine
```

### PoC Baseline

```bash
flutter test test/poc/taiyi_rule_engine_poc_test.dart
```

### Rule Engine Unit Suite

```bash
flutter test test/taiyi/rules/arithmetic_tree_test.dart
flutter test test/taiyi/rules/rule_engine_test.dart
flutter test test/taiyi/rules/rule_kinds_test.dart
flutter test test/taiyi/rules/dun_resolver_test.dart
flutter test test/taiyi/rules/school_document_test.dart
flutter test test/taiyi/rules/school_repository_test.dart
flutter test test/taiyi/rules/official_schools_test.dart
flutter test test/taiyi/rules/metaphysics_core_contract_test.dart
flutter test test/taiyi/rules/school_schema_contract_test.dart
flutter test test/taiyi/rules/no_runtime_execution_test.dart
flutter test test/taiyi/rules/calculator_api_contract_test.dart
```

### Integration And Regression

```bash
flutter test test/taiyi/rules/calculator_rule_engine_integration_test.dart
flutter test test/taiyi/jing_mirror_year_standard_vectors_test.dart
flutter test test/taiyi_pan_calculator_smoke.dart
flutter test test/taiyi/full_metadata_regression_test.dart
flutter analyze
```

### Full Rule Package Gate

```bash
flutter test test/taiyi/rules/
```

## Evidence Required

- OpenSpec validation output.
- Readiness scan output.
- PoC output before production migration.
- Unit suite output for R1-R8.
- Official school asset parsing output.
- CRUD/repository output.
- Calculator integration output.
- Existing regression output.
- `flutter analyze` output.
- GitNexus `detect_changes` summary before commit.

## Residual Risk

- The `10归9` decision differs from some earlier notes that preserve `10`; tests must name the decision and cite this change.
- Official vector source is tentative for 孔令伟 examples; tests must label provenance.
- `metaphysics_core` availability is now a pre-coding gate; if it fails, R8 must use an adapter decision rather than direct implementation.
- Async calculator migration is broad; the calculator API contract gate must choose compatibility adapter or full migration before integration.
- User-facing structured editor tests are intentionally deferred; v1 must close repository/import/export first, then add widget or view-model tests once the editor design exists.
