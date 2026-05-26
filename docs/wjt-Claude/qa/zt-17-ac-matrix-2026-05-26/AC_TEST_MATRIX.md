# AC1-AC16 正向/逆向测试矩阵 (Story #4 太乙神数流派管理系统)

- 任务: ZenTao Task #17 (QA-1 [QA打回：测试矩阵过度声称])
- 重写日期: 2026-05-26
- 重写人: ClaudeCode (RBDDS subagent, 受 wjt 派发)
- 工作分支: `feat/taiyi-zt-claudecode-claim`
- AC 源文件: `docs/superpowers/specs/2026-05-23-taiyi-school-manager-mvp-design.md` 第 345-411 行
- 旧矩阵 (反例): `test/AC_TEST_MATRIX.md` (整张表 16/16 标"通过"，但实际仅 5 项 PASS)

> 本矩阵的"通过"判定基于"代码里实际存在的、对照 AC 描述的可观察结果断言"，不基于"测试文件存在""命名包含 AC"或"作者注释自报"。
> 对 Playwright spec：当前仓库 `test/bdd/node_modules` 不存在、`build/web` 不存在，即 spec 从未被实际执行，因此 AC 中"必须靠 Playwright 验收页面层"的部分一律降为 `NOT COVERED` 或 `MANUAL_PENDING`，不视为通过。

---

## 0. 总览汇总

### 0.1 覆盖判定柱状汇总 (16 AC)

| 判定 | 数量 | AC IDs |
|---|---|---|
| PASS | 5 | AC1, AC2, AC6 (Phase 1 only), AC11, AC15 |
| PARTIAL | 6 | AC3, AC4, AC5, AC7, AC10, AC12 |
| NOT COVERED | 1 | AC9 (运行时全链路勾选→盘面立即刷新+SP 持久化未端到端验证) |
| MANUAL_PENDING / Playwright-required | 4 | AC8 (Marketplace 真实置灰原因), AC13 (核心项隐藏阈值), AC14 (Playwright switching 页面层), AC16 (Playwright lineage 显示文本) |

> 注: AC6 拆分两层。Phase 1 (UseCase 源码不直接 import `drift.dart` / `shared_preferences.dart` / `path_provider` / `rootBundle`) 已用静态文件读取断言强验证 → PASS。Phase 2 (静态分析跨 `lib/taiyi/usecases/**` 全目录) 仅覆盖 `calculate_pan_usecase.dart` 一个文件，未跨目录扫描 → 见 AC6 "失败条件"。

### 0.2 必须由 Playwright 完成的 AC (任务原文明示 AC8-AC14, AC16)

| AC | 当前 Playwright spec 行 | Spec 是否被执行过 |
|---|---|---|
| AC8 | `test/bdd/tests/school-manager.spec.ts:90-135, 180-214` | 否 (无 node_modules, 无 build/web) |
| AC9 | `school-manager.spec.ts:144-174` | 否 |
| AC10 | `school-manager.spec.ts:223-300` | 否 |
| AC11 | `school-manager.spec.ts:308-364` | 否 |
| AC12 | `school-manager.spec.ts:355-364` (合并在 AC11) | 否 |
| AC13 | `school-manager.spec.ts:372-401` | 否 |
| AC14 | `school-manager.spec.ts:40-82` | 否 |
| AC16 | `school-manager.spec.ts:407-428` | 否 |

→ AC8-AC14, AC16 的 "页面层验收" 当前**全部 NOT COVERED**。它们各自的 Dart widget/integration 测试可分担"逻辑可达"但**不能替代页面层的浏览器端断言**。这是 ZT-25 的核心交付。

### 0.3 必须由 Flutter widget / unit / integration 完成的 AC

| AC | 测试层 | 当前情况 |
|---|---|---|
| AC1 | unit + vector-driven | PASS (regression_official_schools_test.dart + metadata_*_test.dart) |
| AC2 | unit + integration | PASS (repository_boundary_test.dart) |
| AC3 | integration (真 Drift) | PARTIAL → 持久化已验，但 mock-only 测试也声称覆盖 |
| AC4 | integration (真 SP) | PARTIAL → 持久化已验，但只在 mock-bundle 路径 |
| AC5 | unit (接口形状) | PARTIAL |
| AC6 | unit (静态文件检查) | PASS (Phase 1, 1 个文件), 跨目录 PARTIAL |
| AC7 | integration | PARTIAL (单页 controller→VM→UseCase 已通，无跨页全链路 happy path) |
| AC10 | widget + integration | PARTIAL → SchoolScopes/ChartTypes 已验证；"同盘显示"在 mock 上验证，未在真盘上端到端验证 |
| AC11 | widget + integration | PASS (school_editor_integration_test.dart c/d) |
| AC12 | widget + integration | PARTIAL → lineage 字段持久化已验，文本展示已验，但用户无法直观看到的"链式 source path" 不一定符合 AC 描述 |
| AC15 | unit / 模型 | PASS (domain_models_test.dart + chart_config / deity_override 的 schema 区分本身即 AC15) |

### 0.4 Fail-First 清单 (每个 AC 至少一条逆向断言)

