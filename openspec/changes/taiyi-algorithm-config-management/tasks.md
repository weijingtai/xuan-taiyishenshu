# Tasks: Taiyi Algorithm Configuration Management

## 1. Safety And Baseline

- [ ] Confirm the worker is on `feat/taiyi-algorithm-config-management` or another non-main feature branch with `git branch --show-current`.
- [ ] Run `git status --short` and record unrelated dirty files before editing.
- [ ] Read `docs/classes/金镜_统宗_四计_三算_alg.md`.
- [ ] Read `docs/classes/4_classes_explain.md` and `docs/classes/4_classes_alg.md` for Fu Ying Jing and Tao Jin Ge boundaries.
- [ ] Run GitNexus impact analysis before editing `TaiYiPanCalculator`, `TaiYiSchool`, or any existing calculator helper symbol.
- [ ] Run the current focused regression set and record failures before implementation:

```bash
flutter test test/taiyi/jing_mirror_year_standard_vectors_test.dart test/taiyi/full_metadata_regression_test.dart test/taiyi_pan_calculator_smoke.dart
```

## 2. Profile Model And Four Official Profiles

- [ ] Create `lib/taiyi/core/algorithm_platform/taiyi_algorithm_tradition.dart`.
- [ ] Create `lib/taiyi/core/algorithm_platform/algorithm_profile.dart`.
- [ ] Create `test/taiyi/algorithm_platform/algorithm_profile_test.dart`.
- [ ] Write failing tests that parse `jingMirror`, `fuYing`, `tongZong`, and `taoJinGe` profiles.
- [ ] Write failing tests that reject unsupported strategy ids with profile id and field path.
- [ ] Implement typed model classes without generated code unless generation is already required by surrounding code.
- [ ] Run:

```bash
flutter test test/taiyi/algorithm_platform/algorithm_profile_test.dart
```

Expected result:

```text
All profile model tests pass.
```

## 3. Official Tradition Assets And Synchronous Registry

- [ ] Create `assets/algorithms/traditions/jing-mirror.json`.
- [ ] Create `assets/algorithms/traditions/fu-ying.json`.
- [ ] Create `assets/algorithms/traditions/tong-zong.json`.
- [ ] Create `assets/algorithms/traditions/tao-jin-ge.json`.
- [ ] Register `assets/algorithms/traditions/` in `pubspec.yaml`.
- [ ] Create `lib/taiyi/core/algorithm_platform/algorithm_registry.dart`.
- [ ] Create `test/taiyi/algorithm_platform/algorithm_registry_test.dart`.
- [ ] Ensure built-in official profiles are resolvable synchronously by `schoolId`.
- [ ] Ensure `fuYing` and `taoJinGe` profiles expose `verificationStatus: needsAuthoritativeVectors`.
- [ ] Run:

```bash
flutter test test/taiyi/algorithm_platform/algorithm_registry_test.dart
```

Expected result:

```text
All registry tests pass.
```

## 4. Foundation Engine

- [ ] Create `lib/taiyi/core/algorithm_platform/algorithm_context.dart`.
- [ ] Create `lib/taiyi/core/algorithm_platform/foundation_engine.dart`.
- [ ] Create `test/taiyi/algorithm_platform/foundation_engine_test.dart`.
- [ ] Add Jing Mirror tests for the configured reference foundation formula.
- [ ] Add Tong Zong tests for the configured reference foundation formula.
- [ ] Add Tao Jin Ge rule test for near-era Jia Zi handling without claiming full numeric parity.
- [ ] Add Fu Ying Jing rule test that verifies the strategy can be selected and reports vector-gated status.
- [ ] Run:

```bash
flutter test test/taiyi/algorithm_platform/foundation_engine_test.dart
```

Expected result:

```text
All foundation tests pass.
```

## 5. Solar Term Provider

- [ ] Create `lib/taiyi/core/algorithm_platform/solar_term_provider.dart`.
- [ ] Create `test/taiyi/algorithm_platform/solar_term_provider_test.dart`.
- [ ] Implement `SolarTermProvider.resolveDunType(DateTime dateTime)`.
- [ ] Include result metadata that identifies whether the boundary is precise or fallback.
- [ ] Add tests around winter and summer solstice boundaries.
- [ ] Ensure final Tong Zong hour parity tests depend on precise boundary status, not fixed June/December dates.
- [ ] Run:

```bash
flutter test test/taiyi/algorithm_platform/solar_term_provider_test.dart
```

Expected result:

```text
All solar-term provider tests pass.
```

## 6. Chart Entry Engine

- [ ] Create `lib/taiyi/core/algorithm_platform/chart_entry_engine.dart`.
- [ ] Create `test/taiyi/algorithm_platform/chart_entry_engine_test.dart`.
- [ ] Implement Jing Mirror year/month/day shared entry strategy.
- [ ] Implement Jing Mirror hour entry strategy.
- [ ] Implement Tong Zong year/month/day/hour entry strategy ids.
- [ ] Implement Fu Ying Jing entry strategy ids with rule-level behavior only.
- [ ] Implement Tao Jin Ge mnemonic year/month/day/hour wheel strategy ids with rule-level behavior only.
- [ ] Run:

```bash
flutter test test/taiyi/algorithm_platform/chart_entry_engine_test.dart
```

Expected result:

```text
All chart entry tests pass.
```

## 7. Eye Engine

- [ ] Create `lib/taiyi/core/algorithm_platform/eye_engine.dart`.
- [ ] Create `test/taiyi/algorithm_platform/eye_engine_test.dart`.
- [ ] Implement Jing Mirror eye strategy for Tian Mu, Shi Ji, Ji Shen, and Ding Da Jiang where supported by existing vectors.
- [ ] Implement Tong Zong eye strategy for year/month/day/hour where supported by existing vectors.
- [ ] Implement Fu Ying Jing rule tests: yang starts Wu De, yin starts Lu Shen.
- [ ] Implement Tao Jin Ge rule tests for mnemonic/fixed eye policy without numeric parity claims.
- [ ] Run:

```bash
flutter test test/taiyi/algorithm_platform/eye_engine_test.dart
```

Expected result:

```text
All eye engine tests pass.
```

## 8. Three Count Engine

- [ ] Create `lib/taiyi/core/algorithm_platform/three_count_engine.dart`.
- [ ] Create `test/taiyi/algorithm_platform/three_count_engine_test.dart`.
- [ ] Implement shared eight-palace traversal `[乾, 离, 艮, 震, 兑, 坤, 坎, 巽]`.
- [ ] Implement palace base numbers `乾=1, 离=2, 艮=3, 震=4, 兑=6, 坤=7, 坎=8, 巽=9`.
- [ ] Implement full-ten rule `((sum - 1) % 10) + 1`.
- [ ] Implement no-count boundary result `0`.
- [ ] Implement Jing Mirror year/month/day/hour strategy ids.
- [ ] Implement Tong Zong year/month/day/hour strategy ids, including hour yang previous-palace and yin next-palace endpoint behavior.
- [ ] Implement Fu Ying Jing and Tao Jin Ge rule-only strategy ids.
- [ ] Add result metadata for whether `dingCount` is proven classical `定算`.
- [ ] Run:

```bash
flutter test test/taiyi/algorithm_platform/three_count_engine_test.dart
```

Expected result:

```text
All three-count tests pass.
```

## 9. Calculator Integration

- [ ] Run GitNexus impact analysis for `TaiYiPanCalculator`.
- [ ] Modify `lib/taiyi/core/school_config.dart` only after impact analysis for `TaiYiSchool`.
- [ ] Add optional `traditionId` and `algorithmProfileId` fields to `TaiYiSchool`, preserving existing JSON compatibility.
- [ ] Modify `lib/taiyi/taiyi_pan_calculator.dart` to obtain algorithm platform outputs through the registry.
- [ ] Preserve synchronous `calculate`, `calculateWithConfig`, and `calculateWithCustomDeities` return types in this change.
- [ ] Integrate foundation, chart entry, eye, and three-count outputs incrementally behind existing pan assembly.
- [ ] Keep existing compatibility behavior for `jiCheng`.
- [ ] Add `test/taiyi/algorithm_platform/calculator_integration_test.dart`.
- [ ] Verify Jing Mirror and Tong Zong supported vectors through the calculator.
- [ ] Verify Fu Ying Jing and Tao Jin Ge calculator paths return vector-gated metadata or warnings rather than invented values.
- [ ] Run:

```bash
flutter test test/taiyi/algorithm_platform/calculator_integration_test.dart
flutter test test/taiyi/jing_mirror_year_standard_vectors_test.dart
flutter test test/taiyi/full_metadata_regression_test.dart
```

Expected result:

```text
All integration and focused regression tests pass, or pre-existing failures are documented.
```

## 10. Discussion Gates For Fu Ying Jing And Tao Jin Ge

- [ ] If implementing numeric Fu Ying Jing outputs, stop and ask the user for authoritative year/month/day/hour vectors or exact source formulas.
- [ ] If implementing numeric Tao Jin Ge outputs, stop and ask the user to confirm the near-era Jia Zi anchor and at least one year/month/day/hour example.
- [ ] Record supplied vectors in `test/taiyi/test_vectors/` before turning rule-only tests into numeric assertions.
- [ ] Keep profiles as `needsAuthoritativeVectors` until numeric tests pass.

## 11. Validation And Closeout

- [ ] Run OpenSpec validation:

```bash
openspec validate taiyi-algorithm-config-management --strict --no-interactive
```

- [ ] Run readiness scan:

```bash
rg -n "[T]BD|[T]ODO|[F]IXME|[p]laceholder|[i]mplement later|[f]ill in|[s]kip:|@[S]kip|[F]akeRepository|[F]akeViewModel|[f]akeAsync" openspec/changes/taiyi-algorithm-config-management
```

- [ ] Run focused platform tests:

```bash
flutter test test/taiyi/algorithm_platform
```

- [ ] Run broader Taiyi tests:

```bash
flutter test test/taiyi/year_metadata_test.dart test/taiyi/month_metadata_test.dart test/taiyi/day_metadata_test.dart test/taiyi/hour_metadata_test.dart test/taiyi/full_metadata_regression_test.dart
```

- [ ] Run analyzer:

```bash
flutter analyze
```

- [ ] Run GitNexus detect changes:

```text
mcp__gitnexus.detect_changes({
  "repo": "xuan-taiyishenshu",
  "scope": "all"
})
```

- [ ] Record validation evidence before review or commit.
