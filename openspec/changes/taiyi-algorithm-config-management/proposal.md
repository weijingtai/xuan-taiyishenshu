# Proposal: Taiyi Algorithm Configuration Management

## Why

TaiYiShenShu currently keeps its important year/month/day/hour foundation calculations in hardcoded Dart logic. The product already has JSON-backed school and deity data, but the algorithm itself is not yet represented as governed configuration. This makes it difficult to compare TongZong, JiCheng, Jing Mirror, and future school variants without editing code paths directly.

The immediate need is to protect recent Jing Mirror year-vector work while creating a stable path toward algorithm profiles that can be reviewed, versioned, and tested independently.

## What Changes

This change introduces a configuration-backed algorithm management plan with two layers:

- Layer 1 SHALL be implemented first. It extracts foundation calculations into typed Dart configuration and a deterministic foundation engine.
- Layer 2 SHALL be planned now, but not implemented in the Layer 1 change. It defines the downstream algorithms that consume Layer 1 outputs.
- Official algorithm profiles SHALL be stored as JSON assets and interpreted by product-domain code, not by executable scripts or arbitrary expression strings.
- Existing `TaiYiPanCalculator` behavior SHALL be preserved unless a failing authoritative vector proves a specific defect.

## Layer 1 Implementation Scope

- Accumulated year/month/day/hour sequence values.
- 72-ju number derivation.
- 360-cycle wuzi yuan-ju derivation.
- Ji-yuan and yuan-name derivation.
- Ru-gong label derivation for profiles that expose it, including `理天`, `理地`, and `理人`.

## Layer 2 Planning Scope

- Taiyi palace, Wen Chang, Ji Shen, and Shi Ji derivation.
- Host count, guest count, and ding count derivation.
- Host general, host deputy general, guest general, and guest deputy general derivation.
- Tian pan, ren pan, shen pan, and derived pan placement outputs.

## Impact

Planned implementation files:

- `lib/taiyi/core/foundation_algorithm_config.dart`
- `lib/taiyi/core/foundation_algorithm_engine.dart`
- `assets/algorithms/foundation/*.json`
- `test/taiyi/algorithm_config/foundation_algorithm_vectors_test.dart`
- `test/taiyi/core/foundation_algorithm_config_test.dart`
- `test/taiyi/core/foundation_algorithm_engine_test.dart`

Planned integration files:

- `lib/taiyi/taiyi_pan_calculator.dart`
- `pubspec.yaml`

## Non-Goals

- This change does not execute repository boundary refactoring.
- This change does not implement Layer 2 algorithms.
- This change does not introduce a general-purpose DSL, scripting engine, or runtime code execution from configuration.
- This change does not relax existing regression vectors for TongZong, JiCheng, or Jing Mirror.
