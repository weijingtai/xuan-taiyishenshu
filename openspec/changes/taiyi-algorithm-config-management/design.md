# Design: Taiyi Algorithm Configuration Management

## Context

The current implementation concentrates several different concerns in `TaiYiPanCalculator`:

1. foundation sequence calculation,
2. chart entry into palace or deity carriers,
3. Tian Mu / Wen Chang, Shi Ji, Ji Shen, and Ding Da Jiang placement,
4. host / guest / ding count calculation,
5. downstream pan assembly.

The implementation must become extensible enough to represent multiple Taiyi source traditions without adding more school-specific branches to the calculator.

This design adopts option C: strategy registry + typed profiles + finite pluggable engines.

## Source Documents

Implementation workers must read:

- `docs/classes/金镜_统宗_四计_三算_alg.md`
- `docs/classes/4_classes_explain.md`
- `docs/classes/4_classes_alg.md`
- `docs/classes/ming_fa_vs_ming_gua.md`
- `docs/classes/ming_fa_vs_ming_gua_2.md`

Immediate production parity is based on `docs/classes/金镜_统宗_四计_三算_alg.md` for Jing Mirror and Tong Zong. The broader four-tradition documents govern profile naming and future extensibility.

## Design Principles

- Profiles describe source tradition, chart-type strategy ids, parameters, and verification status.
- Dart code implements finite strategy ids. JSON cannot execute code and cannot contain arbitrary formulas evaluated at runtime.
- `TaiYiPanCalculator` orchestrates engines; it does not own new algorithm law.
- The first implementation keeps `TaiYiPanCalculator.calculate` synchronous.
- Built-in profiles are available through a synchronous registry. A future async repository may load remote/user profiles without forcing this change to break public calculator callers.
- Numeric outputs require vector evidence. Rule-only profiles must say so explicitly.

## Four First-Class Traditions

| Tradition | Profile id | Implementation status in this change | Verification |
| --- | --- | --- | --- |
| Jing Mirror | `jingMirror` | Implement foundation, entry, eyes, and three-count strategies | existing/current vectors plus new rule tests |
| Fu Ying Jing | `fuYing` | Add first-class profile and rule-level strategy skeleton | `needsAuthoritativeVectors` |
| Tong Zong | `tongZong` | Implement foundation, entry, eyes, and three-count strategies | existing/current vectors plus new rule tests |
| Tao Jin Ge | `taoJinGe` | Add first-class profile and rule-level mnemonic strategies | `needsAuthoritativeVectors` |

`jiCheng` remains supported as a compatibility/custom school through existing behavior or a later compatibility profile.

## Architecture

```text
DateTime + TaiYiChartType + schoolId
  -> AlgorithmProfileRegistry
  -> AlgorithmProfile
  -> AlgorithmContext
  -> FoundationEngine
       FoundationResult
  -> ChartEntryEngine
       ChartEntryResult
  -> EyeEngine
       EyeResult
  -> ThreeCountEngine
       ThreeCountResult
  -> TaiYiPanCalculator downstream pan assembly
```

### Core Files

```text
lib/taiyi/core/algorithm_platform/
  taiyi_algorithm_tradition.dart
  algorithm_profile.dart
  algorithm_registry.dart
  algorithm_context.dart
  foundation_engine.dart
  chart_entry_engine.dart
  eye_engine.dart
  three_count_engine.dart
  solar_term_provider.dart
```

### Profile Assets

```text
assets/algorithms/traditions/
  jing-mirror.json
  fu-ying.json
  tong-zong.json
  tao-jin-ge.json
```

Assets are the governed profile source. The synchronous registry may also embed the same profile maps to avoid immediate async asset loading in pure domain tests.

## Profile Model

Each official profile SHALL include:

- `id`
- `schoolId`
- `tradition`
- `sourceText`
- `version`
- `verificationStatus`
- `foundation`
- `charts.year`
- `charts.month`
- `charts.day`
- `charts.hour`
- `eyes`
- `threeCounts`
- `deities`
- `discussionGates`

Example:

```json
{
  "id": "tongZong.official.v1",
  "schoolId": "tongZong",
  "tradition": "tongZong",
  "sourceText": "太乙统宗宝鉴",
  "version": 1,
  "verificationStatus": "authoritativeVectorsAvailable",
  "foundation": {
    "strategy": "tongZongFoundation",
    "absoluteYearBase": 10155960,
    "baseYear": 1644
  },
  "charts": {
    "year": { "entryStrategy": "tongZongYearEntry" },
    "month": { "entryStrategy": "tongZongMonthEntry" },
    "day": { "entryStrategy": "tongZongDayEntry" },
    "hour": { "entryStrategy": "tongZongHourEntry" }
  },
  "eyes": { "strategy": "tongZongEyes" },
  "threeCounts": { "strategy": "tongZongThreeCounts" },
  "deities": { "strategy": "compatibilityDeities" },
  "discussionGates": []
}
```

Fu Ying Jing and Tao Jin Ge profiles SHALL use `verificationStatus: "needsAuthoritativeVectors"` until numeric vectors are confirmed.

## Result Model

### FoundationResult

Required fields:

- `profileId`
- `tradition`
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
- `verificationStatus`

### ChartEntryResult

Required fields:

- `carrier`: `ninePalace`, `sixteenGod`, `mnemonicWheel`, or `mixed`
- `taiYiPalace`
- `entryPositionName`
- `entryNumber`
- `methodNote`

### EyeResult

Required fields:

- `tianMuName`
- `tianMuPalace`
- `shiJiName`
- `shiJiPalace`
- `jiShenName`
- `jiShenPalace`
- `dingDaJiangName`
- `dingDaJiangPalace`
- `methodNote`

### ThreeCountResult

Required fields:

- `hostCount`
- `guestCount`
- `dingCount`
- `hostClassicalName`
- `guestClassicalName`
- `dingClassicalName`
- `dingCountIsClassicalDingSuan`
- `detail`

The `dingCountIsClassicalDingSuan` field prevents accidental conflation between product `dingCount` and classical `定算`.

## Jing Mirror And Tong Zong Implementable Rules

Use `docs/classes/金镜_统宗_四计_三算_alg.md` as the immediate reference.

### Shared Palace Rules

- Taiyi traversal order is `[乾, 离, 艮, 震, 兑, 坤, 坎, 巽]` (index 0 to 7).
- Middle palace (中五宫) is never part of traversal. All mod 8 operations and palace indexing/traversal SHALL explicitly skip the middle palace and only cycle within the 8 valid palaces.
- Palace base numbers are `乾=1, 离=2, 艮=3, 震=4, 兑=6, 坤=7, 坎=8, 巽=9`.
- Count result is `((sum - 1) % 10) + 1`.
- If sum is zero, result is zero and means no-count (无算).
- No-count (无算) applies when start and Taiyi are in the same palace, or one step from start reaches Taiyi with no traversed palace.
- **Extended No-count Boundary Rule**: When the traversal path does not pass through any valid palace (i.e. start = end), in addition to setting the accumulated sum `S = 0` (no-count), the generals and deputy generals (大将, 参将) SHALL all be mapped to the middle palace (中五宫/无位), and the counting token (算筹) SHALL be recorded as `0`.

### Jing Mirror

- Foundation uses `absoluteYear = 10153917 + (year - 751)` for the reference algorithm path.
- Year/month/day use the same three-count logic.
- Hour has independent entry data but still uses permanent forward walking, Wen Chang as the start for host count, and Taiyi previous palace as endpoint (converting sixteen-god positions to eight-palace positions based on the orthodox sixteen-god to eight-palace mapping table).
- Yin/yang dun does not alter Jing Mirror hour-count direction.

### Tong Zong

- Foundation uses `absoluteYear = 10155960 + (year - 1644)` for the reference algorithm path.
- Year/month/day three-count logic matches Jing Mirror after entry positions are derived.
- Month supports accumulated-month mode and independent branch-start mode as separate strategy ids.
- Day supports solstice Jia Zi start mode as a separate strategy id.
- Hour is the core difference:
  - yang dun starts host count from Wu De;
  - yin dun starts host count from Lu Shen;
  - yang endpoint is Taiyi previous palace;
  - yin endpoint is Taiyi next palace;
  - walking remains forward.

## Solar Term Provider

The platform SHALL introduce `SolarTermProvider`:

```text
SolarTermProvider.resolveDunType(DateTime dateTime)
```

The first implementable provider may use a checked-in table for supported years. It must expose whether the result is precise or fallback. Final parity for Tong Zong hour/day behavior requires precise winter/summer solstice boundary data rather than fixed June/December dates.

## Fu Ying Jing Boundary

Known from current docs:

- It inherits the Jing Mirror foundation family with Song-calendar correction.
- Month calculation (月计) determines yin/yang dun by taking `totalAccumulatedMonths % 18`: if the remainder is `1 to 9` (or `≤ 9`), it is Yang Dun; if it is `10 to 18` (or `0` / `> 9`), it is Yin Dun.
- It uses strict yin/yang dun.
- Yang starts from Wu De.
- Yin starts from Lu Shen.
- Tian Mu, Shi Ji, and host/guest behavior depend on yin/yang policy.

Implementation in this change:

- Add `fuYing` profile.
- Add strategy ids:
  - `fuYingFoundation`
  - `fuYingYearEntry`
  - `fuYingMonthEntry`
  - `fuYingDayEntry`
  - `fuYingHourEntry`
  - `fuYingEyes`
  - `fuYingThreeCounts`
- Add rule-level tests for profile parsing, yin/yang start selection, endpoint policy, and no executable JSON.
- Do not assert numeric pan outputs until the user confirms vectors.

Discussion gate:

- Ask the user for source text or numeric examples before claiming Fu Ying Jing year/month/day/hour parity.

## Tao Jin Ge Boundary

Known from current docs:

- It uses a near-era Jia Zi anchor rather than huge ancient accumulated years.
- Year/month/day/hour are mnemonic wheel style rules.
- It is simplified and human-affair oriented.

Implementation in this change:

- Add `taoJinGe` profile.
- Add strategy ids:
  - `taoJinGeFoundation`
  - `taoJinGeYearWheel`
  - `taoJinGeMonthWheel`
  - `taoJinGeDayWheel`
  - `taoJinGeHourWheel`
  - `taoJinGeEyes`
  - `taoJinGeThreeCounts`
- Add rule-level tests for near-era Jia Zi anchor, wheel rotation shape, profile parsing, and no executable JSON.
- Do not assert numeric pan outputs until the user confirms the exact anchor and examples.

Discussion gate:

- Ask the user whether the near-era Jia Zi anchor is `423` or another source-specific value before claiming Tao Jin Ge parity.

## Migration Strategy

1. Freeze and label existing calculator behavior before code changes.
2. Add profile model and four official profile assets.
3. Add synchronous registry for built-in profiles.
4. Add foundation engine.
5. Add chart entry engine.
6. Add eye engine.
7. Add three-count engine.
8. Integrate the platform behind `TaiYiPanCalculator` for Jing Mirror and Tong Zong while preserving current public API.
9. Add Fu Ying Jing and Tao Jin Ge rule-only integration paths with clear warnings or verification metadata.
10. Run focused vectors, metadata regressions, analyzer, and GitNexus detect-changes.

## Risks And Mitigations

- Risk: JSON becomes a hidden programming language.
  - Mitigation: finite strategy ids only.
- Risk: `dingCount` is confused with classical `定算`.
  - Mitigation: result metadata names the classical mapping and whether equality is proven.
- Risk: Fu Ying Jing or Tao Jin Ge outputs are invented.
  - Mitigation: `needsAuthoritativeVectors` plus discussion gates.
- Risk: immediate async conversion creates unrelated churn.
  - Mitigation: built-in synchronous registry first; async profile repositories later.
- Risk: fixed solstice dates remain hidden in implementation.
  - Mitigation: route dun resolution through `SolarTermProvider`.

## Review Update

The earlier gStack review accepted a foundation-only scope and approved converting all calculator methods to `Future<PanDataModel>`. That review is superseded by this design because the user selected option C and requested four-tradition extensibility.

Updated recommendation:

- Implement a synchronous built-in registry first.
- Implement the full Jing Mirror and Tong Zong four-count path in this change.
- Include Fu Ying Jing and Tao Jin Ge as first-class but vector-gated profiles.
- Split remote/profile repository async loading into a later change if still needed.
