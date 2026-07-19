import 'package:flutter/material.dart';

/// 应用主题（Material 3，浅色 / 深色）
class AppTheme {
  AppTheme._();

  /// 品牌种子色
  static const Color seed = Color(0xFF1565C0);

  /// 成功/正收益色
  static const Color success = Color(0xFF2E7D32);

  /// 警示色
  static const Color warning = Color(0xFFF9A825);

  /// 危险色
  static const Color danger = Color(0xFFC62828);

  /// 浅色主题
  static ThemeData light() => _base(Brightness.light);

  /// 深色主题
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'NotoSansSC',
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 结果区超大数字样式
  static TextStyle bigNumber(BuildContext context) =>
      Theme.of(context).textTheme.displaySmall!.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
        fontFeatures: const [],
      );
}
