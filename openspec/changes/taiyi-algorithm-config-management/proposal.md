# Proposal: Taiyi Algorithm Configuration Management

## Why

TaiYiShenShu currently mixes accumulated sequence, chart entry, Tian Mu / Shi Ji / Ji Shen placement, and host / guest / ding count logic inside `TaiYiPanCalculator`. That makes it difficult to represent different source traditions correctly.

The implementation target is no longer a foundation-only extraction. The new target is an implementable algorithm platform based on option C:

- a typed tradition/profile registry,
- finite Dart strategy classes,
- versioned JSON/configuration assets,
- small pluggable engines for foundation, chart entry, eyes, and three-count calculations.

This change must support four first-class traditions:

- Jing Mirror (`jingMirror`)
- Fu Ying Jing (`fuYing`)
- Tong Zong (`tongZong`)
- Tao Jin Ge (`taoJinGe`)

`jiCheng` remains a compatibility/custom school and is not one of the four source traditions.

## What Changes

This change introduces a governed algorithm platform that can calculate or declare the complete four-countable surfaces needed by the current reference docs:

- foundation values: accumulated year, sequence index, ju number, yuan/ji metadata;
- chart entry: year/month/day/hour entry into palace or tradition-specific carrier;
- eyes: Tian Mu/Wen Chang, Shi Ji, Ji Shen, and Ding Da Jiang where the profile supports it;
- three-count algorithms: host count, guest count, and ding/fixed count with explicit naming and provenance.

The implementation SHALL prioritize a working Jing Mirror and Tong Zong path against authoritative/current regression vectors. Fu Ying Jing and Tao Jin Ge SHALL be modeled as first-class traditions with parseable profiles, rule-level tests, and explicit `needsAuthoritativeVectors` verification status until the user supplies or confirms numeric charts.

## Implementation Scope

### In Scope

- Create `lib/taiyi/core/algorithm_platform/` with focused model and engine files.
- Add four official tradition profiles under `assets/algorithms/traditions/`.
- Implement Jing Mirror and Tong Zong foundation, chart entry, eye, and three-count strategy paths.
- Add Fu Ying Jing strategy skeletons for yin/yang starts, direction policy, and profile selection.
- Add Tao Jin Ge strategy skeletons for near-era Jia Zi and mnemonic year/month/day/hour wheel rules.
- Preserve existing public `TaiYiPanCalculator.calculate` synchronous API for the first implementation pass.
- Add a profile registry that can be synchronous for built-in assets and can later be backed by asynchronous repositories.
- Keep JSON pure data. It may select finite strategy ids and parameters, but it must not execute code or evaluate arbitrary expressions.

### Out Of Scope For This Change

- Full deity runtime migration for all ten essences, sixteen gods, three bases, and big/small travels.
- Personal Taiyi life chart and Taiyi hexagram systems, except as future extension notes.
- Inventing numeric Fu Ying Jing or Tao Jin Ge vectors without user-reviewed source material.
- Repository boundary refactoring unrelated to algorithm correctness.

## Key Design Decisions

- The core API remains synchronous initially. Built-in profiles can be registered in code or loaded before calculator invocation. A future async repository may wrap the registry without forcing a broad API break now.
- `dingCount` and classical `定算` SHALL be audited explicitly. The implementation must not silently treat them as identical unless the strategy and test provenance says so.
- Jing Mirror and Tong Zong use the development reference `docs/classes/金镜_统宗_四计_三算_alg.md` as the immediate source of truth for four-count behavior.
- Fu Ying Jing and Tao Jin Ge are included now as extensible first-class traditions, but their unconfirmed formulas are guarded by discussion gates and rule-only tests.

## Impact

Planned implementation files:

- `lib/taiyi/core/algorithm_platform/taiyi_algorithm_tradition.dart`
- `lib/taiyi/core/algorithm_platform/algorithm_profile.dart`
- `lib/taiyi/core/algorithm_platform/algorithm_registry.dart`
- `lib/taiyi/core/algorithm_platform/algorithm_context.dart`
- `lib/taiyi/core/algorithm_platform/foundation_engine.dart`
- `lib/taiyi/core/algorithm_platform/chart_entry_engine.dart`
- `lib/taiyi/core/algorithm_platform/eye_engine.dart`
- `lib/taiyi/core/algorithm_platform/three_count_engine.dart`
- `lib/taiyi/core/algorithm_platform/solar_term_provider.dart`
- `assets/algorithms/traditions/*.json`
- `test/taiyi/algorithm_platform/*.dart`

Planned integration files:

- `lib/taiyi/taiyi_pan_calculator.dart`
- `lib/taiyi/core/school_config.dart`
- `pubspec.yaml`

## Success Criteria

- Jing Mirror and Tong Zong can be calculated through the new platform for supported year/month/day/hour vectors.
- Fu Ying Jing and Tao Jin Ge have first-class profiles and rule tests, with a clear path to numeric vectors after user confirmation.
- OpenSpec validation and readiness scans pass.
- Focused Taiyi regression tests pass or pre-existing failures are recorded before implementation.
