# UI/UX Design Contract — Deity Editor (Task 31)

Owning agent: UI/UX Designer Agent
File: `lib/pages/deity_editor_page.dart`
Visual system: TaiYi Classic Ink-Wash (existing `lib/theme/taiyi_classic_theme.dart`)
Width target: phone-first 375pt; chips wrap on larger tablet widths.

## 1. Information Architecture (top → bottom)

```
AppBar  [darkWood / paleGold]
  ├── Title:  "星神编辑器" (existing) | "新建星神" (new)
  └── Action: 保存 (Icon.save) | progress spinner while saving
                                  | disabled when official read-only

ScrollView
  ├── [if read-only] OfficialReadOnlyBanner
  │     ├── Lock icon
  │     ├── Heading:   "这是官方星神，只能查看。"
  │     ├── Helper:    "若需修改请先复制为我的星神。复制后会自动生成传承链。"
  │     └── CTA button (cinnabar fill / paleGold text): "复制并编辑"
  │
  ├── Section: 基础信息
  │     └── InkyBorder
  │         └── TextField  name
  │
  ├── Section: 显示样式
  │     └── InkyBorder
  │         ├── Color preview swatch (36x36) + HEX TextField
  │         ├── Curated 9-color palette (4x4pt swatches, selected = cinnabar
  │         │   border + white check icon, unselected = inkBlack 0.3 border)
  │         └── Dropdown "显示样式"   options: 古典/现代/水墨/朱印/金箔 + 未指定
  │
  ├── Section: 适用流派        (helper: "为空则适用所有流派")
  │     └── InkyBorder
  │         └── Wrap of multi-select chips, one per real School from
  │             SchoolViewModel.schools
  │
  ├── Section: 适用盘型        (helper: "为空则适用所有盘型")
  │     └── InkyBorder
  │         └── Wrap of multi-select chips: 年家 / 月家 / 日家 / 时家 / 刻家（预留）
  │
  └── Section: 传承链
        └── InkyBorder
            ├── (if rootOfficialId)  row  "官方根    | <id>"
            ├── (if sourceId)        row  "直接来源  | <id>"
            └── (if lineage)         Wrap of chips parsed from real
                                    deity.lineage segments,  arrow_forward icon
                                    between chips
        OR empty state:  "无传承链（根项）" in italic inkWash
```

## 2. Form Layout Rules

- All sections use the existing `ChineseSectionHeader` + `InkyBorder`
  wrapper for visual continuity with the school editor and the deity
  management dialog.
- Vertical rhythm: 24pt between section headers, 12-16pt internal padding
  inside `InkyBorder`. Matches existing pages.
- Section headers carry the cinnabar→inkWash vertical bar from
  `ChineseSectionHeader` — accent never shifts between pages.
- Save action stays in the AppBar (right side), never duplicated inline,
  to prevent two competing primary CTAs (`primary-action` rule).

## 3. Enumerated-Selector Interaction

### 3.1 Multi-select chips (schools + chart types)
- Minimum hit area **44pt** (constrained via `BoxConstraints(minHeight:
  44, minWidth: 44)`), exceeding Apple HIG. Confirmed by widget test
  "Touch targets for chips meet the >=44 pt minimum".
- Selected state: 1.2px cinnabar border + 12% cinnabar fill + filled
  `Icons.check_box`.
- Unselected state: 0.8px inkWash 0.4 border + transparent fill +
  `Icons.check_box_outline_blank`.
- Read-only state (official): `onTap = null` so InkWell stays inert, icon
  + text desaturated to inkWash 0.6 — visually disabled without changing
  layout footprint.
- Helper text under both chip groups explicitly states "为空则适用所有" so
  users understand the semantics of an empty selection (matches the actual
  filter logic in `CalculatePanUseCase`).

### 3.2 Display-style dropdown
- `DropdownButtonFormField<String>` with the explicit "未指定" entry
  mapped to `null`, so users can clear a style on a derived deity.
- Read-only state inherits the disabled visual from `DropdownButtonFormField`
  (onChanged: null).

## 4. Color Picker UX

The full color-picker package is intentionally avoided to keep dependency
surface flat. Instead we ship a **two-track** picker:

1. **Curated 9-color palette** drawn from `TaiYiClassicTheme` plus two
   neighboring hues so users land on on-brand colors with one tap. Selected
   swatch is identified by a 2px cinnabar border + white check.
2. **Freeform `#RRGGBB` TextField** for power users. We accept either
   `#RRGGBB` or `RRGGBB`, and an 8-char alpha variant — out-of-range input
   silently keeps the prior color (no scary error). Length is capped at 9
   characters (`#RRGGBBAA`).

A 36×36 live preview sits to the left of the HEX field so the value and
its rendered color are seen together — no eye travel.

