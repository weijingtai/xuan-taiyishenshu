import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/rules/nine_palace.dart';

/// 十二宫名称常量(统宗人道命法)。
const List<String> kTwelvePalaceNames = [
  '命宫', '相貌', '父母', '兄弟', '妻妾', '子孙',
  '财帛', '田宅', '官禄', '奴仆', '疾厄', '福德',
];

/// 地支→八宫映射。
const Map<String, String> kBranchToPalace = {
  '子': '坎', '丑': '艮', '寅': '艮', '卯': '震',
  '辰': '巽', '巳': '巽', '午': '离', '未': '坤',
  '申': '兑', '酉': '乾', '戌': '乾', '亥': '坎',
};

/// 十二宫映射结果(单宫)。
class PalaceSlot {
  final int index;
  final String name;
  final String palace;
  final List<String> deities;

  PalaceSlot({
    required this.index,
    required this.name,
    required this.palace,
    this.deities = const [],
  });
}

/// 十二宫映射引擎。
/// 根据配置的 palaceMappings 和输入参数,计算十二宫分布。
class TwelvePalaceMapper {
  final List<DestinyPalaceMappingContract> mappings;

  TwelvePalaceMapper(this.mappings);

  /// 执行映射。
  /// [birthBranch]: 出生时支(如'寅')。
  /// [deityPlacements]: 星神→所落宫位 map(如{'太乙':'乾','文昌':'离'})。
  List<PalaceSlot> map({
    required String birthBranch,
    required Map<String, String> deityPlacements,
  }) {
    final context = <int, String>{};
    final result = <PalaceSlot>[];

    for (final mapping in mappings) {
      final palace = resolveMappingRule(
        mapping.mappingRule,
        birthBranch: birthBranch,
        context: context,
      );
      context[mapping.index] = palace;

      // 将落入此宫的星神收集起来
      final deities = <String>[];
      for (final entry in deityPlacements.entries) {
        if (entry.value == palace) {
          deities.add(entry.key);
        }
      }

      result.add(PalaceSlot(
        index: mapping.index,
        name: mapping.name,
        palace: palace,
        deities: deities,
      ));
    }

    return result;
  }
}

/// 解析单条映射规则,返回对应八宫名。
/// [rule]: 如 'birthBranchPalace', 'sequentialNext(1)', 'fixedPalace(乾)'
/// [context]: 已解析的宫位(index→palace)用于 sequentialNext 引用。
/// [birthBranch]: 出生时支。
String resolveMappingRule(
  String rule, {
  required String birthBranch,
  required Map<int, String> context,
}) {
  if (rule == 'birthBranchPalace') {
    return kBranchToPalace[birthBranch] ?? '坎';
  }

  if (rule.startsWith('sequentialNext(')) {
    final refIndex = int.parse(
      rule.substring('sequentialNext('.length, rule.length - 1),
    );
    final refPalace = context[refIndex] ?? '坎';
    return _nextPalace(refPalace);
  }

  if (rule.startsWith('fixedPalace(')) {
    return rule.substring('fixedPalace('.length, rule.length - 1);
  }

  return '坎'; // fallback
}

/// 在 kTaiYiPalaceOrder 顺行序列中取下一个宫。
String _nextPalace(String current) {
  final idx = kTaiYiPalaceOrder.indexOf(current);
  if (idx < 0) return kTaiYiPalaceOrder[0];
  return kTaiYiPalaceOrder[(idx + 1) % kTaiYiPalaceOrder.length];
}
