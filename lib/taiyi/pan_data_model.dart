import '../enums/eight_door.dart';
import '../enums/gong.dart';
import '../enums/taiyi_enum_extensions.dart';
import '../models/di_pan_model.dart';
import '../models/geju_model.dart';
import '../models/gui_shen_model.dart';
import '../models/ming_pan_model.dart';
import '../models/pan_computed_item.dart';
import '../models/ren_pan_model.dart';
import '../models/shen_pan_model.dart';
import '../models/tian_pan_model.dart';
import '../models/year_ji_model.dart';
import 'pan_enums.dart';

/// 起盘输入模型，记录用户选择和计算所需的时间上下文。
class PanInputModel {
  const PanInputModel({
    required this.dateTime,
    required this.schoolId,
    required this.schoolName,
    required this.chartType,
    this.useTrueSolarTime = false,
    this.location,
    this.birthDateTime,
  });

  /// 起盘使用的公历时间。
  final DateTime dateTime;

  /// 起盘采用的流派 ID（如 'jingMirror'）。
  final String schoolId;

  /// 起盘采用的流派显示名（如 '金镜派'）。
  final String schoolName;

  /// 年家、月家、日家、时家或预留的刻家。
  final TaiYiChartType chartType;

  /// 是否启用真太阳时；当前仅保留参数，尚未参与修正。
  final bool useTrueSolarTime;

  /// 地点信息，后续用于真太阳时或地方规则修正。
  final String? location;

  /// 命盘所需的出生时间（可选）。
  final DateTime? birthDateTime;

  /// 转为可持久化的 JSON 结构，供本地记录保存。
  Map<String, Object?> toJson() => {
    'dateTime': dateTime.toIso8601String(),
    'schoolId': schoolId,
    'schoolName': schoolName,
    'chartType': chartType.name,
    'useTrueSolarTime': useTrueSolarTime,
    'location': location,
    'birthDateTime': birthDateTime?.toIso8601String(),
  };
}

/// 九宫中单宫的排盘结果。
class PalaceDataModel {
  const PalaceDataModel({
    required this.gong,
    required this.items,
    this.note,
  });

  /// 本宫，使用传统太乙宫枚举作为核心类型。
  final EnumTaiYiGong gong;

  /// 本宫承载的所有结构化计算项。
  final List<PanComputedItem> items;

  /// 预留说明字段，用于补充特殊格局或传本差异。
  final String? note;

  /// 兼容旧 UI 的宫数读取。
  int get number => gong.order;

  /// 兼容旧 UI 的宫名读取。
  String get name => gong.gua.name;

  /// 本宫对应地支；当前沿用旧模型的展示需求，后续可迁移到 enum 元数据。
  List<String> get branches => switch (gong) {
    EnumTaiYiGong.Qian => const ['戌', '亥'],
    EnumTaiYiGong.Li => const ['午'],
    EnumTaiYiGong.Gen => const ['丑', '寅'],
    EnumTaiYiGong.Zhen => const ['卯'],
    EnumTaiYiGong.Dui => const ['酉'],
    EnumTaiYiGong.Kun => const ['未', '申'],
    EnumTaiYiGong.Kan => const ['子'],
    EnumTaiYiGong.Xun => const ['辰', '巳'],
    EnumTaiYiGong.Center => const [],
  };

  /// 兼容旧 UI 的星神名称列表。
  List<String> get stars => items
      .where((item) => item.kind != PanComputedItemKind.eightDoor)
      .map((item) => item.name)
      .toList(growable: false);

  /// 兼容旧 UI 的八门名称列表。
  List<String> get doors => items
      .where((item) => item.kind == PanComputedItemKind.eightDoor)
      .map((item) => item.name)
      .toList(growable: false);

  /// 创建带有局部字段变更的新宫位结果。
  PalaceDataModel copyWith({
    List<PanComputedItem>? items,
    String? note,
  }) {
    return PalaceDataModel(
      gong: gong,
      items: items ?? this.items,
      note: note ?? this.note,
    );
  }

