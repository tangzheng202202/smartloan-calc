import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// 设置仓库（shared_preferences 持久化）
class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  /// 加载
  static Future<SettingsRepository> load() async {
    return SettingsRepository(await SharedPreferences.getInstance());
  }

  /// 主题模式：system / light / dark
  String get themeMode =>
      _prefs.getString(AppConstants.prefThemeMode) ?? 'system';

  Future<void> setThemeMode(String value) =>
      _prefs.setString(AppConstants.prefThemeMode, value);

  /// 语言：zh / zh_TW / en
  String get localeCode => _prefs.getString(AppConstants.prefLocale) ?? 'zh';

  Future<void> setLocaleCode(String value) =>
      _prefs.setString(AppConstants.prefLocale, value);

  /// 货币符号：¥ / $ / €
  String get currencySymbol =>
      _prefs.getString(AppConstants.prefCurrency) ?? '¥';

  Future<void> setCurrencySymbol(String value) =>
      _prefs.setString(AppConstants.prefCurrency, value);

  /// 免责声明是否已确认
  bool get disclaimerConfirmed =>
      _prefs.getBool(AppConstants.prefDisclaimerConfirmed) ?? false;

  Future<void> setDisclaimerConfirmed(bool value) =>
      _prefs.setBool(AppConstants.prefDisclaimerConfirmed, value);
}
