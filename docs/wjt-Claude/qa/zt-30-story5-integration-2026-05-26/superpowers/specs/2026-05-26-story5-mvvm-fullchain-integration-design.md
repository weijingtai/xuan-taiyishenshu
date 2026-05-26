# SPEC: Story #5 MVVM+UseCase+Repository 全链路整合验证 (ZT-30)

- **任务**: ZenTao Task #30 — [Story#5][Integrate] MVVM+UseCase+Repository 全链路整合
- **状态**: 草稿 → 评审 → 已批准 (本 SPEC 在子代理派发模式下由 Master 默批，subagent 严格按交付物范围实施)
- **日期**: 2026-05-26
- **执行人**: ClaudeCode-subagent
- **基线分支**: `feat/taiyi-zt-claudecode-claim`
- **依赖**: ZT-21 (已打通 setDeityVisibility → 盘面刷新)、ZT-17 (AC 矩阵基线)
- **互斥**: 与 ZT-25+10 并行，本 SPEC 严禁触碰 `lib/widgets/*.dart` 与 `lib/pages/*.dart`

---

## 1. 背景

Story #5 (太乙管理系统：全链路整合与星神/流派编辑器实现) 要求将 UI 与 ViewModel、UseCase、Repository 完整打通，实现数据闭环。在 ZT-21 完成 "勾选星神→ panData.palaces 立即更新" (AC8/AC9/AC13) 之后，Story #5 仍剩下若干 PARTIAL 整合点，集中在 AC 矩阵的 **AC3 / AC7 / AC10 / AC11 / AC12** 上，需要新的集成测试覆盖。

本 SPEC 的目标不是修改业务逻辑（链路已存在），而是**用真实组件穿透的集成测试**证明 Story #5 的整合在 Drift+SharedPreferences+OfficialJsonRepo+全 UseCase+ViewModel 链路上真正闭环。

## 2. 范围

### 包含

1. **AC3/AC11 收尾**: 编辑保存 → 列表刷新 → 重建 ViewModel/Controller 后状态仍存在 (跨 ViewModel + 真 Drift)。
2. **AC10 (schoolScopes 过滤)**: 真盘 (jingMirror) + Drift 用户星神 (schoolScopes=['jiCheng']) 同盘表现 — 该星神在 jingMirror 上**不应**出现 (AC 矩阵明确缺失项)。
3. **AC12 (多级 lineage)**: 用户星神 A 派生 B 派生 C 后，C.lineage 包含全链路；rootOfficialId 始终指向最初官方源。
4. **AC7 (UI→VM→UseCase→Repo→盘面 recompute) happy path**: 用户复制流派 → 改 epochYear → 保存 → 切换流派 → panData.accumulatedYear 真变化 (跨 ViewModel + Controller，单一测试)。
5. **AC10 (用户副本 + 官方同盘共存)**: 用户星神 B 派生自官方 wenChang，schoolScopes=['jingMirror']，应与官方 wenChang **同时**出现在 jingMirror 年盘上 (不是覆盖，是并列)。

### 不包含

- ZT-21 已 PASS 的 AC8/AC9/AC13 不复测 (会引用 ZT-21 测试名作证)。
- Playwright 页面层 (ZT-25 范围)。
- `lib/widgets/*.dart` 或 `lib/pages/*.dart` 修改 (互斥)。
- `taiyi_pan_calculator.dart` 修改 (ZT-21 已动)。
- 数据库 schema 变更。

## 3. 设计

### 3.1 整合链路 (现状审计)

```
DeityEditorPage / SchoolEditorPage
  ↓ (Provider tree, navigator.dart 提供 VM 注入)
DeityViewModel / SchoolViewModel
  ↓ (持有 UseCase 引用)
SaveUserDeityUseCase / SaveUserSchoolUseCase / CopyDeityUseCase / CopySchoolUseCase
  ↓ (依赖 SchoolRepository / DeityRepository 接口)
DriftUserRepository (用户) + OfficialJsonSchoolRepository (官方) + SharedPreferencesDeityPreferenceRepository (偏好)
  ↓ (绑定真 SQLite + 真 SP)
TaiYiDatabase / SharedPreferences

CalculatePanUseCase
  ↓ (依赖 MultiSchoolRepository + DeityPreferenceRepository)
TaiYiPanCalculator → PanDataModel (palaces 含 PanComputedItem)
```