  /// 转为可持久化的 JSON 结构。
  Map<String, Object?> toJson() => {
    'gongId': gong.id,
    'number': number,
    'name': name,
    'branches': branches,
    'items': items.map((item) => item.toJson()).toList(),
    'note': note,
  };
}

/// 主客算结果。
class HostGuestDataModel {
  const HostGuestDataModel({
    required this.hostCount,
    required this.guestCount,
    required this.dingCount,
    required this.hostPalace,
    required this.guestPalace,
    required this.dingPalace,
    this.dingMuPalace,
    this.dingMuName,
    required this.method,
    this.hostCountDetail,
    this.guestCountDetail,
    this.dingCountDetail,
  });

  /// 主算数。
  final int hostCount;

  /// 客算数。
  final int guestCount;

  /// 定算数（主算除以10之余数，余0则重除为10）。
  final int dingCount;

  /// 主方落宫。
  final EnumTaiYiGong hostPalace;

  /// 客方落宫。
  final EnumTaiYiGong guestPalace;

  /// 定方落宫。
  final EnumTaiYiGong dingPalace;

  /// 定目落宫（时家专用，年/月/日家可为null）。
  final EnumTaiYiGong? dingMuPalace;

  /// 定目名称（如"阳德"等十六神名）。
  final String? dingMuName;

  /// 当前采用的主客算说明。
  final String method;

  final HostCountDetail? hostCountDetail;
  final HostCountDetail? guestCountDetail;
  final HostCountDetail? dingCountDetail;

  Map<String, Object?> toJson() => {
    'hostCount': hostCount,
    'guestCount': guestCount,
    'dingCount': dingCount,
    'hostPalace': hostPalace.id,
    'guestPalace': guestPalace.id,
    'dingPalace': dingPalace.id,
    'dingMuPalace': dingMuPalace?.id,
    'dingMuName': dingMuName,
    'method': method,
    'hostCountDetail': hostCountDetail?.toJson(),
    'guestCountDetail': guestCountDetail?.toJson(),
    'dingCountDetail': dingCountDetail?.toJson(),
  };
}

/// 主客算明细（正宫/间神分算结果）。
class HostCountDetail {
  const HostCountDetail({
    required this.isZhengGong,
    this.isChangShu,
    this.isDuanShu,
    this.isHe,
    this.isBuHe,
    this.detail,
  });

  /// 是否为正宫算（非间神算）。
  final bool isZhengGong;

  /// 是否为长数。
  final bool? isChangShu;

  /// 是否为短数。
  final bool? isDuanShu;

  /// 是否和。
  final bool? isHe;

  /// 是否不和。
  final bool? isBuHe;

  /// 计算过程明细字符串。
  final String? detail;

  Map<String, Object?> toJson() => {
    'isZhengGong': isZhengGong,
    'isChangShu': isChangShu,
    'isDuanShu': isDuanShu,
    'isHe': isHe,
    'isBuHe': isBuHe,
    'detail': detail,
  };
}

/// 命中的典籍引用，当前为后续典籍模块预留。
class ClassicReferenceDataModel {
  const ClassicReferenceDataModel({
    required this.id,
    required this.title,
    required this.reason,
    this.chapterId,
    this.priority = 0,
  });

  /// 引用记录唯一标识。
  final String id;

  /// 典籍或章节标题。
  final String title;

  /// 本章节被引用的原因。
  final String reason;

  /// 章节标识，待典籍库接入后对应章节表。
  final String? chapterId;

  /// 展示优先级，数值越大可越靠前。
  final int priority;

  /// 转为可持久化的 JSON 结构。
  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'reason': reason,
    'chapterId': chapterId,
    'priority': priority,
  };
}

/// 太乙起盘完整结果模型。
///
/// 整合地盘、人盘、天盘、神盘、格局、命盘六大层级，
/// 保留原始 MVP 字段以兼容旧代码。
class PanDataModel {
  const PanDataModel({
    required this.input,
    required this.algorithmVersion,
    required this.accumulatedYear,
    required this.sequenceIndex,
    required this.juNumber,
    required this.dunType,
    required this.taiYiPalace,
    required this.wenChangPalace,
    required this.jiShenPalace,
    required this.palaces,
    required this.eightDoorsByPalace,
    required this.hostGuest,
    required this.diPan,
    required this.renPan,
    required this.tianPan,
    required this.shenPan,
    required this.geJu,
    this.schoolBase,
    this.unplacedItems = const [],
    this.classicReferences = const [],
    this.warnings = const [],
    this.mingPan,
    this.yearJi,
    this.guiShen,
  });

