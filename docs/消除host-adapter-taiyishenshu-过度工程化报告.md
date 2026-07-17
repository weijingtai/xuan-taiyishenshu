# 消除 host-adapter-taiyishenshu 过度工程化报告

## 1. 问题背景

`host-adapter-taiyishenshu` 是一个 275 行的适配器包，用于在 `repository-interface-taiyishenshu`（契约层）和 `xuan-taiyishenshu`（产品层）之间做类型转换。它的存在是因为两层使用了**名义上相同但结构上有微小差异**的类型。

这个包是 AI agents 在执行 storage-refactor 时，按照教科书式"端口-适配器"架构创建的。在当前代码规模下，这属于过度工程化。

## 2. 差异分析：契约类型 vs 产品类型

### 2.1 类型对照表

| 字段 | 产品类型（taiyishenshu） | 契约类型（repository-interface） | 差异 |
|------|--------------------------|--------------------------------|------|
| `DeityDefinition.layer` | `EnumDeityLayer`（Dart enum） | `String` | **enum ↔ String** |
| `DeityAlgorithmSpec.templateId` | `AlgorithmTemplateId`（Dart enum） | `String` | **enum ↔ String** |
| `TaiYiSchool.chartConfigs` | `Map<String, ChartConfig>` | `Map<String, dynamic>` | **强类型 ↔ dynamic** |
| `TaiYiSchool.deityConfigs` | `Map<String, DeityOverride>` | `Map<String, dynamic>` | **强类型 ↔ dynamic** |
| `SchoolEpochConfig` | 手工 JsonSerializable 类 | freezed DTO 类 | **结构完全相同**，框架不同 |
| 其余所有字段（id, name, source 等） | 同类型 | 同类型 | **零差异** |

### 2.2 核心结论

- `SchoolEpochConfig` ↔ `SchoolEpochConfigContract`：**逐字段完全一致**，纯机械复制，适配器在这里做的是无用功
- enum ↔ String：**人为制造的差异**，契约层为了不依赖产品枚举而降级为 String
- Map<String, typed> ↔ Map<String, dynamic>：**序列化需要**，存储层用 dynamic 是合理的，但转换逻辑只需 2 行代码

## 3. 为什么契约层不依赖产品层

当前依赖方向：

```
repository-interface-taiyishenshu  (无外部依赖，仅 equatable/freezed)
         ↑
    xuan-taiyishenshu  (依赖 repository-interface)
```

如果让契约层直接引用产品层的 enum，会产生**循环依赖**（taiyishenshu → repository-interface → taiyishenshu）。

这是 AI agents 创建 adapter 的"理论依据"——但解法不是加一个包，而是**提取共享类型**。

## 4. 消除方案

### 4.1 方案概要

**提取共享枚举到独立包，让契约层直接使用产品枚举，消除 String↔enum 转换。剩余的 Map 转换回归 example/lib/（宿主装配职责）。**

### 4.2 目标架构

```
taiyishenshu-types/           ← 新建：共享枚举 + 值对象
  └── enums/
      ├── deity_kind.dart       (EnumDeityLayer 移入)
      └── algorithm_enums.dart  (AlgorithmTemplateId 移入)

repository-interface-taiyishenshu/
  └── contracts/taiyi_contracts.dart
      ├── layer: EnumDeityLayer     ← 直接使用 enum，不再用 String
      └── templateId: AlgorithmTemplateId  ← 直接使用 enum

xuan-taiyishenshu/
  ├── lib/enums/                 ← 改为 re-export taiyishenshu-types
  ├── lib/taiyi/core/            ← 使用共享 enum（零改动）
  └── example/lib/
      └── taiyi_host.dart        ← 包含剩余的 Map 转换（~10 行）

host-adapter-taiyishenshu/       ← 删除
```

### 4.3 详细步骤

#### 步骤 1：创建共享类型包 `taiyishenshu-types`

```bash
mkdir taiyishenshu-types/lib/enums
```

