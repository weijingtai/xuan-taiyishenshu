import '../../enums/gong.dart';
import '../pan_enums.dart';
import 'algorithm_enums.dart';
import 'algorithm_spec.dart';
import 'calculation_context.dart';
import 'deity_definition.dart';
import 'expression_parser.dart';

class DeityAlgorithmEngine {
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

  DeityPlacementResult _executeSteppedCycle(
    Map<String, dynamic> params,
    CalculationContext ctx,
  ) {
    final spec = SteppedCycleParams.fromJson(params);
    final steps = <StepResult>[];
    int value = switch (spec.baseVariable) {
      AlgorithmBaseVariable.ji => ctx.ji,
      AlgorithmBaseVariable.ju => ctx.juNumber,
      AlgorithmBaseVariable.year => ctx.year,
    } +
        spec.correction;

    final baseVarLabel = switch (spec.baseVariable) {
      AlgorithmBaseVariable.ji => '积数',
      AlgorithmBaseVariable.ju => '局数',
      AlgorithmBaseVariable.year => '年份',
    };

    for (final cs in spec.steps) {
      final pos = value % cs.cycle;
      final normalizedPos = pos == 0 ? cs.cycle : pos;
      final quotient = (normalizedPos - 1) ~/ cs.step;
      final remainder = (normalizedPos - 1) % cs.step + 1;
      steps.add(StepResult(
        label: cs.label,
        quotient: quotient,
        quotientLabel: '第${quotient + 1}${cs.label}',
        remainder: remainder,
        remainderLabel: '入${cs.label}年数',
      ));
      value = remainder;
    }

    List<PalaceStep>? palaceSeq;
    WalkDirection? direction;
    String? startPalace;

    if (spec.dunBinding == null &&
        spec.yangConfig != null &&
        spec.yinConfig != null) {
      final config =
          ctx.dun == DunType.yang ? spec.yangConfig : spec.yinConfig;
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

    final formulaParts = steps.map((s) =>
        "${s.label}${s.quotientLabel}(${s.remainderLabel})").join(" → ");

    return DeityPlacementResult(
      gong: _resolveGong(gong) ?? _branchToGong(gong),
      steps: steps,
      formula:
          '$baseVarLabel${spec.correction >= 0 ? "+" : ""}${spec.correction} → $formulaParts',
    );
  }

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

    final palaceSystemStr = params['palaceSystem'] as String?;
    final seq = palaceSystemStr == 'sixteenZhengJian'
        ? _defaultPalaceSeq(PalaceSystem.sixteenZhengJian)
        : _defaultPalaceSeq(PalaceSystem.nineGong);
    final flatSeq = seq
        .expand<String>(
            (ps) => List.filled(ps.staySteps, ps.palace),
        )
        .toList();
    final currentIdx = flatSeq.indexOf(_gongToName(source.gong));
    final targetIdx = (currentIdx + offset) % flatSeq.length;
    final gong = _resolveGong(flatSeq[targetIdx]);

    return DeityPlacementResult(
      gong: gong,
      steps: [
        StepResult(
          label: '偏移',
          quotient: offset,
          quotientLabel: '$sourceId+$offset',
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
    final seq = (params['palaceSeq'] as List?)
            ?.cast<String>() ??
        _defaultPalaceSeq(PalaceSystem.nineGong)
            .map((p) => p.palace)
            .toList();

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
          quotientLabel: '走$stepsWalked步',
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
          ) ??
          {},
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

  /// 在宫序中行走，返回目标宫名
  String _walkPalaceSequence(
    List<PalaceStep> seq,
    WalkDirection direction,
    String startPalace,
    int stepsToWalk,
  ) {
    final flatSeq = <String>[];
    for (final ps in seq) {
      for (int s = 0; s < ps.staySteps; s++) {
        flatSeq.add(ps.palace);
      }
    }

    final startIdx = flatSeq.indexOf(startPalace);
    final effectiveSteps = stepsToWalk % flatSeq.length;
    int targetIdx;
    if (direction == WalkDirection.forward) {
      targetIdx = (startIdx + effectiveSteps) % flatSeq.length;
    } else {
      targetIdx =
          (startIdx - effectiveSteps) % flatSeq.length;
      if (targetIdx < 0) targetIdx += flatSeq.length;
    }
    return flatSeq[targetIdx];
  }

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
      EnumTaiYiGong.Qian,
      EnumTaiYiGong.Li,
      EnumTaiYiGong.Gen,
      EnumTaiYiGong.Zhen,
      EnumTaiYiGong.Center,
      EnumTaiYiGong.Dui,
      EnumTaiYiGong.Kun,
      EnumTaiYiGong.Kan,
      EnumTaiYiGong.Xun,
    ];
    final normalized = ((index - 1) % seq.length + seq.length) % seq.length;
    return seq[normalized];
  }

  List<PalaceStep> _defaultPalaceSeq(PalaceSystem system) {
    return switch (system) {
      PalaceSystem.nineGong => [
          const PalaceStep(palace: '乾'),
          const PalaceStep(palace: '离'),
          const PalaceStep(palace: '艮'),
          const PalaceStep(palace: '震'),
          const PalaceStep(palace: '巽'),
          const PalaceStep(palace: '兑'),
          const PalaceStep(palace: '坤'),
          const PalaceStep(palace: '坎'),
        ],
      PalaceSystem.sixteenZhengJian => [
          const PalaceStep(palace: '子'),
          const PalaceStep(palace: '丑'),
          const PalaceStep(palace: '艮'),
          const PalaceStep(palace: '寅'),
          const PalaceStep(palace: '卯'),
          const PalaceStep(palace: '辰'),
          const PalaceStep(palace: '巽'),
          const PalaceStep(palace: '巳'),
          const PalaceStep(palace: '午'),
          const PalaceStep(palace: '未'),
          const PalaceStep(palace: '坤'),
          const PalaceStep(palace: '申'),
          const PalaceStep(palace: '酉'),
          const PalaceStep(palace: '戌'),
          const PalaceStep(palace: '乾'),
          const PalaceStep(palace: '亥'),
        ],
      PalaceSystem.mixed => [
          const PalaceStep(palace: '乾'),
          const PalaceStep(palace: '离'),
          const PalaceStep(palace: '艮'),
          const PalaceStep(palace: '震'),
          const PalaceStep(palace: '巽'),
          const PalaceStep(palace: '兑'),
          const PalaceStep(palace: '坤'),
          const PalaceStep(palace: '坎'),
        ],
    };
  }
}
