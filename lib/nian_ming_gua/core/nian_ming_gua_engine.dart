import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:xuan_gua_core/xuan_gua_core.dart';
import 'package:taiyishenshu/gua_core/gua_sequence.dart';
import 'package:taiyishenshu/nian_ming_gua/core/stem_assignment.dart';

/// 太乙年命卦核心引擎。
///
/// 输入年份 → 输出 [NianMingGuaResultContract]。
///
/// 流程:
/// 1. accYear = year + epochBase
/// 2. remainder = accYear % 64 (余0视为64)
/// 3. gua = kTaiYiGuaSequence[remainder - 1]
/// 4. 从配置中查找该卦的 (startStemIndex, repeatAtYao4, yunIndex, yunName)
/// 5. stems = assignStems(startStemIndex, repeatAtYao4)
/// 6. yao = gua.yaoBoolList
/// 7. yangCount = gua.yangYaoCount
/// 8. ce = gua.ceCount
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
    final gua = kTaiYiGuaSequence[guaIndex - 1];
    final guaName = gua.standardName;

    final config = _configMap[guaName];
    if (config == null) {
      throw StateError('NianMingGua config not found for gua: $guaName');
    }

    final stems = assignStems(config.startStemIndex, config.repeatAtYao4);
    final yao = gua.yaoBoolList;
    final yang = gua.yangYaoCount;
    final ce = gua.ceCount;

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
