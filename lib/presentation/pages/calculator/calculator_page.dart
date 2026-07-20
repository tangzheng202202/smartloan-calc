import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/loan_category.dart';
import '../../../domain/entities/loan_input.dart';
import '../../../domain/entities/repayment_method.dart';
import '../../../domain/entities/saved_plan.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../router.dart';
import '../../cubits/calculator/calculator_cubit.dart';
import '../../cubits/plans/plans_cubit.dart';
import '../../widgets/amount_input.dart';
import '../../widgets/disclaimer_footer.dart';
import '../../widgets/down_payment_section.dart';
import '../../widgets/l10n_helpers.dart';
import '../../widgets/pie_chart_card.dart';
import '../../widgets/rate_input.dart';
import '../../widgets/result_summary_card.dart';
import '../../widgets/term_input.dart';
import '../../widgets/trend_chart_card.dart';

/// 计算器页：输入即算，无"计算"按钮
class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  /// 各类别默认年利率（%）
  static const _defaultRates = {
    LoanCategory.mortgage: 3.45,
    LoanCategory.car: 4.5,
    LoanCategory.consumer: 7.2,
  };

  void _switchCategory(CalculatorCubit cubit, LoanCategory c) {
    cubit.update((input) {
      return input
          .withCategoryDefaults(c)
          .copyWith(annualRate: (_defaultRates[c] ?? 3.45) / 100);
    });
  }

  void _toggleCombined(CalculatorCubit cubit, bool enabled) {
    cubit.update((input) {
      if (!enabled) return input.copyWith(isCombined: false);
      // 开启组合贷：默认公积金 40% + 商贷 60%
      final fund = (input.principal * 0.4 / 10000).round() * 10000;
      return input.copyWith(
        isCombined: true,
        fundPrincipal: fund.toDouble(),
        fundAnnualRate: 0.0285,
        commercialPrincipal: input.principal - fund,
        commercialAnnualRate: input.annualRate,
      );
    });
  }

  /// 结果卡附加行：首付 · 购房/车总成本（消费贷返回 null 不展示）
  String? _costLine(
    AppLocalizations l10n,
    LoanInput input,
    CalculatorState state,
  ) {
    final down = input.downPaymentAmount;
    if (!input.hasDownPayment || down == null) return null;
    final downText = Formatters.currency(down);
    final costText = Formatters.currency(
      down + state.result.total.totalPayment,
    );
    // 注意：gen-l10n 占位参数按字母序排列（cost 在前，down 在后）
    return input.category == LoanCategory.car
        ? l10n.costSummaryCar(costText, downText)
        : l10n.costSummaryMortgage(costText, downText);
  }

  Future<void> _savePlan(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final calc = context.read<CalculatorCubit>();
    final input = calc.state.input;
    final defaultName =
        '${l10n.categoryName(input.category)}·${(input.principal / 10000).toStringAsFixed(0)}万·${input.years}年·${(input.annualRate * 100).toStringAsFixed(2)}%';

    final controller = TextEditingController(text: defaultName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.savePlan),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.planNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) return;

    final state = calc.state;
    await context.read<PlansCubit>().savePlan(
      SavedPlan(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        input: state.input,
        result: state.result,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.planSaved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.calculatorTitle)),
      body: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          final cubit = context.read<CalculatorCubit>();
          final input = state.input;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // ---- 贷款类型 ----
              Wrap(
                spacing: 8,
                children: LoanCategory.values
                    .map(
                      (c) => ChoiceChip(
                        label: Text(l10n.categoryName(c)),
                        selected: input.category == c,
                        onSelected: (_) => _switchCategory(cubit, c),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),

              // ---- 组合贷开关（仅房贷）----
              if (input.category == LoanCategory.mortgage)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.combinedSwitch,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  value: input.isCombined,
                  onChanged: (v) => _toggleCombined(cubit, v),
                ),

              // ---- 金额与利率 ----
              // 房贷/车贷：总价 + 首付 → 贷款金额派生；消费贷：直输贷款金额
              if (input.hasDownPayment)
                DownPaymentSection(input: input, cubit: cubit),
              if (!input.hasDownPayment)
                AmountInput(
                  label: l10n.loanAmountLabel,
                  unit: l10n.unitWan,
                  valueWan: input.principal / 10000,
                  onChanged: (wan) =>
                      cubit.update((i) => i.copyWith(principal: wan * 10000)),
                ),
              if (!input.isCombined)
                RateInput(
                  label: l10n.rateLabel,
                  valuePercent: input.annualRate * 100,
                  onChanged: (pct) =>
                      cubit.update((i) => i.copyWith(annualRate: pct / 100)),
                )
              else ...[
                AmountInput(
                  label: l10n.fundAmountLabel,
                  unit: l10n.unitWan,
                  valueWan: input.fundPrincipal / 10000,
                  onChanged: (wan) => cubit.update(
                    (i) => i.withCombinedAmounts(fundYuan: wan * 10000),
                  ),
                ),
                RateInput(
                  label: l10n.fundRateLabel,
                  valuePercent: input.fundAnnualRate * 100,
                  maxPercent: 10,
                  onChanged: (pct) => cubit.update(
                    (i) => i.copyWith(fundAnnualRate: pct / 100),
                  ),
                ),
                const Divider(height: 24),
                AmountInput(
                  label: l10n.commercialAmountLabel,
                  unit: l10n.unitWan,
                  valueWan: input.commercialPrincipal / 10000,
                  onChanged: (wan) => cubit.update(
                    (i) => i.withCombinedAmounts(commercialYuan: wan * 10000),
                  ),
                ),
                RateInput(
                  label: l10n.commercialRateLabel,
                  valuePercent: input.commercialAnnualRate * 100,
                  onChanged: (pct) => cubit.update(
                    (i) => i.copyWith(commercialAnnualRate: pct / 100),
                  ),
                ),
              ],

              // ---- 期限 ----
              TermInput(
                label: l10n.termLabel,
                unit: l10n.unitYear,
                years: input.years,
                onChanged: (y) => cubit.update((i) => i.copyWith(years: y)),
              ),

              // ---- 还款方式 ----
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<RepaymentMethod>(
                  segments: RepaymentMethod.values
                      .map(
                        (m) => ButtonSegment(
                          value: m,
                          label: Text(l10n.methodName(m)),
                        ),
                      )
                      .toList(),
                  selected: {input.method},
                  onSelectionChanged: (s) =>
                      cubit.update((i) => i.copyWith(method: s.first)),
                ),
              ),
              const SizedBox(height: 20),

              // ---- 结果区 ----
              if (state.errors.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.invalidInput,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                )
              else ...[
                ResultSummaryCard(
                  result: state.result,
                  method: input.method,
                  schedule: state.schedule,
                  costLine: _costLine(l10n, input, state),
                ),
                if (input.hasDownPayment && input.principal <= 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.zeroLoanHint,
                      key: const Key('result.zeroLoanHint'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                // 常驻免责声明
                DisclaimerFooter(text: l10n.disclaimerBanner),
                const SizedBox(height: 12),
                TrendChartCard(schedule: state.schedule),
                const SizedBox(height: 12),
                PieChartCard(result: state.result),
                const SizedBox(height: 16),

                // ---- 操作按钮 ----
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.schedule),
                        icon: const Icon(Icons.table_chart_outlined),
                        label: Text(l10n.viewSchedule),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _savePlan(context),
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: Text(l10n.savePlan),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // ---- 工具入口 ----
              Text(
                l10n.toolsTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _ToolTile(
                icon: Icons.payments_outlined,
                title: l10n.prepaymentTool,
                route: AppRoutes.prepayment,
              ),
              _ToolTile(
                icon: Icons.assessment_outlined,
                title: l10n.affordabilityTool,
                route: AppRoutes.affordability,
              ),
              _ToolTile(
                icon: Icons.percent_outlined,
                title: l10n.rateTool,
                route: AppRoutes.rateConverter,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const _ToolTile({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
