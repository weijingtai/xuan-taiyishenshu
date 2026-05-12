# 可配置流派与星神系统 设计规格

## 元信息

- 创建日期: 2026-05-08
- 状态: 已完成（2026-05-09 验收通过）
- 关联需求: 将太乙神数三派硬编码系统重构为可配置的流派/星神引擎，支持 JSON 配置文件驱动的"官方版"和可视化编辑的"用户自定义版"

## 目标

1. 流派可编辑、可切换、可新增——不再硬编码 `TaiYiSchool` 枚举
2. 星神可自由创建，跨流派共享
3. 每种流派通过配置定义：积年参数、包含的星神列表、每个星神的算法参数覆写
4. 星神算法通过 6 种参数化模板 + 表达式兜底表达，覆盖金镜/统宗/集成/淘金歌/登坛必究/黄帝元年全部已知算法
5. 两种配置来源：官方 JSON（`assets/`）+ 用户自定义（数据库），统一通过 Repository 接口加载
6. 三派现有代码全量迁移到新的配置系统

## 非目标

- 本 SPEC 不包含可视化编辑器的 UI 设计（另开 SPEC）
- 不包含小格局判断的补充（属于已有待完成项）
- 不包含典籍匹配和占卜记录功能
- 不包含刻家实现

## 架构设计

### 总体分层

```
┌──────────────────────────────────────────────┐
│                  UI Layer                     │
│  流派选择器 / 信息面板 / 网格 → 读取配置+结果  │
├──────────────────────────────────────────────┤
│           TaiYiPanCalculator (编排层)         │
│  积年→年计→局数→阴阳遁→核心算法→星神→格局    │
├──────────────────────────────────────────────┤
│          DeityAlgorithmEngine (算法引擎)       │
│  模板执行器 (6种) + 表达式解析器 (兜底)        │
├──────────────────────────────────────────────┤
│           SchoolRepository (配置层)            │
│  OfficialJsonRepo (assets/) + CustomRepo (DB) │
├──────────────────────────────────────────────┤
│  数据模型: SchoolConfig / DeityDefinition /   │
│            AlgorithmSpec / SchoolEpochConfig   │
└──────────────────────────────────────────────┘
```

### 核心决策

- `TaiYiSchool` 从 `enum` 改为普通 data class，用 `id: String` 标识
- 星神定义 (`DeityDefinition`) 独立于流派，流派通过 `deityIds` + `overrides` 引用
- 核心算法（积年/局数/阴阳遁/太乙宫/文昌/计神/始击/主客算/大将参将/八门）保留在 Calculator 编排层，不走模板引擎
- 星神落宫计算走模板引擎

## 数据流

```
assets/schools/*.json  ─┐
assets/deities/*.json  ─┤
                         ├─→ SchoolRepository.loadAll() → List<SchoolConfig>
自定义配置 (数据库)     ─┘                              → List<DeityDefinition>
                                  │
                                  ▼
TaiYiPanCalculator.calculate(input)
  │  1. 根据 input.schoolId 查找 SchoolConfig
  │  2. SchoolEpochConfig → 积年
  │  3. 年计 / 局数 / 阴阳遁 (固定编排)
  │  4. 太乙宫 / 文昌 / 计神 / 始击 / 主客算 / 八门 (核心算法)
  │  5. DeityAlgorithmEngine.execute(config.deities, context)
  │     → Map<String, DeityPlacementResult>
  │  6. 格局判断
  │  7. 组装 PanDataModel
  ▼
PanDataModel → UI 渲染
```

## 技术决策

### 1. 数据模型

#### TaiYiSchool（原 enum → data class）

```dart
class TaiYiSchool {
  final String id;           // 唯一标识，如 "jingMirror", "tongZong", "custom:abc123"
  final String name;         // 中文名，如 "金镜派"
  final String source;       // "official" / "custom"
  final SchoolEpochConfig epoch;
  final List<String> deityIds;         // 包含的星神 ID
  final Map<String, dynamic>? overrides; // 星神参数覆写
  final TaiYiPalaceFormula palaceFormula;
  final bool wenChangStayRule;
  final bool useTwelveJiShen;
  final EightDoorMode eightDoorMode;
}
```