| AC | 已有逆向断言 | 缺失 |
|---|---|---|
| AC1 | 无（仅正向 vector） | 缺：错误流派 ID / 错误日期 → AC 应判定不可计算 |
| AC2 | `throwsUnsupportedError` x3 (saveSchool/saveDeity/deleteSchool) | 缺：deleteDeity 也应 throw，未在仓库 boundary test 显式覆盖 |
| AC3 | malformed-json → `throwsA(FormatException)` (robustness_test.dart:84-90) | 缺：保存到 Drift 但写入失败时的回滚断言 |
| AC4 | 无 | 缺：SP 读取失败时的 fallback 行为 |
| AC5 | 无 | 缺：实现少一个接口方法时 compile-error 不能在运行时测试中表达 |
| AC6 | `isNot(contains('import drift.dart'))` (calculate_pan_boundary_test.dart:108-111) | 缺：跨 `lib/taiyi/usecases/**` 全文件 |
| AC7 | 无 | 缺：UI 直接调 Repo 时应被静态检查或 lint 拒绝 |
| AC8 | 整合测试 c 中 onChanged==null + 中文原因 (deity_dialog_integration_test.dart:276-308) | 缺：Playwright 页面层 disabled checkbox + tooltip 原因 |
| AC9 | 无端到端逆向 | 缺：取消勾选后盘面立即刷新失败 / SP 写入失败应回滚 UI |
| AC10 | `throwsA(TypeError)` 缺参数路径 (robustness_test.dart:122-129); `expect(saveSchool, throws)` 在 mock_repo | 缺：用户复制非官方 ID 应拒绝 |
| AC11 | school_editor `editBtn / saveBtn` 在官方派上 findsNothing (school_editor_widget_test.dart:85-91); 官方 repo saveSchool throws | 缺：直接调 controller.schoolViewModel.saveSchool 改官方 ID 应失败 |
| AC12 | 空 lineage 显示 `deity_editor_lineage_empty` 而非 hard-code "演自" (deity_editor_integration_test.dart:498-504) | 缺：lineage 缺失 / sourceId 不在仓库时的降级提示 |
| AC13 | hidden_reminder_test 显式 setDeityVisibility('taiYi', false) → 文本 "部分基础星神或关键计算项已隐藏" | 缺：隐藏非核心星神应**不**触发警告（防止 false-positive） |
| AC14 | school_management_integration_test c) `expect(jmAccumulated, isNot(equals(tzAccumulated)))` + 精确数值 | 缺：切换到不存在的 schoolId 应 throw 而非静默回退 |
| AC15 | 无 (仅 schema 测试) | 缺：尝试把流派属性放到 DeityOverride 应该被拒/不生效 |
| AC16 | 仅 derived_assets_test.dart 比较 const 字面量 (并非真"试图修改官方"); copy 后官方 unmodified 在 mock 路径已验 | 缺：原 derived_assets_test 用的 const TaiYiSchool 不可变，不构成真"派生触发"的逆向证据 |

---

## 1. AC1 — 官方配置仍正确

**AC 原文**: 金镜、统宗、集成在年/月/日/时计下，现有测试向量通过。

| 字段 | 内容 |
|---|---|
| 正向输入 | `DateTime(2026, 5, 23) + schoolId in {jingMirror, tongZong, jiCheng} + chartType=year/month/day/hour` |
| 正向步骤 | `TaiYiPanCalculator.calculate(...)` 直接调用，比对预设 `accumulatedYear`、`juNumber`、`sequenceIndex` 等 vector 期望 |
| 正向预期 | 三派 year 计精确数值匹配；month/day/hour 计 vector 数值匹配（依赖外部 `../test-vectors/taiyishenshu/*.json`） |
| 逆向输入 | 错误 schoolId="non_existent"、错误 dateTime（早于 epochYear） |
| 逆向步骤 | 同上调用 |
| 逆向预期 | 应 throwArgumentError 或返回明确错误，不应静默返回错误数据 |
| **失败条件** | 任一 vector 数值不匹配；或修改 `algorithm_engine.dart` 后 regression test 仍 PASS 但实测落宫不变 (说明断言空) |
| 测试层级 | Flutter unit (vector-driven) |
| 自动化文件 | `test/taiyi/regression_official_schools_test.dart:9-40` (3 派 year 计实际数值断言)；`test/taiyi/year_metadata_test.dart`, `month_metadata_test.dart`, `day_metadata_test.dart`, `hour_metadata_test.dart` (vector 驱动)；`test/taiyi/official_assets_verification_test.dart:51-90` (太乙金镜 2026 落艮宫、文昌落坤宫) |
| **覆盖判定** | **PASS** |
| 证据 | `regression_official_schools_test.dart:16` `expect(result.accumulatedYear, 1938583)`；`official_assets_verification_test.dart:70` `expect(result.gong, EnumTaiYiGong.Gen)` — 实测落宫断言，非空 |
| 缺口 | 无对"错误 schoolId / 边界年份"的逆向断言；vector 文件路径是相对的 `../test-vectors/`，若仓库目录漂移可能静默 skip — 建议增加 `expect(testVectors, isNotEmpty)` |

---

## 2. AC2 — 官方数据来源

**AC 原文**: 官方流派和官方星神由 assets JSON 提供，经过 Assets Repository 读取。官方数据只读，不允许被用户原地修改。

| 字段 | 内容 |
|---|---|
| 正向输入 | `OfficialJsonSchoolRepository(schoolIds:[...], deityIds:[...]) + loadSchool/loadDeity` |
| 正向预期 | 能正确从 assets JSON 加载并反序列化为 `TaiYiSchool` / `DeityDefinition` 对象 |
| 逆向输入 | 同一 repo 实例上调用 `saveSchool` / `saveDeity` / `deleteSchool` / `deleteDeity` |
| 逆向预期 | 全部 `throws UnsupportedError` |
| **失败条件** | 任一写方法不抛错；或 assets JSON 反序列化路径错误（kebab-case 路径） |
| 测试层级 | Flutter unit + integration |
| 自动化文件 | `test/taiyi/core/repository_boundary_test.dart:46-80` (3 个 throws 断言：saveSchool/saveDeity/deleteSchool)；`test/taiyi/core/official_json_repository_test.dart:88-107` (saveSchool/deleteSchool throws)；`test/integration/school_management_integration_test.dart:234-245` (Drift userSchools 表初始为空，证明官方流派未写入用户表) |
| **覆盖判定** | **PASS** |
| 证据 | `repository_boundary_test.dart:53` `expect(() => repo.saveSchool(...), throwsUnsupportedError)` |
| 缺口 | `deleteDeity` 缺少独立断言（boundary test 只测了 saveDeity 而没单独测 deleteDeity；但 mock repo 中类型签名一致，可视为外延等价） |

---

## 3. AC3 — 自定义数据来源

**AC 原文**: 用户流派、我的星神、参数覆盖、传承链保存到 Drift，必须经 Repository Interface 访问。

