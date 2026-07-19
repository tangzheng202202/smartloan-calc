import 'package:intl/intl.dart';

/// 数字/货币格式化工具
///
/// 与原 Swift 版 `Formatters` 语义对齐，货币符号可由设置切换。
class Formatters {
  Formatters._();

  /// 当前货币符号（由 SettingsCubit 更新）
  static String currencySymbol = '¥';

  /// 货币（整数，带千分位），如 ¥1,234,567
  static String currency(num value, {int decimals = 0}) {
    final f = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: decimals,
    );
    return f.format(value);
  }

  /// 货币（保留 2 位小数）
  static String currency2(num value) => currency(value, decimals: 2);

  /// 万元格式，如 123.5 万元（输入 value 单位为元）
  static String wanYuan(num valueInYuan, {int decimals = 1}) {
    final wan = valueInYuan / 10000;
    return '${wan.toStringAsFixed(decimals)} 万元';
  }

  /// 大额自动缩写：≥ 1 亿用亿元，≥ 1 万用万元，否则元
  static String compactYuan(num value) {
    final v = value.toDouble();
    if (v.abs() >= 100000000) {
      return '${(v / 100000000).toStringAsFixed(2)} 亿';
    }
    if (v.abs() >= 10000) {
      return '${(v / 10000).toStringAsFixed(2)} 万';
    }
    return v.toStringAsFixed(0);
  }

  /// 百分比（输入为小数），如 3.45%
  static String percent(num fraction, {int decimals = 2}) {
    return '${(fraction * 100).toStringAsFixed(decimals)}%';
  }

  /// 千分位整数
  static String thousands(num value, {int decimals = 0}) {
    final f = NumberFormat('#,##0');
    if (decimals == 0) return f.format(value.round());
    return NumberFormat('#,##0.${'0' * decimals}').format(value);
  }
}
