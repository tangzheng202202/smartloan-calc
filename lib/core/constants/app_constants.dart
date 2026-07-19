/// 应用常量
class AppConstants {
  AppConstants._();

  /// 应用名（中文）
  static const String appNameZh = '智贷计算器';

  /// 应用名（英文）
  static const String appNameEn = 'SmartLoan Calc';

  /// Hive：方案库 Box
  static const String plansBox = 'plans_box';

  /// Hive：历史记录 Box
  static const String historyBox = 'history_box';

  /// 历史记录上限
  static const int historyLimit = 100;

  /// SharedPreferences：主题模式
  static const String prefThemeMode = 'settings.themeMode';

  /// SharedPreferences：语言
  static const String prefLocale = 'settings.locale';

  /// SharedPreferences：货币符号
  static const String prefCurrency = 'settings.currency';

  /// SharedPreferences：免责声明已确认
  static const String prefDisclaimerConfirmed = 'settings.disclaimerConfirmed';

  /// 金额滑块上限（万元）
  static const double maxAmountWan = 2000;

  /// 期限范围（年）
  static const int minYears = 1;
  static const int maxYears = 35;

  /// 利率范围（%）
  static const double minRatePercent = 0;
  static const double maxRatePercent = 36;
}
