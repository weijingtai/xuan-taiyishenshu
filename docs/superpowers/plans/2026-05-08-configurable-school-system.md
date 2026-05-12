# 可配置流派与星神系统 — 实施计划

- **Goal**: 将硬编码的 TaiYiSchool 枚举 + _RuleProfile + 星神计算重构为配置驱动的引擎系统
- **Architecture**: 4 层——数据模型→Repository→AlgorithmEngine→Calculator
- **Tech Stack**: Dart 3.2+, Flutter, JSON serialization, dart:convert

---

## Group 0: 基础设施

### Task 0.1 — 创建新目录结构

```
mkdir -p lib/taiyi/core
mkdir -p assets/schools
mkdir -p assets/deities
```

commit: `add 创建配置系统目录结构`

---

### Task 0.2 — 新增 WalkDirection 枚举

**文件**: `lib/taiyi/core/algorithm_enums.dart`

```dart
/// 宫位行走方向
enum WalkDirection { forward, reverse }

/// 算法模板类型
enum AlgorithmTemplateId {
  steppedCycle,
  branchWalker,
  cumulativeWalk,
  relativeOffset,
  fixedPosition,
  customFormula,
}

/// 宫位体系
enum PalaceSystem {
  nineGong,
  sixteenZhengJian,
  mixed,
}
```

验证: `dart format lib/taiyi/core/algorithm_enums.dart && flutter analyze lib/taiyi/core/`

commit: `add AlgorithmTemplateId, WalkDirection, PalaceSystem 枚举`

---

## Group 1: 数据模型

### Task 1.1 — SchoolEpochConfig 模型

**文件**: `lib/taiyi/core/school_config.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'school_config.g.dart';

@JsonSerializable()
class SchoolEpochConfig {
  final int ancientBase;
  final int epochYear;
  final int correction;
  final double tropicalYear;

  const SchoolEpochConfig({
    required this.ancientBase,
    required this.epochYear,
    this.correction = 0,
    this.tropicalYear = 365.2425,
  });

  /// 计算积年: ancientBase + (targetYear - epochYear) + correction
  int calculateAccumulatedYear(int targetYear) {
    return ancientBase + (targetYear - epochYear) + correction;
  }

  factory SchoolEpochConfig.fromJson(Map<String, dynamic> json) =>
      _$SchoolEpochConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SchoolEpochConfigToJson(this);
}
```

验证: `flutter analyze lib/taiyi/core/school_config.dart`

commit: `add SchoolEpochConfig 积年配置模型`

---

### Task 1.2 — PalaceStep, CycleStep, DunVariantConfig, SteppedCycleParams

**文件**: `lib/taiyi/core/algorithm_spec.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import '../pan_enums.dart';
import 'algorithm_enums.dart';

part 'algorithm_spec.g.dart';

@JsonSerializable()
class PalaceStep {
  final String palace;
  final int staySteps;

  const PalaceStep({required this.palace, this.staySteps = 1});

  factory PalaceStep.fromJson(Map<String, dynamic> json) =>
      _$PalaceStepFromJson(json);
  Map<String, dynamic> toJson() => _$PalaceStepToJson(this);
}

@JsonSerializable()
class CycleStep {
  final int cycle;
  final int step;
  final String label;

  const CycleStep({
    required this.cycle,
    required this.step,
    required this.label,
  });

  factory CycleStep.fromJson(Map<String, dynamic> json) =>
      _$CycleStepFromJson(json);
  Map<String, dynamic> toJson() => _$CycleStepToJson(this);
}

@JsonSerializable()
class DunVariantConfig {
  final WalkDirection direction;
  final List<PalaceStep> palaceSeq;
  final String startPalace;

  const DunVariantConfig({
    required this.direction,
    required this.palaceSeq,
    required this.startPalace,
  });

  factory DunVariantConfig.fromJson(Map<String, dynamic> json) =>
      _$DunVariantConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DunVariantConfigToJson(this);
}

@JsonSerializable()
class SteppedCycleParams {
  final int correction;
  final List<CycleStep> steps;
  final PalaceSystem palaceSystem;
  final List<PalaceStep>? palaceSeq;
  final WalkDirection? direction;
  final String? startPalace;
  final DunType? dunBinding;
  final DunVariantConfig? yangConfig;
  final DunVariantConfig? yinConfig;
  final Set<TaiYiChartType>? chartRestriction;

  const SteppedCycleParams({
    this.correction = 0,
    required this.steps,
    required this.palaceSystem,
    this.palaceSeq,
    this.direction,
    this.startPalace,
    this.dunBinding,
    this.yangConfig,
    this.yinConfig,
    this.chartRestriction,
  });

  factory SteppedCycleParams.fromJson(Map<String, dynamic> json) =>
      _$SteppedCycleParamsFromJson(json);
  Map<String, dynamic> toJson() => _$SteppedCycleParamsToJson(this);
}
```

验证: `flutter analyze lib/taiyi/core/`

commit: `add PalaceStep, CycleStep, DunVariantConfig, SteppedCycleParams 算法参数模型`

---

### Task 1.3 — DeityAlgorithmSpec + DeityDefinition

**文件**: `lib/taiyi/core/deity_definition.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import '../../enums/deity_kind.dart';
import 'algorithm_enums.dart';

part 'deity_definition.g.dart';

@JsonSerializable()
class DeityAlgorithmSpec {
  final AlgorithmTemplateId templateId;
  final Map<String, dynamic> params;

  const DeityAlgorithmSpec({
    required this.templateId,
    this.params = const {},
  });

  factory DeityAlgorithmSpec.fromJson(Map<String, dynamic> json) =>
      _$DeityAlgorithmSpecFromJson(json);
  Map<String, dynamic> toJson() => _$DeityAlgorithmSpecToJson(this);
}

@JsonSerializable()
class DeityDefinition {
  final String id;
  final String name;
  final EnumDeityLayer layer;
  final DeityAlgorithmSpec algorithm;
  final int priority;
  final String? description;
  final String source;

  const DeityDefinition({
    required this.id,
    required this.name,
    required this.layer,
    required this.algorithm,
    this.priority = 50,
    this.description,
    this.source = 'official',
  });

  factory DeityDefinition.fromJson(Map<String, dynamic> json) =>
      _$DeityDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$DeityDefinitionToJson(this);
}
```

验证: `flutter analyze lib/taiyi/core/`

