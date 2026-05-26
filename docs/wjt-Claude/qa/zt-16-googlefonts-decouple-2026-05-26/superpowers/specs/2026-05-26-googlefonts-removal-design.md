# GoogleFonts 解耦设计规格

## 元信息
- 创建日期: 2026-05-26
- 状态: 已锁定 (RBDDS 子代理: SPEC 即合约, 不需要等用户批准, 见任务派发说明)
- 关联需求: ZenTao Task #16 (MVVM+Repository 集成测试 - GoogleFonts 解耦)
- 工作分支: `feat/taiyi-zt-claudecode-claim`
- 派发人: wjt (Master Agent)
- 派发渠道: RBDDS subagent
- 关联文档: `docs/wjt-Claude/qa/zt-17-ac-matrix-2026-05-26/AC_TEST_MATRIX.md`

## 目标

1. **彻底剥离 GoogleFonts 运行时依赖**: 在 `lib/` 全部源码、`pubspec.yaml` 主依赖、`test/` 测试工具链中, 不再出现 `google_fonts` 包名或 `GoogleFonts.*` 符号调用.
2. **测试反伪**: 不通过 `MockAssetBundle` 注入伪造的 `FontManifest`, 也不引入"测试专用空壳字体" hack.
3. **AC8 验收**: `test/bdd/deity_management_bdd_test.dart` 中 `AC8: Dialog shows sections` 测试通过. Dialog 三区结构 (`系统内置`/`我的星神`/`Marketplace`) + Marketplace placeholder + 空"我的"区指引齐全.
4. **AC10 验收**: `test/bdd/deity_management_bdd_test.dart` 中 `AC10: Copy deity shows SnackBar` 测试通过. 复制按钮触发 SnackBar 反馈, 含"已复制"文本.
5. **零 font not found 噪声**: 测试输出不得出现 `MaShanZheng-Regular`/`LongCang-Regular`/`NotoSerif-Regular` 等 GoogleFonts 默认字符串 与 `font not found` 错误.
6. **静态分析门禁**: `flutter analyze lib/ test/` 在与 GoogleFonts/字体相关的范围内零 warning 零 error.

## 非目标

- **不做** 视觉风格优化: QA 决策已批准视觉降级到 Flutter/system 默认字体 (Roboto / SF Pro / KaiTi).
- **不动** `lib/database/*`, `lib/navigator.dart`, `lib/taiyi/data/*` 业务逻辑.
- **不动** `assets/` 目录 (不引入伪造的字体资源).
- **不动** `lib/pages/beauty_page.dart:37` 现有的 `fontFamily: 'KaiTi'` (系统字体, 与 GoogleFonts 无关).
- **不动** `lib/widgets/school_editor/school_editor_sections.dart` 中 `fontFamily: 'monospace'` (系统字体).
- **不重写** BDD 测试逻辑, 只验证当前状态满足 AC.
- **不修复** 其他 pre-existing 警告 (`unused_local_variable`, `dead_code`, `unused_element` 等), 这些与本任务无关 (surgical-changes 原则).
- **不修改** `docs/superpowers/`, `docs/board/`, 其他 AI 工作区.

## 架构设计

### 历史回顾

在 commit `42919b9 feat(taiyi): integration of MVVM+Repository and UI reactive transition [XUAN-ZT43-f6a8b2]` 中, 已完成了 GoogleFonts 包的整体移除. 该提交的 `pubspec.yaml` diff (5 ++--) 移除了 `google_fonts` 依赖项. 同时所有 `lib/widgets/`、`lib/pages/`、`lib/theme/` 内的 `import 'package:google_fonts/google_fonts.dart'` 与 `GoogleFonts.maShanZheng()` 等调用被替换为 Flutter 内置 `TextStyle` (使用 `fontFamily: 'KaiTi'` / 默认无 family).

### 当前架构 (验证完毕)

```
Flutter App Runtime
  ├── lib/main.dart                    → ThemeData 不引用 GoogleFonts
  ├── lib/theme/taiyi_classic_theme.dart → TextStyle 不引用 GoogleFonts
  ├── lib/widgets/deity_management_dialog.dart → 不引用 GoogleFonts
  ├── lib/widgets/ink_wash_widgets.dart → 不引用 GoogleFonts
  └── lib/pages/*.dart                 → 不引用 GoogleFonts

Test Harness
  └── test/taiyi/test_harness.dart
       ├── 不注入伪造 FontManifest
       ├── 不引入测试专用空壳字体
       ├── MockAssetBundle 仅承载 schools/deities JSON
       └── 历史注释 (line 24-25): "太乙主题已不依赖 GoogleFonts;
                                    统一使用系统/Flutter 内置字体,
                                    测试无需注入 FontManifest 或字体替换开关."
```

### 字体回退路径

| 位置 | 之前 | 之后 |
|------|------|------|
| 中文标题 (`ChineseSectionHeader`, `InkyBorder`) | `GoogleFonts.maShanZheng()` | Flutter `TextStyle` (默认 family, 系统中文字体) |
| 篆体装饰 | `GoogleFonts.longCang()` | Flutter `TextStyle` |
| 衬线正文 | `GoogleFonts.notoSerifSc()` | Flutter `TextStyle` |
| 古文风格 (`beauty_page`) | (本来就是 `KaiTi`) | 不变, `fontFamily: 'KaiTi'` |
| Mono 风格 (`school_editor_sections`) | (本来就是 `monospace`) | 不变, `fontFamily: 'monospace'` |

## 数据流

无运行时数据流变化. 这是一个**依赖解耦** + **验收任务**, 不引入新逻辑.

### 测试执行流

