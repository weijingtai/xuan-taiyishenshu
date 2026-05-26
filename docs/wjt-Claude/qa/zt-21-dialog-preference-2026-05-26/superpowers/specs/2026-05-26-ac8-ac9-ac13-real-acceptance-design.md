# AC8 / AC9 / AC13 真实验收设计规格

## 元信息
- 创建日期: 2026-05-26
- 状态: 已锁定 (RBDDS 子代理: SPEC 即合约, 不需要等用户批准, 见任务派发说明)
- 关联需求: ZenTao Task #21 (QA-5 [QA打回：Dialog 与偏好验收不完整])
- AC 源文件: `docs/superpowers/specs/2026-05-23-taiyi-school-manager-mvp-design.md` 第 345-413 行
- 判定依据: `docs/wjt-Claude/qa/zt-17-ac-matrix-2026-05-26/AC_TEST_MATRIX.md` (AC8 PARTIAL → 目标 PASS; AC9 NOT_COVERED → 目标 PASS; AC13 MANUAL_PENDING → Flutter 层目标 PASS, Playwright 留给 ZT-25)

## 目标

1. **AC9 推到 PASS (Flutter 层)**: 验证勾选/取消星神后, `panData.palaces` 中该星神的标记实际出现/消失, 不只是 SP 写入或 ViewModel state.
2. **AC9 重启恢复**: 设置偏好 → 销毁 Controller → 用同一 SP 重建 → 偏好被恢复且 `panData` 反映该偏好.
3. **AC8 增强**: 验证 Dialog 三区结构完整 (系统内置/我的/Marketplace), 不可用项 `Checkbox.onChanged == null` 且有具体中文原因文本 (反 lock-only 红线).
4. **AC13 双向**:
   - 隐藏核心星神 (太乙/文昌/计神/始击/jiShen) → 主页面 Banner 出现.
   - 隐藏非核心星神 (青龙/朱雀/白虎...) → Banner **不**出现 (反 false-positive).
   - 恢复勾选核心 → Banner 消失.
5. **修复 `setDeityVisibility` toggle-vs-set 漏洞**: 当前实现忽略 `visible` 参数, 调用 toggle, 与本地 cache 可能脱钩. 修复后 SP 与 cache 同步, 重复调用幂等.
6. **修复 `_buildBuiltInItems` 无视偏好的硬塞行为**: 通过新增 `hiddenDeityIds` 参数 (默认空, 向后兼容), 让 hidden 的核心 deity 不被加入 `placedItems`, 这是 AC9 PASS 的算法层基础.

## 非目标

- **不做** Playwright 页面层 (留给 ZT-25).
- **不做** AC14 多流派切换 (ZT-21 任务范围外).
- **不改** Dialog UI 视觉风格 (已存在 ChineseSectionHeader/InkyBorder, 不动).
- **不改** Repository / UseCase 接口签名 (现有 `DeityPreferenceRepository.setEnabled(id, enabled)` 已足够).
- **不修** `_buildBuiltInItems` 函数签名 (CRITICAL 风险, 11 个上游). 改为在 `_calculate` 调用之后过滤 `placedItems`.
- **不动** `lib/database/*` schema, `lib/navigator.dart`, `lib/pages/school_*.dart`, `lib/pages/entity_*.dart`, `assets/`, `pubspec.yaml` 主依赖.
- **不替换**现有 BDD 测试; 增量补充更强的 integration 测试.

## 架构设计

### 数据流 (修改后)

```
User Tap Checkbox (deity_management_dialog)
  ↓
controller.setDeityVisibility(deityId, visible)
  ├── _localVisibilityCache[deityId] = visible        ← cache 与参数对齐
  ├── deityViewModel.setDeityPreference(deityId, visible)  ← NEW: 直接 set, 不 toggle
  │     └── ToggleDeityPreferenceUseCase 改名为 SetDeityPreferenceUseCase 不可行 (signature 已被 7 个文件 import)
  │     └── 改为新增 setDeityPreference(deityId, visible) 方法到 DeityViewModel
  └── calculate(...) 触发重排盘
        ↓
        CalculatePanUseCase
          ├── 读 preferenceRepo.loadEnabledMap()  → preferenceMap
          ├── activeDefinitions = allDeities.where(preferenceMap[d.id] ?? true)
          ├── hiddenDeityIds = preferenceMap.entries.where(!enabled).map(id).toSet()
          └── calculator.calculateWithConfig(definitions: activeDefinitions,
                                             hiddenDeityIds: hiddenDeityIds, ...)  ← NEW 可选参数
                ↓
                _calculate(...)
                  ├── builtInItems = _buildBuiltInItems(...)  ← 未改, 仍然全量
                  ├── engineItems  = engineResults...         ← 已经按 definitions 过滤
                  ├── placedItems  = [...builtInItems, ...engineItems]
                  └── placedItems = placedItems.where(item =>
                        !_isItemHidden(item, hiddenDeityIds))  ← NEW: 过滤
                  └── palaces = _buildPalaces(items: placedItems)
```

