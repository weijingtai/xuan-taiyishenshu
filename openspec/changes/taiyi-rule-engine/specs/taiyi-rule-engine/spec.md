## ADDED Requirements

### Requirement: Schools Are Rule Documents Interpreted Natively
A Taiyi school SHALL be represented as a single structured rule document interpreted by native Dart. The engine SHALL NOT use a string DSL parser, an embedded JavaScript engine, or runtime Dart code generation.

#### Scenario: School document drives a chart without code change
- **WHEN** two school documents differ only in their accumulated-year arithmetic tree
- **THEN** the same engine SHALL produce the two corresponding charts with no change to executable code.

#### Scenario: No runtime code execution
- **WHEN** a school document is loaded
- **THEN** it SHALL be interpreted as data only, with no string-evaluated expressions and no script/VM execution.

### Requirement: Arithmetic Is A Bounded JSON Tree
Arithmetic leaves SHALL be expressed as a JSON arithmetic tree (AST) with a whitelisted node set: integer literal, real literal, variable reference, the binary operators `+ - * ~/ %`, and `floor`. Division `/` SHALL NOT be provided.

#### Scenario: Whitelisted node evaluates
- **WHEN** the engine evaluates `floor(J * 365.2425) + D`
- **THEN** it SHALL return the integer result via tree traversal, with no string parsing.

#### Scenario: Unknown variable or node is rejected
- **WHEN** a tree references an undeclared variable or a non-whitelisted node type
- **THEN** evaluation SHALL fail with an explicit error.

#### Scenario: Depth is bounded
- **WHEN** a tree exceeds the configured maximum depth
- **THEN** validation SHALL reject it, guaranteeing the evaluator is non-Turing-complete.

### Requirement: Users Can Author And Manage Schools
The product SHALL let users create, edit, save, and manage their own schools (including star-deities and key parameters) through full CRUD, while official schools remain read-only bundled assets. Official and user schools SHALL use the same engine.

#### Scenario: User forks and edits an official school
- **WHEN** a user forks an official school, edits a deity rule, and saves
- **THEN** the user school SHALL persist in a user-writable repository and read back identically, without modifying any official asset.

#### Scenario: Adding a star-deity is data-only
- **WHEN** a user adds a star-deity to a school
- **THEN** it SHALL be a new entry in the school's `deities` list with a rule of a known kind, requiring no code deployment.

### Requirement: Rule Taxonomy Covers School-Distinguishing Switches
The rule taxonomy (R1 scalar, R2 palace-walk, R3 walk-and-sum, R4 derive-from-count, R5 relative, R6 table-sequence, R7 predicate, plus an R8 dun/solar-term context) SHALL be sufficient to express the five-school feature set in `docs/classes/5_in_one_classes_alg.md`, including the five distinguishing switches in `docs/classes/core_diff.md`.

#### Scenario: Rule outputs are typed
- **WHEN** a rule is evaluated
- **THEN** it SHALL emit a typed `RuleValue` (`scalar`, `palace`, `deity`, `predicate`, or approved internal `record`) and validation SHALL reject references whose expected output type is incompatible.

#### Scenario: 重留 is editable data
- **WHEN** a palace-walk rule needs 重留一算 positions
- **THEN** they SHALL be a `restAt` object with `values` and `source` fields, not hardcoded logic.

#### Scenario: Chart-range switch is expressed as data
- **WHEN** a school computes only year charts (e.g. 淘金歌)
- **THEN** the unused charts/deities SHALL be disabled via `appliesTo`/`enabled` fields, not by branching code.

### Requirement: Three-Calc Uses Tai Yi Nine-Palace, Man-Shi-Qu-Shi, And Wu-Suan
The three-calculation (主/客/定算) SHALL traverse the Tai Yi nine-palace order (乾1·离2·艮3·震4·中5 excluded·兑6·坤7·坎8·巽9), apply 满十去十 with 10→9, and implement 无算 (S=0).

#### Scenario: Walk uses the abstract palace order
- **WHEN** host-calc walks from 文昌 to the palace before 太乙
- **THEN** it SHALL accumulate 宫本数 along the Tai Yi nine-palace order (skipping center five), NOT a geographic sixteen-god order.

#### Scenario: Wu-suan returns zero
- **WHEN** the start palace equals the 太乙 palace, or one forward step reaches 太乙
- **THEN** the count SHALL be 0 (无算).

#### Scenario: Man-shi-qu-shi with ten-to-nine
- **WHEN** the accumulated sum normalizes to 10
- **THEN** the result SHALL be 9.

### Requirement: Solar Terms Come From metaphysics_core With Mean Or Apparent Mode
阴阳遁, 节气校正, and 甲子日 anchoring SHALL use `metaphysics_core` solar terms (`TwentyFourJieQi`, `JieQiType.leveling`/`stabilizing`), with a per-school `termMode` of 平气 or 定气. Hardcoded solstice dates SHALL NOT be used.

#### Scenario: R8 dependency is proven before implementation
- **WHEN** implementation reaches R8
- **THEN** a contract test SHALL prove the real `metaphysics_core` API can provide 冬至/夏至 boundaries and 平气/定气 mode selection, or an adapter decision SHALL be recorded before production R8 code is written.

#### Scenario: Dun resolved from precise terms
- **WHEN** the engine resolves 阴阳遁 for an hour chart
- **THEN** it SHALL use the precise 冬至/夏至 entry times from `metaphysics_core` under the school's `termMode`, not fixed 6/21 or 12/21 dates.

### Requirement: Contested Values Carry Source Provenance
Values with multiple documentary sources (e.g. 重留位) SHALL carry an explicit `source` field naming the source text.

#### Scenario: 重留位 source is recorded
- **WHEN** an official school sets 天目 重留位
- **THEN** the value SHALL be `5_in_one_classes_alg.md §4.1` (阴德/大武/乾/坤) with a `source` field, so it can be reviewed and changed later.

### Requirement: Rule Validation Is Safe And Explicit
On save, school documents SHALL be validated for known rule kinds, known palace systems, whitelisted bounded arithmetic, acyclic rule references (DAG), and required fields, failing with an error that includes the school id and field path.

#### Scenario: Schema contract is frozen before official assets
- **WHEN** official school documents are authored
- **THEN** the School v1 schema, rule union discriminator, RuleValue output types, provenance field shape, reference rules, and validation error format SHALL already be covered by contract tests.

#### Scenario: Cyclic reference is rejected
- **WHEN** rule A references rule B which references rule A
- **THEN** validation SHALL reject the document with a field-path error.

### Requirement: Calculator API Migration Is Explicitly Gated
Calculator integration SHALL not change public `calculate*` signatures until a contract test records whether this change preserves a synchronous compatibility adapter or intentionally migrates callers to `Future<PanDataModel>`.

#### Scenario: Synchronous compatibility is selected
- **WHEN** the implementation keeps synchronous public calculator APIs
- **THEN** existing smoke tests SHALL compile and run without adding `await` to current call sites.

#### Scenario: Async migration is selected
- **WHEN** the implementation changes calculator APIs to return `Future<PanDataModel>`
- **THEN** integration evidence SHALL list migrated call sites and tests SHALL compile against the async contract.

### Requirement: Runtime Expression Paths Are Not Used By School Documents
School rule documents SHALL not use legacy string expression execution paths.

#### Scenario: Legacy string formula is rejected
- **WHEN** a School document contains a string formula or legacy custom-formula template
- **THEN** validation SHALL reject it and the import path SHALL not call `ExpressionParser` or `_executeCustomFormula`.