commit: `add DeityAlgorithmSpec + DeityDefinition 星神定义模型`

---

### Task 1.4 — TaiYiSchool data class（替代原 enum）

在 `lib/taiyi/core/school_config.dart` 追加：

```dart
@JsonSerializable()
class TaiYiSchool {
  final String id;
  final String name;
  final String source;
  final SchoolEpochConfig epoch;
  final List<String> deityIds;
  final Map<String, dynamic>? overrides;
  final bool wenChangStayRule;
  final bool useTwelveJiShen;
  final String palaceFormula;
  final String eightDoorMode;

  const TaiYiSchool({
    required this.id,
    required this.name,
    required this.epoch,
    this.source = 'official',
    this.deityIds = const [],
    this.overrides,
    this.wenChangStayRule = true,
    this.useTwelveJiShen = false,
    this.palaceFormula = 'jingMirror',
    this.eightDoorMode = 'dynamic',
  });

  factory TaiYiSchool.fromJson(Map<String, dynamic> json) =>
      _$TaiYiSchoolFromJson(json);
  Map<String, dynamic> toJson() => _$TaiYiSchoolToJson(this);
}
```

验证: `flutter analyze lib/taiyi/core/school_config.dart`

commit: `add TaiYiSchool data class 替代硬编码枚举`

---

### Task 1.5 — CalculationContext + DeityPlacementResult + StepResult

**文件**: `lib/taiyi/core/calculation_context.dart`

```dart
import '../../enums/gong.dart';
import '../pan_enums.dart';

class CalculationContext {
  final int ji;
  final int year;
  final int juNumber;
  final DunType dun;
  final TaiYiChartType chartType;
  final Map<String, DeityPlacementResult> computedDeities;

  const CalculationContext({
    required this.ji,
    required this.year,
    required this.juNumber,
    required this.dun,
    required this.chartType,
    this.computedDeities = const {},
  });

  CalculationContext copyWith({
    Map<String, DeityPlacementResult>? computedDeities,
  }) {
    return CalculationContext(
      ji: ji,
      year: year,
      juNumber: juNumber,
      dun: dun,
      chartType: chartType,
      computedDeities: computedDeities ?? this.computedDeities,
    );
  }
}

class DeityPlacementResult {
  final EnumTaiYiGong? gong;
  final List<StepResult> steps;
  final String? formula;
  final String? note;

  const DeityPlacementResult({
    this.gong,
    this.steps = const [],
    this.formula,
    this.note,
  });
}

class StepResult {
  final String label;
  final int quotient;
  final String quotientLabel;
  final int remainder;
  final String remainderLabel;

  const StepResult({
    required this.label,
    required this.quotient,
    required this.quotientLabel,
    required this.remainder,
    required this.remainderLabel,
  });
}
```

验证: `flutter analyze lib/taiyi/core/calculation_context.dart`

commit: `add CalculationContext + DeityPlacementResult + StepResult 计算上下文模型`

---

### Task 1.6 — 运行 build_runner 生成 .g.dart 文件

命令:
```bash
cd "D:/Programme/Flutter/xuan-taiyishenshu/.claude/worktrees/compassionate-kapitsa-bf9771"
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

验证: `ls lib/taiyi/core/*.g.dart` — 应出现多个 `.g.dart` 文件

commit: `add build_runner 生成 JSON 序列化代码`

---

## Group 2: Repository 层

### Task 2.1 — SchoolRepository 接口

**文件**: `lib/taiyi/core/school_repository.dart`

```dart
import 'school_config.dart';
import 'deity_definition.dart';

abstract class SchoolRepository {
  Future<List<TaiYiSchool>> loadAllSchools();
  Future<TaiYiSchool?> loadSchool(String id);
  Future<List<DeityDefinition>> loadAllDeities();
  Future<DeityDefinition?> loadDeity(String id);
  Future<void> saveSchool(TaiYiSchool school);
  Future<void> saveDeity(DeityDefinition deity);
  Future<void> deleteSchool(String id);
  Future<void> deleteDeity(String id);
}
```

验证: `flutter analyze lib/taiyi/core/school_repository.dart`

commit: `add SchoolRepository 接口定义`

---

### Task 2.2 — OfficialJsonSchoolRepository 实现

**文件**: `lib/taiyi/data/official_json_repository.dart`

```dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../core/school_repository.dart';
import '../core/school_config.dart';
import '../core/deity_definition.dart';

class OfficialJsonSchoolRepository implements SchoolRepository {
  final List<String> _schoolIds;
  final List<String> _deityIds;
  Map<String, TaiYiSchool>? _schoolCache;
  Map<String, DeityDefinition>? _deityCache;

  OfficialJsonSchoolRepository({
    required List<String> schoolIds,
    required List<String> deityIds,
  })  : _schoolIds = schoolIds,
        _deityIds = deityIds;

  Future<void> _ensureLoaded() async {
    if (_schoolCache != null && _deityCache != null) return;

    _schoolCache = {};
    for (final id in _schoolIds) {
      final jsonStr = await rootBundle.loadString('assets/schools/$id.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      _schoolCache![id] = TaiYiSchool.fromJson(json);
    }

    _deityCache = {};
    for (final id in _deityIds) {
      final jsonStr = await rootBundle.loadString('assets/deities/$id.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      _deityCache![id] = DeityDefinition.fromJson(json);
    }
  }

  @override
  Future<List<TaiYiSchool>> loadAllSchools() async {
    await _ensureLoaded();
    return _schoolCache!.values.toList();
  }

  @override
  Future<TaiYiSchool?> loadSchool(String id) async {
    await _ensureLoaded();
    return _schoolCache![id];
  }

  @override
  Future<List<DeityDefinition>> loadAllDeities() async {
    await _ensureLoaded();
    return _deityCache!.values.toList();
  }

  @override
  Future<DeityDefinition?> loadDeity(String id) async {
    await _ensureLoaded();
    return _deityCache![id];
  }

  @override
  Future<void> saveSchool(TaiYiSchool school) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> saveDeity(DeityDefinition deity) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> deleteSchool(String id) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> deleteDeity(String id) =>
      throw UnsupportedError('Official repository is read-only');
}
```

**文件**: `pubspec.yaml` 追加 assets 声明：

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/schools/
    - assets/deities/
```

验证: `flutter analyze lib/taiyi/data/`

commit: `add OfficialJsonSchoolRepository 实现 + pubspec assets 声明`

---

### Task 2.3 — 编写 Repository 单元测试

**文件**: `test/taiyi/core/official_json_repository_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfficialJsonSchoolRepository', () {
    test('loadAllSchools 返回非空列表', () {
      // NOTE: 需要 assets 中的 JSON 文件存在后才能通过
      // 先写骨架测试，JSON 配置准备好后补全
    });
    test('loadAllDeities 返回包含 junJi/daYou/wuFu 等默认星神', () {
      // 同上——先写骨架
    });
    test('saveSchool 抛出 UnsupportedError', () {
      // 可直接测试
    });
  });
}
```

验证: `flutter test test/taiyi/core/official_json_repository_test.dart`

commit: `add Repository 单元测试骨架`

---

## Group 3: 表达式引擎

### Task 3.1 — 表达式解析器

**文件**: `lib/taiyi/core/expression_parser.dart`

```dart
/// 安全表达式解析器——仅支持整数四则运算 + 取模 + 整除
/// 支持的运算符: + - * / % ~/
/// 支持的变量: 由调用方注入的 Map<String, int>
///
/// 安全约束: 无函数调用、无网络访问、无文件读写、仅纯算术
class ExpressionParser {
  static int evaluate(String expr, Map<String, int> variables) {
    String processed = expr;
    for (final entry in variables.entries) {
      processed = processed.replaceAll(entry.key, entry.value.toString());
    }
    return _parseAddSub(processed.trim());
  }

  static int _parseAddSub(String expr) {
    final tokens = _tokenize(expr);
    int result = _parseMulDiv(tokens, 0).value;
    int i = _parseMulDiv(tokens, 0).nextIndex;

    while (i < tokens.length) {
      if (tokens[i] == '+') {
        final next = _parseMulDiv(tokens, i + 1);
        result += next.value;
        i = next.nextIndex;
      } else if (tokens[i] == '-') {
        final next = _parseMulDiv(tokens, i + 1);
        result -= next.value;
        i = next.nextIndex;
      } else {
        break;
      }
    }
    return result;
  }

  static _ParseResult _parseMulDiv(List<String> tokens, int index) {
    int value = int.parse(tokens[index]);
    int i = index + 1;

    while (i < tokens.length) {
      final op = tokens[i];
      if (op == '*') {
        value *= int.parse(tokens[i + 1]);
        i += 2;
      } else if (op == '/' || op == '~/') {
        value ~/= int.parse(tokens[i + 1]);
        i += 2;
      } else if (op == '%') {
        value %= int.parse(tokens[i + 1]);
        i += 2;
      } else {
        break;
      }
    }
    return _ParseResult(value, i);
  }

  static List<String> _tokenize(String expr) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];
      if (ch == ' ') continue;
      if ('+-*/%'.contains(ch)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        // 处理 ~/ 两个字符的运算符
        if (ch == '~' && i + 1 < expr.length && expr[i + 1] == '/') {
          tokens.add('~/');
          i++;
        } else {
          tokens.add(ch);
        }
      } else {
        buffer.write(ch);
      }
    }
    if (buffer.isNotEmpty) tokens.add(buffer.toString());
    return tokens;
  }
}

