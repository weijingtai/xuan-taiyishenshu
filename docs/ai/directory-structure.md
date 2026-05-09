# 目录与文件结构规范

## 顶层目录约束

```
<项目根目录>/
  AI_README.md           ← AI 宪法入口（LLM 永远只读）
  README.md              ← 项目说明
  pubspec.yaml           ← Flutter 项目配置
  analysis_options.yaml  ← Lint 配置
  build.yaml             ← 构建配置
  .gitignore             ← Git 忽略规则

  lib/                   ← MUST: 所有源代码
  test/                  ← MUST: 所有测试（镜像 lib/ 结构）
  docs/                  ← MUST: 所有文档 + AI 工作区 + 看板
  scripts/               ← MAY: 辅助脚本

  build/                 ← MUST NOT 提交
  .dart_tool/            ← MUST NOT 提交
  .android/              ← MUST NOT 手动修改
  .ios/                  ← MUST NOT 手动修改
```

MUST NOT: 根目录散落 `.dart` 文件
MUST NOT: 根目录散落非上述列出的 `.md` 文件（所有 .md 文档 MUST 放在 `docs/` 下，除 AI_README.md 和 README.md）
MUST NOT: 根目录出现配置文件（`.env`、`local.properties`、用户 IDE 配置等）

## lib/ 结构约定

```
lib/
  main.dart              ← 入口
  navigator.dart         ← 路由

  taiyi/                 ← 核心算法包
    core/                ← 引擎、枚举、输入输出模型
    rules/               ← 三派规则集实现
    calculators/         ← 各计算步骤
    data/                ← 常量/查表数据
    classics/            ← 典籍模块
    records/             ← 占卜记录

  models/                ← 通用数据模型
  enums/                 ← 枚举定义
  pages/                 ← 页面 Widget
  widgets/               ← 复用 Widget 组件
  controllers/           ← 状态管理/控制器
  painter/               ← 自定义绘制
  theme/                 ← 主题配置
```

MUST: 新包按功能域组织，不按技术层（如不放 models/ 下混放所有模型）
MUST: 已在 docs/Plans.md 中约定的结构，MUST 遵守
SHOULD: 新增独立功能域在 lib/ 下新建包目录

## test/ 结构约定

```
test/
  taiyi/
    core/
    rules/
    calculators/
  models/
  ...
```

MUST: test/ 目录结构镜像 lib/ 结构
MUST: 测试文件命名: `<source_file>_test.dart`
MUST NOT: 测试文件散落在 test/ 根目录

## docs/ 结构约定

```
docs/
  README.md                             ← docs/ 使用说明（人维护，AI 默认只读）

  ai/                                   ← AI 协同宪法（LLM 永远只读）
    CONSTITUTION.md                     ← 全局版本清单
    board-protocol.md                   ← 看板使用协议 + 权限矩阵
    glossary.md                         ← 术语
    principles.md                       ← 原则
    phases.md                           ← 阶段
    delivery-pipeline.md                ← 交付流水线
    code-style.md                       ← 代码规范
    directory-structure.md              ← 目录规范（本文件）
    git-rules.md                        ← Git 规范
    doc-standards.md                    ← 文档规范
    toolchain.md                        ← 工具链
    project-context-guide.md            ← 上下文阅读规则

  ai_dev_init/                          ← AI 首次初始化过程记录
    <developer>-<Model>/                ← 各 AI 的初始化目录
      SELF.md                          ← 初始化会话身份
      logs/                            ← MAY: 初始化过程日志

  board/                                ← 公共进度看板
    TASKS.md                            ← 任务队列（AI 默认只读，写入走 W1-W5）
    PROGRESS.md                         ← 进度仪表盘（AI 永远只读）

  project/                              ← 纯项目内容（人维护，AI 默认只读）
    prds/                               ← 产品需求文档
    features/                           ← 功能规格说明
    architecture/                       ← 架构决策记录 (ADR)
    changelog/                          ← 版本发布日志

  <developer>-<Model>/                  ← 各 AI 的独立工作区
    features/                           ← 功能开发
    refactors/                          ← 重构
    fixes/                              ← 修复
    chores/                             ← 杂项
```

MUST: AI 协同规范放在 `docs/ai/`
MUST: AI 首次初始化过程文件放在 `docs/ai_dev_init/<developer>-<Model>/`
MUST: 看板文件放在 `docs/board/`
MUST: 项目内容放在 `docs/project/`
MUST NOT: docs/ 下放代码、二进制、图片（如有需要，放在 `docs/assets/`）
MUST NOT: AI 任务产生任何文件到全局 `docs/superpowers/`——所有 SPEC 和计划 MUST 放在任务目录下的 `superpowers/` 中

## AI 工作区结构约定

### 目录命名

`docs/<developer>-<Model>/<type>/<name>-<YYYY-MM-DD>/`

| 组件 | 格式 | 示例 |
|------|------|------|
| AI 标识 | `<developer>-<Model>` | `wjt-Claude`, `wjt-Deepseek` |
| 任务类型 | `features` / `refactors` / `fixes` / `chores` | `features` |
| 任务目录 | `<name>-<YYYY-MM-DD>` | `Login-2026-05-09` |

### 任务目录内容

```
<type>/<name>-<date>/
  SELF.md           ← MUST: AI 自身说明文件（模型信息、宪法版本、追溯链）
  superpowers/      ← MUST: 本任务的 SPEC 和实现计划（不可放在全局 docs/superpowers/）
    specs/          ← SPEC 设计文档
    plans/          ← 实现计划
  logs/             ← MAY: 执行日志
```

### 任务创建流程

AI 收到新任务时，MUST 按以下顺序创建目录：

```
1. 创建任务目录: docs/<me>/<type>/<name>-<YYYY-MM-DD>/
2. 写入 SELF.md
3. 创建 superpowers/specs/ 和 superpowers/plans/
4. 在 superpowers/specs/ 中创建 SPEC 文件
5. 所有后续文件（计划、日志等）MUST 输出到此任务目录下
```

MUST: 每个任务目录首次创建时写入 SELF.md
MUST: SELF.md 包含宪法版本表（逐模块）和任务类型/名称/日期
MUST: SPEC 和计划文件 MUST 放在任务目录的 `superpowers/` 下，NOT 全局 `docs/superpowers/`
MUST NOT: 在全局 `docs/superpowers/` 创建新文件（已有文件为历史记录，只读）

## 权限矩阵

详见 [docs/ai/board-protocol.md](board-protocol.md) 完整权限矩阵。

核心规则：
- AI 永远只读: `AI_README.md`、`docs/ai/`、其他 AI 的 `docs/<other>/`、全局 `docs/superpowers/`（历史记录）
- AI 自主读写: 自己的 `docs/<me>/<type>/<name>-<date>/`（含 superpowers/）
- AI 初始化时自主读写: `docs/ai_dev_init/<me>/`
- AI 经人许可+命令后可写: `docs/board/`、`docs/Plans.md`、`docs/project/`

## 新增文件/目录的准入标准

| 检查项 | 标准 |
|--------|------|
| 文件位置 | 是否符合上述目录约定 |
| 文件命名 | snake_case (Dart) / kebab-case (Markdown) / `<name>-<YYYY-MM-DD>` (任务目录) |
| 是否冲突 | 不重复已有文件的职责 |
| 是否过细 | 单一函数不单独建文件（除非是公开 API 核心算法） |
