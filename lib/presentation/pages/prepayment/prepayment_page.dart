import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/prepayment_result.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/calculator/calculator_cubit.dart';
import '../../cubits/prepayment/prepayment_cubit.dart';

/// 提前还款模拟页：对比"缩短期限"与"减少月供"两种模式
class PrepaymentPage extends StatelessWidget {
  const PrepaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final baseInput = context.read<CalculatorCubit>().state.input;
    return BlocProvider(
      create: (_) => PrepaymentCubit(baseInput: baseInput),
      child: const _PrepaymentView(),
    );
  }
}

class _PrepaymentView extends StatefulWidget {
  const _PrepaymentView();

  @override
  State<_PrepaymentView> createState() => _PrepaymentViewState();
}

class _PrepaymentViewState extends State<_PrepaymentView> {
  late final TextEditingController _monthsController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final s = context.read<PrepaymentCubit>().state;
    _monthsController = TextEditingController(text: '${s.monthsPaid}');
    _amountController = TextEditingController(
      text: s.prepayAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _monthsController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.prepaymentTitle)),
      body: BlocBuilder<PrepaymentCubit, PrepaymentState>(
        builder: (context, state) {
          final cubit = context.read<PrepaymentCubit>();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // ---- 输入区 ----
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _monthsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText:
                            '${l10n.monthsPaidLabel} (0-${state.baseInput.months - 1})',
                      ),
                      onChanged: (raw) {
                        final v = int.tryParse(raw);
                        if (v != null) cubit.setMonthsPaid(v);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.prepayAmountLabel,
                      ),
                      onChanged: (raw) {
                        final v = double.tryParse(raw);
                        if (v != null) cubit.setPrepayAmount(v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!state.valid)
                Text(
                  l10n.prepayInvalidHint,
                  style: TextStyle(color: theme.colorScheme.error),
                )
              else ...[
                if (state.reduceTerm != null &&
                    state.reduceTerm!.newPrincipal <= 0)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.paidOffTip),
                    ),
                  )
                else ...[
                  // ---- 柱状图对比 ----
                  _CompareBarChart(
                    original:
                        state.reduceTerm?.originalRemainingInterest ??
                        state.reducePayment?.originalRemainingInterest ??
                        0,
                    reduceTerm: state.reduceTerm,
                    reducePayment: state.reducePayment,
                  ),
                  const SizedBox(height: 12),
                  if (state.reduceTerm != null)
                    _ModeCard(result: state.reduceTerm!),
                  const SizedBox(height: 12),
                  if (state.reducePayment != null)
                    _ModeCard(result: state.reducePayment!),
                ],
              ],
              const SizedBox(height: 16),
              Text(
                l10n.disclaimerBanner,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 两种模式节省利息柱状图
class _CompareBarChart extends StatelessWidget {
  final double original;
  final PrepaymentResult? reduceTerm;
  final PrepaymentResult? reducePayment;

  const _CompareBarChart({
    required this.original,
    required this.reduceTerm,
    required this.reducePayment,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final maxY = [
      original,
      reduceTerm?.newTotalInterest ?? 0,
      reducePayment?.newTotalInterest ?? 0,
    ].fold<double>(0, (a, b) => b > a ? b : a);
    if (maxY <= 0) return const SizedBox.shrink();

    BarChartGroupData group(int x, double value, Color color) {
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: value,
            color: color,
            width: 28,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }

    final labels = [
      l10n.chartLabelOriginal,
      l10n.chartLabelReduceTerm,
      l10n.chartLabelReducePayment,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.compareModesTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxY * 1.15,
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        interval: maxY / 2,
                        getTitlesWidget: (v, meta) => Text(
                          Formatters.compactYuan(v),
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              labels[i],
                              style: theme.textTheme.labelSmall,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    group(0, original, scheme.outline),
                    group(1, reduceTerm?.newTotalInterest ?? 0, scheme.primary),
                    group(
                      2,
                      reducePayment?.newTotalInterest ?? 0,
                      scheme.tertiary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单模式结果卡片
class _ModeCard extends StatelessWidget {
  final PrepaymentResult result;

  const _ModeCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isReduceTerm = result.mode == PrepaymentMode.reduceTerm;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isReduceTerm ? l10n.modeReduceTerm : l10n.modeReducePayment,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.interestSavedLabel}: '
              '${Formatters.currency(result.interestSaved)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.success,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 20),
            _line(
              l10n.remainingNow,
              Formatters.currency(result.remainingBefore),
            ),
            _line(
              l10n.newMonthlyPaymentLabel,
              Formatters.currency(result.newMonthlyPayment),
            ),
            _line(l10n.newTermLabel, l10n.monthsCount(result.newMonths)),
            if (isReduceTerm)
              _line(
                l10n.monthsSavedLabel,
                l10n.monthsCount(result.monthsSaved),
              ),
            _line(
              l10n.originalInterestLabel,
              Formatters.currency(result.originalRemainingInterest),
            ),
            _line(
              l10n.newInterestLabel,
              Formatters.currency(result.newTotalInterest),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
