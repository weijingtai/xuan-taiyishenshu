# Tasks: Taiyi Algorithm Configuration Management

## 1. Safety And Baseline

- [ ] Confirm the worker is not on `main` or `master` with `git branch --show-current`.
- [ ] Run `git status --short` and record unrelated dirty files before editing.
- [ ] Run GitNexus impact analysis before editing `TaiYiPanCalculator` or any existing symbol.
- [ ] Run the current focused regression set:

```bash
flutter test test/taiyi/jing_mirror_year_standard_vectors_test.dart test/taiyi_year_eye_rules_flutter_test.dart test/taiyi_pan_calculator_smoke.dart
```

Expected result:

```text
All tests pass, or every failure is recorded as pre-existing before implementation begins.
```

## 2. Freeze Foundation Vectors

- [ ] Create `test/taiyi/algorithm_config/foundation_algorithm_vectors_test.dart`.
- [ ] Add Jing Mirror year vectors for `1949-06-07 15:08`, `2026-06-07 15:08`, and `2027-06-07 15:08`.
- [ ] Add TongZong year/month/day/hour authoritative vectors from the current full metadata regression source.
- [ ] Add JiCheng year/month/day/hour baseline vectors from the current full metadata regression source and label their source provenance in test names.
- [ ] Assert only Layer 1 outputs in this test: accumulated sequence, ju number, wuzi yuan-ju, ji-yuan, yuan name, and ru-gong label.
- [ ] Run the new vector test and confirm it fails because the config engine does not exist yet:

```bash
flutter test test/taiyi/algorithm_config/foundation_algorithm_vectors_test.dart
```

## 3. Define Foundation Config Model

- [ ] Create `lib/taiyi/core/foundation_algorithm_config.dart`.
- [ ] Create `test/taiyi/core/foundation_algorithm_config_test.dart`.
- [ ] Add model tests for parsing the Jing Mirror JSON example from `design.md`.
- [ ] Add model tests that reject unknown template names with the profile id and field path in the error message.
- [ ] Implement immutable model classes:

```text
FoundationAlgorithmConfig
AccumulatedYearFormula
ChartSequenceFormula
CycleFormula
YuanFormula
RuGongFormula
```

- [ ] Run:

```bash
flutter test test/taiyi/core/foundation_algorithm_config_test.dart
```

Expected result:

```text
All model tests pass.
```

## 4. Build Foundation Engine

- [ ] Create `lib/taiyi/core/foundation_algorithm_engine.dart`.
- [ ] Create `test/taiyi/core/foundation_algorithm_engine_test.dart`.
- [ ] Implement `FoundationResult` as an immutable value object.
- [ ] Implement `FoundationAlgorithmEngine.calculate`.
- [ ] Cover these templates with unit tests:

```text
linearYear
accumulatedYear
tianZhengMonth
tropicalDay
dayTimesChineseHour
juModuloThree
```

- [ ] Run:

```bash
flutter test test/taiyi/core/foundation_algorithm_engine_test.dart
```

Expected result:

```text
All engine tests pass.
```

## 5. Add Official Foundation Assets

- [ ] Create `assets/algorithms/foundation/jing_mirror_foundation_v1.json`.
- [ ] Create `assets/algorithms/foundation/tong_zong_foundation_v1.json`.
- [ ] Create `assets/algorithms/foundation/ji_cheng_foundation_v1.json`.
- [ ] Register the asset directory in `pubspec.yaml`.
- [ ] Add asset-loading tests that parse every official profile and verify unique ids.
- [ ] Run:

```bash
flutter test test/taiyi/core/foundation_algorithm_config_test.dart test/taiyi/core/foundation_algorithm_engine_test.dart
```

Expected result:

```text
All model, engine, and asset parsing tests pass.
```

## 6. Integrate With Existing Calculator

- [ ] Run GitNexus impact analysis for `TaiYiPanCalculator` callers.
- [ ] Implement the `FoundationAlgorithmConfigLoader` supporting async loading and parsed profile caching.
- [ ] Change the signatures of `calculate`, `calculateWithConfig`, and `calculateWithCustomDeities` in `TaiYiPanCalculator` to return `Future<PanDataModel>`.
- [ ] Wire `TaiYiPanCalculator` to obtain Layer 1 fields from `FoundationAlgorithmEngine` by asynchronously loading profiles.
- [ ] Update all repository interfaces, view models, and UI pages to handle the asynchronous Future return type.
- [ ] Convert all unit and integration tests calling `calculate` or `calculateWithConfig` to run asynchronously (using `Future<void>` and `await`).
- [ ] Preserve existing downstream palace, count, deity, and metadata behavior.
- [ ] Keep the old hardcoded foundation path only as a temporary adapter if needed for one incremental commit.
- [ ] Run:

```bash
flutter test test/taiyi/algorithm_config/foundation_algorithm_vectors_test.dart test/taiyi/jing_mirror_year_standard_vectors_test.dart test/taiyi_year_eye_rules_flutter_test.dart test/taiyi_pan_calculator_smoke.dart
```

Expected result:

```text
All focused tests pass asynchronously.
```

## 7. Validate Full Regression Scope

- [ ] Run all Taiyi metadata regression tests available in the worker workspace:

```bash
flutter test test/taiyi/year_metadata_test.dart test/taiyi/month_metadata_test.dart test/taiyi/day_metadata_test.dart test/taiyi/hour_metadata_test.dart
```

- [ ] If `test/taiyi/full_metadata_regression_test.dart` exists, run it:

```bash
flutter test test/taiyi/full_metadata_regression_test.dart
```

- [ ] Run analyzer:

```bash
flutter analyze
```

- [ ] If analyzer fails because of existing unrelated warnings, record the exact count and a representative unrelated file list.
- [ ] Run GitNexus detect changes before commit and record affected symbols and flows.

## 8. Layer 2 Planning Gate

- [ ] Do not implement Layer 2 in the Layer 1 worker.
- [ ] Produce a follow-up OpenSpec for Layer 2A core palace derivation after Layer 1 tests pass.
- [ ] The Layer 2A OpenSpec SHALL name the input `FoundationResult` fields, palace-order profile, output fields, and required vectors.
- [ ] Produce separate follow-up OpenSpec changes for Layer 2B, Layer 2C, and Layer 2D unless the user explicitly authorizes combining them.
- [ ] Confirm every Layer 2 follow-up has its own gStack validation doc before implementation begins.
