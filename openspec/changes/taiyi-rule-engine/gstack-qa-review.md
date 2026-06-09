# gStack QA / Engineering Review: Taiyi Rule Engine

## Review Scope

Reviewed files:

- `openspec/changes/taiyi-rule-engine/proposal.md`
- `openspec/changes/taiyi-rule-engine/design.md`
- `openspec/changes/taiyi-rule-engine/tasks.md`
- `openspec/changes/taiyi-rule-engine/specs/taiyi-rule-engine/spec.md`
- `openspec/changes/taiyi-rule-engine/test-plan.md`
- `test/poc/taiyi_rule_engine_poc_test.dart`

## Local Evidence

Commands run:

```bash
openspec validate taiyi-rule-engine --strict --no-interactive
rg -n "[T]BD|[T]ODO|[F]IXME|[p]laceholder|[i]mplement later|[f]ill in|[s]kip:|@[S]kip|[F]akeRepository|[F]akeViewModel|[f]akeAsync" openspec/changes/taiyi-rule-engine
flutter test test/poc/taiyi_rule_engine_poc_test.dart
```

Results:

- OpenSpec strict validation: PASS.
- Readiness scan: PASS, no matches.
- PoC test: PASS, 11/11.

## Role Verdicts

### gStack QA Reviewer

Verdict before remediation: **QA-REVISE**.

Rationale:

- Overall direction is feasible.
- PoC proves part of R1/R3, but test plan needed hard pre-coding gates for dependencies that can cause late-stage restart.
- Highest risks were R8 dependency, calculator API migration, insufficient schema contract, and legacy string execution path.

### gStack Engineering Plan Reviewer

Verdict before remediation: **ENG-REVISE**.

Rationale:

- Architecture is implementable.
- School JSON contract was too loose for official assets, repository, editor, and calculator integration.
- Tasks had sequencing risks: official assets before schema, DAG checks in wrong phase, UI editor too early, async migration too broad.

## Required Remediations Applied

- Added School v1 schema contract to `design.md`.
- Added typed `RuleValue` model to `design.md`.
- Standardized contested provenance shape as `{ "values": [...], "source": "..." }`.
- Added R8 `metaphysics_core` contract spike gate before `dun_resolver.dart`.
- Added calculator API contract gate before changing `TaiYiPanCalculator.calculate*`.
- Added no-runtime-execution gate for legacy string formula paths.
- Reordered `tasks.md` so schema validation precedes official assets.
- Moved DAG validation to School document phase.
- Split UI editor out of v1 implementation; v1 keeps repository/import/export.
- Added `BLOCKED_UNTIL` pre-coding gates to `test-plan.md`.
- Added OpenSpec requirements for RuleValue typing, R8 dependency proof, schema freeze, calculator API migration, and runtime-expression rejection.

## Current Gate Status

Current verdict after documentation remediation: **QA-REVISE, cleared to start contract-test implementation only**.

Implementation is not cleared for full production work until these tests exist and run red first:

- `test/taiyi/rules/metaphysics_core_contract_test.dart`
- `test/taiyi/rules/school_schema_contract_test.dart`
- `test/taiyi/rules/no_runtime_execution_test.dart`
- `test/taiyi/rules/calculator_api_contract_test.dart`

## Early Development Stop Rules

Stop implementation and return for review if any of these occur:

- `metaphysics_core` cannot supply required solar-term data and no adapter decision is documented.
- Official school JSON is written before schema contract tests pass.
- `TaiYiPanCalculator.calculate*` signatures are changed before calculator API contract is approved.
- School import accepts legacy string formula execution.
- User CRUD or official assets bypass School document validation.
- Temporarily sourced vectors are promoted to final correctness gates without source confirmation.

## Next Verifier Action

The next QA verifier should ask the implementation worker for:

1. Red-test output for the four contract tests above.
2. Green-test output after contract implementation.
3. Updated OpenSpec validation output.
4. GitNexus impact reports before touching calculator or repository symbols.
