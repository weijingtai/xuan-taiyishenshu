# Design: Taiyi Algorithm Configuration Management

## Context

The product has three separate concerns that must stay separated:

1. Storage and repository boundaries decide how schools, deities, and user preferences are loaded.
2. Foundation algorithms derive accumulated sequence values and cycle identities from time, chart type, and school profile.
3. Derived algorithms place Taiyi-related entities and calculate host/guest/ding values from foundation results.

This design treats the foundation layer as the first configurable unit because every downstream algorithm depends on it. It also records a concrete Layer 2 roadmap so future work can proceed without mixing downstream placement logic into the foundation extraction.

## Design Principles

- Configuration describes formulas; Dart code executes them through known typed templates.
- Official profiles are immutable JSON assets.
- User-editable school metadata can select an algorithm profile, but cannot provide executable code.
- Foundation outputs are deterministic and serializable for vector tests.
- Layer 2 consumes a `FoundationResult`; it does not recompute accumulated sequence logic.

## Layer 1 Architecture

```text
DateTime + TaiYiChartType + school algorithm profile id
  -> FoundationAlgorithmConfig
  -> FoundationAlgorithmEngine
  -> FoundationResult
       accumulatedYear
       sequenceIndex
       juNumber
       wuZiYuanJu
       yuanShu
       yuanName
       ruJiJiShu
       ruJiNianShu
       ruGongLabel
  -> existing TaiYiPanCalculator downstream logic
```

### FoundationAlgorithmConfig

`FoundationAlgorithmConfig` is a typed product-domain model loaded from JSON-like maps. The implementation SHALL include these model types:

- `FoundationAlgorithmConfig`
- `AccumulatedYearFormula`
- `ChartSequenceFormula`
- `CycleFormula`
- `YuanFormula`
- `RuGongFormula`

Supported template names for Layer 1:

- `linearYear`
- `accumulatedYear`
- `tianZhengMonth`
- `tropicalDay` (supports optional `baseSchoolId` parameter to reference another school's accumulated year)
- `dayTimesChineseHour` (supports optional `baseSchoolId` parameter to reference another school's accumulated year)
- `juModuloThree`

The model SHALL reject unknown template names with an explicit error that includes the profile id and field path.

### JSON Asset Layout

Official profiles SHALL live under:

```text
assets/algorithms/foundation/
  jing_mirror_foundation_v1.json
  tong_zong_foundation_v1.json
  ji_cheng_foundation_v1.json
```

Each profile SHALL include:

#### 1. Jing Mirror Foundation Profile (`jing_mirror_foundation_v1.json`)
```json
{
  "id": "jingMirror.foundation.v1",
  "school": "jingMirror",
  "version": 1,
  "accumulatedYear": {
    "template": "linearYear",
    "ancientBase": 1937281,
    "epochYear": 724,
    "correction": 0
  },
  "sequences": {
    "year": {"template": "accumulatedYear"},
    "month": {"template": "tianZhengMonth"},
    "day": {"template": "tropicalDay", "dayOffset": 4235},
    "hour": {"template": "dayTimesChineseHour", "hourOffset": 121847027}
  },
  "ju": {"cycle": 72, "zeroAsCycle": true},
  "wuZiYuanJu": {"cycle": 360, "zeroAsCycle": true},
  "jiYuan": {"cycle": 60, "zeroAsCycle": true},
  "yuan": {
    "cycle": 72,
    "names": ["甲子元", "丙子元", "戊子元", "庚子元", "壬子元"]
  },
  "ruGong": {
    "template": "juModuloThree",
    "labels": ["理天", "理地", "理人"]
  }
}
```

#### 2. Tongzong Foundation Profile (`tong_zong_foundation_v1.json`)
```json
{
  "id": "tongZong.foundation.v1",
  "school": "tongZong",
  "version": 1,
  "accumulatedYear": {
    "template": "linearYear",
    "ancientBase": 10155219,
    "epochYear": 1303,
    "correction": 1
  },
  "sequences": {
    "year": {"template": "accumulatedYear"},
    "month": {"template": "tianZhengMonth"},
    "day": {
      "template": "tropicalDay",
      "dayOffset": 4420,
      "baseSchoolId": "jingMirror"
    },
    "hour": {
      "template": "dayTimesChineseHour",
      "hourOffset": 2231,
      "baseSchoolId": "jingMirror"
    }
  },
  "ju": {"cycle": 72, "zeroAsCycle": true},
  "wuZiYuanJu": {"cycle": 360, "zeroAsCycle": true},
  "jiYuan": {"cycle": 60, "zeroAsCycle": true},
  "yuan": {
    "cycle": 72,
    "names": ["甲子元", "丙子元", "戊子元", "庚子元", "壬子元"]
  },
  "ruGong": {
    "template": "juModuloThree",
    "labels": ["理天", "理地", "理人"]
  }
}
```

#### 3. Jicheng Foundation Profile (`ji_cheng_foundation_v1.json`)
```json
{
  "id": "jiCheng.foundation.v1",
  "school": "jiCheng",
  "version": 1,
  "accumulatedYear": {
    "template": "linearYear",
    "ancientBase": 0,
    "epochYear": 1684,
    "correction": 1
  },
  "sequences": {
    "year": {"template": "accumulatedYear"},
    "month": {"template": "tianZhengMonth"},
    "day": {"template": "tropicalDay", "dayOffset": 0},
    "hour": {"template": "dayTimesChineseHour", "hourOffset": 0}
  },
  "ju": {"cycle": 72, "zeroAsCycle": true},
  "wuZiYuanJu": {"cycle": 360, "zeroAsCycle": true},
  "jiYuan": {"cycle": 60, "zeroAsCycle": true},
  "yuan": {
    "cycle": 72,
    "names": ["甲子元", "丙子元", "戊子元", "庚子元", "壬子元"]
  },
  "ruGong": {
    "template": "juModuloThree",
    "labels": ["理天", "理地", "理人"]
  }
}
```

### FoundationResult

`FoundationResult` SHALL be a plain immutable value object. It SHALL carry enough fields to let downstream code use foundation outputs without reading configuration directly.

The result SHALL include:

- `profileId`
- `chartType`
- `dateTime`
- `accumulatedYear`
- `sequenceIndex`
- `juNumber`
- `wuZiYuanJu`
- `yuanShu`
- `yuanName`
- `ruJiJiShu`
- `ruJiNianShu`
- `ruGongLabel`

## Layer 1 Migration Strategy

1. Freeze foundation vectors before production code changes.
2. Add model tests and implement `FoundationAlgorithmConfig`.
3. Add engine tests and implement `FoundationAlgorithmEngine`.
4. Add official JSON assets and asset-loading tests.
5. Implement an asynchronous profile loader that reads assets asynchronously and parses them, caching the parsed config in an in-memory map.
6. Convert `TaiYiPanCalculator`'s calculation methods (such as `calculate`, `calculateWithConfig`, `calculateWithCustomDeities`) to return `Future<PanDataModel>`.
7. Wire `TaiYiPanCalculator` to asynchronously load the profile, get the engine result, and calculate foundation fields while keeping existing downstream logic.
8. Update all repository interfaces, view models, pages, and tests that call `calculate` or `calculateWithConfig` to handle Futures using `await`.
9. Run focused vector tests for Jing Mirror, TongZong, and JiCheng.
10. Run analyzer and GitNexus detect-changes gates before any commit.

## Layer 2 Roadmap

Layer 2 SHALL be planned as four sublayers. These sublayers can become separate OpenSpec changes after Layer 1 is stable.

### Layer 2A: Core Palace Derivation

Inputs:

- `FoundationResult`
- chart type
- school profile id
- existing Taiyi palace order definitions

Outputs:

- `taiYiPalace`
- `wenChangPalace`
- `jiShenPalace`
- `shiJiPalace`

Validation vectors:

- Jing Mirror year vectors for 1949, 2026, and 2027.
- TongZong year/month/day/hour authoritative regression vectors.
- JiCheng year/month/day/hour baseline vectors marked by source provenance.

### Layer 2B: Host Guest Ding Counts

Inputs:

- `FoundationResult`
- Layer 2A palace outputs
- host/guest count route profile

Outputs:

- `hostCount`
- `guestCount`
- `dingCount`

Relationship to accumulated sequence:

- Counts SHALL NOT read raw accumulated sequence unless the configured school formula explicitly declares it.
- The default route SHALL derive counts from Layer 2A positions, which themselves are derived from Layer 1 foundation outputs.

### Layer 2C: Generals And Deputy Generals

Inputs:

- Layer 2B count outputs
- general-selection profile
- palace order profile

Outputs:

- `hostGeneral`
- `hostDeputyGeneral`
- `guestGeneral`
- `guestDeputyGeneral`

Relationship to accumulated sequence:

- Generals have an indirect relationship to accumulated sequence through Layer 1 and Layer 2B.
- A direct accumulated-sequence shortcut SHALL be forbidden unless represented as a named school-specific formula template and covered by vectors.

### Layer 2D: Derived Pan Placements

Inputs:

- Layer 2A palace outputs
- Layer 2B counts
- Layer 2C generals
- deity and school configuration from existing product repositories

Outputs:

- tian pan placements
- ren pan placements
- shen pan placements
- derived interpretive metadata already exposed by the product

Acceptance requirement:

- Pan outputs SHALL match existing full metadata regression vectors before any Layer 2 sublayer can be marked complete.

## Configuration Governance

Each official profile SHALL include:

- stable id
- school key
- version number
- source note or vector provenance reference
- supported chart types
- supported templates

Profile version updates SHALL be treated as algorithm changes and require vector evidence. A profile id SHALL NOT be silently reused for incompatible behavior.

## gStack Application Notes

This plan is application-ready only after:

- OpenSpec validation passes for `taiyi-algorithm-config-management`.
- gStack readiness scan finds no empty planning text.
- Current regression work is isolated from this documentation-only change.
- The implementation worker starts from Layer 1 tests and does not implement Layer 2 behavior.

## Risks

- Risk: JSON becomes a hidden programming language.
  - Mitigation: use finite typed templates only.
- Risk: Layer 2 behavior changes accidentally while Layer 1 is migrated.
  - Mitigation: freeze full metadata regression tests before wiring the calculator.
- Risk: school profiles disagree on formula names.
  - Mitigation: keep profile ids versioned and require vector provenance for every official profile.
- Risk: root-level governance ignores package-local OpenSpec.
  - Mitigation: if parent governance is required, copy this change under the root `openspec/changes/` directory and validate from the migration root before implementation.

## GSTACK REVIEW REPORT

### Step 0: Scope Challenge
- **Decision**: Scope accepted as-is with specific refinements for cross-school sequence references (`baseSchoolId` parameter) and asynchronous conversion.
- **Complexity Check**: Passed (touches 7 files, introduces modular configuration and engine classes).

### Architecture & Design Review
- **Issue**: Conversion of calculation path to asynchronous (`Future<PanDataModel>`) to support dynamic, non-blocking JSON asset loading.
- **Decision**: Approved. Convert all `TaiYiPanCalculator` calculation methods to async.
- **Issue**: Caching loaded profiles.
- **Decision**: Approved. Cache parsed config profiles in memory after the first load to keep subsequent calculations instantaneous.

### NOT in scope
- **Layer 2 Algorithms**: Considered and explicitly deferred to later sublayer changes (2A/2B/2C/2D) to keep Layer 1 focused and low-risk.
- **Repository Boundary Refactoring**: Explicitly deferred. The configuration engine operates inside existing repository boundaries.
- **Runtime Code Execution**: Explicitly forbidden to avoid security risks (profiles are pure data parsed into templates).

### What already exists
- **Official JSON School Repository**: Reused. The existing asset system is leveraged to load the new foundation config files without reinventing the file storage mechanism.
- **TaiYiPanCalculator Downstream Placement Logic**: Reused. The downstream logic is kept intact and only wired to the new engine outputs.

### Failure modes
- **Corrupted or Missing JSON profile**: Handled by throwing explicit parser errors during parsing. Unit tests verify that invalid profiles fail fast.
- **Fast-changing dates/schools causing race conditions**: Handled by caching profiles in memory so I/O is performed only once.

### Worktree parallelization strategy
Sequential implementation, no parallelization opportunity since all Layer 1 tasks are tightly integrated in `lib/taiyi/core/` and `lib/taiyi/taiyi_pan_calculator.dart`.

### Lake Score
2/2 recommendations chose the complete option (fully asynchronous calculation path and robust in-memory caching).

