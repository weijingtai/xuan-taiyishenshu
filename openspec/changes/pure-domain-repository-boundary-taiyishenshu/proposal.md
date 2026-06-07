## Why

The current TaiYiShenShu product layer is close to a pure domain package, but it still has a runtime dependency on `repository_interface_taiyishenshu` through repository DTO re-exports, contract mappers, and `TaiYiDataAssembly` constructor types. This blocks a clean domain boundary because product usecases and viewmodels depend on product ports while the product package itself still owns contract adaptation.

## What Changes

- **BREAKING**: remove `repository_interface_taiyishenshu` from the product package runtime dependency surface.
- Define all product-facing repository ports in the TaiYiShenShu domain/product layer, including deity preference state, without importing contract DTO packages.
- Move `TaiYiSchoolContract` / `DeityDefinitionContract` mapping and contract repository adapters out of product `lib/taiyi/**` and into host-side or dedicated adapter-side code.
- Change `TaiYiDataAssembly` to accept product/domain repository ports instead of contract-typed ports.
- Keep `example/lib/taiyi_host.dart` as the backend assembly boundary that creates `OfficialJsonSchoolRepository`, `DriftUserRepository`, and `SharedPreferencesDeityPreferenceRepository`, then adapts them before injecting product ports.
- Preserve existing school/deity load, copy, save, delete, preference toggle, and pan calculation behavior.
- Add static boundary checks so `lib/taiyi/**` cannot import `repository_interface_taiyishenshu`, `persistence_drift`, `persistence_preferences`, `persistence_assets`, `shared_preferences`, or `drift`.
- Mark algorithm management/configuration work as adjacent future scope, not part of this repository boundary change.

## Capabilities

### New Capabilities

- `domain-repository-boundary`: Product/domain repository boundary for TaiYiShenShu, covering pure product ports, contract adapter placement, dependency rules, migration gates, and behavior preservation.

### Modified Capabilities

- None. There are no existing OpenSpec capabilities in `openspec/specs/` for this repository.

## Impact

- Affected product files planned for implementation: `lib/taiyi/core/school_repository.dart`, `lib/taiyi/taiyi_assembly.dart`, `lib/taiyi/usecases/**`, and `lib/taiyi/viewmodels/**`.
- Affected host/test files planned for implementation: `example/lib/taiyi_host.dart`, `test/taiyi/test_harness.dart`, assembly tests, repository boundary tests, usecase tests, and integration tests that currently inspect contract-typed assembly fields or call `.toContract()`.
- Affected dependencies planned for implementation: `pubspec.yaml` runtime dependency and override entries for `repository_interface_taiyishenshu`; persistence dependencies remain dev/test or host-side only unless a separate host package is introduced.
- Non-impact: `lib/taiyi/taiyi_pan_calculator.dart` and algorithm configuration are out of scope for this change.