## 5. Lineage Display

- Lineage is **derived data only**. The contract:
  - Show `rootOfficialId` if non-null (label "官方根")
  - Show `sourceId` if non-null (label "直接来源")
  - Parse `deity.lineage` by splitting on `" -> "`, trimming each segment.
    Render as Wrap of paleGold chips with `Icons.arrow_forward` icons
    between segments.
- Hard-coded "演自/派生自/copy of" copy is **explicitly banned** by spec
  and verified in test (d). Empty state reads "无传承链（根项）" with
  italic inkWash typography to communicate "this is informational, not an
  error".

## 6. Official Read-Only Visual Contract

- Banner background: `paleGold @ 25%` fill + `goldLeaf @ 60%` 1px border —
  warm advisory tone, not alarming red.
- Lead icon: `Icons.lock_outline` (18pt, darkWood).
- Heading typography: `getTitleStyle(fontSize: 15, color: darkWood, bold)`.
- Helper line: `fontSize 13, inkWash`.
- CTA: 36pt fill button, cinnabar background + paleGold text. Cinnabar is
  the brand "活动 / 当前选中" accent (consistent with the section header
  bar and selected chip border) so users immediately recognize it as the
  primary recovery path.
- The whole "official read-only" treatment is *additive*: the form below
  still renders so the user can read each field, just non-interactively.

## 7. Feedback / Motion

- Save: button transitions to a 18pt `CircularProgressIndicator(strokeWidth:
  2)` in paleGold while `_saving = true`. Inline (in-place) so layout never
  shifts. Once persisted: SnackBar "保存成功" + `Navigator.pop` returning
  the saved deity to the caller. Duration of the spinner = real async
  await; no artificial delays.
- Copy-and-edit: same in-place spinner pattern; on success a SnackBar
  reports `"已复制为我的星神：<name>"` and the form re-hydrates without
  navigation, so the user keeps their mental context.
- Errors are reported as `SnackBar(content: Text('保存失败：$e'))` — never
  silent. Never swallowed.

## 8. Accessibility

- **Keyboard focus order** (Tab traversal): banner CTA → name field → HEX
  field → swatches (left-to-right) → display-style dropdown → school chips
  → chart-type chips → AppBar save action. This matches the visual
  top-to-bottom, left-to-right order. Verified manually by reading the
  build tree — Wrap renders in order so default focus order is correct.
- **Touch targets** ≥44pt for every chip and the copy-and-edit CTA;
  verified by widget test.
- **State by color alone is avoided**: every chip carries an icon
  (`check_box` vs `check_box_outline_blank`) in addition to the cinnabar
  fill / border. Color is reinforcing, not load-bearing.
- **Disabled vs read-only** is visually and semantically distinct:
  read-only (official) keeps text legible at full contrast but disables
  onTap and removes the AppBar save action; truly invalid actions
  (`disabled` while saving) use Flutter's built-in `enabled: false`.
- **Live announcements**: `SnackBar` is the existing Flutter
  `ScaffoldMessenger` pattern, which uses `Live`-region semantics so
  screen readers announce save success and errors.
- **Error placement** is at the bottom of the screen via SnackBar, not at
  the top of the form — appropriate for a single-screen async save.

## 9. Visual Tokens (reused from TaiYiClassicTheme)

| Token        | Used for                                |
|--------------|-----------------------------------------|
| ricePaper    | Scaffold background                     |
| darkWood     | AppBar background, section title color  |
| paleGold     | AppBar foreground, banner background    |
| goldLeaf     | banner border, lineage chip border      |
| cinnabar     | accent (selected chip, CTA, accents)    |
| inkBlack     | body text                               |
| inkWash      | secondary text, dividers, disabled text |

No new colors are introduced.

## 10. Anti-patterns explicitly rejected

| Anti-pattern                                                | Rejection rationale                                 |
|-------------------------------------------------------------|-----------------------------------------------------|
| Emoji as section icons                                      | Material icons (`Icons.lock_outline`, `Icons.copy`) |
| Placeholder-only labels                                     | All inputs carry visible `labelText`                |
| SnackBar without write                                      | Save always passes through Drift                    |
| Hard-coded "演自/派生自" lineage copy                          | Lineage parsed from `deity.lineage` only            |
| Editing official deity in place                              | Banner + disabled inputs + force copy-and-edit      |
| Two competing primary CTAs                                  | Save lives only in AppBar                           |
| Tap targets < 44pt                                          | `BoxConstraints(minHeight: 44, minWidth: 44)`       |
| Layout shift on press                                        | Color/border change only, no transform              |
| State conveyed by color alone                                | Always paired with icon (checkbox/uncheckbox)       |

— UI/UX Designer Agent (Task 31)