**`taiyishenshu-types/pubspec.yaml`**：
```yaml
name: taiyishenshu_types
publish_to: none
environment:
  sdk: ">=3.2.3 <4.0.0"
```

**`taiyishenshu-types/lib/taiyishenshu_types.dart`**：
```dart
export 'enums/deity_kind.dart';
export 'enums/algorithm_enums.dart';
```

将以下文件**移动**（不是复制）到 `taiyishenshu-types/lib/enums/`：
- `xuan-taiyishenshu/lib/enums/deity_kind.dart` → 含 `EnumDeityLayer`、`EnumDeityKind`
- `xuan-taiyishenshu/lib/taiyi/core/algorithm_enums.dart` → 含 `AlgorithmTemplateId`

#### 步骤 2：让 `xuan-taiyishenshu` re-export 共享类型

`xuan-taiyishenshu/lib/enums/deity_kind.dart` 改为：
```dart
export 'package:taiyishenshu_types/taiyishenshu_types.dart' show EnumDeityKind, EnumDeityLayer;
```

`xuan-taiyishenshu/lib/taiyi/core/algorithm_enums.dart` 改为：
```dart
export 'package:taiyishenshu_types/taiyishenshu_types.dart'
    show AlgorithmTemplateId, WalkDirection, PalaceSystem, AlgorithmBaseVariable;
```

在 `xuan-taiyishenshu/pubspec.yaml` 添加依赖：
```yaml
dependencies:
  taiyishenshu_types:
    path: ../taiyishenshu-types
```

**效果**：`xuan-taiyishenshu` 内部所有代码的 import 不需要改动，re-export 保持兼容。

#### 步骤 3：让契约层直接使用产品枚举

`repository-interface-taiyishenshu/pubspec.yaml` 添加依赖：
```yaml
dependencies:
  taiyishenshu_types:
    path: ../taiyishenshu-types
```

修改 `repository-interface-taiyishenshu/lib/src/contracts/taiyi_contracts.dart`：

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taiyishenshu_types/taiyishenshu_types.dart';  // 新增

// ...

@freezed
class DeityDefinitionContract with _$DeityDefinitionContract {
  const factory DeityDefinitionContract({
    required String id,
    required String name,
    required EnumDeityLayer layer,           // ← String 改为 EnumDeityLayer
    required DeityAlgorithmSpecContract algorithm,
    // ... 其余不变
  }) = _DeityDefinitionContract;
}

