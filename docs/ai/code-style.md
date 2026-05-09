# Dart/Flutter 代码规范

## 基础规则

MUST: 代码 MUST 通过 `flutter analyze`（基于 `analysis_options.yaml` 中的 `flutter_lints`）
MUST: 代码 MUST 通过 `dart format`，无格式差异
MUST: 编码使用 UTF-8

## 命名规范

| 类型 | 规范 | 正确示例 | 错误示例 |
|------|------|----------|----------|
| 文件名 | snake_case | `taiyi_engine.dart` | `TaiYiEngine.dart` |
| 类名 | PascalCase | `TaiYiEngine` | `taiYiEngine` |
| 方法/函数 | camelCase | `calculateJuNumber()` | `CalculateJuNumber()` |
| 变量 | camelCase | `accumulatedYear` | `accumulated_year` |
| 常量 | camelCase | `defaultJuCycle` | `DEFAULT_JU_CYCLE` |
| 枚举值 | camelCase | `jingMirror` | `JING_MIRROR` |
| 私有成员 | `_` 前缀 + camelCase | `_ruleSet` | `ruleSet_` |

MUST NOT: 拼音命名（项目专有术语除外：taiyi, wenchang, jishen 等已约定）
MUST NOT: 单字母变量名（循环索引 `i`, `j`, `k` 除外）
MUST NOT: 匈牙利命名法或前缀类型编码（`strName`, `bIsValid`）
MUST NOT: SCREAMING_SNAKE_CASE 常量（Dart 风格用 camelCase）

## 文件结构

MUST: 一个文件一个核心类/职责
MUST: 文件行数上限 300 行（超出 MUST 拆分）
MUST NOT: 一个文件中混合不相关的多个类

**导入顺序**（各组间空行分隔）：

```dart
// 1. dart: 内置库
import 'dart:math';

// 2. package: 依赖
import 'package:flutter/material.dart';

// 3. 相对路径导入
import 'taiyi_engine.dart';
```

MUST NOT: 使用 `show` / `hide` 修饰符（除非解决直接命名冲突）

## 注释规范

| 场景 | 规范 |
|------|------|
| 公开类/方法/函数 | MUST 有一行中文 `///` 简述 |
| 私有核心方法 | MUST 有一行中文 `//` 简述（非核心的私有助手方法可省略） |
| 复杂逻辑分支 | MUST 在分支前有 `//` 说明 WHY（不说 WHAT） |
| 枚举值 | 每个值 MUST 有 `///` 中文说明 |

**示例：**

```dart
/// 太乙排盘统一入口，按流派和盘类型计算完整盘面
class TaiYiEngine {
  /// 计算积年，不同流派使用不同积年基准
  int _calculateAccumulatedYear(TaiYiInput input) {
    // 金镜派和统宗派使用古积年，集成派使用当代甲子元
    if (input.school == TaiYiSchool.jiCheng) {
      return _contemporaryOriginYear(input);
    }
    return _ancientAccumulatedYear(input);
  }
}
```

MUST: 注释描述 WHAT（代码本身已表达）
MUST: 注释描述 WHY（为什么这样写、为什么不用另一种方式）
MUST NOT: 冗余注释（如 `// 创建对象` 在 `new Foo()` 上方）
MUST NOT: 注释掉的代码（直接删除，Git 历史可恢复）

## 代码质量

| 规则 | 级别 |
|------|------|
| MUST NOT 硬编码字符串/数字（提取为常量或枚举） | 硬门禁 |
| MUST NOT 超过 300 行单文件 | 软提醒 |
| MUST NOT 嵌套超过 3 层的 if/for/while | 软提醒 |
| MUST NOT 使用 `dynamic`（除非与平台通道交互） | 软提醒 |
| MUST NOT 忽略异常而不记录原因 | 硬门禁 |
| SHOULD 优先使用 `const` 构造函数 | 最佳实践 |
| SHOULD 使用 `final` 而非 `var`（当变量不再赋值时） | 最佳实践 |
