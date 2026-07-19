import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/cubits/settings/settings_cubit.dart';
import 'router.dart';

/// 智贷计算器 App 根组件
class SmartLoanApp extends StatelessWidget {
  const SmartLoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          locale: settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
