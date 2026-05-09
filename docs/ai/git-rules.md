# Git 分支与提交规范

## Type 允许值

分支与提交共用同一 type 列表：

| type | 含义 | 分支可用 | 提交可用 |
|------|------|---------|---------|
| feat | 新功能 | Y | Y |
| fix | 缺陷修复 | Y | Y |
| update | 修改已有功能/逻辑 | Y | Y |
| refactor | 纯重构（不改变功能） | Y | Y |
| docs | 文档变更 | Y | Y |
| chore | 构建/依赖/工具变更 | Y | Y |
| remove | 删除文件/功能 | — | Y |
| init | 项目初始化 | — | Y |

`remove` 和 `init` 仅用于提交，不用于分支（分别用 `chore` 分支承载）。

## 分支命名

```
MUST 格式: <type>/<short-description>

short-description:
  MUST: 小写英文字母 + 连字符
  MUST: 至少包含一个中文拼音或英文功能关键词
  MUST: 长度 8-40 字符
```

**正确示例：**
```
feat/yang-dun-calculator
fix/wenchang-redouble
refactor/gong-panel-extract
docs/ai-readme
```

**错误示例：**
```
dev                   ← type 不在允许列表
feat/fix-bug          ← 描述无意义
feat/a                ← 描述太短
测试分支               ← 未使用英文/拼音
```

## 提交信息

```
MUST 格式: <type>: <中文简述>

MUST: 简述不超过 30 个中文字
MUST: 简述准确描述"做了什么"，不描述"为什么"（为什么在注释中说明）
```

**正确示例：**
```
feat: 太乙年家积年计算器
fix: 阴阳遁冬至分界错误
update: 统宗派五福宫盈差配置
refactor: 九宫面板提取为独立组件
remove: 废弃的旧占卜记录模型
init: Flutter 项目基础结构
```

**错误示例：**
```
"fix bug"              ← 缺少 type 分隔符（冒号+空格）
"fix"                  ← 缺少简述
"修改了一些代码"        ← 缺少 type
"WIP"                  ← 不可合并的临时提交
"update: code"         ← 简述非中文
"add: new feature"     ← type 不在允许列表 + 简述非中文
```

## 提交粒度

MUST: 一个提交 = 一个逻辑变更
MUST: 一个逻辑变更的 diff 可独立 revert 而不破坏其他功能
MUST NOT: 混入不相关的文件修改（如修 A 功能时顺带改 B 功能的不相关代码）
MUST NOT: 提交调试代码、打印语句、注释掉的代码
MUST NOT: 提交 `--no-verify`（跳过 Git hooks）

## 提交内容红线

| MUST NOT | 示例 |
|----------|------|
| 密钥/凭证 | `.env`, `credentials.json`, API keys |
| 大二进制 | `*.apk`, `*.ipa`, `*.zip`, 图片资源（>100KB 的除外） |
| 生成目录 | `build/`, `.dart_tool/`, `.android/`, `.ios/` |
| IDE 配置 | `.vscode/`, `.idea/`（已在 .gitignore 中则为安全） |

MUST: Git 操作前确认 .gitignore 已排除生成目录