@freezed
class DeityAlgorithmSpecContract with _$DeityAlgorithmSpecContract {
  const factory DeityAlgorithmSpecContract({
    required AlgorithmTemplateId templateId,  // ← String 改为 AlgorithmTemplateId
    @Default({}) Map<String, dynamic> params,
  }) = _DeityAlgorithmSpecContract;
}
```

修改后重新运行 `dart run build_runner build` 重新生成 freezed 代码。

#### 步骤 4：将适配器代码回归 example/lib/

将 `host-adapter-taiyishenshu/lib/src/adapters/taiyi_contract_adapters.dart` 中**仅剩的 Map 转换逻辑**移回 `xuan-taiyishenshu/example/lib/taiyi_host.dart`。

消除 adapter 后，`taiyi_host.dart` 中的适配代码缩减为：

```dart
// 仅保留 Map<String, dynamic> ↔ 强类型的转换（~10 行）
// SchoolEpochConfig / TaiYiSchoolContract 的字段完全一致，直接构造即可
// 不再需要 enum.name / byName 转换
```

具体来说，原来的 275 行适配器将变为：

1. **`SchoolEpochConfig` ↔ `SchoolEpochConfigContract`**：字段完全一致，用工厂构造直接转换（或直接用 product 类型，见 4.4）
2. **`TaiYiSchool` ↔ `TaiYiSchoolContract`**：仅 `chartConfigs` 和 `deityConfigs` 需要 `toJson()` / `fromJson()` 转换
3. **`DeityDefinition` ↔ `DeityDefinitionContract`**：enum 已统一，零转换
4. **`DeityAlgorithmSpec` ↔ `DeityAlgorithmSpecContract`**：enum 已统一，零转换
5. **4 个 Adapter 类**（`ContractOfficialSchoolAdapter` 等）：移入 `example/lib/` 作为宿主装配代码

#### 步骤 4.4（可选简化）：进一步消除 contract DTO

`SchoolEpochConfig` 和 `SchoolEpochConfigContract` 结构完全一致。可以：

- 让 `TaiYiSchoolContract.epoch` 直接使用 `SchoolEpochConfig`（产品类型）
- 删除 `SchoolEpochConfigContract`

这需要 `repository-interface-taiyishenshu` 额外依赖 `taiyishenshu-types` 中导出的 `SchoolEpochConfig`，或者把 `SchoolEpochConfig` 也移入共享包。

**如果执行此步**，`TaiYiSchoolContract` 的 `epoch` 字段直接用 product 类型，进一步减少转换代码。

#### 步骤 5：更新所有引用方

需要更新的文件（共 8 处 dart import + 2 处 pubspec.yaml）：

| 文件 | 改动 |
|------|------|
| `xuan-taiyishenshu/pubspec.yaml` | 删除 `host_adapter_taiyishenshu` 依赖，添加 `taiyishenshu_types` |
| `xuan-taiyishenshu/example/pubspec.yaml` | 删除 `host_adapter_taiyishenshu` 依赖 |
| `xuan-taiyishenshu/example/lib/taiyi_host.dart` | 改为 import example 内的适配代码，或直接 import contract 类型 |
| `xuan-taiyishenshu/test/taiyi/fakes/taiyi_contract_adapters.dart` | 改为本地定义或 import example |
| `xuan-taiyishenshu/test/taiyi/usecases/robustness_test.dart` | 更新 import |
| `xuan-taiyishenshu/test/taiyi/core/repository_boundary_test.dart` | 更新 import |
| `xuan-taiyishenshu/test/integration/school_editor_integration_test.dart` | 更新 import |
| `xuan-taiyishenshu/test/integration/zt30_fullchain_school_save_recompute_test.dart` | 更新 import |
| `xuan-taiyishenshu/test/integration/deity_editor_integration_test.dart` | 更新 import |

#### 步骤 6：删除 host-adapter-taiyishenshu

```bash
rm -rf host-adapter-taiyishenshu/
```

#### 步骤 7：验证

```bash
# 1. 共享类型包静态分析
cd taiyishenshu-types && dart analyze lib/

# 2. 契约包重新生成 + 分析
cd repository-interface-taiyishenshu && dart run build_runner build --delete-conflicting-outputs && dart analyze lib/

# 3. 产品包分析
cd xuan-taiyishenshu && dart analyze lib/ && dart analyze test/ && dart analyze example/

# 4. 测试通过
cd xuan-taiyishenshu && flutter test

# 5. 确认无残留引用
grep -r "host_adapter_taiyishenshu" xuan-taiyishenshu/ --include='*.dart'
grep -r "host-adapter-taiyishenshu" xuan-taiyishenshu/ --include='*.yaml'
```

## 5. 改动量估算

| 项目 | 行数 |
|------|------|
| 新建 `taiyishenshu-types/` | ~30 行（pubspec + barrel + 移入的 enum 文件） |
| 修改 `taiyi_contracts.dart` | ~5 行（2 个字段类型改为 enum） |
| 修改 `taiyi_host.dart` | ~20 行（嵌入简化后的适配逻辑） |
| 修改各 test 文件 | 每文件 1 行 import 改动 |
| 删除 `host-adapter-taiyishenshu/` | -275 行 |
| **净减少** | **~220 行** |

## 6. 架构收益

- 消除一个独立包及其维护成本
- 契约层直接使用产品枚举，类型安全不降级
- 适配逻辑回归宿主层（example/lib/），符合"谁组装谁转换"原则
- 共享枚举包可被其他术数包复用（如果未来需要）