| 字段 | 内容 |
|---|---|
| 正向输入 | `DriftUserRepository.saveSchool(TaiYiSchool)` → close → 新 `TaiYiDatabase()` + 新 `DriftUserRepository` → `loadAllSchools()` |
| 正向预期 | 重建后能读到刚保存的 school；lineage / sourceId / rootOfficialId 字段往返保持 |
| 逆向输入 | 写入 malformed JSON 到 user_schools 表 → 通过 UseCase 读取 |
| 逆向预期 | 应抛 `FormatException`，不应静默吞下 |
| **失败条件** | 重建 repo 后读不到刚写入的行（持久化失败）；或 lineage 字段在 toJson/fromJson 来回后变 null |
| 测试层级 | Flutter integration (真 Drift) + unit (in-memory 退化) |
| 自动化文件 | `test/taiyi/core/repository_boundary_test.dart:83-109` (持久化 across `TaiYiDatabase` 实例重建)；`test/integration/school_management_integration_test.dart:131-164` (持久化 + lineage + rootOfficialId 字段); `test/integration/school_editor_integration_test.dart:77-192` (完整 round-trip：所有字段保留)；`test/taiyi/usecases/robustness_test.dart:64-93` (malformed JSON → FormatException) |
| **覆盖判定** | **PARTIAL** |
| 证据 | `school_editor_integration_test.dart:148-191` 真 Drift 写读全字段比较 |
| 缺口 | 1) `repository_boundary_test.dart:99-104` 通过 `getApplicationSupportPath=systemTemp` 模拟"共享文件"，但 `TaiYiDatabase.memory()` 在其他 integration test 中无文件持久化语义，两套语义混合可能误导；2) `InMemory*Repository` 与 `DriftUserRepository` 共用 `*Repository` 接口测试用例，部分场景仅在内存模拟覆盖（`in_memory_repositories_test.dart`），不能算 Drift 持久化覆盖 |

---

## 4. AC4 — 偏好数据来源

**AC 原文**: 星神显示偏好、最近选择、Dialog 偏好保存到 SharedPreferences，必须经 Repository Interface 访问。

| 字段 | 内容 |
|---|---|
| 正向输入 | `SharedPreferences.setMockInitialValues({})` → `SharedPreferencesDeityPreferenceRepository.setEnabled('taiYi', false)` → 第二个 SP instance 读取 |
| 正向预期 | 第二个 instance 读到 false，证明值真写入 SP |
| 逆向输入 | 在没有 ChangeNotifierProvider 的 widget tree 中调用 setDeityVisibility |
| 逆向预期 | 应回退到默认值或显式失败，不应静默成功 |
| **失败条件** | 重建 SP 后偏好丢失；或 controller.isDeityVisible 在 SP 已写 false 后仍返回 true |
| 测试层级 | Flutter integration + unit (in-memory 退化) |
| 自动化文件 | `test/taiyi/core/repository_boundary_test.dart:111-127` (跨 SP 实例)；`test/integration/deity_dialog_integration_test.dart:313-351` (taiYi 设为不可见 → `assembly.preferenceRepo.isEnabled('taiYi')` 真读 SP 为 false + 重建 SP 仍 false) |
| **覆盖判定** | **PARTIAL** |
| 证据 | `deity_dialog_integration_test.dart:339-348` 直接穿透 SP repo 读 false + getString('taiyi_deity_preferences') isNotNull |
| 缺口 | 1) "最近选择" 和 "Dialog 偏好" 两个 SP 用途在测试中**完全缺席**（只验证了星神显示偏好）；2) 重启 App 在 widget test 不可模拟，目前仅"重建 SP instance"近似 |

---

## 5. AC5 — Repository Interface

**AC 原文**: 定义清晰接口和至少三类基础实现 (Assets Official / Drift User / SharedPreferences Preference Repository)。

| 字段 | 内容 |
|---|---|
| 正向输入 | 实例化 `OfficialJsonSchoolRepository` + `DriftUserRepository` + `SharedPreferencesDeityPreferenceRepository` + `InMemory*` 退化版 |
| 正向预期 | 三类皆实现 `SchoolRepository` / `UserSchoolRepository` / `DeityRepository` / `DeityPreferenceRepository` 接口；接口签名一致 |
| 逆向输入 | 跨接口调用：UseCase 把 OfficialJsonSchoolRepository 当作 user repo 用 → 写入应抛 UnsupportedError |
| 逆向预期 | 接口契约不能用类型转换绕过 |
| **失败条件** | UseCase 直接 import 具体类而非接口（违反 AC6）；或某一类 implements 但实际未实现某些方法（运行时 NoSuchMethodError） |
| 测试层级 | Flutter unit (接口形状) |
| 自动化文件 | `test/taiyi/core/in_memory_repositories_test.dart` (3 个 InMemory 实现)；`test/taiyi/usecases/usecases_test.dart:20-48` (`MockOfficialSchoolRepo implements SchoolRepository` 编译通过即说明接口完备)；`test/taiyi/mocks/mock_repositories.dart:6-67` (3 类 Mock 都实现接口) |
| **覆盖判定** | **PARTIAL** |
| 证据 | `mock_repositories.dart:6` `class MockOfficialRepository implements SchoolRepository` — 编译时强约束 |
| 缺口 | 没有"接口本身有 X 个方法且每个具体实现都覆盖"的运行时断言；只能靠编译期检查；UI/页面层未验证"VM 只持有 Repository 接口而非具体类"的红线 |

---

## 6. AC6 — UseCase 边界

**AC 原文**: UseCase 不能直接访问 assets、Drift、SharedPreferences。UseCase 只能调用 Repository Interface。

