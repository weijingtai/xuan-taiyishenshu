/// 年计（岁计）太乙核心参数。
///
/// 基于正确积年数计算的五子元局及相关参数。
///
/// 公式（《太乙统宗宝鉴》年计体系）：
/// - 五子元局 = 积年数 % 360
/// - 元数 = int(五子元局 / 72) + 1（1-5：甲子元1、丙子元2、戊子元3、庚子元4、壬子元5）
/// - 局数 = 五子元局 % 72（1-72局，0代表72局）
/// - 入纪纪数 = int(五子元局 / 60) + 1（1-6纪）
/// - 入纪年数 = 五子元局 % 60（0-59）
/// - 年卦编号 = 积年数 % 64（0-63伏羲六十四卦）
/// - 太乙行宫年数 = 积年数 % 24
/// - 太乙行宫宫数 = int(太乙行宫年数 / 3) + 1（1-9宫）
/// - 太乙入宫年书 = 太乙行宫年数 % 3（0→理天，1→理地，2→理人）
///
/// 显示格式："第<元数><五元对应名><局数>局"
class YearJiDataModel {
  /// 积年数（传统积年，非101539体系）。
  final int jiNian;

  /// 五子元局 = 积年数 % 360。
  /// 积年累除360的余数，表示该年在360大周中的位置。
  final int wuZiYuanJu;

  /// 元数 = int(五子元局 / 72) + 1。
  /// 表示该年属于五元中的第几元（1-5）。
  final int yuanShu;

  /// 五元名称。
  /// 按顺序为：甲子元(1)、丙子元(2)、戊子元(3)、庚子元(4)、壬子元(5)。
  final String wuZiYuanName;

  /// 局数 = 五子元局 % 72。
  /// 太乙岁计局数（1-72局），0代表72局。
  final int juShu;

  /// 入纪纪数 = int(五子元局 / 60) + 1。
  /// 表示该年属于第几纪（每纪60年，1-6纪循环）。
  final int ruJiJiShu;

  /// 入纪年数 = 五子元局 % 60。
  /// 表示该年在当前纪（60年）内的序号（0-59）。
  final int ruJiNianShu;

  /// 年卦编号 = 积年数 % 64。
  /// 伏羲六十四卦序号（0-63），用于年卦预测。
  final int nianGuaBianHao;

  /// 太乙行宫年数 = 积年数 % 24。
  /// 太乙在九宫循环中每年行进一度，24年一循环。
  final int taiYiXingGongNianShu;

  /// 太乙行宫宫数 = int(太乙行宫年数 / 3) + 1。
  /// 将24年分配到九宫（每宫3年），得到太乙所在宫（1-9）。
  final int taiYiXingGongGongShu;

  /// 太乙入宫年书 = 太乙行宫年数 % 3。
  /// 表示太乙入宫后的第几年（0→理天，1→理地，2→理人）。
  final int taiYiRuGongNianShu;

  /// 太乙入宫年书的中文标签。
  /// "理天" / "理地" / "理人"。
  final String taiYiRuGongNianShuLabel;

  const YearJiDataModel({
    required this.jiNian,
    required this.wuZiYuanJu,
    required this.yuanShu,
    required this.wuZiYuanName,
    required this.juShu,
    required this.ruJiJiShu,
    required this.ruJiNianShu,
    required this.nianGuaBianHao,
    required this.taiYiXingGongNianShu,
    required this.taiYiXingGongGongShu,
    required this.taiYiRuGongNianShu,
    required this.taiYiRuGongNianShuLabel,
  });

  /// 完整的太乙年局文字描述。
  /// 格式："第<元数><五元名><局数>局"
  String get displayText => '第$yuanShu$wuZiYuanName$juShu';

  Map<String, Object?> toJson() => {
    'jiNian': jiNian,
    'wuZiYuanJu': wuZiYuanJu,
    'yuanShu': yuanShu,
    'wuZiYuanName': wuZiYuanName,
    'juShu': juShu,
    'ruJiJiShu': ruJiJiShu,
    'ruJiNianShu': ruJiNianShu,
    'nianGuaBianHao': nianGuaBianHao,
    'taiYiXingGongNianShu': taiYiXingGongNianShu,
    'taiYiXingGongGongShu': taiYiXingGongGongShu,
    'taiYiRuGongNianShu': taiYiRuGongNianShu,
    'taiYiRuGongNianShuLabel': taiYiRuGongNianShuLabel,
  };
}

/// 五元名称列表，按顺序排列（index 0 = 甲子元）。
const List<String> wuZiYuanNames = [
  '甲子元',
  '丙子元',
  '戊子元',
  '庚子元',
  '壬子元',
];