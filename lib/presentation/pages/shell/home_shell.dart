import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/settings/settings_cubit.dart';
import '../calculator/calculator_page.dart';
import '../plans/plans_page.dart';
import '../settings/settings_page.dart';

/// 主框架：底部三个 Tab（计算器 / 方案库 / 我的）
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // 首启免责声明门：未确认前弹窗，确认后方可进入
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowDisclaimer();
    });
  }

  /// 跳转到计算器 Tab（方案库/历史"载入计算器"用）
  void switchToCalculator() => setState(() => _index = 0);

  Future<void> _maybeShowDisclaimer() async {
    if (!mounted) return;
    final settings = context.read<SettingsCubit>();
    if (settings.state.disclaimerConfirmed) return;
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.disclaimerDialogTitle),
        content: SingleChildScrollView(child: Text(l10n.disclaimerDialogBody)),
        actions: [
          FilledButton(
            onPressed: () {
              settings.confirmDisclaimer();
              Navigator.pop(ctx);
            },
            child: Text(l10n.disclaimerAgree),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const CalculatorPage(),
          PlansPage(onLoadPlan: switchToCalculator),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calculate_outlined),
            selectedIcon: const Icon(Icons.calculate),
            label: l10n.tabCalculator,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: l10n.tabPlans,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
