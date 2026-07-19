import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/repositories/settings_repository.dart';

/// 设置状态
class SettingsState extends Equatable {
  /// 主题模式
  final ThemeMode themeMode;

  /// 语言（null 表示跟随系统，默认简体中文）
  final Locale? locale;

  /// 货币符号（¥ / $ / €）
  final String currencySymbol;

  /// 免责声明是否已确认
  final bool disclaimerConfirmed;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('zh'),
    this.currencySymbol = '¥',
    this.disclaimerConfirmed = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    String? currencySymbol,
    bool? disclaimerConfirmed,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      disclaimerConfirmed: disclaimerConfirmed ?? this.disclaimerConfirmed,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    locale,
    currencySymbol,
    disclaimerConfirmed,
  ];
}

/// 设置 Cubit：主题 / 语言 / 货币 / 免责声明确认状态
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repo;

  SettingsCubit(this._repo) : super(const SettingsState()) {
    _load();
  }

  void _load() {
    final theme = switch (_repo.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final locale = switch (_repo.localeCode) {
      'zh_TW' => const Locale('zh', 'TW'),
      'en' => const Locale('en'),
      _ => const Locale('zh'),
    };
    final currency = _repo.currencySymbol;
    Formatters.currencySymbol = currency;
    emit(
      SettingsState(
        themeMode: theme,
        locale: locale,
        currencySymbol: currency,
        disclaimerConfirmed: _repo.disclaimerConfirmed,
      ),
    );
  }

  /// 切换主题
  Future<void> setThemeMode(ThemeMode mode) async {
    final key = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _repo.setThemeMode(key);
    emit(state.copyWith(themeMode: mode));
  }

  /// 切换语言
  Future<void> setLocale(Locale locale) async {
    final code = locale.countryCode == 'TW'
        ? 'zh_TW'
        : (locale.languageCode == 'en' ? 'en' : 'zh');
    await _repo.setLocaleCode(code);
    emit(state.copyWith(locale: locale));
  }

  /// 切换货币符号
  Future<void> setCurrency(String symbol) async {
    await _repo.setCurrencySymbol(symbol);
    Formatters.currencySymbol = symbol;
    emit(state.copyWith(currencySymbol: symbol));
  }

  /// 确认免责声明
  Future<void> confirmDisclaimer() async {
    await _repo.setDisclaimerConfirmed(true);
    emit(state.copyWith(disclaimerConfirmed: true));
  }
}
