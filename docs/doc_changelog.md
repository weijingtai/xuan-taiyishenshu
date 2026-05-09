# 文档体系变更日志

## 2026-05-09 — 文档体系结构调整

### 变更内容

1. **新增 `docs/ai_dev_init/` 初始化目录**：AI 首次接入项目时，MUST 在 `docs/ai_dev_init/<developer>-<Model>/` 下创建 `SELF.md` 及过程日志。该目录用于保存所有"过程"文件（初始化记录、读取日志等），而非最终输出结果。

2. **任务目录规范重申**：所有 feature / refactor / fix / chore 类型任务，MUST 先在 `docs/<developer>-<Model>/<type>/<name>-<YYYY-MM-DD>/` 下创建任务目录，所有产物（含 superpowers/specs/ 和 superpowers/plans/）MUST 输出在该任务目录下。**禁止**在全局 `docs/superpowers/` 下生成任务文件。

3. **移除 `docs/superpowers/`**：该目录是开发 `weijingtai/docs` 项目时的 AI 协同宪法引导产物，宪法体系已于 2026-05-09 正式交付完成。该目录中的 SPEC 和 Plan 均为引导性文档，不涉及本项目（太乙神数）的实际功能开发。已从 git 历史中移除，并在 `.gitignore` 中添加忽略规则。

### 移除 docs/superpowers 的原因

- `docs/superpowers/` 中的文件（`ai-readme-design.md`、`ai-governance-v2-design.md`、`ai-readme-implementation.md`）全部用于**设计 AI 协同宪法本身**，属于元层面的引导开发工作
- 该阶段工作已于 2026-05-09 随宪法 12 模块全部交付而完成
- 此后本项目的所有实际开发任务（太乙神数功能）的 SPEC 和 Plan 均存放在各自任务目录的 `superpowers/` 下，不再使用全局 `docs/superpowers/`
- 保留该目录会造成混淆——AI 可能误以为应在其中创建新 SPEC

### 当前文档体系结构

```
docs/
  ai/                      ← AI 协同宪法（12 模块，永远只读）
  ai_dev_init/             ← AI 初始化过程记录（过程文件，非输出结果）
    <developer>-<Model>/
      SELF.md              ← 初始化会话身份
      logs/                ← 初始化过程日志
  board/                   ← 公共进度看板
  project/                 ← 纯项目内容（PRD、功能说明、架构、发布日志）
  <developer>-<Model>/     ← 各 AI 独立工作区
    features/              ← 功能开发（含 superpowers/specs + plans）
    refactors/             ← 重构
    fixes/                 ← 修复
    chores/                ← 杂项
  doc_changelog.md         ← 本文件
```