**现状结论**: 链路已完整 (assembly.dart 第 50-83 行注入完成)，无需新代码即可工作。本任务用集成测试**穿透验证**链路真实可达。

### 3.2 测试矩阵

| 测试 ID | AC | 链路 | 关键断言 |
|---|---|---|---|
| `zt30_fullchain_school_save_recompute` | AC3/AC7/AC11 | SchoolViewModel.copySchool → save → controller.calculate | 改 epochYear 后 accumulatedYear 真变化 |
| `zt30_fullchain_deity_save_reload` | AC3/AC7/AC10 | DeityViewModel.copyDeity → save → loadDeities → controller.calculate | 用户星神出现在 panData 中 |
| `zt30_school_scope_filter` | AC10 | 用户星神 schoolScopes=['jiCheng'] + jingMirror 盘 | 该星神不在 panData.palaces.items |
| `zt30_multilevel_lineage` | AC12 | CopyDeityUseCase 链式: official→A→B | B.lineage 含 'official(taiYi)' + 'user_a_xxx' + 'user_b_xxx'; rootOfficialId 始终 'taiYi' |
| `zt30_official_user_coexist` | AC10 | 用户副本 schoolScopes=['jingMirror'] + 官方 wenChang | 同盘共存，两个 name 都在 |
| `zt30_repo_interface_only` | AC5 | 验证 ViewModel 字段类型 (反射/runtime) | usecase 字段是接口类型 |

### 3.3 反伪完成红线 (本 SPEC 强制)

- **无 Fake/Mock**: 测试必须使用 `TaiYiDatabase.memory()` + 真 `DriftUserRepository` + 真 `OfficialJsonSchoolRepository` (通过 MockAssetBundle 读真 assets) + 真 `SharedPreferencesDeityPreferenceRepository`。
- **无 `skip:`**: 任何 `skip:true` 或 `@Skip` 自动判 FAIL。
- **断言到产品代码路径**: 不准 `expect(true, isTrue)` 或 `expect(mock.calls.length, 1)`，必须断言到 `controller.panData!.palaces` 的具体内容、`reloaded.lineage` 的具体字符串、`accumulatedYear` 的具体 int。
- **断言用户星神出现在盘面**: 不依赖"loadDeities 返回多少行"，必须 `panData.palaces.expand(items).any((i) => i.name == X)`。

## 4. 验收条件

### AC30.1 — 流派编辑→保存→盘面重算 (AC3/AC7/AC11 收尾)

- [ ] 测试 `zt30_fullchain_school_save_recompute` 跑通
- [ ] 通过 `SchoolViewModel.copySchool` 真实在 Drift 写入用户副本
- [ ] 通过 `SchoolViewModel.saveSchool(updated)` 真实更新副本 epoch
- [ ] 切换到副本后 `controller.calculate(schoolId: copyId)` → `panData.accumulatedYear` 与原 jingMirror 不同
- [ ] 重建 TaiYiPanController (复用同 db+prefs) 后副本仍可加载

### AC30.2 — 星神编辑→保存→盘面包含 (AC3/AC7/AC10 收尾)

- [ ] 测试 `zt30_fullchain_deity_save_reload` 跑通
- [ ] `DeityViewModel.copyDeity(sourceId:'wenChang', newId:'user_wc_xxx')` 真实在 Drift 写入用户副本
- [ ] `controller.calculate` 后 `panData.palaces.expand(items).map(name)` 包含用户星神 name
- [ ] 重建 controller 后用户副本仍存在

### AC30.3 — schoolScopes 过滤 (AC10 关键缺口)

- [ ] 测试 `zt30_school_scope_filter` 跑通
- [ ] 用户星神 schoolScopes=['jiCheng'] 在 jingMirror 盘上**不**出现
- [ ] 切换到 jiCheng 后该星神**出现**
- [ ] 这是 AC 矩阵明确标注"未验证"的 AC10 缺口

### AC30.4 — 多级 lineage (AC12 缺口)