#### SchoolEpochConfig

```dart
class SchoolEpochConfig {
  final int ancientBase;       // 上元积年基数
  final int epochYear;         // 纪元锚点年（公元）
  final int correction;        // 修正值
  final double tropicalYear;   // 默认 365.2425
}
```

#### DeityDefinition

```dart
class DeityDefinition {
  final String id;             // 唯一标识
  final String name;           // 中文名
  final DeityLayer layer;      // 天盘/神盘/人盘/地盘/命盘 (复用已有 EnumDeityLayer)
  final DeityAlgorithmSpec algorithm;
  final int priority;          // 同宫显示优先级
  final String? description;
  final String source;         // "official" / "custom"
}
```

#### DeityAlgorithmSpec

```dart
class DeityAlgorithmSpec {
  final AlgorithmTemplateId templateId;  // 6 种模板之一
  final Map<String, dynamic> params;     // 模板参数
}
```

#### PalaceStep

```dart
class PalaceStep {
  final String palace;         // 宫位标识（引用 EnumTaiYiGong 或分支名或卦名）
  final int staySteps;         // 停留步数，默认 1
}
```

#### SteppedCycleParams（params 的具体结构，用于校验）

```dart
class SteppedCycleParams {
  final int correction;
  final List<CycleStep> steps;
  final PalaceSystem palaceSystem;
  final List<PalaceStep>? palaceSeq;
  final WalkDirection? direction;
  final String? startPalace;
  final DunType? dunBinding;  // null = 阴阳遁双模式
  final DunVariantConfig? yangConfig;
  final DunVariantConfig? yinConfig;
  final Set<TaiYiChartType>? chartRestriction;  // null/empty = 通用
}

class CycleStep {
  final int cycle;     // 大周
  final int step;      // 步长
  final String label;  // 层标签，如 "阳九"、"邦"
}

class DunVariantConfig {
  final WalkDirection direction;
  final List<PalaceStep> palaceSeq;
  final String startPalace;
}
```

### 2. 六种算法模板

| 模板 | 用途 | 覆盖星神 |
|------|------|---------|
| `steppedCycle` | 多层周步法：逐层取模÷步长→商+余→宫序索引 | 君基/臣基/民基/五福/大游/小游/四神/天乙/地乙/直符/飞符/阳九/百六 |
| `branchWalker` | 支神步进：在 16 神/12 神序列上按周期步进 | 文昌/天目、计神 |
| `cumulativeWalk` | 逐宫累进：从某宫起沿序列逐宫累加 | 太乙行宫（年家） |
| `relativeOffset` | 联动偏移：目标星神宫 + offset | 飞符(=太乙+2)、始击(=计神→艮→文昌) |
| `fixedPosition` | 定宫：固定在某宫 | 四神(青龙=艮/朱雀=离/白虎=兑/玄武=坎) |
| `customFormula` | 表达式兜底 | 特殊未覆盖算法 |

### 3. 新增枚举（仅 3 个）

```dart
enum WalkDirection { forward, reverse }

enum AlgorithmTemplateId {
  steppedCycle, branchWalker, cumulativeWalk,
  relativeOffset, fixedPosition, customFormula
}

enum PalaceSystem {
  nineGong,         // 基于 9 宫（乾离艮震中兑坤坎巽）
  sixteenZhengJian, // 基于 16 正间宫
  mixed,            // 混合
}
```

### 4. 复用已有枚举

| 已有枚举 | 文件 | 用途 |
|---------|------|------|
| `EnumTaiYiGong` | `lib/enums/gong.dart` | 落宫类型 |
| `EnumDeityLayer` | `lib/enums/deity_kind.dart` | 星神层级 |
| `EnumTaiYiSixteenGods` | `lib/enums/god.dart` | 十六神名 |
| `DunType` | `lib/taiyi/pan_enums.dart` | 阳遁/阴遁 |
| `TaiYiChartType` | `lib/taiyi/pan_enums.dart` | 盘类型限制 |

### 5. Repository 接口

