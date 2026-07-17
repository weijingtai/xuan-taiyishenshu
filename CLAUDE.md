> **架构方向 · 盘面渲染统一到 `metaphysics-chart-ui`（Chart-UI）**
>
> 本模块的「排盘 / 盘面」渲染将迁移到共享的专用排盘包 `metaphysics-chart-ui`（4 个通用渲染器 + 自带 5 级优先级 token 主题系统），**替换当前模块内自有的盘面实现**。
> - 不要再扩展或重写模块自有的盘面 Canvas painter / 盘面级主题；新的盘面工作一律经 Chart-UI 的中性模型 + 渲染器 + 模块适配器接入。
> - 盘面样式**不走** `XuanThemeData.component()` / `ComponentStyle` 通用主题迁移；那条通路只负责非盘面的 card / 组件（这些组件不退役，照常迁移）。
> - 背景见 `openspec/changes/create-metaphysics-chart-ui-package`（QiZhengSiYu 为首个迁移消费者）。

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **xuan-taiyishenshu** (6856 symbols, 13609 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? `npx gitnexus analyze` (npm 11 crash → `npm i -g gitnexus`; #1939).

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows. For regression review, compare against the default branch: `detect_changes({scope: "compare", base_ref: "main"})`.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit changes without running `detect_changes()` to check affected scope.

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
