## ADDED Requirements

### Requirement: Four Traditions Are First-Class Algorithm Profiles
The TaiYiShenShu product SHALL represent Jing Mirror, Fu Ying Jing, Tong Zong, and Tao Jin Ge as first-class algorithm traditions.

#### Scenario: Official profiles are parsed
- **WHEN** official tradition profiles are loaded from `assets/algorithms/traditions/`
- **THEN** each profile SHALL parse into a typed `AlgorithmProfile` without executable code or string-evaluated expressions.

#### Scenario: JiCheng remains compatibility-only
- **WHEN** the registry describes source traditions
- **THEN** `jiCheng` SHALL NOT be listed as one of the four source traditions and SHALL remain available only through compatibility or custom-school behavior.

#### Scenario: Verification status is explicit
- **WHEN** a profile lacks user-confirmed numeric vectors
- **THEN** the profile SHALL expose `verificationStatus` as `needsAuthoritativeVectors`.

### Requirement: Strategy Registry Provides Extensible Algorithm Dispatch
The product SHALL dispatch algorithm work through a typed strategy registry rather than hard-coded school branches in `TaiYiPanCalculator`.

#### Scenario: Built-in registry is synchronous
- **WHEN** `TaiYiPanCalculator.calculate` runs for built-in official profiles
- **THEN** the registry SHALL provide the profile synchronously and SHALL NOT require changing the public return type to `Future<PanDataModel>` in this change.

#### Scenario: Unknown strategy is rejected
- **WHEN** a profile references an unsupported strategy id
- **THEN** parsing or registry resolution SHALL fail with an explicit error containing the profile id, strategy id, and field path.

### Requirement: Foundation Engine Produces Governed Foundation Outputs
The foundation engine SHALL calculate accumulated year, sequence index, ju number, yuan/ji metadata, and ru-gong label where the selected tradition supports them.

#### Scenario: Jing Mirror reference foundation is calculated
- **WHEN** the engine calculates Jing Mirror for a supported vector
- **THEN** it SHALL use the configured Jing Mirror foundation strategy and SHALL expose the selected profile id in the result.

#### Scenario: Tong Zong reference foundation is calculated
- **WHEN** the engine calculates Tong Zong for a supported vector
- **THEN** it SHALL use the configured Tong Zong foundation strategy and SHALL expose the selected profile id in the result.

#### Scenario: Tao Jin Ge near-era foundation is rule-tested
- **WHEN** the engine calculates Tao Jin Ge without authoritative numeric vectors
- **THEN** it SHALL use near-era Jia Zi profile parameters and SHALL mark the result as `needsAuthoritativeVectors`.

### Requirement: Chart Entry Engine Separates Year Month Day Hour Rules
The chart entry engine SHALL calculate chart-type-specific entry results independently of downstream pan assembly.

#### Scenario: Jing Mirror year month day share count logic
- **WHEN** Jing Mirror year, month, or day chart entry is calculated
- **THEN** the result SHALL be compatible with the shared Jing Mirror three-count logic for those chart types.

#### Scenario: Jing Mirror hour uses independent hour entry
- **WHEN** Jing Mirror hour chart entry is calculated
- **THEN** the result SHALL keep permanent forward walking and Taiyi previous-palace endpoint policy.

#### Scenario: Tong Zong hour uses yin-yang entry policy
- **WHEN** Tong Zong hour chart entry is calculated
- **THEN** the result SHALL expose enough information for the count engine to use Wu De for yang dun, Lu Shen for yin dun, Taiyi previous palace for yang endpoint, and Taiyi next palace for yin endpoint.

### Requirement: Eye Engine Produces Tian Mu Shi Ji Ji Shen And Ding Da Jiang
The eye engine SHALL produce named and palatial eye outputs needed by the three-count engine.

#### Scenario: Jing Mirror eyes are calculated
- **WHEN** Jing Mirror eyes are calculated for a supported chart type
- **THEN** the engine SHALL return Tian Mu, Shi Ji, Ji Shen, and Ding Da Jiang data or an explicit unsupported field when a source vector does not include that element.

#### Scenario: Fu Ying Jing yin-yang starts are rule-tested
- **WHEN** Fu Ying Jing eyes are calculated for yang and yin dun
- **THEN** yang SHALL start from Wu De and yin SHALL start from Lu Shen.

### Requirement: Three Count Engine Implements Host Guest And Ding Count With Provenance
The three-count engine SHALL calculate host count, guest count, and ding/fixed count with explicit classical mapping metadata.

#### Scenario: Middle palace is excluded
- **WHEN** count traversal walks palaces or mod 8 operations run
- **THEN** the traversal/indexing SHALL use `[乾, 离, 艮, 震, 兑, 坤, 坎, 巽]` and SHALL explicitly skip the middle palace.

#### Scenario: Full-ten rule is applied
- **WHEN** a traversal sum is greater than zero
- **THEN** the result SHALL be `((sum - 1) % 10) + 1`.

