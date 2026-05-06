import '../enums/gong.dart';
import '../enums/ming_gong.dart';
import '../enums/taiyi_enum_extensions.dart';

/// 命盘数据模型（太乙命法）。
///
/// 统宗派命法最全；金镜古法逆排；集成同统宗但简化星神。
class MingPanModel {
  const MingPanModel({
    required this.mingGong,
    required this.shenGong,
    required this.twelvePalaces,
    this.methodNote,
  });

  /// 命宫所在太乙宫（生年地支宫）。
  final EnumTaiYiGong mingGong;

  /// 身宫所在太乙宫（金镜看生时，统宗/集成看生月）。
  final EnumTaiYiGong shenGong;

  /// 十二宫排布结果。
  final List<MingPalaceModel> twelvePalaces;

  /// 计算方法说明。
  final String? methodNote;

  Map<String, Object?> toJson() => {
    'mingGong': mingGong.id,
    'shenGong': shenGong.id,
    'twelvePalaces': twelvePalaces.map((p) => p.toJson()).toList(),
    'methodNote': methodNote,
  };
}

/// 命盘十二宫中单宫模型。
class MingPalaceModel {
  const MingPalaceModel({
    required this.palaceType,
    required this.gong,
    this.deities = const [],
    this.note,
  });

  /// 十二宫类型（命/财/官/福…）。
  final EnumMingGong palaceType;

  /// 对应的太乙宫。
  final EnumTaiYiGong gong;

  /// 本宫所临的星神名称列表。
  final List<String> deities;

  /// 附加说明。
  final String? note;

  Map<String, Object?> toJson() => {
    'palaceType': palaceType.name,
    'gongId': gong.id,
    'deities': deities,
    'note': note,
  };
}