class _ParseResult {
  final int value;
  final int nextIndex;
  const _ParseResult(this.value, this.nextIndex);
}
```

**文件**: `test/taiyi/core/expression_parser_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/expression_parser.dart';

void main() {
  group('ExpressionParser', () {
    test('加法', () {
      expect(ExpressionParser.evaluate('1 + 2', {}), 3);
    });
    test('减法', () {
      expect(ExpressionParser.evaluate('5 - 3', {}), 2);
    });
    test('乘法', () {
      expect(ExpressionParser.evaluate('3 * 4', {}), 12);
    });
    test('整除 ~/', () {
      expect(ExpressionParser.evaluate('10 ~/ 3', {}), 3);
    });
    test('取模 %', () {
      expect(ExpressionParser.evaluate('10 % 3', {}), 1);
    });
    test('混合运算', () {
      expect(ExpressionParser.evaluate('2 + 3 * 4', {}), 14);
    });
    test('变量替换', () {
      expect(ExpressionParser.evaluate('ji + correction', {'ji': 100, 'correction': 250}), 350);
    });
    test('阳九公式: ji % 4560 ~/ 456', () {
      // 金镜 724年: 积年=13331, 13331%4560=4211, 4211~/456=9
      expect(ExpressionParser.evaluate('ji % 4560 ~/ 456', {'ji': 13331}), 9);
    });
  });
}
```

验证:
```bash
cd "D:/Programme/Flutter/xuan-taiyishenshu/.claude/worktrees/compassionate-kapitsa-bf9771"
flutter test test/taiyi/core/expression_parser_test.dart
```
预期: 7 passed

commit: `add 表达式解析器 + 单元测试 (7 passed)`

---

## Group 4: 算法引擎

### Task 4.1 — DeityAlgorithmEngine 骨架 + fixedPosition 执行器

**文件**: `lib/taiyi/core/algorithm_engine.dart`

```dart
import '../../enums/gong.dart';
import 'algorithm_enums.dart';
import 'algorithm_spec.dart';
import 'calculation_context.dart';
import 'deity_definition.dart';
import 'expression_parser.dart';

class DeityAlgorithmEngine {
  /// 执行单个星神的算法，返回落宫结果
  DeityPlacementResult execute(
    DeityDefinition deity,
    CalculationContext ctx,
  ) {
    final spec = deity.algorithm;
    switch (spec.templateId) {
      case AlgorithmTemplateId.fixedPosition:
        return _executeFixedPosition(spec.params, ctx);
      case AlgorithmTemplateId.steppedCycle:
        return _executeSteppedCycle(spec.params, ctx);
      case AlgorithmTemplateId.relativeOffset:
        return _executeRelativeOffset(spec.params, ctx);
      case AlgorithmTemplateId.branchWalker:
        return _executeBranchWalker(spec.params, ctx);
      case AlgorithmTemplateId.cumulativeWalk:
        return _executeCumulativeWalk(spec.params, ctx);
      case AlgorithmTemplateId.customFormula:
        return _executeCustomFormula(spec.params, ctx);
    }
  }

