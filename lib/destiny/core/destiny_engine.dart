import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/taiyi_pan_calculator.dart';
import 'package:taiyishenshu/taiyi/pan_data_model.dart';
import 'package:taiyishenshu/taiyi/pan_enums.dart';
import 'twelve_palaces.dart';

/// 地支序(用于时辰推算)。
const List<String> _kBranches = [
  '子', '丑', '寅', '卯', '辰', '巳',
  '午', '未', '申', '酉', '戌', '亥',
];

/// 太乙人道命法核心引擎。
/// 调度流程:时计入局(复用) → 提取星神 → 十二宫映射(可配置)。
class DestinyEngine {
  final TaiYiPanCalculator _calculator;

  const DestinyEngine({TaiYiPanCalculator? calculator})
      : _calculator = calculator ?? const TaiYiPanCalculator();

  /// 计算人道命法命盘。
  /// [birthTime]: 出生时间(精确到时辰)。
  /// [config]: 命法配置(含积年参数+十二宫映射)。
  /// [schoolId]: 使用的流派 ID(默认 'tongZong')。
  DestinyResultContract calculate({
    required DateTime birthTime,
    required DestinyConfigContract config,
    String schoolId = 'tongZong',
  }) {
    // 1. 时计入局(复用现有 TaiYiPanCalculator)
    final pan = _calculator.calculate(
      dateTime: birthTime,
      schoolId: schoolId,
      chartType: TaiYiChartType.hour,
    );

    // 2. 提取核心星神位置
    final deityPlacements = <String, String>{};
    for (final palace in pan.palaces) {
      final palaceName = palace.name; // 八宫名(乾/坤/震等)
      for (final star in palace.stars) {
        deityPlacements[star] = palaceName;
      }
    }

    // 太乙/文昌/始击 从顶层字段获取(更精确)
    final taiYiPalaceName = pan.taiYiPalace.gua.name;
    final wenChangPalaceName = pan.wenChangPalace.gua.name;
    final shiJiPalaceName = pan.jiShenPalace.gua.name;

    deityPlacements['太乙'] = taiYiPalaceName;
    deityPlacements['文昌'] = wenChangPalaceName;
    deityPlacements['始击'] = shiJiPalaceName;

    // 3. 推算出生时辰地支
    final birthBranch = _hourToBranch(birthTime.hour);

    // 4. 十二宫映射
    final mapper = TwelvePalaceMapper(config.palaceMappings);
    final palaces = mapper.map(
      birthBranch: birthBranch,
      deityPlacements: deityPlacements,
    );

    // 5. 构造结果 Contract
    final palaceResults = palaces
        .map((p) => DestinyPalaceResultContract(
              index: p.index,
              name: p.name,
              deities: p.deities,
            ))
        .toList();

    return DestinyResultContract(
      accumulatedHour: pan.accumulatedYear, // 复用积年字段
      juNumber: pan.juNumber,
      dunType: pan.dunType == DunType.yang ? 'yang' : 'yin',
      taiYiPalace: taiYiPalaceName,
      wenChangPalace: wenChangPalaceName,
      shiJiPalace: shiJiPalaceName,
      hostCount: pan.hostGuest.hostCount,
      guestCount: pan.hostGuest.guestCount,
      twelvePalaces: palaceResults,
    );
  }

  /// 将 24 小时制转为地支(每 2 小时一个时辰)。
  /// 23:00-00:59 = 子, 01:00-02:59 = 丑, ...
  String _hourToBranch(int hour) {
    final index = ((hour + 1) % 24) ~/ 2;
    return _kBranches[index];
  }
}
