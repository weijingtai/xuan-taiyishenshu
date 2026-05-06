/// 太乙排盘采用的流派。
enum TaiYiSchool {
  /// 《太乙金镜式经》体系，作为古法基准。
  jingMirror,

  /// 《太乙数统宗大全》体系，偏实用改良。
  tongZong,

  /// 《古今图书集成》体系，偏简化普及。
  jiCheng,
}

/// 起盘所属的盘类型。
enum TaiYiChartType {
  /// 年家太乙。
  year,

  /// 月家太乙。
  month,

  /// 日家太乙。
  day,

  /// 时家太乙。
  hour,

  /// 刻家太乙，当前仅预留模型入口。
  ke,
}

/// 太乙时家等体系使用的阴阳遁。
enum DunType {
  /// 阳遁。
  yang,

  /// 阴遁。
  yin,
}

/// 流派枚举的中文显示名。
extension TaiYiSchoolLabel on TaiYiSchool {
  String get label => switch (this) {
        TaiYiSchool.jingMirror => '金镜派',
        TaiYiSchool.tongZong => '统宗派',
        TaiYiSchool.jiCheng => '集成派',
      };
}

/// 盘类型枚举的中文显示名。
extension TaiYiChartTypeLabel on TaiYiChartType {
  String get label => switch (this) {
        TaiYiChartType.year => '年家',
        TaiYiChartType.month => '月家',
        TaiYiChartType.day => '日家',
        TaiYiChartType.hour => '时家',
        TaiYiChartType.ke => '刻家',
      };
}

/// 遁法枚举的中文显示名。
extension DunTypeLabel on DunType {
  String get label => switch (this) {
        DunType.yang => '阳遁',
        DunType.yin => '阴遁',
      };
}