  /// 批量执行，返回 Map<星神ID, DeityPlacementResult>
  Map<String, DeityPlacementResult> executeAll(
    List<DeityDefinition> deities,
    CalculationContext ctx,
  ) {
    final results = <String, DeityPlacementResult>{};
    var currentCtx = ctx;
    for (final deity in deities) {
      final result = execute(deity, currentCtx);
      results[deity.id] = result;
      currentCtx = currentCtx.copyWith(
        computedDeities: Map.from(currentCtx.computedDeities)..addAll(results),
      );
    }
    return results;
  }

  DeityPlacementResult _executeFixedPosition(
    Map<String, dynamic> params,
    CalculationContext ctx,
  ) {
    final gongName = params['gong'] as String;
    final gong = _resolveGong(gongName);
    return DeityPlacementResult(
      gong: gong,
      steps: [
        StepResult(
          label: '定宫',
          quotient: 0,
          quotientLabel: '',
          remainder: 0,
          remainderLabel: '固定在$gongName',
        ),
      ],
    );
  }
}
```

验证: `flutter analyze lib/taiyi/core/algorithm_engine.dart`

---

### Task 4.2 — steppedCycle 执行器

在 `lib/taiyi/core/algorithm_engine.dart` 追加 `_executeSteppedCycle`:

```dart
  DeityPlacementResult _executeSteppedCycle(
    Map<String, dynamic> params,
    CalculationContext ctx,
  ) {
    final spec = SteppedCycleParams.fromJson(params);
    final steps = <StepResult>[];
    int value = ctx.ji + spec.correction;

    for (final cs in spec.steps) {
      final pos = value % cs.cycle;
      final quotient = pos ~/ cs.step;
      final remainder = pos % cs.step;
      steps.add(StepResult(
        label: cs.label,
        quotient: quotient,
        quotientLabel: '第${quotient + 1}${cs.label}',
        remainder: remainder == 0 ? cs.step : remainder,
        remainderLabel: '入${cs.label}年数',
      ));
      value = remainder == 0 ? cs.step : remainder;
    }

    // 选择遁法对应的宫序
    List<PalaceStep>? palaceSeq;
    WalkDirection? direction;
    String? startPalace;

    if (spec.dunBinding == null && spec.yangConfig != null && spec.yinConfig != null) {
      // 阴阳遁双模式
      final config = ctx.dun == DunType.yang ? spec.yangConfig : spec.yinConfig;
      palaceSeq = config!.palaceSeq;
      direction = config.direction;
      startPalace = config.startPalace;
    } else {
      palaceSeq = spec.palaceSeq;
      direction = spec.direction;
      startPalace = spec.startPalace;
    }

    final gong = _walkPalaceSequence(
      palaceSeq ?? _defaultPalaceSeq(spec.palaceSystem),
      direction ?? WalkDirection.forward,
      startPalace!,
      steps.last.quotient,
    );

    return DeityPlacementResult(
      gong: _resolveGong(gong),
      steps: steps,
      formula: '积年${spec.correction >= 0 ? "+" : ""}${spec.correction} → ${steps.map((s) => "${s.label}${s.quotientLabel}(${s.remainderLabel})").join(" → ")}',
    );
  }
```

commit: `add DeityAlgorithmEngine 骨架 + fixedPosition + steppedCycle 执行器`

---

### Task 4.3 — steppedCycle 步宫算法 + _resolveGong 辅助方法

在 `algorithm_engine.dart` 追加：

```dart
  /// 在宫序中行走，返回目标宫名
  String _walkPalaceSequence(
    List<PalaceStep> seq,
    WalkDirection direction,
    String startPalace,
    int stepsToWalk,
  ) {
    final flatSeq = <String>[];
    int startIdx = 0;
    for (int i = 0; i < seq.length; i++) {
      for (int s = 0; s < seq[i].staySteps; s++) {
        flatSeq.add(seq[i].palace);
      }
      if (seq[i].palace == startPalace) startIdx = i;
    }

    final effectiveSteps = stepsToWalk % flatSeq.length;
    int targetIdx;
    if (direction == WalkDirection.forward) {
      targetIdx = (startIdx + effectiveSteps) % flatSeq.length;
    } else {
      targetIdx = (startIdx - effectiveSteps) % flatSeq.length;
    }
    return flatSeq[targetIdx];
  }

  /// 将宫名解析为 EnumTaiYiGong
  EnumTaiYiGong? _resolveGong(String name) {
    return switch (name) {
      '乾' => EnumTaiYiGong.Qian,
      '离' => EnumTaiYiGong.Li,
      '艮' => EnumTaiYiGong.Gen,
      '震' => EnumTaiYiGong.Zhen,
      '巽' => EnumTaiYiGong.Xun,
      '兑' => EnumTaiYiGong.Dui,
      '坤' => EnumTaiYiGong.Kun,
      '坎' => EnumTaiYiGong.Kan,
      '中' => EnumTaiYiGong.Center,
      _ => null,
    };
  }

  List<PalaceStep> _defaultPalaceSeq(PalaceSystem system) {
    return switch (system) {
      PalaceSystem.nineGong => [
        const PalaceStep(palace: '乾'), const PalaceStep(palace: '离'),
        const PalaceStep(palace: '艮'), const PalaceStep(palace: '震'),
        const PalaceStep(palace: '中'), const PalaceStep(palace: '兑'),
        const PalaceStep(palace: '坤'), const PalaceStep(palace: '坎'),
        const PalaceStep(palace: '巽'),
      ],
      PalaceSystem.sixteenZhengJian => [
        const PalaceStep(palace: '子'), const PalaceStep(palace: '丑'),
        const PalaceStep(palace: '艮'), const PalaceStep(palace: '寅'),
        const PalaceStep(palace: '卯'), const PalaceStep(palace: '辰'),
        const PalaceStep(palace: '巽'), const PalaceStep(palace: '巳'),
        const PalaceStep(palace: '午'), const PalaceStep(palace: '未'),
        const PalaceStep(palace: '坤'), const PalaceStep(palace: '申'),
        const PalaceStep(palace: '酉'), const PalaceStep(palace: '戌'),
        const PalaceStep(palace: '乾'), const PalaceStep(palace: '亥'),
      ],
      PalaceSystem.mixed => [
        const PalaceStep(palace: '乾'), const PalaceStep(palace: '离'),
        const PalaceStep(palace: '艮'), const PalaceStep(palace: '震'),
        const PalaceStep(palace: '兑'), const PalaceStep(palace: '坤'),
        const PalaceStep(palace: '坎'), const PalaceStep(palace: '巽'),
      ],
    };
  }
