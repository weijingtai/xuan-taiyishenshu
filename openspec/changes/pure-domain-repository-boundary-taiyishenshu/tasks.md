## 1. Safety And Baseline

- [ ] 1.1 Confirm the branch is `storage-refactor/taiyishenshu` and record `git status --short` before any implementation edits.
- [ ] 1.2 Identify unrelated dirty files and exclude them from edits, staging, and review evidence.
- [ ] 1.3 Refresh GitNexus if stale and run required impact analysis before editing production symbols.
- [ ] 1.4 Capture baseline import/dependency scans for `lib/taiyi/**` and `pubspec.yaml`.

## 2. Product Port Purification

- [ ] 2.1 Define product-owned repository ports for school, user school, deity, and deity preference access without contract imports.
- [ ] 2.2 Remove contract DTO exports from product repository core files.
- [ ] 2.3 Remove product/contract mapper extensions from product `lib/taiyi/**`.
- [ ] 2.4 Verify usecases and viewmodels still depend only on product/domain ports.

## 3. Assembly Boundary Migration

- [ ] 3.1 Change `TaiYiDataAssembly` constructor and exposed repository fields to product port types.
- [ ] 3.2 Remove private contract adapters from product assembly.
- [ ] 3.3 Keep product-only multi-repository aggregation behavior for calculation/load flows.
- [ ] 3.4 Update assembly injection tests to assert product-port behavior instead of contract concrete type exposure.

## 4. Host And Test Adapter Relocation

- [ ] 4.1 Move contract DTO mapping into host/test adapter helpers outside product `lib/taiyi/**`.
- [ ] 4.2 Wrap `OfficialJsonSchoolRepository`, `DriftUserRepository`, and `SharedPreferencesDeityPreferenceRepository` into product ports before constructing `TaiYiDataAssembly`.
- [ ] 4.3 Update `example/lib/taiyi_host.dart` to remain the backend construction boundary.
- [ ] 4.4 Update test harnesses and integration tests that currently use `.toContract()` or contract-typed assembly fields.

## 5. Dependency Cleanup

- [ ] 5.1 Remove `repository_interface_taiyishenshu` from runtime `dependencies` if product compilation no longer needs it.
- [ ] 5.2 Keep any remaining contract dependency in dev/test or host-only scope with documented rationale.
- [ ] 5.3 Verify persistence packages remain outside product runtime imports.

## 6. Validation Gates

- [ ] 6.1 Run static import boundary scan over `lib/taiyi/**` and confirm no contract/persistence/shared-preferences/drift imports.
- [ ] 6.2 Run `flutter analyze` and record result.
- [ ] 6.3 Run focused usecase, viewmodel, repository boundary, assembly, and integration tests.
- [ ] 6.4 Run GitNexus detect changes before commit/review to confirm affected scope matches this OpenSpec.
- [ ] 6.5 Complete the gStack architecture verification checklist in `gstack-validation.md`.
- [ ] 6.6 Complete the gStack QA verification checklist in `gstack-validation.md`.

## 7. Review And Rollback Readiness

- [ ] 7.1 Confirm no implementation changed `lib/taiyi/taiyi_pan_calculator.dart` as part of this boundary task.
- [ ] 7.2 Confirm no algorithm management/configuration work was mixed into this change.
- [ ] 7.3 Prepare rollback notes limited to files touched by the implementation.
- [ ] 7.4 Leave this OpenSpec change unarchived until implementation, tests, review, and delivery evidence pass.
