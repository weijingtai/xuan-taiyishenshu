# Design: Taiyi MingGua + Destiny

> 数理基准：太乙九宫 = 乾1·离2·艮3·震4·中5(不入)·兑6·坤7·坎8·巽9(非洛书)。
> 统宗积年 = 公元后年份 + 10153917。

## 1. Context

项目已有完整的太乙局法排盘系统（年/月/日/时计）和规则引擎（JSON 驱动，7种 rule kinds）。现需新增两个独立但相关的命学体系：

- **太乙命卦（统运入卦）**：以积年为模数，匹配太乙专属卦序，定本命/流年卦。
- **太乙人道命法（命盘）**：以时计局法为基础，新增十二人身宫映射层。

两者虽同源于太乙积年体系，但底层模型完全独立，不可混用。

## 2. Design Principles

1. **方案 C（混合架构）**：命卦用独立轻量引擎；命法扩展 rule engine 模式。
2. **配置化优先**：所有算法参数（积年公式、卦序、动爻规则、十二宫映射）均为 JSON 数据，用户可编辑/保存/切换版本。
3. **Repository Interface 统一**：Contract DTO 和 Repository 接口扩展 `repository-interface-taiyishenshu`。
4. **目录分离**：`lib/minggua/` 和 `lib/destiny/` 独立，互不依赖。
5. **MVP UI**：最小可用展示页面，验证算法正确性。

## 3. Architecture Overview

```
repository-interface-taiyishenshu/     ← 扩展
  lib/src/contracts/
    ming_gua_contracts.dart            ← 新增
    destiny_contracts.dart             ← 新增
  lib/src/repositories/
    ming_gua_repository.dart           ← 新增
    destiny_repository.dart            ← 新增

xuan-taiyishenshu/
  lib/minggua/                         ← 太乙命卦（独立引擎）
    core/
      ming_gua_engine.dart             ← 核心计算
      gua_sequence.dart                ← 64卦序 + 八卦爻数据
      gua_models.dart                  ← Gua, DongYao 内部模型
    repository/
      ming_gua_repository_impl.dart    ← 读 JSON assets
      ming_gua_user_repository.dart    ← 用户自定义配置存取
    usecases/
      calculate_ming_gua_usecase.dart
    viewmodels/
      ming_gua_view_model.dart

  lib/destiny/                         ← 太乙人道命法（rule engine 扩展）
    core/
      destiny_engine.dart              ← 调度：时计→星神→十二宫
      twelve_palaces.dart              ← 十二宫模型 + 映射规则解释器
      destiny_models.dart              ← DestinyChart, PalaceSlot 内部模型
    rules/
      destiny_rule_kinds.dart          ← 新 rule kinds: palaceMapping, bodyPalace
    repository/
      destiny_repository_impl.dart     ← 读 JSON assets
      destiny_user_repository.dart     ← 用户编辑的映射规则
    usecases/
      calculate_destiny_usecase.dart
    viewmodels/
      destiny_view_model.dart

  assets/minggua/
    tong_zong_sequence.json            ← 统宗64卦序配置
    config.json                        ← 命卦参数

  assets/destiny/
    tong_zong_destiny.json             ← 统宗命法规则集
    twelve_palaces_default.json        ← 十二宫默认映射

  lib/pages/
    ming_gua_sample_page.dart          ← 命卦 MVP UI
    destiny_sample_page.dart           ← 命法 MVP UI
```

## 4. Module A: 太乙命卦（MingGua）

### 4.1 算法流程

```
输入：年份 (int)
  ↓
Step 1: 取积年 → accYear = year + epochBase (10153917)
  ↓
Step 2: 定本卦 → remainder = accYear % 64; index = (remainder==0) ? 64 : remainder
         本卦 = guaSequence[index - 1]
  ↓
Step 3: 定动爻 → 判阴阳辰（六十甲子偶=阳）
         阳辰：从初爻(1)向上数 → position = ((remainder-1) % 6) + 1
         阴辰：从上爻(6)向下数 → position = 6 - ((remainder-1) % 6)
  ↓
Step 4: 生变卦 → 翻转动爻 → 查卦名

输出：MingGuaResultContract
```

### 4.2 Contracts

```dart
@freezed
class MingGuaConfigContract with _$MingGuaConfigContract {
  const factory MingGuaConfigContract({
    required String id,
    required String name,
    required int epochBase,              // 10153917
    required List<String> guaSequence,   // 64 卦名（统宗卷十三序）
    @Default('standard') String dongYaoRule,
    @Default('official') String source,
  }) = _MingGuaConfigContract;
}

@freezed
class MingGuaResultContract with _$MingGuaResultContract {
  const factory MingGuaResultContract({
    required int accumulatedYear,
    required int remainder,
    required int guaIndex,               // 1-64
    required String benGuaName,
    required List<bool> benGuaYao,       // 6爻 [初..上], true=阳
    required int dongYaoPosition,        // 1-6
    required bool isYangChen,
    required String bianGuaName,
    required List<bool> bianGuaYao,
    int? yunIndex,                       // 所属十二运 (1-12)
  }) = _MingGuaResultContract;
}
```

