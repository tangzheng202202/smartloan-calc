import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../router.dart';
import '../../cubits/history/history_cubit.dart';
import '../../cubits/settings/settings_cubit.dart';

/// 我的 / 设置页
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _confirmClearHistory(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearHistory),
        content: Text(l10n.clearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<HistoryCubit>().clear();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.historyCleared)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // ---- 外观 ----
              _SectionHeader(text: l10n.appearanceSection),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: Text(l10n.themeLabel),
                      trailing: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(l10n.themeSystem),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(l10n.themeLight),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(l10n.themeDark),
                          ),
                        ],
                        selected: {state.themeMode},
                        onSelectionChanged: (s) => cubit.setThemeMode(s.first),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.payments_outlined),
                      title: Text(l10n.currencyLabel),
                      trailing: SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: '¥', label: Text('¥')),
                          ButtonSegment(value: r'$', label: Text(r'$')),
                          ButtonSegment(value: '€', label: Text('€')),
                        ],
                        selected: {state.currencySymbol},
                        onSelectionChanged: (s) => cubit.setCurrency(s.first),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.language_outlined),
                      title: Text(l10n.languageLabel),
                      trailing: DropdownButton<Locale>(
                        value: state.locale,
                        underline: const SizedBox.shrink(),
                        items: [
                          DropdownMenuItem(
                            value: const Locale('zh'),
                            child: Text(l10n.langZhCN),
                          ),
                          DropdownMenuItem(
                            value: const Locale('zh', 'TW'),
                            child: Text(l10n.langZhTW),
                          ),
                          DropdownMenuItem(
                            value: const Locale('en'),
                            child: Text(l10n.langEn),
                          ),
                        ],
                        onChanged: (locale) {
                          if (locale != null) cubit.setLocale(locale);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- 数据 ----
              _SectionHeader(text: l10n.dataSection),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.delete_sweep_outlined),
                      title: Text(l10n.clearHistory),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _confirmClearHistory(context),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.cloud_off_outlined),
                      title: Text(
                        l10n.offlineBadge,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- 关于 ----
              _SectionHeader(text: l10n.aboutSection),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(l10n.aboutButton),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.about),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: Text(l10n.privacyButton),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.privacy),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.gavel_outlined),
                      title: Text(l10n.disclaimerButton),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.disclaimer),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.tag),
                      title: Text(l10n.versionLabel),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;

  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