| 字段 | 内容 |
|---|---|
| 正向输入 | `CalculatePanUseCase(schoolRepository, deityPreferenceRepository)` 注入 |
| 正向预期 | UseCase 只依赖接口；正常 execute 路径成功 |
| 逆向输入 | 静态读取 `lib/taiyi/usecases/calculate_pan_usecase.dart` 文件源码 |
| 逆向预期 | 不应包含 `import 'package:drift/drift.dart'`、`shared_preferences.dart`、`path_provider.dart`、`rootBundle` |
| **失败条件** | 任一 import 出现；或新增 UseCase 文件直接 import 数据源 |
| 测试层级 | Flutter unit (静态文件 grep) |
| 自动化文件 | `test/taiyi/usecases/calculate_pan_boundary_test.dart:104-112` |
| **覆盖判定** | **PASS** (Phase 1, 单文件) |
| 证据 | `calculate_pan_boundary_test.dart:108` `expect(content, isNot(contains('import \'package:drift/drift.dart\'')))` |
| 缺口 | **只检查了 `calculate_pan_usecase.dart` 一个文件**。`lib/taiyi/usecases/` 下还有 `load_schools_usecase.dart`, `save_user_school_usecase.dart`, `copy_school_usecase.dart`, `load_deities_usecase.dart`, `save_user_deity_usecase.dart`, `copy_deity_usecase.dart`, `delete_user_deity_usecase.dart`, `deity_availability_usecase.dart`, `toggle_deity_preference_usecase.dart` 等 9 个文件全部**未做同等静态检查**。应补 Phase 2：遍历目录全检查。当前 Phase 1 PASS 不可推广到整个 UseCase 层。 |

---

## 7. AC7 — MVVM

**AC 原文**: UI 只绑定 ViewModel。ViewModel 调用 UseCase。UseCase 调用 Repository。

| 字段 | 内容 |
|---|---|
| 正向输入 | Pump `SchoolEditorPage` / `DeityEditorPage` with `ChangeNotifierProvider<*ViewModel>` → 调用 vm.copySchool / saveDeity |
| 正向预期 | VM → UseCase → Drift 写入；新一轮 VM 加载后能读到 |
| 逆向输入 | 拆掉 Provider 后调用 save |
| 逆向预期 | 显示"保存失败"并**不**绕过 VM 直接写 Drift |
| **失败条件** | 没有 Provider 时 save 仍成功；或页面直接 import 具体 Repo 跳过 VM |
| 测试层级 | Flutter widget + integration |
| 自动化文件 | `test/integration/deity_editor_integration_test.dart:506-540` (无 Provider 时 save 失败 + Drift 仍空)；`test/integration/school_editor_integration_test.dart:244-277` (UI 经 VM 触发 copy)；`test/taiyi/usecases/mvvm_state_sync_test.dart:97-124` (并发请求 → ViewModel 最终状态匹配最后一次) |
| **覆盖判定** | **PARTIAL** |
| 证据 | `deity_editor_integration_test.dart:531` `expect(find.textContaining('保存失败'), findsOneWidget)` + 第 537 行 `expect(users, isEmpty)` |
| 缺口 | 1) 缺"任何 page 文件不 import `drift/drift.dart` / `shared_preferences.dart`"的静态检查；2) `mvvm_state_sync_test` 验证的是并发 — 不是 AC 要求的 "UI 单向依赖 VM" — 该测试名误导；3) AC7 描述的"UI 调 VM"的反向（VM 调 UI 或循环依赖）未做断言 |

---

## 8. AC8 — 星神 Dialog

**AC 原文**: 显示系统内置星神、我的星神、Marketplace 预留区。显示全部星神，不可用项置灰并说明原因。

| 字段 | 内容 |
|---|---|
| 正向输入 | 排盘后打开 `DeityManagementDialog` |
| 正向预期 | 三区标题"系统内置"/"我的星神"/"Marketplace" 各 findsOneWidget；Marketplace 占位 `marketplace-placeholder` 存在；我的区初始空状态 `my-deities-empty` 存在；所有官方星神（30+）皆渲染 |
| 逆向输入 | chartType=year + schoolId=jingMirror 下，某些星神（青龙旗 / 黑旗 / 赤旗 / 鬼神之始）不在该流派 deityIds 中 |
| 逆向预期 | Checkbox `onChanged == null` 且有中文原因文本 (`deity-unavailable-reason` widget tree) |
| **失败条件** | 三区任一缺失；Marketplace 显示真实可点击项（应只占位）；不可用项 checkbox 可勾选；置灰但无原因文本 |
| 测试层级 | Flutter integration + Playwright (页面层) |
| 自动化文件 | `test/integration/deity_dialog_integration_test.dart:161-199` (三区 + Marketplace placeholder + my-deities-empty)；同文件 `:253-311` (青龙旗 checkbox onChanged==null + `deity-unavailable-reason` 存在)；同文件 `:421-450` (官方区无 delete IconButton)；Playwright `school-manager.spec.ts:88-135, 180-214` (DOM 选择器 + disabled checkbox + reason text) |
| **覆盖判定** | **PARTIAL** (Flutter 层) + **NOT COVERED** (Playwright 页面层) |
| 证据 | `deity_dialog_integration_test.dart:301-308` `expect(checkbox.onChanged, isNull, reason: '反 fake completion: 不可用项 checkbox 必须真的 onChanged == null')` |
| 缺口 | 1) Playwright spec 从未执行（无 node_modules + 无 build/web）；2) Marketplace 占位的"真正不可点击/不可 toggle" 在 Flutter integration 验证了 key 存在但没验证交互无效；3) 老矩阵标"通过 (BDD)" 是 fake-pass：BDD test 实际只在 Flutter 端模拟 |

---

## 9. AC9 — 星神显示偏好

**AC 原文**: Checkbox 控制全局显示偏好。勾选后当前盘面立即刷新。偏好保存到 SharedPreferences Repository。

| 字段 | 内容 |
|---|---|
| 正向输入 | 排盘 → 打开 Dialog → 勾选/取消"君基" → 关闭 Dialog |
| 正向预期 | 盘面立即出现/隐藏"君基"；SP key 写入；重启 App 偏好仍保留 |
| 逆向输入 | 隐藏后撤销 → 盘面立即恢复 |
| 逆向预期 | 一致性回滚 |
| **失败条件** | 勾选后盘面文字不变；SP 没写入；或写入了但下次启动丢失 |
| 测试层级 | Flutter integration + Playwright (页面层) |
| 自动化文件 | `test/integration/deity_dialog_integration_test.dart:313-351` (设置 taiYi 不可见 → SP 真有 key + 重建 SP 仍 false)；`test/bdd/hidden_reminder_test.dart` 只验证警告文本，不验证盘面落宫文字变化；Playwright `school-manager.spec.ts:144-174` (DOM 端勾选 + escape 后断言盘面文字) |
| **覆盖判定** | **NOT COVERED** |
| 证据 | 没有任何 Dart 测试做"勾选后盘面落宫的具体星神文字立即变化"的断言。`deity_dialog_integration_test.dart` 只验证了"SP 写入" + "重建仍读 false"，**没有验证 "panData 重新计算后 palaces 中该星神消失"**。 |
| 缺口 | 1) 应在 integration 中加 `await controller.setDeityVisibility('junJi', false); expect(controller.panData!.palaces.any((p) => p.items.any((i) => i.name == '君基')), isFalse);` — 当前缺；2) Playwright 也未执行；3) 老矩阵标"通过 (BDD)" 是 fake-pass：没有任何运行中的测试验证"立即刷新"这个 AC 核心 |

