import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/gua_core/gua_sequence.dart';
import 'package:taiyishenshu/nian_ming_gua/core/stem_assignment.dart';

/// 太乙年命卦核心引擎。
///
/// 输入年份 → 输出 [NianMingGuaResultContract]。
///
/// 流程:
/// 1. accYear = year + epochBase
/// 2. remainder = accYear % 64 (余0视为64)
/// 3. guaName = kTaiYiGuaSequence[remainder - 1]
/// 4. 从配置中查找该卦的 (startStemIndex, repeatAtYao4, yunIndex, yunName)
/// 5. stems = assignStems(startStemIndex, repeatAtYao4)
/// 6. yao = kGuaYaoMap[guaName]
/// 7. yangCount = yangYaoCount(guaName)
/// 8. ce = ceCount(guaName)
/// 9. 组装返回 NianMingGuaResultContract
class NianMingGuaEngine {
  final int epochBase;
  final Map<String, NianMingGuaConfigContract> _configMap;

  NianMingGuaEngine({
    this.epochBase = 10153917,
    required List<NianMingGuaConfigContract> configs,
  }) : _configMap = {
          for (final c in configs) c.guaName: c,
        };

  NianMingGuaResultContract calculate({required int year}) {
    final accYear = year + epochBase;
    final rawRemainder = accYear % 64;
    final guaIndex = rawRemainder == 0 ? 64 : rawRemainder;
    final guaName = kTaiYiGuaSequence[guaIndex - 1];

    final config = _configMap[guaName];
    if (config == null) {
      throw StateError('NianMingGua config not found for gua: $guaName');
    }

    final stems = assignStems(config.startStemIndex, config.repeatAtYao4);
    final yao = kGuaYaoMap[guaName]!;
    final yang = yangYaoCount(guaName);
    final ce = ceCount(guaName);

    return NianMingGuaResultContract(
      accumulatedYear: accYear,
      guaIndex: guaIndex,
      guaName: guaName,
      yao: yao,
      yangYaoCount: yang,
      yinYaoCount: 6 - yang,
      ceCount: ce,
      stems: stems,
      branch: kFixedBranch,
      yunIndex: config.yunIndex,
      yunName: config.yunName,
    );
  }
}
