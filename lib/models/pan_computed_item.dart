import '../enums/eight_door.dart';
import '../enums/taiyi_enum_extensions.dart';
import '../enums/gong.dart';

/// 起盘计算项类型。
enum PanComputedItemKind {
  deity,
  general,
  eye,
  taiYiDoor,
  eightDoor,
  count,
  customDeity,
}

/// 起盘计算项来源。
enum PanComputedItemSource {
  builtIn,
  custom,
}

/// 宫位中的一个结构化计算结果。
///
/// 传统太乙、文昌、计神、主客算、八门和用户自定义神都使用这个模型。
class PanComputedItem {
  const PanComputedItem({
    required this.id,
    required this.name,
    required this.kind,
    required this.source,
    required this.priority,
    this.gong,
    this.reason,
    this.metadata = const {},
  });

  /// 稳定标识。内置项使用 `builtIn:*`，自定义神使用 `custom:*`。
  final String id;

  /// 展示名。
  final String name;

  /// 计算项类型。
  final PanComputedItemKind kind;

  /// 所落太乙宫；为空表示未落宫。
  final EnumTaiYiGong? gong;

  /// 来源：内置或自定义。
  final PanComputedItemSource source;

  /// 同宫排序优先级，数值越小越靠前。
  final int priority;

  /// 计算或引用原因说明。
  final String? reason;

  /// 算法中间值与扩展元数据。
  final Map<String, Object?> metadata;

  /// 是否已经落入某一宫。
  bool get isPlaced => gong != null;

  PanComputedItem copyWith({
    EnumTaiYiGong? gong,
    String? reason,
    Map<String, Object?>? metadata,
  }) {
    return PanComputedItem(
      id: id,
      name: name,
      kind: kind,
      gong: gong ?? this.gong,
      source: source,
      priority: priority,
      reason: reason ?? this.reason,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'gongId': gong?.id,
        'source': source.name,
        'priority': priority,
        'reason': reason,
        'metadata': metadata,
      };
}

/// 八门落宫项构造工具。
PanComputedItem eightDoorItem({
  required EnumEightDoor door,
  required EnumTaiYiGong gong,
  int priority = 500,
}) {
  return PanComputedItem(
    id: 'builtIn:eightDoor:${door.id}',
    name: door.name,
    kind: PanComputedItemKind.eightDoor,
    gong: gong,
    source: PanComputedItemSource.builtIn,
    priority: priority,
    metadata: {
      'eightDoorId': door.id,
      'singleName': door.singleName,
    },
  );
}
