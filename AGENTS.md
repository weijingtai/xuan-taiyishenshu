1|<!-- gitnexus:start -->
     2|# GitNexus — Code Intelligence
     3|
     4|This project is indexed by GitNexus as **xuan-taiyishenshu** (1498 symbols, 3138 relationships, 102 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.
     5|
     6|> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.
     7|
     8|## Always Do
     9|
    10|- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
    11|- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
    12|- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
    13|- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
    14|- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.
    15|
    16|## Never Do
    17|
    18|- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
    19|- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
    20|- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
    21|- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.
    22|
    23|## Resources
    24|
    25|| Resource | Use for |
    26||----------|---------|
    27|| `gitnexus://repo/xuan-taiyishenshu/context` | Codebase overview, check index freshness |
    28|| `gitnexus://repo/xuan-taiyishenshu/clusters` | All functional areas |
    29|| `gitnexus://repo/xuan-taiyishenshu/processes` | All execution flows |
    30|| `gitnexus://repo/xuan-taiyishenshu/process/{name}` | Step-by-step execution trace |
    31|
    32|## CLI
    33|
    34|| Task | Read this skill file |
    35||------|---------------------|
    36|| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
    37|| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
    38|| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
    39|| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
    40|| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
    41|| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |
    42|
    43|<!-- gitnexus:end -->
    44|---
    45|

## CI Commands
- format: `dart format .`
- lint/analyze: `dart analyze`
- test: `flutter test`
- build/smoke: `flutter build bundle`
- verify-vectors: `flutter test test/test_vectors_test.dart`

## Architecture Boundaries
- 核心算法目录：`lib/taiyi/`, `lib/models/`
- 敏感配置目录：`lib/config/` (如有)

## BDD/TDD Protocol
- **Test-First**: Bugs, core algorithms, and schema changes MUST have a test or test-vector before implementation.
- **Test-Vectors**: Located in `test-vectors/taiyishenshu/`. Must include `reasoning` and `authoritative_source`.
- **Metadata Verification**: Ensure internal calculation states (accumulated numbers, ju numbers) are verified.

## Hindsight 项目记忆

本项目共享记忆 bank: `S:P:TaiYiShenShu`

### 铁律
- Bug 修复后 **必须** 写入 bank（含失败尝试记录）
- 进入项目工作前 **必须** 先 recall 此 bank
- 写入必须使用格式模板，不允许自由文本
- 详细规范见 `docs/HINDSIGHT_PROJECT_BANK_SPEC.md`

### 写入模板
```
[类别] 问题一句话描述

组件: 受影响的具体文件/模块路径
功能: 涉及的具体功能名称（用于 tag 细分）
现象: 用户可见的表现
尝试:
  1. [agent名] 方案 → 结果（成功/失败）+ 原因
  2. [agent名] 方案 → 结果（成功/失败）+ 原因
最终方案: 怎么修的
下一步: 待做事项（如有）
tags: bug-fix:<功能名>
```

### Tag 规则
- 格式: `<类别>:<功能名>`
- 类别: `bug-fix` / `pitfall` / `migration` / `design`
- 功能名: 代码中实际存在的组件名，kebab-case
- 示例: `bug-fix:size-calculator`, `pitfall:drift-persistence`
- 单个功能 tag ≥ 20 条时细分，整个 bank ≥ 200 条时评估拆子 bank

## Hindsight Project Memory

本项目共享记忆 bank: `S:P:TaiYiShenShu`

### 铁律：Bug 修复必须写入
任何 agent 修复 bug 后，**必须**写入 S:P:TaiYiShenShu，包含：
- **每条记录 ≤ 200 字符**（中文约100字）
- 失败尝试（比成功记录更重要）
- 精简格式：`[tag] 标题` + `尝试: 失败方案 → 最终方案` + `tags: xxx`
- tag 使用三段式：`<类别>:<模块>[:<功能>]`
- 详细上下文放项目文件，不放 Hindsight

### 铁律：工作前先 Recall
任何 agent 进入本项目工作前，**必须**先 recall S:P:TaiYiShenShu 获取：
- 已知 bug 记录（避免重复试错）
- 踩坑记录（避免踩同一个坑）
- 架构决策（避免违背已确定的设计）

### 容量规则
- < 50 条：正常
- 50-100 条：用 `<模块>:<功能>` 三级 tag 细分
- 100-200 条：归档过时记录（tag: archived）
- **> 200 条：必须通知用户确认后才能拆子 bank**

### 详细规则
- Tag 规则：`../docs/HINDSIGHT_TAG_RULES.md`
- Memory 使用范式（必读）：`../docs/MEMORY_USAGE_PATTERN.md`
- 核心原则：不要防御性设计，遇到了再改

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **xuan-taiyishenshu** (1498 symbols, 3138 relationships, 102 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/xuan-taiyishenshu/context` | Codebase overview, check index freshness |
| `gitnexus://repo/xuan-taiyishenshu/clusters` | All functional areas |
| `gitnexus://repo/xuan-taiyishenshu/processes` | All execution flows |
| `gitnexus://repo/xuan-taiyishenshu/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
