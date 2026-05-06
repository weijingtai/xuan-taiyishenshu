import '../enums/gong.dart';
import '../enums/taiyi_enum_extensions.dart';

/// 人盘数据模型。
///
/// 人盘描述十六神流转后的排布，以及由此推算出的天目（文昌）、
/// 始击（客目）和计神。
class RenPanModel {
  const RenPanModel({
    required this.sixteenGodsByPalace,
    required this.tianMuGong,
    required this.shiJiGong,
    required this.jiShenGong,
    this.tianMuName,
    this.shiJiName,
    this.jiShenName,
    this.methodNote,
  });

  /// 人盘十六神流转后的落宫映射。
  ///
  /// 键为太乙宫，值为落入此宫的星神名称列表（按流转顺序）。
  final Map<EnumTaiYiGong, List<String>> sixteenGodsByPalace;

  /// 天目（文昌）所在宫。
  final EnumTaiYiGong tianMuGong;

  /// 始击（客目）所在宫。
  final EnumTaiYiGong shiJiGong;

  /// 计神所在宫。
  final EnumTaiYiGong jiShenGong;

  /// 天目落宫对应的十六神名（如"吕申"）。
  final String? tianMuName;

  /// 始击落宫对应的十六神名。
  final String? shiJiName;

  /// 计神落宫对应的十六神名。
  final String? jiShenName;

  /// 计算方法说明（记录流派差异）。
  final String? methodNote;

  Map<String, Object?> toJson() => {
    'sixteenGodsByPalace': sixteenGodsByPalace.map(
      (k, v) => MapEntry(k.id, v),
    ),
    'tianMuGong': tianMuGong.id,
    'shiJiGong': shiJiGong.id,
    'jiShenGong': jiShenGong.id,
    'tianMuName': tianMuName,
    'shiJiName': shiJiName,
    'jiShenName': jiShenName,
    'methodNote': methodNote,
  };
}