### 4.3 Repository 接口

```dart
abstract class MingGuaRepository {
  Future<List<MingGuaConfigContract>> loadAllConfigs();
  Future<MingGuaConfigContract?> loadConfig(String id);
  Future<void> saveConfig(MingGuaConfigContract config);
  Future<void> deleteConfig(String id);
}
```

### 4.4 Engine（核心 ~150 行）

```dart
class MingGuaEngine {
  final MingGuaConfigContract config;
  MingGuaEngine(this.config);

  MingGuaResultContract calculate({required int year}) { ... }
}
```

关键实现细节：
- 卦序严格使用 `config.guaSequence`，不硬编码。
- 八卦爻数据（六十四卦每卦的六爻阴阳）从 `gua_sequence.dart` 的常量 Map 获取。
- 动爻规则由 `config.dongYaoRule` 控制，'standard' = 统宗规则（同余数定爻，阳下→上/阴上→下）。

### 4.5 卦序数据差异

统宗 vs 周易通行序唯一差异：**第 43 位**。
- 统宗：43=姤，无"夬"
- 通行：43=夬，44=姤

其余 62 卦位置相同。这意味着若后续需支持其他卦序，只需替换 `guaSequence` 配置。

## 5. Module B: 太乙人道命法（Destiny）

### 5.1 算法流程

```
输入：DateTime (出生时间) + DestinyConfig (流派配置)
  ↓
Step 1: 积时入局
  - 复用 taiyi_pan_calculator._accumulatedHour() → 总积时
  - 总积时 ÷ 72 → 时局数 (1-72)
  - 节气判阴阳局
  ↓
Step 2: 定天目(文昌/主目) + 始击(客目)
  - 阳局：武德起，顺行十六神
  - 阴局：吕申起，逆行十六神
  - 始击 = 天目对冲
  ↓
Step 3: 主客算
  - 主算：天目 → 太乙（阳前一/阴后一），累计宫本数
  - 客算：始击 → 太乙，同法
  ↓
Step 4: 星神定位
  - 十精、三基、大小游等行十六神（统宗特有）
  - 复用现有 rule engine 的 walk/walkSum kinds
  ↓
Step 5: 十二宫映射（可配置）
  - 命宫基准：出生时支/年支落宫
  - 按 palaceMappings 配置将星神映射到十二宫
  - 每宫产出：{宫名, 落入星神列表, 吉凶标记}

输出：DestinyResultContract
```

### 5.2 Contracts

```dart
@freezed
class DestinyConfigContract with _$DestinyConfigContract {
  const factory DestinyConfigContract({
    required String id,
    required String name,
    required SchoolEpochConfigContract epoch,
    required List<DestinyPalaceMappingContract> palaceMappings,
    @Default('official') String source,
    @Default({}) Map<String, dynamic> rules,
  }) = _DestinyConfigContract;
}

@freezed
class DestinyPalaceMappingContract with _$DestinyPalaceMappingContract {
  const factory DestinyPalaceMappingContract({
    required int index,            // 1-12
    required String name,          // '命宫', '相貌', '父母'...
    required String mappingRule,   // 规则 ID 引用
  }) = _DestinyPalaceMappingContract;
}

@freezed
class DestinyResultContract with _$DestinyResultContract {
  const factory DestinyResultContract({
    required int accumulatedHour,
    required int juNumber,             // 1-72
    required String dunType,           // 'yang' | 'yin'
    required String taiYiPalace,
    required String wenChangPalace,    // 天目
    required String shiJiPalace,       // 始击
    required int hostCount,            // 主算
    required int guestCount,           // 客算
    required List<DestinyPalaceResultContract> twelvePalaces,
  }) = _DestinyResultContract;
}

@freezed
class DestinyPalaceResultContract with _$DestinyPalaceResultContract {
  const factory DestinyPalaceResultContract({
    required int index,
    required String name,
    required List<String> deities,
    String? interpretation,
  }) = _DestinyPalaceResultContract;
}
```

### 5.3 Repository 接口

```dart
abstract class DestinyRepository {
  Future<List<DestinyConfigContract>> loadAllConfigs();
  Future<DestinyConfigContract?> loadConfig(String id);
  Future<void> saveConfig(DestinyConfigContract config);
  Future<void> deleteConfig(String id);
}
```

### 5.4 十二宫映射设计（核心可编辑层）

