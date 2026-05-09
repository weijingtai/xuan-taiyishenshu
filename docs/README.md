# docs/ 目录说明

## 结构概览

```
docs/
  README.md               ← 本文件（docs/ 使用说明）
  Plans.md                ← 项目总体规划（人维护）

  ai/                     ← AI 协同宪法（LLM 只读）
  board/                  ← 公共进度看板（LLM 受限读写）
  project/                ← 纯项目内容（人维护）

  <developer>-<Model>/    ← 各 AI 的独立工作区
    features/             ← 功能开发任务
    refactors/            ← 重构任务
    fixes/                ← 修复任务
    chores/               ← 杂项任务
```

## 使用者指南

### 人（项目维护者）
- 编辑 `Plans.md` 把控项目方向
- 维护 `docs/board/PROGRESS.md` 跟踪进度
- 维护 `docs/project/` 下的 PRD/ADR/Changelog
- 维护 `docs/ai/` 下的宪法文件（通过 SPEC Coding 流程）
- 维护 `AI_README.md`（宪法入口）

### AI（任意模型/IDE）
- MUST 首次接入时读取 `AI_README.md` 及 `docs/ai/` 下全部模块
- MUST 严格遵守 `docs/ai/board-protocol.md` 中的权限矩阵
- MUST 仅在自己的 `<me>/` 目录下自主写入
- MUST 对其他区域的操作经"人"的明确命令 + 许可

## 权限速查

| AI 可以自主做的 | AI 不可以自主做的 |
|---------------|-----------------|
| 写 `docs/<me>/features/<name>-<date>/` 下所有文件 | 写 `docs/ai/` 下任何文件 |
| 读 `docs/ai/` 全部模块 | 写 `AI_README.md` |
| 读其他 AI 的工作目录（`docs/<other>/`） | 写 `docs/board/` 下任何文件 |
| 经人许可 + 命令后写 `docs/board/` | 写 `docs/Plans.md` |
| 经人许可 + 命令后写 `docs/project/` | 主动读取 `docs/board/` |

详见 `docs/ai/board-protocol.md` 完整权限矩阵。
