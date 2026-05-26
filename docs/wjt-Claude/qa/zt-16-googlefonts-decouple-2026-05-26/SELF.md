# SELF

## AI 身份
- 使用者: wjt
- 模型 ID: claude-opus-4-7[1M]
- 模型品牌: Anthropic Claude
- 访问入口: Claude Code RBDDS subagent

## 本项目宪法版本
| 模块 | 版本 |
|------|------|
| AI_README.md | 1.1.0 |
| CONSTITUTION.md | 1.1.0 |
| board-protocol.md | 1.1.0 |
| glossary.md | 1.0.0 |
| principles.md | 1.0.0 |
| phases.md | 1.1.0 |
| delivery-pipeline.md | 1.0.0 |
| code-style.md | 1.0.0 |
| directory-structure.md | 1.1.0 |
| git-rules.md | 1.0.0 |
| doc-standards.md | 1.1.0 |
| toolchain.md | 1.0.0 |
| project-context-guide.md | 1.1.0 |

## 本任务
- 任务类型: refactor (依赖解耦) + 验收 (BDD AC8/AC10)
- 任务名称: GoogleFonts 解耦验收
- 关联看板任务 ID: ZenTao Task #16 (MVVM+Repository 集成测试 - GoogleFonts 解耦)
- 创建日期: 2026-05-26
- 工作分支: feat/taiyi-zt-claudecode-claim
- 派发人: wjt (Master Agent)
- 派发协议: RBDDS subagent, SPEC 即合约, 不需要等用户批准

## 任务目标摘要

QA 决策: 开发阶段统一用 Flutter/system 自带基础字体, 不再使用 Google Fonts 作为太乙页面/BDD 的依赖.
**#16 不允许因 google_fonts 字体加载失败而手动开门.**

## 验收要求 (来自 ZenTao #16)

1. BDD 必须在**无 GoogleFonts 运行时拉取**、**无测试专用空壳字体**下通过
2. `test/bdd/deity_management_bdd_test.dart` 中 **AC8/AC10 必须通过**
3. 测试输出**不得出现** `MaShanZheng-Regular`/`LongCang-Regular`/`NotoSerif-Regular` font not found
4. **不接受**仅通过 `MockAssetBundle` 伪造 `FontManifest`
5. All test passed

## 写入白名单 (本任务范围)
- `lib/**/*.dart` 仅去除/替换 GoogleFonts
- `test/bdd/deity_management_bdd_test.dart`
- `test/bdd/*.dart` (清理字体 hack)
- `pubspec.yaml` (可移除 `google_fonts`)
- 任务目录 `docs/wjt-Claude/qa/zt-16-googlefonts-decouple-2026-05-26/`

## 严禁修改
- `lib/database/*`, `lib/navigator.dart`, `lib/taiyi/data/*` 业务
- `assets/`, `docs/<other>/`, `docs/board/`, `docs/superpowers/`
- `AGENTS.md`, `AI_README.md`, `docs/ai/`