```

commit: `add steppedCycle 步宫算法 + 宫名解析 + 默认宫序`

---

### Task 4.4 — relativeOffset + cumulativeWalk + branchWalker + customFormula 执行器

在 `algorithm_engine.dart` 追加剩余 4 个执行器：

```dart
  DeityPlacementResult _executeRelativeOffset(
    Map<String, dynamic> params,
    CalculationContext ctx,
  ) {
    final sourceId = params['sourceDeityId'] as String;
    final offset = params['offset'] as int;
    final source = ctx.computedDeities[sourceId];
    if (source == null || source.gong == null) {
      return const DeityPlacementResult(note: '源星神未计算');
    }

    final seq = _defaultPalaceSeq(
      (params['palaceSystem'] as String? == 'sixteenZhengJian')
          ? PalaceSystem.sixteenZhengJian
          : PalaceSystem.nineGong,
    );
    final flatSeq = seq.expand<String>((ps) =>
      List.filled(ps.staySteps, ps.palace),
    ).toList();
    final currentIdx = flatSeq.indexOf(_gongToName(source.gong));
    final targetIdx = (currentIdx + offset) % flatSeq.length;
    final gong = _resolveGong(flatSeq[targetIdx]);

    return DeityPlacementResult(
      gong: gong,
      steps: [
        StepResult(
          label: '偏移',
          quotient: offset,
          quotientLabel: '${sourceId}+$offset',
          remainder: 0,
          remainderLabel: '',
        ),
      ],
    );
  }

  DeityPlacementResult _executeBranchWalker(
    Map<String, dynamic> params,
    CalculationContext ctx,
  ) {
    final cycle = params['cycle'] as int;
    final startBranch = params['startBranch'] as String;
    final branches = (params['branches'] as List).cast<String>();
    final position = ctx.ji % cycle;
    final index = position % branches.length;
    final branch = branches[index];
    final gong = _branchToGong(branch);

    return DeityPlacementResult(
      gong: gong,
      steps: [
        StepResult(
          label: '支神步进',
          quotient: index,
          quotientLabel: '第${index + 1}位($branch)',
          remainder: position,
          remainderLabel: '入位年数',
        ),
      ],
    );
  }

  DeityPlacementResult _executeCumulativeWalk(
    Map<String, dynamic> params,
    CalculationContext ctx,
  ) {
    final cycle = params['cycle'] as int;
    final step = params['step'] as int;
    final startPalace = params['startPalace'] as String;
    final seq = (params['palaceSeq'] as List?)?.cast<String>()
        ?? _defaultPalaceSeq(PalaceSystem.nineGong).map((p) => p.palace).toList();
    
    final pos = ctx.ji % cycle;
    final stepsWalked = pos ~/ step;
    final remainder = pos % step;
    final startIdx = seq.indexOf(startPalace);
    final targetIdx = (startIdx + stepsWalked) % seq.length;
    final gong = _resolveGong(seq[targetIdx]);

    return DeityPlacementResult(
      gong: gong,
      steps: [
        StepResult(
          label: '逐宫累进',
          quotient: stepsWalked,
          quotientLabel: '走${stepsWalked}步',
          remainder: remainder == 0 ? step : remainder,
          remainderLabel: '入宫年数',
        ),
      ],
    );
  }

  DeityPlacementResult _executeCustomFormula(
    Map<String, dynamic> params,
    CalculationContext ctx,
  ) {
    final formula = params['formula'] as String;
    final variables = Map<String, int>.from(
      (params['variables'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ) ?? {},
    );
    variables['ji'] = ctx.ji;
    variables['ju'] = ctx.juNumber;
    variables['year'] = ctx.year;
    
    final result = ExpressionParser.evaluate(formula, variables);
    final gong = _resolvePalaceIndex(result);

    return DeityPlacementResult(
      gong: gong,
      formula: formula,
      steps: [
        StepResult(
          label: '表达式',
          quotient: result,
          quotientLabel: '$formula = $result',
          remainder: 0,
          remainderLabel: '',
        ),
      ],
    );
  }

  String _gongToName(EnumTaiYiGong? gong) {
    return switch (gong) {
      EnumTaiYiGong.Qian => '乾',
      EnumTaiYiGong.Li => '离',
      EnumTaiYiGong.Gen => '艮',
      EnumTaiYiGong.Zhen => '震',
      EnumTaiYiGong.Center => '中',
      EnumTaiYiGong.Dui => '兑',
      EnumTaiYiGong.Kun => '坤',
      EnumTaiYiGong.Kan => '坎',
      EnumTaiYiGong.Xun => '巽',
      null => '中',
    };
  }

  EnumTaiYiGong? _branchToGong(String branch) {
    return switch (branch) {
      '子' || '丑' => EnumTaiYiGong.Kan,
      '寅' || '艮' => EnumTaiYiGong.Gen,
      '卯' || '辰' => EnumTaiYiGong.Zhen,
      '巳' || '巽' => EnumTaiYiGong.Xun,
      '午' || '未' => EnumTaiYiGong.Li,
      '申' || '坤' => EnumTaiYiGong.Kun,
      '酉' || '戌' => EnumTaiYiGong.Dui,
      '亥' || '乾' => EnumTaiYiGong.Qian,
      _ => null,
    };
  }

  EnumTaiYiGong? _resolvePalaceIndex(int index) {
    const seq = [
      EnumTaiYiGong.Qian, EnumTaiYiGong.Li, EnumTaiYiGong.Gen,
      EnumTaiYiGong.Zhen, EnumTaiYiGong.Center, EnumTaiYiGong.Dui,
      EnumTaiYiGong.Kun, EnumTaiYiGong.Kan, EnumTaiYiGong.Xun,
    ];
    final normalized = ((index - 1) % seq.length + seq.length) % seq.length;
    return seq[normalized];
  }
```

验证: `flutter analyze lib/taiyi/core/algorithm_engine.dart`

commit: `add relativeOffset + cumulativeWalk + branchWalker + customFormula 执行器`

---

### Task 4.5 — 算法引擎单元测试（steppedCycle + 阳九 + 文昌）

**文件**: `test/taiyi/core/algorithm_engine_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_engine.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/taiyi/core/algorithm_spec.dart';
import 'package:taiyishenshu/taiyi/core/calculation_context.dart';
import 'package:taiyishenshu/taiyi/core/deity_definition.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';

void main() {
  late DeityAlgorithmEngine engine;

  setUp(() {
    engine = DeityAlgorithmEngine();
  });

  group('fixedPosition', () {
    test('四神青龙定在艮宫', () {
      final deity = DeityDefinition(
        id: 'siShen_qingLong',
        name: '青龙',
        layer: EnumDeityLayer.shenPan,
        algorithm: const DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.fixedPosition,
          params: {'gong': '艮'},
        ),
      );
      final ctx = CalculationContext(
        ji: 10155219, year: 2024, juNumber: 1,
        dun: DunType.yang, chartType: TaiYiChartType.year,
      );
      final result = engine.execute(deity, ctx);
      expect(result.gong, EnumTaiYiGong.Gen);
    });
  });

  group('steppedCycle — 阳九三层取模', () {
    test('金镜 阳九 724年 开元十二年', () {
      final deity = DeityDefinition(
        id: 'yangJiu',
        name: '阳九',
        layer: EnumDeityLayer.tianPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.steppedCycle,
          params: SteppedCycleParams(
            correction: 0,
            steps: const [
              CycleStep(cycle: 4560, step: 456, label: '阳九'),
              CycleStep(cycle: 456, step: 38, label: '邦'),
            ],
            palaceSystem: PalaceSystem.sixteenZhengJian,
            direction: WalkDirection.forward,
            startPalace: '寅',
          ).toJson(),
        ),
      );
      final ctx = CalculationContext(
        ji: 13331, year: 724, juNumber: 1,
        dun: DunType.yang, chartType: TaiYiChartType.year,
      );
      final result = engine.execute(deity, ctx);
      // 13331%4560=4211, 4211~/456=9 → 第10阳九
      expect(result.steps[0].quotient, 9);
      expect(result.steps[0].remainder, 107);
      // 107~/38=2 → 第3邦, 107%38=31 → 入邦第31年
      expect(result.steps[1].quotient, 2);
      expect(result.steps[1].remainder, 31);
      // 寅顺行2步 → 辰
      expect(result.gong, EnumTaiYiGong.Zhen); // 辰→震
    });
  });

  group('steppedCycle — 阴阳遁双模式 (文昌)', () {
    test('阳遁申起顺行 文昌落宫', () {
      final yangSeq = [
        const PalaceStep(palace: '申'), const PalaceStep(palace: '酉'),
        const PalaceStep(palace: '戌'), const PalaceStep(palace: '乾', staySteps: 2),
        const PalaceStep(palace: '亥'), const PalaceStep(palace: '子'),
        const PalaceStep(palace: '丑'), const PalaceStep(palace: '艮'),
        const PalaceStep(palace: '寅'), const PalaceStep(palace: '卯'),
        const PalaceStep(palace: '辰'), const PalaceStep(palace: '巽'),
        const PalaceStep(palace: '巳'), const PalaceStep(palace: '午'),
        const PalaceStep(palace: '未'), const PalaceStep(palace: '坤', staySteps: 2),
      ];
      final deity = DeityDefinition(
        id: 'wenChang',
        name: '文昌',
        layer: EnumDeityLayer.renPan,
        algorithm: DeityAlgorithmSpec(
          templateId: AlgorithmTemplateId.steppedCycle,
          params: SteppedCycleParams(
            steps: const [CycleStep(cycle: 18, step: 1, label: '文昌步')],
            palaceSystem: PalaceSystem.sixteenZhengJian,
            dunBinding: null, // 阴阳遁双模式
            yangConfig: const DunVariantConfig(
              direction: WalkDirection.forward,
              startPalace: '申',
              palaceSeq: [], // will be populated in test
            ),
            yinConfig: const DunVariantConfig(
              direction: WalkDirection.reverse,
              startPalace: '寅',
              palaceSeq: [],
            ),
          ).toJson(),
        ),
      );
      // Just verify the structure — full integration test later
      expect(deity.algorithm.templateId, AlgorithmTemplateId.steppedCycle);
    });
  });
}
```

验证:
```bash
flutter test test/taiyi/core/algorithm_engine_test.dart
```
预期: 3 passed

commit: `add 算法引擎单元测试 — fixedPosition + 阳九 + 文昌骨架`

---

## Group 5: 官方 JSON 配置

### Task 5.1 — 核心星神 JSON 配置（第一批：主客算相关）

**文件**: `assets/deities/tai-yi.json`
**文件**: `assets/deities/zhu-da-jiang.json`
**文件**: `assets/deities/ke-da-jiang.json`
**文件**: `assets/deities/zhu-can-jiang.json`
**文件**: `assets/deities/ke-can-jiang.json`
**文件**: `assets/deities/ding-da-jiang.json`
**文件**: `assets/deities/ding-can-jiang.json`

这些是核心算法星神（不走模板引擎，但需要在配置中注册）。每个 JSON 基础结构：

```json
{
  "id": "taiYi",
  "name": "太乙",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [{"cycle": 72, "step": 3, "label": "宫"}],
      "palaceSystem": "nineGong",
      "direction": "forward",
      "startPalace": "乾",
      "dunBinding": null,
      "chartRestriction": null
    }
  },
  "priority": 10,
  "source": "official"
}
```

验证: 确保每个 JSON 文件有效 `dart run` JSON parse

commit: `add 核心星神 JSON 配置 (第一批 7 个)`

---

### Task 5.2 — 天盘星神 JSON 配置（第二批：三基五福大游小游等）

星神列表和文件:

| 文件 | 星神 | 模板 | 关键参数 |
|------|------|------|---------|
| `assets/deities/jun-ji.json` | 君基 | steppedCycle | 360/30, 午起, 统宗覆写 correction=+250 |
| `assets/deities/chen-ji.json` | 臣基 | steppedCycle | 360/36/3, 午起, 统宗覆写 correction=+250 |
| `assets/deities/min-ji.json` | 民基 | steppedCycle | 360/12, 戌起, 统宗覆写 correction=+34 |
| `assets/deities/wu-fu.json` | 五福 | steppedCycle | 225/45, 乾起 |
| `assets/deities/da-you.json` | 大游 | steppedCycle | 288/36, 坤起, correction=-145 |
| `assets/deities/xiao-you.json` | 小游 | steppedCycle | 360/24/3, 一宫起, 跳中五 |
| `assets/deities/fei-fu.json` | 飞符 | relativeOffset | source=太乙, offset=+2 |
| `assets/deities/si-shen.json` | 四神 | steppedCycle | 36/3, custom宫序 |
| `assets/deities/tian-yi-star.json` | 天乙 | steppedCycle | 36/3, 酉起 custom宫序 |
| `assets/deities/di-yi.json` | 地乙 | steppedCycle | 36/3, 巳起 custom宫序 |
| `assets/deities/zhi-fu-star.json` | 直符 | steppedCycle | 36/3, 中起 custom宫序 |

验证: JSON 格式正确，每个文件可由 `jsonDecode` 解析

commit: `add 天盘星神 JSON 配置 (第二批 11 个)`

---

### Task 5.3 — 神盘星神 + 文昌计神始击 JSON 配置（第三批）

| 文件 | 星神 | 模板 |
|------|------|------|
| `assets/deities/tai-sui.json` | 太岁 | branchWalker |
| `assets/deities/sui-po.json` | 岁破 | relativeOffset (source=太岁, offset=6) |
| `assets/deities/zhi-fu.json` | 直符(神盘) | branchWalker |
| `assets/deities/he-shen.json` | 合神 | relativeOffset (source=直符) |
| `assets/deities/wen-chang.json` | 文昌/天目 | steppedCycle (阴阳遁双模式) |
| `assets/deities/ji-shen.json` | 计神 | branchWalker |
| `assets/deities/shi-ji.json` | 始击 | relativeOffset |
| `assets/deities/qing-long.json` | 青龙 | fixedPosition (艮) |
| `assets/deities/zhu-que.json` | 朱雀 | fixedPosition (离) |
| `assets/deities/bai-hu.json` | 白虎 | fixedPosition (兑) |
| `assets/deities/xuan-wu.json` | 玄武 | fixedPosition (坎) |
| `assets/deities/feng-bo.json` | 风伯 | branchWalker |
| `assets/deities/yu-shi.json` | 雨师 | branchWalker |
| `assets/deities/qing-long-qi.json` | 青龙旗 | relativeOffset (source=太岁) |
| `assets/deities/hei-qi.json` | 黑旗 | steppedCycle |
| `assets/deities/chi-qi.json` | 赤旗 | steppedCycle |
| `assets/deities/gui-shen-zhi-shi.json` | 贵神值事 | steppedCycle |

验证: `dart run` JSON parse

commit: `add 神盘 + 文昌计神始击 JSON 配置 (第三批 17 个)`

---

### Task 5.4 — 三派 JSON 配置

**文件**: `assets/schools/jing-mirror.json`

```json
{
  "id": "jingMirror",
  "name": "金镜派",
  "source": "official",
  "epoch": {
    "ancientBase": 1937281,
    "epochYear": 724,
    "correction": 0,
    "tropicalYear": 365.2425
  },
  "deityIds": [
    "taiYi", "zhuDaJiang", "keDaJiang", "zhuCanJiang", "keCanJiang",
    "dingDaJiang", "dingCanJiang",
    "junJi", "chenJi", "minJi", "wuFu", "daYou", "xiaoYou", "feiFu",
    "siShen", "tianYiStar", "diYi", "zhiFuStar",
    "taiSui", "suiPo", "zhiFu", "heShen",
    "qingLong", "zhuQue", "baiHu", "xuanWu", "fengBo", "yuShi",
    "wenChang", "jiShen", "shiJi"
  ],
  "wenChangStayRule": true,
  "useTwelveJiShen": false,
  "palaceFormula": "jingMirror",
  "eightDoorMode": "dynamic"
}
```

**文件**: `assets/schools/tong-zong.json`
同上结构，`epoch.ancientBase = 10155219`, `epoch.epochYear = 1303`, `overrides` 包含三基/五福/大游等修正值

**文件**: `assets/schools/ji-cheng.json`
`epoch.contemporaryEpochYear` 模式, `palaceFormula = "jiCheng"`, `useTwelveJiShen = true`, `eightDoorMode = "fixed"`

commit: `add 金镜派 + 统宗派 + 集成派 JSON 学校配置`

---

### Task 5.5 — JSON 配置校验测试

**文件**: `test/taiyi/core/json_config_validation_test.dart`

```dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JSON 配置校验', () {
    test('所有官方学校 JSON 可解析且必需字段完整', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // NOTE: 需要 flutter_test 环境加载 assets
    });
    test('所有官方星神 JSON 可解析', () async {});
    test('所有星神引用的 deityId 在星神定义中存在', () async {});
    test('所有学校的 deityIds 引用的星神全部存在', () async {});
  });
}
```

commit: `add JSON 配置校验测试骨架`

---

## Group 6: 计算器重构

### Task 6.1 — TaiYiPanCalculator 集成 SchoolConfig

修改 `lib/taiyi/taiyi_pan_calculator.dart`:

- 添加 `TaiYiSchool? _currentSchool` 字段
- 修改 `calculate()` 接受 `String schoolId` 而非 `TaiYiSchool` enum
- `_calculate()` 中: 加载 `SchoolConfig` → 用 `SchoolEpochConfig` 替换原有的硬编码积年计算
- 删除 `_RuleProfile` 类
- 保留核心算法方法不变

```dart
class TaiYiPanCalculator {
  static const algorithmVersion = '2.0.0';
  late final SchoolRepository _repository;
  