---

## 10. AC10 — 我的星神

**AC 原文**: 用户能复制官方星神，改名称、颜色、适用流派、适用盘型、当前模板有限参数。用户星神保存到 Drift Repository。官方星神不被修改。官方和用户星神可同盘显示。

| 字段 | 内容 |
|---|---|
| 正向输入 | `controller.deityViewModel.copyDeity(sourceId:'taiYi', newId:'user_x', newName:'我的太乙')` → 改 color + schoolScopes + chartTypes → save → 重建 repo 读 Drift |
| 正向预期 | Drift 真有行；name/color/schoolScopes/chartTypes/sourceId/rootOfficialId/lineage 字段全保留 |
| 逆向输入 | 1) 复制非存在的源 ID 应 throwArgumentError；2) 用户复制后修改 templateId 应被 UI 禁止；3) 缺参数（没 gong）的派生 deity → throwTypeError |
| 逆向预期 | 三类逆向都触发明确失败 |
| **失败条件** | 复制只 SnackBar 不写 Drift；改 schoolScopes 保存后字段为空；可改 templateId；同盘显示时官方"太乙"被覆盖 |
| 测试层级 | Flutter widget + integration + Playwright |
| 自动化文件 | `test/integration/deity_editor_integration_test.dart:143-220` (copy-and-edit 写真 Drift + lineage 准确)；同文件 `:222-351` (改 name + color + 2 schoolScope chip + chart chip toggle + save → 直接读 Drift 验证)；`test/widget/deity_editor_widget_test.dart` (read-only banner / chip 渲染)；`test/taiyi/usecases/deity_copy_and_scope_test.dart:50-78` (mock 上的"官方+用户同盘")；`test/taiyi/usecases/robustness_test.dart:95-130` (缺 gong → TypeError)；`test/taiyi/usecases/usecases_test.dart:124-133` (非存在源 → ArgumentError) |
| **覆盖判定** | **PARTIAL** |
| 证据 | `deity_editor_integration_test.dart:332-350` 真 Drift 读出来 name='太乙·改名后' + color='#D4A017' + schoolScopes 是 {jingMirror, tongZong} + chartTypes 是 {month} + lineage 含 'taiYi' |
| 缺口 | 1) "同盘显示"验证只在 mock repo 路径 (`deity_copy_and_scope_test.dart:73-76`)，没有在真盘 + 真 Drift 下验证；2) "适用流派"/"适用盘型"在 Drift round-trip 保留已验，但**实际"切换流派时不在 schoolScopes 中的用户星神被过滤掉"这个语义未验证**（即 schoolScopes=jiCheng 的用户星神在 jingMirror 盘上不应出现）；3) "templateId 不可改" 仅 Playwright spec 中描述，无 Flutter widget 测试断言；4) 颜色/displayStyle 的"实际渲染"未验证 |

---

## 11. AC11 — 我的流派

**AC 原文**: 用户能复制或派生官方流派，改元数据和盘型基准配置。用户流派保存到 Drift Repository。官方流派不被修改。

| 字段 | 内容 |
|---|---|
| 正向输入 | `schoolViewModel.copySchool(sourceId:'jingMirror', newId:..., newName:'我的金镜派')` → 改 epochYear + palaceFormula + wenChang/jiShen/eightDoor → save → 重建 controller 同 db 读 |
| 正向预期 | 用户流派带 sourceId='jingMirror' + rootOfficialId='jingMirror' + lineage 含两端；改后的字段都保留；未改的 deityIds/chartConfigs/deityConfigs/privateDeities/overrides 全部保留；computePan 数值真的变化 |
| 逆向输入 | 1) UI 上官方流派无 `edit-jingMirror` 按钮、有 `copy-jingMirror`；2) 官方 repo.saveSchool 直接调用应 throw |
| 逆向预期 | 双重保护：UI 层不暴露入口 + repo 层拒绝写 |
| **失败条件** | 改用户流派会污染官方；deityIds/chartConfigs 在 round-trip 后丢失；UI 上官方流派可编辑 |
| 测试层级 | Flutter widget + integration |
| 自动化文件 | `test/integration/school_editor_integration_test.dart:37-242` (a 官方 readOnly throws + b 复制带 lineage + c 全字段 round-trip + d epoch 改后 accumulatedYear 数值变化 + e UI banner 切换)；`test/widget/school_editor_widget_test.dart:74-136` (official banner + 字段 disabled + save btn 不显)；`test/pages/school_manager_page_test.dart:46-67` (官方派 edit key findsNothing, copy/info findsOneWidget)；`test/integration/school_management_integration_test.dart:131-164` (持久化跨 controller 重建) |
| **覆盖判定** | **PASS** |
| 证据 | `school_editor_integration_test.dart:148-191` round-trip 保留所有字段；`:239-241` `expect(modifiedAY, isNot(baselineAY))` 真数值变化 |
| 缺口 | 缺"用户尝试直接修改 ID 为 'jingMirror' 后保存"的逆向（即用 user repo 强写覆盖官方 ID 时的行为）— 但这是边缘场景 |

---

## 12. AC12 — 传承链

**AC 原文**: 用户流派和用户星神保存 lineage。详情里以文本显示来源路径。