  /// 本次起盘的输入快照。
  final PanInputModel input;

  /// 算法版本，用于历史记录复盘和未来迁移。
  final String algorithmVersion;

  /// 积年值；不同流派会采用不同基准或偏移。
  final int accumulatedYear;

  /// 盘类型对应的递推序号，归约为 72 局前使用。
  final int sequenceIndex;

  /// 太乙局数，范围为 1 到 72。
  final int juNumber;

  /// 阴遁或阳遁。
  final DunType dunType;

  /// 太乙所在宫。
  final EnumTaiYiGong taiYiPalace;

  /// 文昌、天目所在宫。
  final EnumTaiYiGong wenChangPalace;

  /// 计神所在宫。
  final EnumTaiYiGong jiShenPalace;

  /// 流派积年基数描述，如"金镜派基数: 1937281"。
  final String? schoolBase;

  /// 九宫完整结果（兼容旧 UI）。
  final List<PalaceDataModel> palaces;

  /// 八门落宫映射，键为太乙宫，值为开休生伤杜景死惊。
  final Map<EnumTaiYiGong, EnumEightDoor> eightDoorsByPalace;

  /// 未能落宫的计算项，例如算法失败的自定义神。
  final List<PanComputedItem> unplacedItems;

  /// 主客算结果。
  final HostGuestDataModel hostGuest;

  /// 命中的典籍章节引用，当前先为空列表。
  final List<ClassicReferenceDataModel> classicReferences;

  /// 算法简化、传本差异或未实现能力的提示。
  final List<String> warnings;

  /// ── 分层盘面模型 ──

  /// 地盘：九宫固定结构，十六神对应。
  final DiPanModel diPan;

  /// 人盘：十六神流转，计神/天目/始击。
  final RenPanModel renPan;

  /// 天盘：太乙/主客大将参将/三基五福等。
  final TianPanModel tianPan;

  /// 神盘：太岁/岁破/直符/四神等。
  final ShenPanModel shenPan;

  /// 格局判断结果。
  final GeJuResultModel geJu;

  /// 命盘（可选，需要出生时间）。
  final MingPanModel? mingPan;

  /// 年计（岁计）太乙数据。
  /// 仅年家太乙时存在此字段，包含入纪元数、入局数、太乙行宫等核心参数。
  final YearJiDataModel? yearJi;

  /// 太乙贵神排盘结果。
  final GuiShenModel? guiShen;

  /// 转为可持久化的 JSON 结构，供占卜历史保存。
  Map<String, Object?> toJson() => {
    'input': input.toJson(),
    'algorithmVersion': algorithmVersion,
    'accumulatedYear': accumulatedYear,
    'sequenceIndex': sequenceIndex,
    'juNumber': juNumber,
    'dunType': dunType.name,
    'taiYiPalace': taiYiPalace.id,
    'wenChangPalace': wenChangPalace.id,
    'jiShenPalace': jiShenPalace.id,
    'schoolBase': schoolBase,
    'palaces': palaces.map((item) => item.toJson()).toList(),
    'eightDoorsByPalace': eightDoorsByPalace.map(
      (key, value) => MapEntry(key.id, value.id),
    ),
    'unplacedItems': unplacedItems.map((item) => item.toJson()).toList(),
    'hostGuest': hostGuest.toJson(),
    'classicReferences':
        classicReferences.map((reference) => reference.toJson()).toList(),
    'warnings': warnings,
    'diPan': diPan.toJson(),
    'renPan': renPan.toJson(),
    'tianPan': tianPan.toJson(),
    'shenPan': shenPan.toJson(),
    'geJu': geJu.toJson(),
    'mingPan': mingPan?.toJson(),
    'yearJi': yearJi?.toJson(),
    'guiShen': guiShen?.toJson(),
  };
}
