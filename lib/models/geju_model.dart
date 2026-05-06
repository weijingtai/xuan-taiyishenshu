import '../enums/deity_kind.dart';
import '../enums/geju.dart';
import '../enums/gong.dart';
import '../enums/taiyi_enum_extensions.dart';

/// 格局判断结果模型。
///
/// 格局定义三派一致，差异仅在金镜派是否细拆小格局。
class GeJuResultModel {
  const GeJuResultModel({
    required this.patterns,
    this.methodNote,
  });

  /// 命中的格局列表。
  final List<GeJuEntry> patterns;

  /// 计算方法说明。
  final String? methodNote;

  /// 是否命中间局类型。
  bool has(EnumGeJu type) => patterns.any((p) => p.type == type);

  /// 获取指定类型的所有格局条目。
  List<GeJuEntry> of(EnumGeJu type) =>
      patterns.where((p) => p.type == type).toList();

  Map<String, Object?> toJson() => {
    'patterns': patterns.map((p) => p.toJson()).toList(),
    'methodNote': methodNote,
  };
}

/// 单条格局命中记录。
class GeJuEntry {
  const GeJuEntry({
    required this.type,
    required this.description,
    this.relatedGongs = const [],
    this.relatedDeities = const [],
    this.severity,
    this.classicReference,
  });

  /// 格局类型。
  final EnumGeJu type;

  /// 格局描述（如"客目掩太乙，同宫于离"）。
  final String description;

  /// 与本格局相关的宫位。
  final List<EnumTaiYiGong> relatedGongs;

  /// 与本格局相关的星神类型。
  final List<EnumDeityKind> relatedDeities;

  /// 格局严重程度，数值越大越严重。
  final int? severity;

  /// 典籍引用标识，待典籍模块接入后使用。
  final String? classicReference;

  Map<String, Object?> toJson() => {
    'type': type.name,
    'description': description,
    'relatedGongs': relatedGongs.map((g) => g.id).toList(),
    'relatedDeities': relatedDeities.map((d) => d.name).toList(),
    'severity': severity,
    'classicReference': classicReference,
  };
}
