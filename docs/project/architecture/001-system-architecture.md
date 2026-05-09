# ADR 001：系统架构决策

## 元信息

- 日期：2026-05-08
- 状态：已采纳
- 决策者：wjt

## 背景

太乙神数排盘需要支持三种流派（金镜/统宗/集成）四种盘类型（年/月/日/时），流派间在积年基数、太乙宫公式、文昌停留规则、计神序列、八门排法等方面存在差异。需要选择一种架构，既能共享公共计算逻辑，又能清晰表达流派差异。

## 决策

### ADR 001-1：策略模式封装流派差异

**决策**：使用内部 `_RuleProfile` 类（工厂构造函数 `forSchool()`）封装三派所有差异参数，而非抽象接口 + 三个实现类。

**理由**：
- 三派差异本质是参数差异（积年基数、公式类型、布尔开关），不是行为差异
- 数据驱动的规则配置比多态分派更简洁，避免三个只有数据不同的类
- 单一计算器类 + 规则配置使算法流程统一，差异点集中在一处

**权衡**：如果未来流派行为差异显著增大（不同计算步骤），可能需要重构为策略接口。当前规模下数据驱动足矣。

### ADR 001-2：ChangeNotifier + Listener 而非第三方状态管理

**决策**：使用 Flutter 内置 `ChangeNotifier` + 手动 `addListener`，不引入 Provider/Riverpod/Bloc。

**理由**：
- 应用只有一个主页面 + 一个核心状态对象，不需要多层依赖注入
- 避免引入第三方库的学习成本和版本兼容问题
- 手动 Listener 订阅在 `initState`/`dispose` 中管理，生命周期清晰

**权衡**：如果未来页面和状态对象增多，可能需要迁移到 Provider 或 Riverpod。当前规模下手动管理足够。

### ADR 001-3：扁平 lib/taiyi/ 而非嵌套 calculators/rules/core

**决策**：核心算法文件直接放在 `lib/taiyi/` 下，不使用 `lib/taiyi/core/`、`lib/taiyi/rules/`、`lib/taiyi/calculators/` 等嵌套结构。

**理由**：
- 当前算法集中在单一计算器文件（`taiyi_pan_calculator.dart`，1740 行），拆分到子目录会导致过多单文件包
- 枚举和模型已经按类型分到 `lib/enums/` 和 `lib/models/`
- 将来如果需要拆分（如将 `_RuleProfile` 提升为独立文件、拆分计算步骤），再建子目录

**权衡**：如果 `taiyi_pan_calculator.dart` 继续增长超过 3000 行，应考虑按计算步骤拆分为多个文件。

### ADR 001-4：PanComputedItem 统一输出格式

**决策**：使用 `PanComputedItem`（含 ID/名称/类型/落宫/来源/优先级/原因/元数据）作为统一的星神/八门/格局等计算结果的容器，而非每种结果使用不同模型。

**理由**：
- UI 层可以用统一方式渲染任意计算项，无需为每种星神写不同 Widget
- JSON 序列化统一，方便未来本地存储
- 优先级字段支持 UI 排序

### ADR 001-5：package:common 提取共享基础库

**决策**：将八卦枚举（`Enum8Gua`）、阴阳（`YinYang`）、二十四节气（`Season24Tag`）、九宫常量（`ConstantNineGongDataClass`）、环形文字绘制（`TextCircleRingPainter`、`CircleRingPainter`）等通用术数基础组件提取到独立 Git 仓库 `xuan-common`。

**理由**：
- 这些组件与太乙神数算法无关，是通用术数基础
- 可在多个术数项目（奇门、六壬等）间复用
- 独立版本管理，避免耦合

## 架构图

```
┌─────────────────────────────────────────────────┐
│  UI Layer (pages/ + widgets/)                    │
│  TaiYiPanPage → PanInfoPanel, TaiYiPanGrid, ... │
├─────────────────────────────────────────────────┤
│  Controller Layer                                │
│  TaiYiPanController (ChangeNotifier)             │
├─────────────────────────────────────────────────┤
│  Algorithm Layer (taiyi/)                        │
│  TaiYiPanCalculator + _RuleProfile              │
├─────────────────────────────────────────────────┤
│  Model Layer (models/ + enums/)                  │
│  PanDataModel, DiPanModel, TianPanModel, ...    │
├─────────────────────────────────────────────────┤
│  External: package:common                        │
│  Enum8Gua, YinYang, Season24Tag, ...            │
└─────────────────────────────────────────────────┘
```

## 后果

- 正面：架构简洁，代码集中于少量文件，新人理解成本低
- 负面：计算器文件过长（1740 行），未来需要拆分
- 风险：扁平结构如果持续增长可能变得难以导航