#### Scenario: No-count boundary is applied
- **WHEN** start and Taiyi are in the same palace or one step from start reaches Taiyi without traversed palace
- **THEN** the count result SHALL be zero and the detail SHALL identify it as no-count.
- **WHEN** the traversal path does not pass through any valid palace (start = end)
- **THEN** the count result SHALL be zero, the generals and deputies SHALL map to the middle palace (中五宫), and the counting token SHALL be `0`.

#### Scenario: Sixteen-god mapping is applied
- **WHEN** calculations require converting sixteen-god positions to eight-palace positions
- **THEN** the conversion SHALL map positions according to the orthodox sixteen-god to eight-palace mapping table.

#### Scenario: Ding count provenance is explicit
- **WHEN** a strategy emits `dingCount`
- **THEN** it SHALL also emit whether the value is proven to correspond to classical `定算`.

#### Scenario: Tong Zong hour endpoint changes by dun
- **WHEN** Tong Zong hour count is calculated under yang dun
- **THEN** the endpoint SHALL be Taiyi previous palace.
- **WHEN** Tong Zong hour count is calculated under yin dun
- **THEN** the endpoint SHALL be Taiyi next palace.

### Requirement: Solar Term Provider Controls Dun Boundaries
The product SHALL route yin/yang dun resolution through a `SolarTermProvider`.

#### Scenario: Precise boundary is available
- **WHEN** winter or summer solstice data is available for the requested year
- **THEN** the provider SHALL use the precise boundary rather than fixed calendar dates.

#### Scenario: Precise boundary is unavailable
- **WHEN** precise solstice data is unavailable
- **THEN** the provider SHALL return a result that identifies the fallback status so tests and metadata can detect it.

### Requirement: Fu Ying Jing And Tao Jin Ge Are Vector-Gated
The product SHALL include Fu Ying Jing and Tao Jin Ge as first-class profiles without inventing unverified numeric outputs.

#### Scenario: Fu Ying Jing lacks numeric vectors
- **WHEN** Fu Ying Jing is calculated without user-confirmed vectors
- **THEN** tests SHALL assert profile and rule behavior only and SHALL NOT assert invented pan values.

#### Scenario: Tao Jin Ge lacks numeric vectors
- **WHEN** Tao Jin Ge is calculated without user-confirmed vectors
- **THEN** tests SHALL assert near-era Jia Zi and mnemonic wheel behavior only and SHALL NOT assert invented pan values.

#### Scenario: User vectors are later supplied
- **WHEN** the user supplies authoritative Fu Ying Jing or Tao Jin Ge vectors
- **THEN** this change or a follow-up change SHALL add numeric regression tests before claiming parity.

### Requirement: Eight Generals Positioning And Chart Coordination Rules
The product SHALL support calculating the Eight Generals (地乙, 君基, 臣基, 民基, 主大将, 主小将/参将, 飞符, 四神) under all four calculations (年/月/日/时) and resolve their chart coordination rules.

#### Scenario: Eight Generals are calculated for Jing Mirror
- **WHEN** the engine calculates Jing Mirror year, month, or day chart
- **THEN** it SHALL calculate Jun Ji (午起30步), Chen Ji (午起3步), Min Ji (戌起1步), Di Yi (巳起3步), Fei Fu (辰起3步), and Si Shen (大周180/小周36/宫步3) based on the absolute year or division number.

#### Scenario: Eight Generals are calculated for Tong Zong
- **WHEN** the engine calculates Tong Zong year, month, or day chart
- **THEN** it SHALL calculate Jun Ji (午起24步), Chen Ji (午起3步), Min Ji (戌起1步), Di Yi (巳起3步), Fei Fu (辰起3步), and Si Shen (大周240/小周24/宫步3).

#### Scenario: Three-count results determine 大小将
- **WHEN** three-count results are formatted
- **THEN** the main general, guest general, and ding general (主大将, 客大将, 定大将) SHALL map to their corresponding palaces, and their corresponding deputy generals (主小将/参将, 客小将, 定小将) SHALL be computed as $(大将 \times 3) \bmod 10$ with 10 mapped to 9/Xun.

#### Scenario: Hour chart excludes tri-bases and other auxiliary generals
- **WHEN** any tradition calculates the hour chart
- **THEN** the output SHALL exclude Jun Ji, Chen Ji, Min Ji, Di Yi, Fei Fu, and Si Shen, keeping only the core main and deputy generals.

#### Scenario: Chart coordination rules are resolved
- **WHEN** host, guest, and ding charts (主局, 客局, 定局) are assembled
- **THEN** the configuration of each chart SHALL coordinate the corresponding eye, main general, deputy general, and auxiliary base/general.

### Requirement: Regression Evidence Is Required Before Completion
The implementation SHALL provide validation evidence before being marked complete.

#### Scenario: Implementation is proposed for review
- **WHEN** the algorithm platform implementation is proposed for review
- **THEN** evidence SHALL include OpenSpec validation, readiness scan, focused vector tests, analyzer result, and GitNexus detect-changes output.
