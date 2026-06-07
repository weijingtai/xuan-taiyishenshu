## ADDED Requirements

### Requirement: Foundation Algorithms Are Configuration Backed
The TaiYiShenShu product SHALL support official foundation algorithm profiles represented as JSON assets and interpreted by typed Dart domain logic.

#### Scenario: Official profile is loaded
- **WHEN** a foundation algorithm profile is loaded from `assets/algorithms/foundation/`
- **THEN** the product SHALL parse it into `FoundationAlgorithmConfig` without requiring executable code or string-evaluated expressions.

#### Scenario: Unknown formula template is rejected
- **WHEN** a profile contains an unsupported template name
- **THEN** parsing SHALL fail with an explicit error that includes the profile id and field path.

### Requirement: Foundation Engine Produces Layer 1 Outputs
The foundation engine SHALL calculate accumulated sequence, ju number, wuzi yuan-ju, ji-yuan, yuan label, and ru-gong label for supported chart types.

#### Scenario: Jing Mirror year vector is reproduced
- **WHEN** the engine calculates the Jing Mirror year profile for `2026-06-07 15:08`
- **THEN** it SHALL produce accumulated year `1938583`, ju number `55`, wuzi yuan-ju `343`, and ru-gong label `理天`.

#### Scenario: Year, month, day, and hour chart types use typed formulas
- **WHEN** the engine calculates supported chart types
- **THEN** each chart type SHALL use its configured typed formula and SHALL NOT duplicate hardcoded sequence math in downstream placement code.

### Requirement: Layer 1 Preserves Existing Downstream Behavior
Layer 1 implementation SHALL preserve existing downstream pan, palace, deity, host/guest, and metadata behavior unless an authoritative vector proves a defect.

#### Scenario: Calculator uses foundation result
- **WHEN** `TaiYiPanCalculator` is wired to the foundation engine
- **THEN** existing downstream behavior SHALL continue to pass focused Jing Mirror and metadata regression tests.

#### Scenario: Layer 2 behavior is not changed
- **WHEN** the Layer 1 worker modifies production code
- **THEN** it SHALL NOT introduce new palace, count, general, or pan placement formulas beyond consuming Layer 1 outputs.

### Requirement: Layer 2 Is Planned As Downstream Algorithm Management
Layer 2 SHALL be documented as downstream algorithm planning before implementation and SHALL consume `FoundationResult` as its primary input.

#### Scenario: Core palace derivation is planned
- **WHEN** Layer 2A planning is prepared
- **THEN** it SHALL define Taiyi palace, Wen Chang, Ji Shen, and Shi Ji inputs, outputs, formula profiles, and vector gates.

#### Scenario: Host guest ding counts are planned
- **WHEN** Layer 2B planning is prepared
- **THEN** it SHALL define host count, guest count, ding count, their relationship to Layer 2A palace outputs, and their vector gates.

#### Scenario: Generals are planned
- **WHEN** Layer 2C planning is prepared
- **THEN** it SHALL define host general, host deputy general, guest general, and guest deputy general selection profiles and vector gates.

#### Scenario: Derived pan placements are planned
- **WHEN** Layer 2D planning is prepared
- **THEN** it SHALL define tian pan, ren pan, shen pan, and derived metadata acceptance gates.

### Requirement: Algorithm Profile Versions Are Governed
Official algorithm profile changes SHALL be versioned and validated by vector evidence.

#### Scenario: Profile behavior changes
- **WHEN** an official profile changes behavior
- **THEN** the change SHALL either increment the profile version or document why the correction is backwards-compatible and vector-proven.

#### Scenario: Implementation is proposed for completion
- **WHEN** the algorithm configuration implementation is proposed for review
- **THEN** review evidence SHALL include OpenSpec validation, gStack readiness scan, focused vector tests, analyzer result, and GitNexus detect-changes output.
