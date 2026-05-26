# SELF.md — ZT-21 子代理初始化记录

- 代理身份: ClaudeCode (Claude Opus 4.7 1M-context, RBDDS subagent)
- 派发者: Master Agent (ClaudeCode 主体)
- ZenTao 账号: ClaudeCode
- 任务 ID: ZenTao #21 (QA-5 星神 Dialog 与显示偏好真实验收)
- 工作分支: `feat/taiyi-zt-claudecode-claim`
- 工作目录: `docs/wjt-Claude/qa/zt-21-dialog-preference-2026-05-26/`
- 启动日期: 2026-05-26

## 已读宪法清单
- [x] AGENTS.md (xuan-taiyishenshu)
- [x] AI_README.md (xuan-taiyishenshu)
- [x] docs/ai/principles.md
- [x] docs/ai/phases.md (Part A + Part B)
- [x] docs/ai/delivery-pipeline.md
- [x] docs/ai/code-style.md (Dart/Flutter 命名 + 注释)

## 引用宪法版本
- 项目宪法: 由 AI_README.md 链接至 docs/ai/* (12 模块体系)
- 全局宪法路由: `~/.claude/CLAUDE.md` → `.ai-governance/DEVELOPMENT-GOVERNANCE-ROUTER.md`
- RBDDS 萌芽委派契约: Master 派发，子代理仅产出，不动看板/不 commit

## 与本任务相关的输入
- `docs/wjt-Claude/qa/zt-17-ac-matrix-2026-05-26/AC_TEST_MATRIX.md` (Master 在 ZT-17 已完成的新矩阵; AC8/AC9/AC13 由本任务推进)
- `docs/superpowers/specs/2026-05-23-taiyi-school-manager-mvp-design.md` 第 345-413 行 (AC 原文)
- `lib/widgets/deity_management_dialog.dart` (Dialog 三区已存在; 不可用置灰已有原因文本)
- `lib/controllers/taiyi_pan_controller.dart` (`setDeityVisibility` 存在 toggle-vs-set 漏洞)
- `lib/taiyi/usecases/calculate_pan_usecase.dart` (`preferenceMap` 加载已有, 但未影响 `builtInItems`)
- `lib/taiyi/taiyi_pan_calculator.dart` (`_buildBuiltInItems` 硬塞太乙/文昌/计神/始击, 这是 AC9 失败的根因)
- `test/integration/deity_dialog_integration_test.dart` (现有覆盖: SP 写入 + 重建 SP + onChanged==null)
- `test/bdd/hidden_reminder_test.dart` / `test/bdd/deity_visibility_bdd_test.dart`

## 禁区遵守清单
- 不写 `docs/<other-ai>/` / `docs/board/` / `docs/Plans.md` / `README.md` / `AI_README.md` / `docs/ai/`
- 不切换分支, 不 git commit/push, 不调 ZenTao API
- 不改 `lib/database/*` schema, 不动 `lib/navigator.dart` / `lib/pages/school_*.dart` / `lib/pages/entity_*.dart` / `assets/` / `pubspec.yaml` 主依赖
- 不用 `--no-verify` / `skip` / `@Skip` / 空断言

## 产出位置
- SPEC: `superpowers/specs/2026-05-26-ac8-ac9-ac13-real-acceptance-design.md`
- 状态文件: `../../../../tmp/task_21_state.json` (由 Master 读取的路径)
