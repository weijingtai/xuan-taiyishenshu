# Taiyi Shenshu Algorithm Regression Report

**Date:** 2026-06-07
**Branch:** `storage-refactor/taiyishenshu`
**Status:** Deviations Found

## 1. Overview
A full regression was performed on the `TongZong` (统宗) and `JiCheng` (集成) algorithm systems across all four chart types (Year, Month, Day, Hour). `JingMirror` (金镜) was also included as a control.

The regression verified:
- Accumulated numbers (`sequenceIndex`)
- Ju numbers (`juNumber`)
- Dun types (`dunType`)
- Main/Guest Fixed counts (`hostCount`, `guestCount`, `dingCount`)
- Key board fields (`taiYiPalace`, `wenChangPalace`)

## 2. Regression Results (Summary of Deviations)

| School | Chart Type | Status | Key Deviations |
| --- | --- | --- | --- |
| **TongZong** | Year | **PASS** | Matches code behavior and authoritative vectors. |
| | Month | **FAIL** | `dingCount`: Actual 25 vs Expected 12. |
| | Day | **FAIL** | `hostCount`: Actual 32 vs Expected 31. |
| | Hour | **FAIL** | `hostCount`: Actual 34 vs Expected 27. |
| **JiCheng** | All | **BASELINE** | Baseline established for all chart types (see Appendix). |
| **JingMirror**| Hour | **FAIL** | `hostCount`: Actual 22 vs Expected 15. |

## 3. Findings & Evidence

### A. Missing `chartConfigs` in Asset JSONs
The refactored schools in `assets/schools/*.json` are missing critical `chartConfigs` which define `dayOffset`, `hourOffset`, and `zhangSui`/`zhangYue`.
- **Evidence:** `cat assets/schools/tong-zong.json` shows no `chartConfigs` block.
- **Impact:** Any usage of the new `OfficialJsonSchoolRepository` to drive calculations (e.g., via `calculateWithConfig`) will result in incorrect accumulated numbers for Month/Day/Hour. The current `calculate()` method only passes because it still uses hardcoded defaults.

### B. `correction` Value Mismatch
- **Evidence:** `lib/taiyi/taiyi_pan_calculator.dart` uses `correction: 1` for `tongZong` and `jiCheng` in `_defaultSchoolConfig`. However, `assets/schools/tong-zong.json` and `assets/schools/ji-cheng.json` specify `correction: 0`.
- **Impact:** Switching to asset-based configuration will cause a -1 shift in `accumulatedYear` for these schools, breaking regression for all years.

### C. Host/Guest/Ding Count Discrepancies
Several non-year charts show deviations in Host/Guest/Ding counts despite having the correct `juNumber` and `sequenceIndex`.
- **Evidence:** 
    - `TongZong` Month: `dingCount` actual `25` vs expected `12`.
    - `JingMirror` Hour: `hostCount` actual `22` vs expected `15`.
- **Root Cause Analysis:** The `_walkAndSumWithDetail` logic or the sixteen-god sequence used in the engine does not perfectly align with the specific "authoritative source" vectors for non-year charts. This suggests missing chart-type specific calculation rules.

## 4. Minimal Fix Recommendations

1.  **Sync Asset JSONs with Hardcoded Configs:**
    - Update `assets/schools/jing-mirror.json` and `assets/schools/tong-zong.json` to include the `chartConfigs` block currently hardcoded in `lib/taiyi/taiyi_pan_calculator.dart`.
    - Update `assets/schools/tong-zong.json` and `assets/schools/ji-cheng.json` to use `correction: 1`.

2.  **Audit `HostGuest` Logic for Non-Year Charts:**
    - Investigation needed to confirm if the `_walkAndSum` loop should include or exclude the start/end positions differently for Month/Day/Hour charts, or if the palace numbers (`_hostGuestPalaceNumber`) differ in those contexts.

## 5. Appendix: Jicheng Baseline (2026-05-23 08:25)
- **Year:** AccumYear 343, Ju 55, Taiyi Gen, Wenchang Kun.
- **Month:** SeqIndex 4110, Ju 6, Taiyi Kun, Wenchang Qian.
- **Day:** SeqIndex 125055, Ju 63, Taiyi Li, Wenchang Kan.
- **Hour:** SeqIndex 1500664, Ju 40, Taiyi Kan, Wenchang Zhen.