```dart
abstract class SchoolRepository {
  Future<List<TaiYiSchool>> loadAllSchools();
  Future<TaiYiSchool?> loadSchool(String id);
  Future<List<DeityDefinition>> loadAllDeities();
  Future<DeityDefinition?> loadDeity(String id);
  Future<void> saveSchool(TaiYiSchool school);     // Custom 实现
  Future<void> saveDeity(DeityDefinition deity);   // Custom 实现
  Future<void> deleteSchool(String id);            // Custom 实现
  Future<void> deleteDeity(String id);             // Custom 实现
}
```

两种实现：
- `OfficialJsonSchoolRepository`: 从 `assets/schools/` 和 `assets/deities/` 加载 JSON，只读
- `CustomSchoolRepository`: 从本地数据库读写用户自定义数据

### 6. 三种官方流派 JSON 迁移

金镜派、统宗派、集成派的完整配置写入 `assets/schools/` 目录。每个星神定义写入 `assets/deities/`。代码中不再有流派分支——`_RuleProfile` 删除，`TaiYiPanCalculator` 改为从 `SchoolConfig` 读取参数。

### 7. 计算上下文与结果

```dart
class CalculationContext {
  final int ji;
  final int year;
  final int juNumber;
  final DunType dun;
  final TaiYiChartType chartType;
  final Map<String, DeityPlacementResult> computedDeities;
}

class DeityPlacementResult {
  final EnumTaiYiGong? gong;
  final List<StepResult> steps;
  final String? formula;
  final String? note;
}

class StepResult {
  final String label;
  final int quotient;
  final String quotientLabel;
  final int remainder;
  final String remainderLabel;
}
```

## 验收条件

### Phase 1: 数据模型 + 算法引擎

- [x] `TaiYiSchool` data class 实现，替代原 enum
- [x] `SchoolEpochConfig` 实现，覆盖金镜/统宗/集成/淘金歌/黄帝元年/登坛必究的积年公式
- [x] `DeityDefinition` + `DeityAlgorithmSpec` + `PalaceStep` 模型实现
- [x] 3 个新枚举 + 所有模型 JSON 序列化/反序列化
- [x] `SchoolRepository` 接口定义
- [x] `OfficialJsonSchoolRepository` 实现（从 assets 加载）
- [x] 金镜派 JSON 配置完整（school + 全部星神）
- [x] 统宗派 JSON 配置完整
- [x] 集成派 JSON 配置完整
- [x] `DeityAlgorithmEngine` 实现 6 种模板执行器
- [x] `steppedCycle` 支持多层级（阳九三层取模验证通过）
- [x] `steppedCycle` 支持阴阳遁双模式（文昌验证通过）
- [x] `steppedCycle` 支持 PalaceStep 自定义停留步数（乾坤停2步验证通过）
- [x] `relativeOffset` 支持联动偏移（始击验证通过）
- [x] `fixedPosition` 支持定宫（四神验证通过）
- [x] `customFormula` 表达式引擎实现（安全沙箱）
- [x] 表达式引擎支持 `+ - * / % ~/` 运算符

### Phase 2: 计算器对接

- [x] `TaiYiPanCalculator` 重构：从 SchoolConfig 读取参数，删除 `_RuleProfile`
- [x] 积年计算适配 `SchoolEpochConfig`
- [x] 星神计算改为调用 `DeityAlgorithmEngine`（金镜/统宗星神结果与迁移前一致）
- [x] 核心算法（太乙宫/文昌/计神/始击/主客算/八门）保持固定编排不变
- [x] `PanDataModel` 扩展支持 `List<StepResult>` 的分步结果
- [x] `flutter analyze` 零 warning
- [x] `flutter test` 全部通过（40 个测试无回归）

### Phase 3: UI 适配

- [x] 流派选择器改为从 `SchoolRepository.loadAllSchools()` 动态加载
- [x] 星神信息面板改为遍历 `DeityPlacementResult.steps` 动态渲染
- [x] 新增流派可通过 JSON 配置直接使用

## 变更记录

| 日期 | 变更内容 | 原因 |
|------|---------|------|
| 2026-05-08 | 初始创建 | superpowers-brainstorm 产出 |
| 2026-05-09 | SPEC 验收通过，全部 26 项验收条件完成 | 实施完毕：69 文件变更，40 测试通过，零 warning |