### `_isItemHidden` 映射规则

内置 item 的 id 形如 `builtIn:taiYi`, `builtIn:wenChang`, `builtIn:jiShen`, `builtIn:shiJi`. 引擎 item 的 id 形如 `engine:taiYi`. 我们提取冒号后第一段 → deity id, 命中 `hiddenDeityIds` 则过滤. 八门 / 主算 / 客算 / 天盘其他星神 不属于"用户偏好可隐藏的星神", 不参与过滤 (保留盘面其它元素).

允许过滤的 prefix 集合: `builtIn:` 后跟以下 ID 之一: `taiYi`, `wenChang`, `jiShen`, `shiJi`. 加上所有 `engine:` 开头的 item.

### AC13 核心星神集合

`TaiYiPanController.showHiddenWarning` 已使用 `['taiYi', 'wenChang', 'shiJi', 'jiShen']`. 保留. 增量: 测试覆盖非核心 (例如 `qingLong`) 隐藏 **不**触发 banner.

## 数据流 (典型测试场景)

**Scenario AC9-A: 取消 wenChang → panData 中"文昌"消失**
```
SharedPreferences.setMockInitialValues({})
assembly = TaiYiDataAssembly.test(prefs: prefs, db: TaiYiDatabase.memory(), bundle: realBundle)
controller = TaiYiPanController(assembly)
await controller.loadSchools()
await controller.calculate(dateTime: 2024-06-01, schoolId: 'jingMirror', chartType: year)
// 前置: 盘面包含 文昌
expect(_allPalaceNames(controller.panData!), contains('文昌'))
await controller.setDeityVisibility('wenChang', false)
// 后置: SP 已写入 false; panData 中"文昌"已经消失
expect(await assembly.preferenceRepo.isEnabled('wenChang'), isFalse)
expect(_allPalaceNames(controller.panData!), isNot(contains('文昌')))
```

**Scenario AC9-B: SP 重建后状态恢复**
```
prefs = await SharedPreferences.getInstance()  // mock
assembly1 = TaiYiDataAssembly.test(prefs: prefs, db: db, bundle: bundle)
controller1 = TaiYiPanController(assembly1)
await controller1.loadSchools()
await controller1.calculate(...)
await controller1.setDeityVisibility('junJi', false)
// 销毁 controller1, 重建 assembly + controller, 同一 SP 同一 db
assembly2 = TaiYiDataAssembly.test(prefs: prefs, db: db, bundle: bundle)
controller2 = TaiYiPanController(assembly2)
await controller2.loadSchools()
await controller2.calculate(...)
// 偏好被持久化
expect(controller2.isDeityVisible('junJi'), isFalse)
expect(_allPalaceNames(controller2.panData!), isNot(contains('君基')))
```

**Scenario AC13 逆向: 隐藏非核心不触发**
```
await controller.setDeityVisibility('qingLong', false)
expect(controller.showHiddenWarning, isFalse)
```

## 技术决策

### TD-1: `_buildBuiltInItems` 改造方式

**选项 A**: 改函数签名增 `hiddenDeityIds` 参数. ← CRITICAL impact, 11 个上游 (regression tests 会断). PASS.

**选项 B**: 在 `_calculate` 末尾过滤 `placedItems`. ← 局部改动, 函数签名不变, 上游 0 风险.

**选择 B**, 并在 `_calculate`/`calculateWithConfig` 新增可选参数 `hiddenDeityIds` (默认空集). regression tests 不传参 → 行为不变, 0 风险.

### TD-2: 修复 `setDeityVisibility` 的 toggle 漏洞

当前: `deityViewModel.toggleDeityPreference(id)` toggle, 与传入的 `visible` 脱钩. 重复 `setDeityVisibility(id, false)` 两次会变成 false → true.

修法: 在 `DeityViewModel` 加方法 `setDeityPreference(deityId, enabled)`, 直接调 `preferenceRepo.setEnabled(deityId, enabled)`. 调用方:`TaiYiPanController.setDeityVisibility` 改用此新方法. `toggleDeityPreference` 保留 (不破坏现有 viewmodel test).