- [ ] 测试 `zt30_multilevel_lineage` 跑通
- [ ] 链式 copy: official taiYi → user_a_xxx → user_b_xxx
- [ ] user_b.lineage 包含两层派生标记 (含 'taiYi' 和 'user_a_xxx')
- [ ] user_b.rootOfficialId 仍是 'taiYi' (不是 'user_a_xxx')
- [ ] 持久化重建 Repository 后 lineage 字段保留

### AC30.5 — 官方+用户同盘共存 (AC10 mock-only → 真盘)

- [ ] 测试 `zt30_official_user_coexist` 跑通
- [ ] 复制 wenChang 为 user_wc_jm, schoolScopes=['jingMirror']
- [ ] jingMirror 年盘上同时包含官方 '文昌' 和用户副本 (不同 name 或 id)
- [ ] 官方 wenChang 字段未被污染 (从 OfficialJsonSchoolRepository 重读对照)

### AC30.6 — 自测门禁

- [ ] `flutter analyze lib/ test/` 新增/修改文件零 warning
- [ ] `flutter test --concurrency=1 test/integration/zt30_*.dart` 全绿
- [ ] 反伪扫描全部为空: `rg "TODO|FIXME|placeholder" test/integration/zt30_*`, `rg "skip:|@Skip" test/integration/zt30_*`, `rg "fakeAsync\\(\\(\\) async \\{\\}\\)|FakeRepository|FakeViewModel" test/integration/zt30_*`
- [ ] 真实组件扫描非空: `rg "TaiYiDatabase.memory|DriftUserRepository|CopyDeityUseCase|SaveUserSchoolUseCase|CalculatePanUseCase" test/integration/zt30_*`

## 5. 实现约束

1. 测试文件命名: `test/integration/zt30_<topic>_test.dart`
2. 复用 `_FakePathProviderPlatform` + `_MockAssetBundle` 模式 (参考 `school_management_integration_test.dart`)。
3. 复用 `TaiYiDataAssembly.test(...)` 工厂。
4. 不引入新依赖。
5. 每个测试独立 `db.close()` / `addTearDown`。
6. 不修改 lib/ 任何文件 — 链路已就绪，本 SPEC 只补测。

## 6. 风险

| 风险 | 缓解 |
|---|---|
| 测试发现 lib/ 链路实际有缺陷 | 写到 state.json 的 next_recommended_task 字段，不擅自修复 lib/ |
| ZT-21 同分支并发改 controller | 已确认 controller 修改完成，本 SPEC 不再触碰 controller |
| ZT-25 改 widgets/pages 引入冲突 | 不写入这两个目录 |

## 7. 不变量 (post-merge)

