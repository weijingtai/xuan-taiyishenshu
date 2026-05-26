# Subagent Report — Task 31 [Story#5][UI] 星神编辑器 UI 实现

## Role / Delegation
- Role: UI/UX Designer Agent + combined UI implementation fallback
- Source: `.ai-governance/roles/ui-ux-designer-agent.md` + Master Agent fallback
- Delegating Master: Wave 3 dispatcher
- Task: ZenTao Task 31 — 星神编辑器 UI 实现 (Story #5, parent story=8)
- Branch: `feat/ZT-12-16-taiyi-mvvm-repo` (verified, did not switch from main)
- Writable scope (this run):
  - `lib/pages/deity_editor_page.dart` (created, new file)
  - `test/integration/deity_editor_integration_test.dart` (created)
  - `test/widget/deity_editor_widget_test.dart` (created)
  - **No** modification to `lib/taiyi/data/*`, `lib/taiyi/usecases/*`,
    `lib/taiyi/taiyi_assembly.dart`, `lib/database/*`,
    `lib/widgets/deity_management_dialog.dart`,
    `lib/pages/school_manager_page.dart`,
    `lib/pages/entity_editor_page.dart`,
    `lib/pages/school_editor_page.dart`, or `lib/navigator.dart`.

## Status
**COMPLETE.** All five mandated deliverables shipped, all integration + widget
tests pass under serial flutter test, and the anti fake-completion red lines
hold (zero TODOs, zero hard-coded lineage text, zero FakeViewModel in the
integration suite, zero `skip:` in tests).

## Scope (5 mandated items)
1. **Editable fields wired to real data**
   - Name: `TextField` bound to `_nameController` → written through
     `DeityViewModel.saveDeity` → `SaveUserDeityUseCase` →
     `DriftUserRepository.saveUserDeity`.
   - Display color: curated palette + freeform HEX `TextField` with
     parser. Stored to `deity.color` as `#RRGGBB`.
   - Display style: `DropdownButtonFormField<String>` over a fixed enum
     `[classical, modern, ink_wash, cinnabar_seal, gold_leaf]`. Persisted to
     `deity.displayStyle`.
   - Applicable schools: multi-select chips whose options come from
     `SchoolViewModel.schools` (real `LoadSchoolsUseCase`), persisted to
     `deity.schoolScopes`.
   - Applicable chart types: multi-select chips over
     `[year, month, day, hour, ke]`. `ke` is rendered with the spec-mandated
     "预留" label. Persisted to `deity.chartTypes`.
   - Read-only metadata: `source`, `sourceId`, `rootOfficialId`, `lineage`
     are surfaced directly from the loaded `DeityDefinition` — never
     synthesized.

2. **Save through the real ViewModel → UseCase → Repository chain**
   - `_onSavePressed()` resolves the `DeityViewModel` from the nearest
     `Provider`, calls `viewModel.saveDeity(updated)`, which delegates to
     `SaveUserDeityUseCase` → `DriftUserRepository.saveUserDeity`, persisting
     into the Drift `userDeities` table.
   - On success: success `SnackBar` + `Navigator.pop(updated)` so callers
     (Dialog / list page) can refresh.
   - On missing Provider or empty name: error `SnackBar` is shown and no
     write is attempted (test case (e) asserts this).
   - There is no `Future.delayed` / fake-save short-circuit.

3. **Official deities are immovable in-place**
   - When `deity.source == 'official'`, every input is disabled (`enabled:
     false`), the AppBar save button's `onPressed` is `null`, and a banner
     reading `"这是官方星神，只能查看。若需修改请先复制为我的星神。"` is rendered.
   - The banner exposes a **「复制并编辑」** button keyed
     `deity_editor_copy_and_edit_button` which calls the existing
     `CopyDeityUseCase` through `DeityViewModel.copyDeity`. The Drift write
     happens inside the UseCase; the editor then replaces its bound
     `_editing` deity with the freshly persisted copy and re-hydrates the
     form so the user is now editing a user-owned derivative.

4. **Lineage rendered from real data only**
   - `_LineageSection` reads `deity.sourceId`, `deity.rootOfficialId`, and
     splits `deity.lineage` on `" -> "`. The chain is rendered as labeled
     chips with arrow icons between them.
   - **Zero hard-coded lineage strings.** The regression `rg "演自|copy
     of|从.*复制" lib/pages/deity_editor_page.dart` returns only one match —
     a documentation comment explicitly stating that such literals are
     forbidden.
   - When `lineage`, `sourceId`, and `rootOfficialId` are all null (e.g. an
     official root or a brand-new user deity), the section renders the
     spec-mandated empty state `"无传承链（根项）"` (key
     `deity_editor_lineage_empty`).

5. **Real persistence tests**
   - `test/integration/deity_editor_integration_test.dart` (5 cases, all
     green) drives the editor through the real `TaiYiDataAssembly.test`
     wiring with `TaiYiDatabase.memory()` and `OfficialJsonSchoolRepository`
     bound to the on-disk asset JSON.
   - Case (a): official `taiYi` is opened read-only; tapping "Copy and edit"
     writes exactly one row to the Drift user table and the editor switches
     to the editable derivative.
   - Case (b): seeded user deity is edited (name, color via swatch,
     schoolScopes, chartTypes toggled), saved, then **read back from a
     freshly constructed `DriftUserRepository(db)` against the same DB
     instance**. Every field value is asserted exact, including the toggle
     sequence `{} → {year} → {year, month} → {month}`. Lineage from the
     CopyDeityUseCase is preserved through save.
   - Case (c): a pre-persisted user deity with full `chartTypes`,
     `schoolScopes`, `color`, `displayStyle`, `sourceId`, `rootOfficialId`,
     and `lineage` is loaded into a fresh editor; every form widget is
     asserted hydrated and the lineage chain Wrap contains the literal
     persisted segments.
   - Case (d): official root deity (no lineage) renders the empty-state
     widget, and the page text never contains `"演自"` or `"派生自"`.
   - Case (e): saving with no `Provider` ancestor surfaces an error
     `SnackBar` and the Drift user table stays empty — proving the editor
     never bypasses the VM/UseCase chain.
   - `test/widget/deity_editor_widget_test.dart` (4 cases, all green)
     covers pure-UI shape: official read-only mode, user editable mode,
     lineage chip rendering without hard-coded text, and chip touch target
     ≥44pt.

## Evidence (all green)

```
$ flutter analyze lib/pages/deity_editor_page.dart \
    test/integration/deity_editor_integration_test.dart \
    test/widget/deity_editor_widget_test.dart
Analyzing 3 items...
   info • The imported package 'provider' isn't a dependency ...
   info • The imported package 'plugin_platform_interface' ...
   info • The imported package 'provider' ...
   info • The imported package 'shared_preferences' ...
   info • The imported package 'provider' ...
5 issues found.    # all info-level only — same as existing files in repo

$ flutter test test/widget/deity_editor_widget_test.dart
+4: All tests passed!

$ flutter test test/integration/deity_editor_integration_test.dart
+5: All tests passed!

$ flutter test --concurrency=1
+160: All tests passed!
```

Anti fake-completion regex checks (all pass — only doc-comment occurrences):

```
$ rg "TODO|FIXME|placeholder|即将开放|待调整|assume existing data" \
    lib/pages/deity_editor_page.dart \
    test/integration/deity_editor_integration_test.dart
# Only matches: 2 doc-comment uses of the word "placeholder" in
# lib/pages/deity_editor_page.dart describing the spec-reserved `ke`
# chart type and the default-template-for-new-deity placeholder. No
# product placeholders, no TODOs.

$ rg "skip:" test
# 0 matches

$ rg "演自|copy of|从.*复制" lib/pages/deity_editor_page.dart
# Only match: 1 doc comment in _LineageSection that explicitly forbids
# such literals. No emitted UI text.

$ rg "FakeViewModel" test/integration/deity_editor_integration_test.dart
# Only matches: 2 doc-comment references stating the file is FakeViewModel-free.
```

## Result vs QA punch list

| QA item | Status |
|---|---|
| 1. 名称/颜色/样式/适用流派/适用盘型 真实可编辑                  | yes |
| 2. 保存调用 ViewModel→UseCase→DriftUserRepo 写入 Drift,刷新 UI | yes |
| 3. 传承链来自真实 sourceId/rootOfficialId/lineage,无硬编码      | yes |
| 4. 官方星神不可原地修改,编辑必须复制为用户派生                  | yes |
| 5. widget + integration 测试,保存后重新加载仍存在               | yes |

## Risk / Required follow-ups

- **Navigation wire is unowned by me.** I do not modify `lib/navigator.dart`
  per scope rules. **Master Agent must wire the route** as:
  - Route name: `DeityEditorPage.routeName == '/taiyishenshu/deity-editor'`
  - Push pattern:
    ```dart
    Navigator.of(context).pushNamed(
      DeityEditorPage.routeName,
      arguments: DeityEditorArgs(deity: someDeity),
    );
    ```
    or equivalent typed `Navigator.push(MaterialPageRoute(builder: (_) =>
    DeityEditorPage(deity: someDeity)))`.
  - Entry points expected to invoke this:
    1. `DeityManagementDialog` long-press / edit button on a deity chip
       (Task 15) — currently routes to the legacy `EntityEditorPage`; needs
       redirection.
    2. The "我的" list section in the same dialog — edit button on a user
       deity.
    3. School manager page when (later) it exposes a "私有星神" sub-area.
  - The page expects `DeityViewModel` and `SchoolViewModel` reachable via
    `Provider` ancestors. `TaiYiPanController` already exposes both, so a
    `ChangeNotifierProvider<DeityViewModel>.value(value:
    controller.deityViewModel)` wrap at the route push site is sufficient.

- **Legacy `lib/pages/entity_editor_page.dart`** still contains a no-op
  save branch for the deity case. Master may choose to (a) delete it once
  every call site is migrated to `DeityEditorPage` / `SchoolEditorPage`, or
  (b) replace its body with `Navigator.pushReplacementNamed` to the new
  route. Out of scope for this task.

- **Provider declared transitively only.** The project's existing pages
  (`taiyi_pan_page.dart`, `school_manager_page.dart`,
  `deity_management_dialog.dart`) already import `package:provider/provider.dart`
  while it is only present in `pubspec.lock` as a transitive dep. Repo
  convention is to suppress the `depend_on_referenced_packages` info
  warning, which my files inherit. If the team wants this tightened, the
  fix is a one-line addition under `dependencies:` in `pubspec.yaml`.

- **`ke` chart type** is intentionally shown with the label "刻家（预留）"
  per the product spec. No algorithm support is implied; the chip just
  writes the string `"ke"` into `chartTypes`.

## Next Action
Hand back to Master for:
1. Routing wire (`/taiyishenshu/deity-editor`) in `lib/navigator.dart` and
   call-site redirection from `DeityManagementDialog`.
2. ZenTao Task 31 status update to "Resolved" pending QA re-verification
   against this report's Evidence section.

— UI/UX Designer Agent (Task 31)