### TD-3: 测试驱动验收文件命名

- `test/integration/zt21_visibility_panel_refresh_test.dart` (AC9 立即刷新)
- `test/integration/zt21_sp_persistence_restart_test.dart` (AC9 重启恢复)
- `test/integration/zt21_ac13_core_vs_noncore_test.dart` (AC13 双向)
- `test/widget/zt21_dialog_sections_widget_test.dart` (AC8 三区 + 不可用原因)

所有新增测试 `--concurrency=1` 全绿; 不用 `skip` / `@Skip` / Mock; 必须穿透到真 `panData.palaces`.

### TD-4: AC13 文本统一

源 SPEC 文本: "盘面解释可能不完整" (单句).
Flutter 实现: "部分基础星神或关键计算项已隐藏，盘面解释可能不完整。" (前缀 + SPEC 子串).
Playwright spec (ZT-25 待执行): "盘面解释可能不完整" (与 SPEC 一致).

**决策**: Flutter 当前文本**包含** SPEC 子串, 不冲突. 测试断言用 `textContaining('盘面解释可能不完整')` (而不是 `'部分基础星神或关键计算项已隐藏'`), 这样 Flutter / Playwright / SPEC 三方对齐. 现有 BDD 测试 `hidden_reminder_test.dart:34` / `deity_visibility_bdd_test.dart:44` 用了 `'部分基础星神或关键计算项已隐藏'`, **不**改它们 (避免回归), 只在新增测试统一用 SPEC 子串.

## 权衡与已知限制

- **限制 1**: 过滤 `_buildBuiltInItems` 输出依赖 ID 命名约定 (`builtIn:<deityId>`). 若未来重命名内置项 ID, 过滤会失效. 我们用常量 `_filterableBuiltInDeityIds = {'taiYi', 'wenChang', 'jiShen', 'shiJi'}` 显式枚举, 单测覆盖, 漂移会被发现.
- **限制 2**: 主算 / 客算 / 八门 / 天盘其它项 (青龙/朱雀...) 暂不通过 preference 隐藏 (它们不在 `assets/deities/*.json` 主索引中, 隐藏后落宫语义未定义). 这是 SPEC 层未规定的, 保守不动.
- **限制 3**: `showHiddenWarning` 仅检查 4 个核心 ID. 实际太乙 dial-down 应包括"主算"等更多项, 但 AC13 原文未定义, 不扩展.
- **限制 4**: 现有 BDD test `deity_visibility_bdd_test.dart` 测试取消 taiYi 后 banner 出现, 但 **没有**测试 banner 文本对应的盘面文字消失. 我们补 AC9 integration 测试.

## 验收条件

每条 `[ ]` 独立可验证. 100% 勾选才算 B2 通过.

### AC8 (Dialog 三区 + 置灰原因)
- [ ] AC8.1 Dialog 渲染时, 文本"系统内置"、"我的星神"、"Marketplace" 各 findsOneWidget. 测试: `zt21_dialog_sections_widget_test.dart::AC8_1`
- [ ] AC8.2 Marketplace 占位 (`ValueKey('marketplace-placeholder')`) findsOneWidget, 且其外层 `AbsorbPointer.absorbing` 为 true (不可交互). 测试: `zt21_dialog_sections_widget_test.dart::AC8_2`
- [ ] AC8.3 我的星神区初始为空时, `ValueKey('my-deities-empty')` findsOneWidget. 测试: `zt21_dialog_sections_widget_test.dart::AC8_3`
- [ ] AC8.4 在 chartType=year + schoolId=jingMirror 下, 至少一个不可用星神 (青龙旗) 的 `Checkbox.onChanged == null`, 且其 ListTile 有 `ValueKey('deity-unavailable-reason')` 文本节点且文本不等于"未知". 测试: `zt21_dialog_sections_widget_test.dart::AC8_4`
- [ ] AC8.5 至少 30 个 source=='official' 星神被加载, 验证三区数据驱动而非硬编码. 测试: `zt21_dialog_sections_widget_test.dart::AC8_5`