  TaiYiPanCalculator({SchoolRepository? repository}) {
    _repository = repository ?? OfficialJsonSchoolRepository(
      schoolIds: const ['jingMirror', 'tongZong', 'jiCheng'],
      deityIds: const [...], // all deity IDs
    );
  }

  Future<PanDataModel> calculate(PanInputModel input) async {
    final schools = await _repository.loadAllSchools();
    final school = schools.firstWhere((s) => s.id == input.schoolId);
    final deities = await _repository.loadAllDeities();
    final schoolDeities = deities.where((d) => school.deityIds.contains(d.id)).toList();
    return _calculate(input, school, schoolDeities);
  }

  PanDataModel _calculate(
    PanInputModel input,
    TaiYiSchool school,
    List<DeityDefinition> deities,
  ) {
    // 1. Epoch config → accumulated year
    final ji = school.epoch.calculateAccumulatedYear(input.dateTime.year);
    // 2. 年计
    // 3. 局数
    // 4. 阴阳遁
    // 5. 核心算法 (太乙宫/文昌/计神/始击/主客算/八门) — 保留现有逻辑
    // 6. DeityAlgorithmEngine.executeAll(deities, ctx)
    // 7. 格局
    // 8. 组装 PanDataModel
  }
}
```

验证: `flutter analyze lib/taiyi/taiyi_pan_calculator.dart`

commit: `update TaiYiPanCalculator 集成 SchoolConfig + 删除 _RuleProfile`

---

### Task 6.2 — PanInputModel 适配：schoolId 替换 school enum

**文件**: `lib/taiyi/pan_data_model.dart`

```dart
class PanInputModel {
  final DateTime dateTime;
  final String schoolId;          // was: TaiYiSchool school
  final TaiYiChartType chartType;
  final bool useTrueSolarTime;
  final String? location;
  final DateTime? birthDateTime;
  