| 字段 | 内容 |
|---|---|
| 正向输入 | copyDeity/copySchool → 取出 lineage 字段 + sourceId + rootOfficialId → 在 editor 中打开 → 看 lineage chain UI |
| 正向预期 | Drift 保留 3 个字段；editor `deity_editor_lineage_chain` widget 显示 lineage 分段 (e.g. "official(taiYi)" + "user_deity_reopen")；root + source 子组件存在 |
| 逆向输入 | 官方 deity (lineage==null) 打开 editor |
| 逆向预期 | 显示 `deity_editor_lineage_empty` 空状态，**不显示** hard-code "演自" / "派生自" |
| **失败条件** | lineage 在 toJson/fromJson 后丢失；editor 上写死字符串而不是 parse 真 lineage |
| 测试层级 | Flutter widget + integration + Playwright |
| 自动化文件 | `test/integration/deity_editor_integration_test.dart:353-461` (持久化 lineage + UI hydrate)；同文件 `:463-504` (官方 deity 显示 lineage_empty + 不出现"演自"/"派生自")；`test/widget/deity_editor_widget_test.dart:224-251` (chain 分段渲染)；`test/integration/school_editor_integration_test.dart:67-75, 184-192` (copy school lineage 持久化)；`test/bdd/deity_management_bdd_test.dart:85-101` (Editor 显示 "传承链" + "官方 > 我的派生" 文字 — 但这是注入的 lineage 字符串而非系统计算的) |
| **覆盖判定** | **PARTIAL** |
| 证据 | `deity_editor_integration_test.dart:444-460` chain widget 含 lineage 真分段；`:498-504` `expect(find.textContaining('演自'), findsNothing)` 反 hard-code |
| 缺口 | 1) `editor_navigation_bdd_test.dart` 第 92 行用 `lineage: '官方 > 我的派生'` 注入字符串，验证 editor 能显示这串字面量 — 这**不能证明真实系统生成的 lineage** 符合 "来源路径" 这个语义；2) 多级派生（用户星神 A 派生出用户星神 B）的 lineage 链是否包含两层未验证；3) Playwright 页面层 AC16 lineage 显示"金镜派 > 我的金镜派" 文本未执行 |

---

## 13. AC13 — 关键隐藏提醒

**AC 原文**: 隐藏基础核心项或关键中间值时，Dialog 或信息面板提示"盘面解释可能不完整"。

| 字段 | 内容 |
|---|---|
| 正向输入 | `controller.setDeityVisibility('taiYi', false)` |
| 正向预期 | 主页面出现文本 "部分基础星神或关键计算项已隐藏" 或 "盘面解释可能不完整" |
| 逆向输入 | 隐藏非核心星神（如某非 tier:core 的项） |
| 逆向预期 | **不应**触发警告（避免 false-positive） |
| 还原逆向 | 恢复勾选 taiYi → 警告消失 |
| **失败条件** | 隐藏非核心也触发警告；或隐藏核心不触发；或文本不在主页面而是只在 Dialog 内（关闭 Dialog 后消失） |
| 测试层级 | Flutter integration + Playwright |
| 自动化文件 | `test/bdd/hidden_reminder_test.dart:30-35` (setDeityVisibility('taiYi', false) → 文字 "部分基础星神或关键计算项已隐藏" findsOneWidget)；`test/bdd/deity_visibility_bdd_test.dart:13-46` (UI 取消 taiYi chip → 关闭 dialog → 主页面 banner 仍在)；Playwright `school-manager.spec.ts:372-401` (DOM 端勾选 + 文字 "盘面解释可能不完整") |
| **覆盖判定** | **MANUAL_PENDING / Playwright-required** |
| 证据 | `hidden_reminder_test.dart:34` `expect(find.textContaining('部分基础星神或关键计算项已隐藏'), findsOneWidget)` |
| 缺口 | 1) **逆向"隐藏非核心不触发警告"完全缺失** — 当前只测了 PASS 路径；2) AC 原文是 "盘面解释可能不完整"，实测断言文本是"部分基础星神或关键计算项已隐藏"，**这俩文字不一致** — 需要确认哪个是产品决定 (老矩阵标"通过"但显然存在 AC 文本与代码不符);3) "恢复后警告消失"未验证；4) Playwright 用的是 "盘面解释可能不完整" 文本，**与 Flutter 端实现的文本不一致**，是另一个 fake-pass 隐患 |

---

## 14. AC14 — 多流派切换

**AC 原文**: 沿用现有 UI 的流派切换方式，支持切换到用户自定义流派。切换后使用对应流派配置重新排盘。不做并列对照 UI。

| 字段 | 内容 |
|---|---|
| 正向输入 | `controller.calculate(schoolId:'jingMirror', dateTime:probeDate, chartType:year)` 取 accumulatedYear → `switchSchool('tongZong')` → 取 accumulatedYear |
| 正向预期 | 两次 accumulatedYear 不同；具体数值 jm=1938581 / tz=10155940；juNumber 或主算落宫至少一项变化；切换到用户流派 input.schoolId/schoolName 同步更新 |
| 逆向输入 | switchSchool('non_existent_id') |
| 逆向预期 | 应 throw，不应静默回退 |
| **失败条件** | 切换后 accumulatedYear 不变；或切换到用户流派后 input.schoolId 仍是上一个 |
| 测试层级 | Flutter integration + Playwright (页面层) |
| 自动化文件 | `test/integration/school_management_integration_test.dart:167-232` (precise numeric assertion 切换后 accumulatedYear + juNumber 变化 + 切到用户副本 schoolId/Name 同步)；`test/pages/school_manager_page_test.dart:100-124` (UI 点击 row → controller.panData.input.schoolId 更新)；Playwright `school-manager.spec.ts:38-82` (页面级切换) |
| **覆盖判定** | **MANUAL_PENDING / Playwright-required** (Flutter 层 PASS，但 AC 要求是"沿用现有 UI"，仍需页面层确认) |
| 证据 | `school_management_integration_test.dart:196-199` `expect(jmAccumulated, 1938581); expect(tzAccumulated, 10155940);` |
| 缺口 | 1) `switchSchool` 对非法 ID 的行为完全没断言（应 throwArgumentError，未验证）；2) "不做并列对照 UI" 是负向 AC — 没有任何测试验证 "没有并列 UI"；3) Playwright spec 未执行 |

