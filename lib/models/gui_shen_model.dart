import '../enums/gong.dart';
import '../enums/gui_shen.dart';

/// 太乙贵神排盘结果：记录每个宫位对应的贵神，以及值事贵神。
class GuiShenModel {
  const GuiShenModel({
    required this.zhiShiGuiShen,
    required this.palaceMap,
    required this.zhiShiIndex,
  });

  /// 值事贵神（坐镇中五宫）。
  final EnumGuiShen zhiShiGuiShen;

  /// 值事贵神序号（1-9，对应逆行表中的位置）。
  final int zhiShiIndex;

  /// 宫位 → 贵神映射（中五宫 = 值事贵神，其余按洛书顺行）。
  final Map<EnumTaiYiGong, EnumGuiShen> palaceMap;

  /// 查询某宫位的贵神。
  EnumGuiShen? of(EnumTaiYiGong gong) => palaceMap[gong];

  /// 洛书九宫顺行路线（不含中宫）：一→二→三→四→（五跳过）→六→七→八→九
  /// 对应宫位枚举顺序。
  static const luoShuForwardPalaces = [
    EnumTaiYiGong.Kan,   // 一
    EnumTaiYiGong.Kun,   // 二
    EnumTaiYiGong.Zhen,  // 三
    EnumTaiYiGong.Xun,   // 四
    EnumTaiYiGong.Center,// 五（中宫，值事贵神）
    EnumTaiYiGong.Qian,  // 六
    EnumTaiYiGong.Dui,   // 七
    EnumTaiYiGong.Gen,   // 八
    EnumTaiYiGong.Li,    // 九
  ];

  Map<String, Object?> toJson() => {
    'zhiShiGuiShen': zhiShiGuiShen.label,
    'zhiShiIndex': zhiShiIndex,
    'palaceMap': palaceMap.map(
      (k, v) => MapEntry(k.name, v.label),
    ),
  };
}
