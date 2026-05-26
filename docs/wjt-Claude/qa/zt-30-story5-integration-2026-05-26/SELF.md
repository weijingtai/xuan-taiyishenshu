# SELF — ClaudeCode-subagent (ZT-30)

- 任务: ZenTao Task #30 — [Story#5][Integrate] MVVM+UseCase+Repository 全链路整合
- 分支: `feat/taiyi-zt-claudecode-claim` (不切换)
- 受派发: Master (RBDDS subagent)
- 工作目录: `docs/wjt-Claude/qa/zt-30-story5-integration-2026-05-26/`
- 日期: 2026-05-26

## 边界

- 写白名单: `lib/taiyi/viewmodels/*.dart` (除 ZT-21 已改部分)、`lib/taiyi/usecases/*.dart` (除 ZT-21 已改部分)、`lib/taiyi/taiyi_assembly.dart`、`lib/navigator.dart`、新建 `test/integration/zt30_*.dart`、本任务目录文档。
- 写禁止: `lib/widgets/*.dart`、`lib/pages/*.dart` (ZT-25+10 在改 Key/Semantics)、`lib/main.dart`、`lib/taiyi/taiyi_pan_calculator.dart`、`lib/controllers/taiyi_pan_controller.dart` (ZT-21 已改)、`lib/database/*` schema、`assets/`、`pubspec.yaml`、`docs/ai/`、其它 docs。

## 范围 (审计 ZT-21 后剩余整合点)

继承 ZT-21 已打通的 "勾选→盘面刷新" (AC8/AC9/AC13)，本任务关注 Story #5 其余整合点:

1. **AC3/AC10/AC11**: 编辑器→ViewModel→UseCase→Repository→重载列表的完整闭环 (跨 ViewModel 触发)。
2. **AC10 (schoolScopes 过滤)**: 用户星神 schoolScopes=['jiCheng'] 在 jingMirror 盘上不应出现 — 当前 AC 矩阵明确标缺。
3. **AC12 (多级 lineage)**: A→B→C 多级派生的 lineage 链是否完整保留。
4. **AC7 (MVVM 全链路 happy path)**: school 编辑保存 → 盘面 recompute → accumulatedYear 变化 单一测试覆盖。

## 交付物

- SPEC: `superpowers/specs/2026-05-26-story5-mvvm-fullchain-integration-design.md`
- 新增测试: `test/integration/zt30_*.dart`
- 状态: `tmp/task_30_state.json`