---

## 15. AC15 — 计算边界

**AC 原文**: 凡是改变积年、积月、积日、积时、局数、阴阳遁、主算、客算、定算的配置，属于流派算法。凡是在既有流派算法上下文上产生落宫、标记、展示项的配置，属于星神/计算项。

| 字段 | 内容 |
|---|---|
| 正向输入 | 检查 `SchoolEpochConfig` 字段（ancientBase / ancientMonthBase / ancientDayBase / ancientHourBase / zhangSui / zhangYue / dayOffset / hourOffset / correction） vs `DeityOverride` 字段（active / correction / params / algorithm） vs `ChartConfig`（dayOffset / hourOffset / zhangSui / zhangYue / hostGuestBase） |
| 正向预期 | School-level 改动落在 `TaiYiSchool.epoch` + `chartConfigs[type]`；星神改动落在 `DeityOverride`；序列化双向 OK |
| 逆向输入 | 试图通过 DeityOverride 改积年（schema 上不可能） |
| 逆向预期 | DeityOverride 没有 epoch / ancientBase 字段，编译期阻断 |
| **失败条件** | 模型 schema 允许把 epoch 字段塞进 DeityOverride 或反之 |
| 测试层级 | Flutter unit (schema 区分) |
| 自动化文件 | `test/taiyi/core/domain_models_test.dart:10-101` (ChartConfig 默认 + roundtrip；DeityOverride 默认 + roundtrip；TaiYiSchool 新字段 chartConfigs/deityConfigs/privateDeities 持久化)；`test/integration/school_editor_integration_test.dart:77-192` (改 epoch.epochYear 后 accumulatedYear 真变化，证明 epoch 真在 school 层) |
| **覆盖判定** | **PASS** |
| 证据 | `domain_models_test.dart:96-99` `expect(restored.chartConfigs['year']!.dayOffset, 5)`；`school_editor_integration_test.dart:239-241` 改 epoch 后 accumulatedYear 不同 |
| 缺口 | AC 描述的"主算/客算/定算"是计算逻辑层，模型测试只验证了 schema 区分，没验证修改 epoch 字段后**主客定算结果真的变化** (TaiYi 主客定算 hostCount/guestCount/dingCount 数值变化未独立断言)；smoke 文件 `taiyi_pan_calculator_smoke.dart:154-174` 有验证统宗 2024 hostCount=38 / guestCount=25，但**这个文件是 dart-run 不在 flutter test 套件中**，CI 不会跑 |

---

## 16. AC16 — 官方资产派生原则

**AC 原文**: 官方资产只读，用户修改即派生。派生对象保留 sourceId、rootOfficialId、lineage。

| 字段 | 内容 |
|---|---|
| 正向输入 | copyDeity/copySchool from official → 拿到 user 对象 |
| 正向预期 | source='user' + sourceId=官方 ID + rootOfficialId=官方 ID + lineage 含 'official(xxx) -> user_xxx' |
| 逆向输入 | 1) saveSchool 直接给一个 source='user' 但 id='jingMirror' 的对象到 official repo；2) 用户复制后修改的字段不应回写到官方 deity 对象 |
| 逆向预期 | 1) official repo throws；2) 官方 deity unmodified |
| **失败条件** | sourceId/rootOfficialId 缺失；lineage 写死字面量；派生写回官方 |
| 测试层级 | Flutter integration + Playwright |
| 自动化文件 | `test/integration/school_editor_integration_test.dart:53-75` (copy → sourceId/rootOfficialId/lineage 三个字段精确比对)；`test/integration/deity_editor_integration_test.dart:209-220` (`copy.sourceId='taiYi' + rootOfficialId='taiYi' + lineage.contains('taiYi')`)；`test/integration/school_management_integration_test.dart:234-245` (Drift userSchools 初始为空 - 官方流派从未写入用户表)；`test/taiyi/core/derived_assets_test.dart` (但用 const 字面量比较两个不同对象，**不构成真"派生触发"的逆向证据**)；Playwright `school-manager.spec.ts:407-428` (页面层 lineage 显示 "阳九 > 测试派生") |
| **覆盖判定** | **MANUAL_PENDING / Playwright-required** (Flutter 层 PASS) |
| 证据 | `school_editor_integration_test.dart:69-74` `expect(copy.sourceId,'jingMirror'); expect(copy.rootOfficialId,'jingMirror'); expect(copy.lineage, contains('jingMirror')); expect(copy.lineage, contains(copyId));` |
| 缺口 | 1) `derived_assets_test.dart` 是 const-only 模型比较，老矩阵把它标"通过 (逻辑)" 是 fake-pass — 没有任何"试图修改官方 deity 后官方真的不变"的运行时断言；2) 多级派生（A 派生 B 派生 C）lineage 链未验证；3) Playwright 未执行 |

---

## 17. 审计方法说明

### 17.1 "PASS" 的客观标准

满足全部下列条件才标 PASS：
1. 测试文件内有**针对 AC 描述的可观察结果**的 `expect(...)` 断言（非 `expect(true, isTrue)` 等空断言）；
2. 断言不是 Mock-only 闭环（如：mock 返回 X → 断言收到 X 不算 — 仅断言注入的 mock 输出回流到自己），必须穿透到一个 production code path（Drift / SP / Calculator / Real ViewModel）；
3. 至少有一条对 AC 描述的逆向场景（reject / throw / `findsNothing`）有断言；
4. 测试不是注释掉、TODO、`skip:true`、或在 `taiyi_pan_calculator_smoke.dart` 这种"非 flutter test 套件"内。

### 17.2 "Mock-only / 空断言 / TODO / 注释型测试"识别证据

