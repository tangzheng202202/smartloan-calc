import '../utils/formatters.dart';

/// 数字扩展：快捷格式化
extension NumFormatX on num {
  /// 货币（整数）
  String get asCurrency => Formatters.currency(this);

  /// 货币（2 位小数）
  String get asCurrency2 => Formatters.currency2(this);

  /// 万元（输入单位为元）
  String get asWanYuan => Formatters.wanYuan(this);

  /// 大额缩写（万元/亿元）
  String get asCompactYuan => Formatters.compactYuan(this);

  /// 百分比（输入为小数）
  String get asPercent => Formatters.percent(this);
}
