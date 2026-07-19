import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/saved_plan.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/calculator/calculator_cubit.dart';
import '../../cubits/history/history_cubit.dart';
import '../../cubits/plans/plans_cubit.dart';
import '../../widgets/l10n_helpers.dart';

/// 方案库页：已存方案管理 + 历史记录
class PlansPage extends StatelessWidget {
  /// 载入方案后切换回计算器 Tab 的回调
  final VoidCallback onLoadPlan;

  const PlansPage({super.key, required this.onLoadPlan});

  void _loadPlan(BuildContext context, dynamic input) {
    context.read<CalculatorCubit>().loadInput(input);
    onLoadPlan();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).planLoaded)),
    );
  }

  Future<void> _renamePlan(BuildContext context, SavedPlan plan) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: plan.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renamePlanTitle),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && context.mounted) {
      await context.read<PlansCubit>().renamePlan(plan.id, name);
    }
  }

  Future<void> _deletePlan(BuildContext context, SavedPlan plan) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePlanTitle),
        content: Text(l10n.deletePlanBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<PlansCubit>().deletePlan(plan.id);
    }
  }

  void _showCompare(BuildContext context, List<SavedPlan> plans) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        Widget cell(String s, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            s,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: bold ? FontWeight.w700 : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    l10n.compareTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    defaultColumnWidth: const FixedColumnWidth(110),
                    border: TableBorder.all(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    children: [
                      TableRow(
                        children: [
                          cell(l10n.planNameColumn, bold: true),
                          for (final p in plans) cell(p.name, bold: true),
                        ],
                      ),
                      TableRow(
                        children: [
                          cell(l10n.resultMonthly, bold: true),
                          for (final p in plans)
                            cell(
                              Formatters.currency(
                                p.result.total.monthlyPayment,
                              ),
                            ),
                        ],
                      ),
                      TableRow(
                        children: [
                          cell(l10n.resultTotalInterest, bold: true),
                          for (final p in plans)
                            cell(
                              Formatters.currency(p.result.total.totalInterest),
                            ),
                        ],
                      ),
                      TableRow(
                        children: [
                          cell(l10n.resultTotalPayment, bold: true),
                          for (final p in plans)
                            cell(
                              Formatters.currency(p.result.total.totalPayment),
                            ),
                        ],
                      ),
                      TableRow(
                        children: [
                          cell(l10n.loanAmountLabel, bold: true),
                          for (final p in plans)
                            cell(Formatters.wanYuan(p.input.principal)),
                        ],
                      ),
                      TableRow(
                        children: [
                          cell(l10n.rateLabel, bold: true),
                          for (final p in plans)
                            cell(Formatters.percent(p.input.annualRate)),
                        ],
                      ),
                      TableRow(
                        children: [
                          cell(l10n.termLabel, bold: true),
                          for (final p in plans)
                            cell(l10n.yearsCount(p.input.years)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.plansTitle)),
      body: BlocBuilder<PlansCubit, PlansState>(
        builder: (context, plansState) {
          final plansCubit = context.read<PlansCubit>();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // ---- 对比操作栏 ----
              if (plansState.selectedIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            final selected = plansCubit.selectedPlans();
                            if (selected.length < 2) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.compareNeedTwo)),
                              );
                              return;
                            }
                            _showCompare(context, selected);
                          },
                          icon: const Icon(Icons.compare_arrows),
                          label: Text(
                            '${l10n.compareButton} (${plansState.selectedIds.length})',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: plansCubit.clearSelection,
                        child: Text(l10n.clear),
                      ),
                    ],
                  ),
                ),

              // ---- 方案列表 ----
              if (plansState.plans.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      l10n.emptyPlans,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                for (final plan in plansState.plans)
                  Card(
                    child: ListTile(
                      leading: Checkbox(
                        value: plansState.selectedIds.contains(plan.id),
                        onChanged: (_) => plansCubit.toggleSelect(plan.id),
                      ),
                      title: Text(
                        plan.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${l10n.resultMonthly} '
                        '${Formatters.currency(plan.result.total.monthlyPayment)} · '
                        '${l10n.resultTotalInterest} '
                        '${Formatters.currency(plan.result.total.totalInterest)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) {
                          switch (action) {
                            case 'load':
                              _loadPlan(context, plan.input);
                            case 'rename':
                              _renamePlan(context, plan);
                            case 'delete':
                              _deletePlan(context, plan);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'load',
                            child: Text(l10n.loadPlan),
                          ),
                          PopupMenuItem(
                            value: 'rename',
                            child: Text(l10n.rename),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(l10n.delete),
                          ),
                        ],
                      ),
                      onTap: () => _loadPlan(context, plan.input),
                    ),
                  ),

              const SizedBox(height: 24),

              // ---- 历史记录 ----
              const _HistorySection(),
            ],
          );
        },
      ),
    );
  }
}

/// 历史记录区块
class _HistorySection extends StatefulWidget {
  const _HistorySection();

  @override
  State<_HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<_HistorySection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 进入页面时刷新，避免与计算器页的自动写入产生时序差
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HistoryCubit>().refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.historySection,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (state.entries.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      await context.read<HistoryCubit>().clear();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.historyCleared)),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                    label: Text(l10n.clearHistoryButton),
                  ),
              ],
            ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
              onChanged: (v) => context.read<HistoryCubit>().search(v),
            ),
            const SizedBox(height: 8),
            if (state.entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n.historyEmpty,
                  style: theme.textTheme.bodySmall,
                ),
              )
            else
              for (final e in state.entries.take(30))
                Card(
                  child: ListTile(
                    dense: true,
                    title: Text(
                      '${l10n.categoryName(e.input.category)} · '
                      '${Formatters.wanYuan(e.input.principal)} · '
                      '${l10n.yearsCount(e.input.years)} · '
                      '${Formatters.percent(e.input.annualRate)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      '${l10n.methodName(e.input.method)} · '
                      '${l10n.resultMonthly} '
                      '${Formatters.currency(e.monthlyPayment)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        context.read<CalculatorCubit>().loadInput(e.input);
                        // 通过 PlansPage 的回调切回计算器
                        final plans = context
                            .findAncestorWidgetOfExactType<PlansPage>();
                        plans?.onLoadPlan();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.planLoaded)),
                        );
                      },
                      child: Text(l10n.loadPlan),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}