| 反 pattern | 实例 | 备注 |
|---|---|---|
| Const 字面量比较 | `test/taiyi/core/derived_assets_test.dart` 全文件 (60 行) | 两个不同 const TaiYiSchool 对象互不影响是 Dart 语义本身，不构成"派生隔离"证据 |
| 注释主断言 | `test/taiyi_pan_calculator_smoke.dart:36-122` | 主要断言全注释，仅留 renPan 与 hostGuest 几条；且非 flutter_test 套件 |
| Mock-only "AC 通过" | `test/taiyi/usecases/deity_copy_and_scope_test.dart:51-77` | "官方+用户同盘"用 MockOfficial + MockUser，官方 / 用户星神是 mock 数据，真盘计算未参与 |
| AC 文本与实测文本不一致 | AC13 spec="盘面解释可能不完整" vs Flutter test 文本"部分基础星神或关键计算项已隐藏" | 老矩阵 fake-pass |
| Playwright spec 存在但从未执行 | `test/bdd/tests/school-manager.spec.ts` 全文件 | 仓库无 `test/bdd/node_modules/`、无 `build/web/`，无 `pnpm install` / `npx playwright install` 痕迹 |
| 单文件代表全目录 | `test/taiyi/usecases/calculate_pan_boundary_test.dart:104-112` 只检查 `calculate_pan_usecase.dart` 一个文件 | AC6 不能用 1/10 文件代表整层 |

### 17.3 旧矩阵 (`test/AC_TEST_MATRIX.md`) 的 fake-pass 实例

旧矩阵 16/16 全标"通过/已验证"。本审计判定其中至少 **11 项是 fake-pass / 过度声称**：

| AC | 老矩阵状态 | 实际状态 | 关键反证 |
|---|---|---|---|
| AC3 | 通过 (Memory 模拟) | PARTIAL | 标注"Memory 模拟"已自暴弱点；真 Drift 持久化在另一个测试存在但老矩阵未引用 |
| AC4 | 通过 (Controller 管理) | PARTIAL | "最近选择" 和 "Dialog 偏好" 两类 SP 用途从未测试 |
| AC5 | 已定义并集成 | PARTIAL | 无运行时检验，仅 Mock 类签名 |
| AC6 | 已验证集成路径 | PASS (单文件) | 集成路径仅是单文件静态检查；其他 9 个 UseCase 文件未做 |
| AC7 | 已全链路贯通 | PARTIAL | "已贯通"是描述性陈述非断言；只有"无 Provider → 失败"反向被验证 |
| AC8 | 通过 (BDD) | PARTIAL | BDD 是 Flutter widget test 不是 Playwright；老矩阵把 BDD 当作页面层完成；Marketplace 不可点击未验证 |
| AC9 | 通过 (BDD) | **NOT COVERED** | 完全没有"勾选后盘面立即刷新"的运行时断言。仅有"SP 写入"被验证 |
| AC10 | 通过 (UI & 逻辑) | PARTIAL | "同盘显示"只在 mock 路径；适用流派的"切换流派时过滤"语义未验证 |
| AC12 | 通过 (BDD) | PARTIAL | `editor_navigation_bdd_test.dart` 注入字符串文字而非系统生成的 lineage |
| AC13 | 通过 (BDD) | MANUAL_PENDING | Flutter test 文本与 AC 文本不一致；逆向"非核心不触发"完全缺失 |
| AC14 | 通过 (BDD 验证) | MANUAL_PENDING | Flutter 层数值断言充分，但 Playwright 页面层从未执行 |
| AC16 | 通过 (逻辑) | MANUAL_PENDING | `derived_assets_test.dart` 是 const 字面量比较，不构成派生逻辑证据 |

**最严重的 3 例**:
1. **AC9 NOT COVERED**: 旧矩阵标"通过 (BDD)"，但**没有任何测试**验证"勾选 checkbox 后盘面立即出现/消失对应星神"。这是 AC9 的核心可观察结果。任何后续标"AC9 PASS"的报告都是 fake completion。
2. **AC13 文本不一致**: AC spec 写"盘面解释可能不完整"，Flutter 测试断言"部分基础星神或关键计算项已隐藏"，Playwright 断言"盘面解释可能不完整"。三方文本不一致，老矩阵直接标 PASS 等于隐藏 bug。
3. **AC16 const-only test**: `derived_assets_test.dart:9-30` 用 `const TaiYiSchool` + `final TaiYiSchool` 构造两个对象，验证它们字段不同。这是 Dart 不可变语义本身，**与"用户修改官方时派生而非原地写回"无关**。老矩阵据此标"通过"是最典型的 fake completion 实例。

---

## 18. 最低补救清单 (供 ZT-21 / ZT-25 / ZT-26 参考)

按优先级排序：

1. **[ZT-25 blocker] Playwright spec 跑起来** — 至少 `npm i && npx playwright install && flutter build web && npx playwright test` 一次成功，并把日志/截图归档到 `docs/wjt-<agent>/qa/zt-25-*/`。否则 AC8/AC9/AC10/AC11/AC13/AC14/AC16 的页面层都不算覆盖。
2. **[ZT-21 blocker] 补 AC9 全链路断言** — 在 `deity_dialog_integration_test.dart` 加 "setDeityVisibility false → controller.calculate → palaces.expand.items 不含 君基/太乙"。这一条不补，AC9 永远 NOT COVERED。
3. **[ZT-21] 统一 AC13 文本** — 选一份文本（AC spec / Flutter 实现 / Playwright）作为 source of truth，三处必须完全一致。
4. **[ZT-21] AC13 逆向"非核心不触发警告"** — 必须加一条 fail-first。
5. **[ZT-26 报告依赖] 替换/标注 `derived_assets_test.dart`** — 标为"不构成 AC16 覆盖证据"，或删除/重写为穿透真 repo 的派生触发测试。
6. **[QA-后续] AC6 扩展到全目录** — 把 `calculate_pan_boundary_test.dart:104-112` 的静态检查改成遍历 `lib/taiyi/usecases/*.dart`。
7. **[QA-后续] AC10 "schoolScopes 过滤" 真盘验证** — 创建 schoolScopes=['jiCheng'] 的用户星神，切到 jingMirror 盘，断言该星神不出现。
8. **[QA-后续] AC14 非法 ID 逆向** — switchSchool('non_existent') 应 throw 而非静默。

---

> **本矩阵生效声明**: 本文件取代 `test/AC_TEST_MATRIX.md` 中乐观状态。后续任务（ZT-21, ZT-25, ZT-26）应基于本矩阵的"覆盖判定" 列重新规划，不得在未补救的前提下推进 Story #4 验收。