- 任何后续修改 lib/taiyi/usecases/* 后，本 SPEC 测试仍应 PASS。
- 反伪扫描红线永久生效。

## 8. 验收证据 (2026-05-26 verification run)

### 8.1 静态门禁 (PASS)

`flutter analyze lib/taiyi/ test/integration/zt30_*.dart` (29 issues, 0 error):

- ZT-30 5 个测试文件: 仅 5 条 info 级 `depend_on_referenced_packages` (path_provider_platform_interface / plugin_platform_interface / shared_preferences) — 与既有 repo 内 lib/taiyi/data/* 同类风格一致。
- lib/taiyi/: 既有 12 条 unused_element warning (taiyi_pan_calculator.dart pre-existing) + 既有 deprecation/depend_on_referenced_packages info。**未引入新 error / warning**。

### 8.2 反伪静态扫描 (PASS)

| 扫描 | 期望 | 实际 |
|---|---|---|
| `rg "TODO|FIXME|placeholder" test/integration/zt30_*` | 空 | **空 ✅** |
| `rg "skip:|@Skip" test/integration/zt30_*` | 空 | **空 ✅** |
| `rg "FakeRepository\|FakeViewModel\|fakeAsync\\(\\(\\) async \\{\\}\\)" test/integration/zt30_*` | 空 | **空 ✅** (仅 `_FakePathProviderPlatform` 是 path_provider 平台桩 + `_RealAssetBundle` 真 assets 读取, 命名以 Real 强调) |
| `rg "TaiYiDatabase.memory\|DriftUserRepository\|CopyDeityUseCase\|CalculatePanUseCase" test/integration/zt30_*` | 非空 | **5/5 文件覆盖 ✅** |

### 8.3 编译/runtime 门禁 (PASS — verified 2026-05-28)

**Upstream 阻塞已解除**: xuan-common 分支 `refactor/common-slim` 提交
`84abb34` (orphan-import 清理) 与 `66ba351` (窄化 enum re-export 打破
four_zhu_card↔xuan-common 循环) 之后，xuan-taiyishenshu 测试编译已通过。

`flutter test test/integration/zt30_*.dart` (2026-05-28):

```
00:00 +0: loading .../zt30_fullchain_deity_save_reload_test.dart
00:01 +1: ZT-30 AC30.2: 星神编辑→保存→盘面包含 fullchain_deity_save_reload: 用户复制星神→改名→保存→重新计算→panData 包含新名
00:01 +1: loading .../zt30_fullchain_school_save_recompute_test.dart
00:01 +2: ZT-30 AC30.1: 流派编辑→保存→盘面重算 fullchain_school_save_recompute: copy→edit epoch→save→switch→accumulatedYear 真变化
00:01 +2: loading .../zt30_multilevel_lineage_test.dart
00:01 +3: ZT-30 AC30.4: 多级 lineage → user_a → user_b, B.lineage 含两层链, rootOfficialId 仍是 taiYi
00:01 +4: ZT-30 AC30.4: 多级 lineage official(jingMirror) → user_a → user_b, B.rootOfficialId 仍是 jingMirror
00:01 +4: loading .../zt30_official_user_coexist_test.dart
00:02 +5: ZT-30 AC30.5: 官方+用户同盘共存 — 官方 wenChang + 用户副本 (schoolScopes=[jingMirror]) 同盘并列
00:02 +6: ZT-30 AC30.5: 官方+用户同盘共存 — assembly 三类基础实现可识别, ViewModel 通过 UseCase 持有它们 (AC5)
00:02 +6: loading .../zt30_school_scope_filter_test.dart
00:02 +7: ZT-30 AC30.3: schoolScopes 过滤 — schoolScopes=[jiCheng] 用户星神在 jingMirror 盘不出现, 切到 jiCheng 才出现
00:02 +8: ZT-30 AC30.3: schoolScopes 过滤 — chartTypes_filter: chartTypes=[month] 用户星神在 year 盘不出现, 切到 month 盘出现
00:02 +8: All tests passed!
```

8 / 8 tests PASS across 5 files. 无 skip, 无 fakeAsync 空体, 无字符串作弊。

### 8.4 AC 矩阵映射 (PASS — verified)

| AC | 测试 | 状态 | 备注 |
|---|---|---|---|
| AC3 | zt30_fullchain_deity_save_reload + zt30_fullchain_school_save_recompute | **PASS** | 编辑→保存→重建后状态保留断言通过 |
| AC5 | zt30_official_user_coexist (repo_interface_only) | **PASS** | 三类基础实现 + composite repo runtimeType 断言通过 |
| AC7 | 全 5 测试文件 happy path | **PASS** | accumulatedYear baseline 严格断言通过 |
| AC10 (schoolScopes) | zt30_school_scope_filter | **PASS** | jingMirror not contains + jiCheng contains + 回归 jingMirror not contains 三向断言通过 |
| AC10 (mock-only→真盘) | zt30_official_user_coexist | **PASS** | 同盘并列 + 官方未污染 双向断言通过 |
| AC11 | zt30_fullchain_school_save_recompute (第 4 块) | **PASS** | 重建 controller 复用同 db+prefs 通过 |
| AC12 | zt30_multilevel_lineage (2 tests) | **PASS** | rootOfficialId 不漂移 + lineage 分段计数严格通过 |

### 8.5 移交 master 决策项 (已完成)

- ~~解锁 `flutter test`: xuan-common `card_template_setting.dart` 需在 `refactor/common-slim` 分支修复~~ — 已通过 xuan-common 两次 commit (`84abb34` + `66ba351`) 解除：narrow enum re-export 已为 `card_template_setting.dart` 提供正确的 `ColorPreviewMode` 类型来源。