  const PanInputModel({
    required this.dateTime,
    required this.schoolId,
    required this.chartType,
    this.useTrueSolarTime = false,
    this.location,
    this.birthDateTime,
  });
}
```

同步更新 `lib/taiyi/pan_enums.dart` — 移除 `TaiYiSchool` enum 定义（保留到 `.g.dart` 再删以确保向后兼容）

验证: `flutter analyze`

commit: `update PanInputModel — schoolId 替代 TaiYiSchool enum`

---

### Task 6.3 — 控制器适配

**文件**: `lib/controllers/taiyi_pan_controller.dart`

```dart
class TaiYiPanController extends ChangeNotifier {
  PanDataModel? _panData;
  bool _isCalculating = false;
  String? _error;
  late final TaiYiPanCalculator _calculator;

  // 新增: 可用流派列表
  List<TaiYiSchool> _availableSchools = [];
  String _currentSchoolId = 'jingMirror';

  TaiYiPanController({SchoolRepository? repository}) {
    _calculator = TaiYiPanCalculator(repository: repository);
  }

  Future<void> loadSchools() async {
    _availableSchools = await _calculator.repository.loadAllSchools();
    notifyListeners();
  }

  Future<void> calculate({
    DateTime? dateTime,
    String? schoolId,
    TaiYiChartType? chartType,
  }) async {
    _isCalculating = true; _error = null; notifyListeners();
    try {
      _panData = await _calculator.calculate(PanInputModel(
        dateTime: dateTime ?? DateTime.now(),
        schoolId: schoolId ?? _currentSchoolId,
        chartType: chartType ?? TaiYiChartType.year,
      ));
      _currentSchoolId = schoolId ?? _currentSchoolId;
    } catch (e) {
      _error = e.toString();
      _panData = null;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }
}
```

验证: `flutter analyze lib/controllers/taiyi_pan_controller.dart`

commit: `update TaiYiPanController 适配新配置系统`

---

### Task 6.4 — 回归测试验证

```bash
cd "D:/Programme/Flutter/xuan-taiyishenshu/.claude/worktrees/compassionate-kapitsa-bf9771"
flutter analyze   # 预期: 零 warning (已有 info 除外)
flutter test      # 预期: All tests passed (允许已有 17 个通过)
```

验证: 现有 17 个测试不回归

commit: `verify 回归测试通过 — 金镜/统宗星神结果一致`

---

## Group 7: UI 适配

### Task 7.1 — 流派选择器动态加载

**文件**: `lib/pages/taiyi_pan_page.dart`

```dart
class _TaiYiPanPageState extends State<TaiYiPanPage> {
  List<TaiYiSchool> _schools = [];

