import '../enums/door.dart';
import '../enums/god.dart';
import '../enums/gong.dart';
import '../taiyi/pan_enums.dart';

/// 自定义神定义。
class CustomDeityDefinition {
  const CustomDeityDefinition({
    required this.id,
    required this.name,
    required this.school,
    required this.enabled,
    required this.priority,
    required this.algorithm,
    this.description,
  });

  /// 稳定 ID，建议格式为 `custom:{source}:{uuid}`。
  final String id;

  /// 展示名。
  final String name;

  /// 绑定流派。
  final TaiYiSchool school;

  /// 是否启用。
  final bool enabled;

  /// 同宫显示优先级。
  final int priority;

  /// 自定义神算法配置。
  final CustomDeityAlgorithmSpec algorithm;

  /// 描述说明。
  final String? description;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'school': school.name,
        'enabled': enabled,
        'priority': priority,
        'algorithm': algorithm.toJson(),
        'description': description,
      };
}

/// 自定义神算法模板配置。
class CustomDeityAlgorithmSpec {
  const CustomDeityAlgorithmSpec({
    required this.templateId,
    required this.version,
    required this.params,
  });

  /// 模板 ID，例如 `juOffset`、`branchMapping`。
  final String templateId;

  /// 模板版本。
  final int version;

  /// 模板参数。引用 enum 时使用 enum.name 作为 ID。
  final Map<String, Object?> params;

  Map<String, Object?> toJson() => {
        'templateId': templateId,
        'version': version,
        'params': params,
      };
}

/// 自定义神仓储接口。
abstract class CustomDeityRepository {
  Future<List<CustomDeityDefinition>> loadDefinitions({
    required TaiYiSchool school,
  });
}

/// 内存自定义神仓储，主要用于测试和临时配置。
class InMemoryCustomDeityRepository implements CustomDeityRepository {
  const InMemoryCustomDeityRepository(this.definitions);

  final List<CustomDeityDefinition> definitions;

  @override
  Future<List<CustomDeityDefinition>> loadDefinitions({
    required TaiYiSchool school,
  }) async {
    return definitions
        .where(
            (definition) => definition.enabled && definition.school == school)
        .toList(growable: false);
  }
}

/// JSON 自定义神仓储占位。
///
/// 当前只定义形状，后续接入导入导出时再补解析逻辑。
class JsonCustomDeityRepository implements CustomDeityRepository {
  const JsonCustomDeityRepository();

  @override
  Future<List<CustomDeityDefinition>> loadDefinitions({
    required TaiYiSchool school,
  }) async {
    return const [];
  }
}

/// 本地 DB 自定义神仓储占位。
///
/// 当前只定义形状，后续接入 drift/sqflite 时再补实现。
class DbCustomDeityRepository implements CustomDeityRepository {
  const DbCustomDeityRepository();

  @override
  Future<List<CustomDeityDefinition>> loadDefinitions({
    required TaiYiSchool school,
  }) async {
    return const [];
  }
}

/// 自定义神算法可引用的传统 enum 类型说明。
class CustomDeityEnumRefs {
  const CustomDeityEnumRefs({
    this.gong,
    this.sixteenGod,
    this.taiYiDoor,
  });

  final EnumTaiYiGong? gong;
  final EnumTaiYiSixteenGods? sixteenGod;
  final EnumTaiYiDoor? taiYiDoor;
}