十二宫映射规则存为 JSON 配置，每个宫位引用一个规则 ID：

```json
{
  "palaceMappings": [
    {"index": 1, "name": "命宫", "mappingRule": "birthBranchPalace"},
    {"index": 2, "name": "相貌", "mappingRule": "sequentialNext(1)"},
    {"index": 3, "name": "父母", "mappingRule": "sequentialNext(2)"},
    {"index": 4, "name": "兄弟", "mappingRule": "sequentialNext(3)"},
    {"index": 5, "name": "妻妾", "mappingRule": "sequentialNext(4)"},
    {"index": 6, "name": "子孙", "mappingRule": "sequentialNext(5)"},
    {"index": 7, "name": "财帛", "mappingRule": "sequentialNext(6)"},
    {"index": 8, "name": "田宅", "mappingRule": "sequentialNext(7)"},
    {"index": 9, "name": "官禄", "mappingRule": "sequentialNext(8)"},
    {"index": 10, "name": "奴仆", "mappingRule": "sequentialNext(9)"},
    {"index": 11, "name": "疾厄", "mappingRule": "sequentialNext(10)"},
    {"index": 12, "name": "福德", "mappingRule": "sequentialNext(11)"}
  ]
}
```

`mappingRule` 类型：
- `birthBranchPalace`：出生时支/年支落宫（命宫基准）
- `sequentialNext(ref)`：上一宫的下一宫（顺行）
- `fixedPalace(name)`：固定宫位
- 后续可扩展更多映射规则

这样不同底本的十二宫映射差异（宫位顺序、命宫取法）只需更改 JSON，无需改代码。

### 5.5 与现有 taiyi_pan_calculator 的关系

命法引擎**调用**现有计算器的时计能力，但不修改它：

```dart
class DestinyEngine {
  final TaiYiPanCalculator _calculator;
  final DestinyConfigContract config;

  DestinyResultContract calculate({required DateTime birthTime}) {
    // 1. 用现有时计逻辑获取基础盘面
    final basePan = _calculator.calculate(
      dateTime: birthTime,
      schoolId: _mapSchoolId(config),
      chartType: TaiYiChartType.hour,
    );

    // 2. 从基础盘面提取关键星神位置
    // 3. 执行十二宫映射
    // 4. 组装 DestinyResultContract
  }
}
```

## 6. UI Sample（MVP）

### 6.1 命卦页面

- 输入：年份选择器（默认当年）
- 输出卡片：
  - 积年、余数
  - 本卦名 + 六爻图示（━ / ╴╴ 表示阳/阴爻）
  - 动爻标记（红色）
  - 变卦名 + 六爻图示
  - 所属十二运（如有）

### 6.2 命法页面

- 输入：日期时间选择器
- 输出：
  - 时局信息（局数、阴阳遁）
  - 天目 / 始击 / 太乙位置
  - 主算 / 客算数值
  - 十二宫列表（每宫：宫名 + 落入星神）

## 7. Testing Strategy

### 7.1 命卦测试

- **单元测试**：已知年份 → 已知卦（如积年=10153917+2026=10155943, ÷64=...）
- **边界测试**：余数=0（未济）、余数=1（乾）、余数=64（不存在→应为0映射到64）
- **阴阳辰**：验证干支偶/奇 → 动爻方向
- **卦序校验**：统宗第43位=姤（非夬）

### 7.2 命法测试

- **积时入局**：复用现有时计测试向量
- **主客算**：对照《统宗》时计专属规则（阴局止太乙后一宫）
- **十二宫映射**：配置化验证（给定映射规则 + 星神位置 → 十二宫分布）
- **配置可编辑**：修改 JSON → 结果变化 → 验证 CRUD

## 8. Implementation Phases

### Phase 1: Interface + 命卦核心（~2天）
- 扩展 `repository-interface-taiyishenshu` 新增 Contracts + Repository 接口
- 实现 `lib/minggua/core/`（引擎 + 卦序数据）
- 单元测试覆盖核心算法

### Phase 2: 命卦 Repository + UseCase + ViewModel（~1天）
- 实现 JSON assets 读取
- UseCase + ViewModel
- 命卦 Sample UI 页面

### Phase 3: 命法核心（~3天）
- 实现 `lib/destiny/core/`（引擎 + 十二宫映射解释器）
- 与 taiyi_pan_calculator 集成（时计调用）
- 新增 rule kinds（如需）
- 单元测试

### Phase 4: 命法 Repository + UseCase + ViewModel + UI（~2天）
- JSON 配置文件编写
- Repository 实现
- UseCase + ViewModel
- 命法 Sample UI 页面

### Phase 5: 集成验证 + 文档（~1天）
- 端到端集成测试
- 更新 README / Understand Anything 知识图谱
- 归档 OpenSpec
