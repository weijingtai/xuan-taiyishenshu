import '../enums/gong.dart';
import '../enums/taiyi_enum_extensions.dart';

/// 地盘数据模型。
///
/// 地盘为九宫固定结构，每宫对应1位正神+1位间神，三派一致、永不动。
class DiPanModel {
  const DiPanModel({required this.palaces});

  /// 九宫地盘数据，按 EnumTaiYiGong 顺序排列。
  final List<DiPanPalaceModel> palaces;

  /// 按宫位枚举查找地盘宫数据。
  DiPanPalaceModel of(EnumTaiYiGong gong) {
    return palaces.firstWhere((p) => p.gong == gong);
  }

  Map<String, Object?> toJson() => {
    'palaces': palaces.map((p) => p.toJson()).toList(),
  };
}

/// 地盘单宫模型。
///
/// 每宫固定承载1位正神和1位间神；中宫无星神。
class DiPanPalaceModel {
  const DiPanPalaceModel({
    required this.gong,
    this.zhengShen,
    this.jianShen,
  });

  /// 本宫。
  final EnumTaiYiGong gong;

  /// 正神名称（如"阳德"），中宫为 null。
  final String? zhengShen;

  /// 间神名称（如"大义"），中宫为 null。
  final String? jianShen;

  Map<String, Object?> toJson() => {
    'gongId': gong.id,
    'zhengShen': zhengShen,
    'jianShen': jianShen,
  };
}