  @override
  void initState() {
    super.initState();
    _controller.loadSchools().then((_) {
      setState(() { _schools = _controller.availableSchools; });
    });
  }

  // 流派 ChoiceChips 改为从 _schools 动态渲染
  Widget _buildSchoolChips() {
    return Wrap(
      children: _schools.map((school) => ChoiceChip(
        label: Text(school.name),
        selected: _controller.currentSchoolId == school.id,
        onSelected: (_) => _controller.recalculateWith(schoolId: school.id),
      )).toList(),
    );
  }
}
```

验证: `flutter analyze lib/pages/taiyi_pan_page.dart`

commit: `update 流派选择器动态加载 SchoolConfig 列表`

---

### Task 7.2 — 信息面板动态渲染星神分步结果

**文件**: `lib/widgets/pan_info_panel.dart`

天盘/神盘信息区不再硬编码字段列表，改为遍历 `DeityPlacementResult` 列表动态生成 `_infoChip`：

```dart
Widget _buildDynamicDeitySection(String title, Color color, List<DeityPlacement> placements) {
  return Column(
    children: [
      _sectionTitle(title, color),
      Wrap(
        children: placements.map((p) => _infoChip(
          p.name,
          '${p.gong?.label ?? "未落宫"} ${p.steps.isNotEmpty ? "(${p.steps.last.remainderLabel})" : ""}',
        )).toList(),
      ),
    ],
  );
}
```

验证: `flutter analyze lib/widgets/pan_info_panel.dart`

commit: `update 星神信息面板改为动态渲染 DeityPlacementResult.steps`

---

### Task 7.3 — 端到端验证

```bash
flutter analyze
flutter test
```

并手动运行 example app 确认三种流派均可排盘，星神结果无变化。

commit: `verify 端到端验证 — 三派排盘 UI 无回归`

---

## 任务依赖图

```
Group 0 (目录+枚举)
  ↓
Group 1 (数据模型 1.1-1.6)
  ↓
Group 2 (Repository 2.1-2.3)  ←──┐
  ↓                              │
Group 3 (表达式引擎 3.1)         │
  ↓                              │
Group 4 (算法引擎 4.1-4.5)       │
  ↓                              │
Group 5 (JSON 配置 5.1-5.5) ────┘ (5.5 依赖 2.1-2.2)
  ↓
Group 6 (计算器重构 6.1-6.4)
  ↓
Group 7 (UI 适配 7.1-7.3)
```

---

## 里程碑

| 里程碑 | 完成标志 | 任务数 |
|--------|---------|--------|
| M1: 模型层就绪 | Group 0-1 全部提交 | 8 |
| M2: 配置引擎就绪 | Group 2-5 全部提交 + 测试通过 | 10 |
| M3: 计算器迁移完成 | Group 6 全部提交 + 全量测试无回归 | 4 |
| M4: UI 适配完成 | Group 7 全部提交 + 端到端验证 | 3 |
| **总计** | | **25 tasks** |