```
flutter test test/bdd/deity_management_bdd_test.dart
  → TaiYiTestHarness.setup()
      ├── TestWidgetsFlutterBinding.ensureInitialized()
      ├── PathProviderPlatform.instance = _FakePathProviderPlatform()
      └── 加载真实 schools/deities JSON 到 _mockAssets (非 fontManifest)
  → AC8 / AC10 / AC11 / AC12 testWidgets
      ├── TaiYiPanController(assembly: assembly)
      ├── pump MaterialApp(home: TaiYiPanPage)
      ├── tap Icons.auto_awesome → 打开 deity_management_dialog
      └── expect 文本 / Key / SnackBar
  → tearDown: db close
```

测试中**无任何 font asset 加载**, 因此**无任何 font not found 报错**.

## 技术决策

### TD-1: 完全移除 vs 留作可选依赖

**决策**: 完全移除.

**理由**:
- QA 决策已批准视觉降级.
- 留作可选会带来"测试环境某些路径仍 fallback 到 GoogleFonts"的灰区, 增加 AC 验收复杂度.
- `flutter pub get` 时无需联网拉取 google_fonts package 本体, CI 离线友好.

### TD-2: 测试 harness 是否需要 fontManifest 处理

**决策**: 不需要.

**理由**:
- Flutter 测试环境下, 未声明 `fontFamily` 的 `Text` widget 使用 `kTestFontFamily` (Ahem 字体), 不触发 FontManifest 查询.
- 显式声明的 `fontFamily: 'KaiTi'` / `fontFamily: 'monospace'` 在测试环境下静默 fallback, 不抛错.
- `test_harness.dart` 中已有注释明确不注入 FontManifest.

### TD-3: AC8 / AC10 当前实现是否需要修改

**决策**: 不修改, 仅验证.

**理由**:
- 经实测 `flutter test --concurrency=1 test/bdd/deity_management_bdd_test.dart`, AC8 / AC10 / AC11 / AC12 全部 PASS (4/4).
- 测试输出零 `font not found`.
- BDD 测试当前断言:
  - AC8: 三区文本 + `marketplace-placeholder` Key + `my-deities-empty` Key 全部 findsOneWidget.
  - AC10: SnackBar widget + `已复制` 文本 findsOneWidget.

### TD-4: pubspec.yaml 复检

**决策**: 复检确认无 `google_fonts:` 行.

**结果**: `dependencies:` 节中只声明 `logger`, `tuple`, `tyme`, `intl`, `meta`, `collection`, `json_annotation`, `cupertino_icons`, `common`. **无 `google_fonts`**.

## 权衡与已知限制

| 项目 | 状态 |
|------|------|
| 视觉风格降级 | 已接受 (QA 批准) |
| 中文字符在桌面端测试可能渲染为方块 (Ahem 字体) | 已接受 (BDD 通过 `expect(find.text('...'))`, 不依赖像素渲染) |
| iOS/Android 真机字体回退到系统字体 | 已接受 (生产环境用户体验仍可读) |
| 历史 `lib/pages/beauty_page.dart` 中 `fontFamily: 'KaiTi'` 在 Android 上可能找不到该字体 | **out of scope** (这是历史代码, 与 GoogleFonts 解耦无关) |

## 验收条件（必须可逐项勾选）

- [x] **VC-1**: `grep -rEn "google_fonts\|GoogleFonts" lib/` 返回零匹配 (Exit code 1, 无 stdout).
- [x] **VC-2**: `pubspec.yaml` 主依赖节 (`dependencies:`) 不包含 `google_fonts:`.
- [x] **VC-3**: `grep -rEn "MockAssetBundle.*FontManifest|fakeFontManifest" test/` 返回零匹配 (Exit code 1, 无 stdout).
- [x] **VC-4**: `grep -rn "MaShanZheng\|LongCang\|NotoSerif" lib/ test/` 返回零匹配 (Exit code 1, 无 stdout).
- [x] **VC-5**: `flutter pub get` 成功无错误.
- [x] **VC-6**: `flutter analyze lib/ test/` 不引入新的 warning/error (本任务相关范围内为零; pre-existing warnings 不在本任务 surgical 范围内).
- [x] **VC-7**: `flutter test --concurrency=1 test/bdd/deity_management_bdd_test.dart` 全绿: `+4 -0`, AC8/AC10/AC11/AC12 均 PASS.
- [x] **VC-8**: BDD 测试输出 `flutter test test/bdd/deity_management_bdd_test.dart 2>&1 | grep -i "font not found"` 返回零行.
- [x] **VC-9**: `test/taiyi/test_harness.dart` 中已有注释 (line 24-25) 明确不注入 FontManifest, 且代码与注释一致.

## 变更记录

| 日期 | 修订人 | 变更摘要 |
|------|--------|---------|
| 2026-05-26 | ClaudeCode (RBDDS subagent) | 初稿 + 锁定. 验证 GoogleFonts 解耦在 commit 42919b9 已完成, 本 SPEC 用于记录验收状态. |

## 给 Master 的建议

1. **本任务 ZT-16 实际是验收任务**: 真正的代码解耦工作在 commit `42919b9` 已经完成. 本 RBDDS 子代理交付的是**反伪验证 + SPEC 归档**, 不引入代码修改.
2. **后续若要在 lib/ 再次引入字体, 必须**:
   - 优先使用 `assets/fonts/*.ttf` 本地资源 + `pubspec.yaml > flutter > fonts:` 声明.
   - 严禁 `package:google_fonts` 运行时拉取.
   - 测试必须能在离线环境 + 无 FontManifest 伪造下绿.
3. **建议把 `grep -rEn "google_fonts|GoogleFonts" lib/` 加到 CI pre-commit hook**, 防止回滚.