### AC9 (勾选 → 盘面落宫立即出现/消失)
- [ ] AC9.1 排盘后 `panData.palaces` 至少有一个 item.name == "文昌"; `setDeityVisibility('wenChang', false)` 后 `panData.palaces` 中所有宫 items.name 都不再含 "文昌". 测试: `zt21_visibility_panel_refresh_test.dart::AC9_1_wenChang`
- [ ] AC9.2 同上, 用 `junJi` (君基): 取消后 panData 不含 "君基"; 恢复后 "君基" 重新出现. 测试: `zt21_visibility_panel_refresh_test.dart::AC9_2_junJi_round_trip`
- [ ] AC9.3 重复调用 `setDeityVisibility('wenChang', false)` 两次, SP 中 wenChang 仍为 false, panData 中仍无文昌 (幂等性, 防止 toggle 漏洞回归). 测试: `zt21_visibility_panel_refresh_test.dart::AC9_3_idempotent`

### AC9 SharedPreferences 重启恢复
- [ ] AC9.4 (重启恢复) 用同一 mock SP + 同一内存 DB, 销毁 controller1 → 重建 assembly2 + controller2; `controller2.isDeityVisible('junJi')` 为 false; `controller2.panData` 不含 "君基". 测试: `zt21_sp_persistence_restart_test.dart::AC9_4_restart_recovery`
- [ ] AC9.5 (重启恢复+重做盘) 在 controller2 中调用 `setDeityVisibility('junJi', true)` 恢复 → panData 重新出现 "君基" → SP 写入 true. 测试: `zt21_sp_persistence_restart_test.dart::AC9_5_restart_then_restore`

### AC13 (核心隐藏阈值 + 文本统一)
- [ ] AC13.1 隐藏 `taiYi` (核心) → `controller.showHiddenWarning == true`; Pan Page 渲染后含 `textContaining('盘面解释可能不完整')`. 测试: `zt21_ac13_core_vs_noncore_test.dart::AC13_1_core_triggers`
- [ ] AC13.2 隐藏 `qingLong` (非核心) → `controller.showHiddenWarning == false`; Pan Page 不含警告文本. 测试: `zt21_ac13_core_vs_noncore_test.dart::AC13_2_noncore_silent`
- [ ] AC13.3 隐藏 `taiYi` → 恢复 `taiYi` → Banner 消失 (`showHiddenWarning == false`, Pan Page 不含警告). 测试: `zt21_ac13_core_vs_noncore_test.dart::AC13_3_restore_clears`

### 反伪完成 + 自测门禁
- [ ] G1 `flutter analyze lib/ test/` 零 warning (info-level 容许并列出).
- [ ] G2 `flutter test --concurrency=1 test/integration/zt21_* test/widget/zt21_*` 全部 PASS, 无 stderr 异常.
- [ ] G3 反伪扫描 4 条 rg 全部通过 (见报告章节).
- [ ] G4 `npx gitnexus detect-changes` 仅显示本 SPEC 范围内被改的符号; 无意外漂移.

## 变更记录

| 日期 | 修订 | 说明 |
|---|---|---|
| 2026-05-26 | v1.0 | 初稿. RBDDS 子代理由 Master 派发, SPEC 直接锁定. |

## 影响分析 (GitNexus 摘要)

记录每个被改符号的 `gitnexus_impact` 结果, HIGH/CRITICAL 已采取规避策略.

| 符号 | 上游数 | 风险 | 规避策略 |
|---|---|---|---|
| `TaiYiPanController.setDeityVisibility` | 2 (hidden_reminder_test, deity_dialog_integration_test) | LOW | 保留参数签名, 只改内部实现 (从 toggle → set), 现有测试断言"设置后 isVisible/SP 状态" 仍 PASS |
| `TaiYiPanController` (Class) | 21 (20 direct, 7 processes) | CRITICAL | **不改公开 API**, 仅在内部实现修复. 不增/不删字段, 只在 setDeityVisibility 内部换调用 |
| `_buildBuiltInItems` | 11 (regression tests + calculateWithConfig + calculateWithCustomDeities) | CRITICAL | **不改签名**. 在 `_calculate` 末尾新增过滤步骤; 新增 `hiddenDeityIds` 通过 `_calculate`/`calculateWithConfig` 的可选参数传入 (默认空集, 上游不传参 = 行为不变) |
| `CalculatePanUseCase.call/execute` | MEDIUM (9 direct) | MEDIUM | 内部已经加载 `preferenceMap`, 我们多 build 一个 `hiddenDeityIds` 集合传给 calculator; 公开签名不变 |
| `DeityViewModel` 新增方法 `setDeityPreference(id, enabled)` | 新 API, 0 上游 | LOW | 纯增量, 不动现有 `toggleDeityPreference` 以保证现有 viewmodel test PASS |

详细输出已记录在 SELF.md 附录及随附状态文件 `tmp/task_21_state.json` 的 `gitnexus_impact_summary` 字段.
