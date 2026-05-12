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
