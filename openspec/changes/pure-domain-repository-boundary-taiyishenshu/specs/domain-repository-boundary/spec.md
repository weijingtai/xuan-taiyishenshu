## ADDED Requirements

### Requirement: Product Layer Has Pure Repository Ports
The TaiYiShenShu product layer SHALL define repository ports using product/domain models and primitive preference values only.

#### Scenario: Product usecase consumes product ports
- **WHEN** a TaiYiShenShu usecase loads, saves, copies, deletes, toggles preferences, or calculates a pan through repository access
- **THEN** it SHALL depend on product/domain repository ports and SHALL NOT require contract DTO types.

#### Scenario: Product viewmodel consumes product behavior
- **WHEN** a TaiYiShenShu viewmodel orchestrates school or deity workflows
- **THEN** it SHALL depend on usecases and product preference ports only and SHALL NOT import persistence or contract packages.

### Requirement: Product Layer Excludes Contract And Persistence Imports
The product `lib/taiyi/**` tree SHALL NOT import or export `repository_interface_taiyishenshu`, `persistence_drift`, `persistence_preferences`, `persistence_assets`, `shared_preferences`, or `drift`.

#### Scenario: Static boundary scan
- **WHEN** the implementation runs an import scan over `lib/taiyi/**`
- **THEN** the scan SHALL find no contract, persistence, shared preferences, or drift imports or exports.

#### Scenario: Runtime dependency scan
- **WHEN** the implementation inspects product runtime dependencies
- **THEN** `repository_interface_taiyishenshu` SHALL NOT be required for product `lib/taiyi/**` compilation.

### Requirement: Contract Adaptation Lives At Host Or Adapter Boundary
Contract DTO mapping and contract repository wrapping SHALL live outside product `lib/taiyi/**`.

#### Scenario: Host assembles backends
- **WHEN** the example host builds `TaiYiDataAssembly`
- **THEN** it SHALL create concrete backend repositories, adapt them to product repository ports, and inject product ports into the assembly.

#### Scenario: Product assembly receives dependencies
- **WHEN** `TaiYiDataAssembly` is constructed
- **THEN** its constructor SHALL accept product repository ports rather than `repository_interface_taiyishenshu` contract ports.

### Requirement: Existing TaiYi Behavior Is Preserved
The repository boundary migration SHALL preserve existing school, deity, preference, and pan calculation behavior.

#### Scenario: Official and user data coexist
- **WHEN** official school/deity data and user school/deity data are loaded after migration
- **THEN** official data SHALL remain read-only and user data SHALL remain writable through product ports.

#### Scenario: Preference persistence remains available
- **WHEN** a deity preference is toggled, read, and reloaded through the host-backed assembly
- **THEN** the persisted enabled state SHALL match the pre-migration behavior.

#### Scenario: Pan calculation uses migrated ports
- **WHEN** pan calculation loads school and deity data after migration
- **THEN** it SHALL produce the same behavior as the pre-migration product usecase for equivalent inputs.

### Requirement: Migration Is Implementation-Gated
Implementation SHALL NOT be accepted until architecture, static dependency, analyzer, and focused test gates pass.

#### Scenario: Architecture gate
- **WHEN** implementation is proposed for review
- **THEN** the review SHALL include evidence that the product/host boundary matches this OpenSpec design and that unresolved adapter-location decisions are documented.

#### Scenario: QA gate
- **WHEN** implementation is proposed for completion
- **THEN** the QA evidence SHALL include static boundary scans, analyzer result, focused tests, and any available host smoke result before the change is considered ready.

### Requirement: Algorithm Configuration Is Out Of Scope
Algorithm management system configuration SHALL remain outside this repository boundary change.

#### Scenario: Adjacent algorithm request appears
- **WHEN** implementation planning encounters algorithm configuration work
- **THEN** it SHALL be recorded as adjacent or follow-up scope and SHALL NOT be mixed into this repository boundary implementation.
