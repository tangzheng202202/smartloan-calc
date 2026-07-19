import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../domain/entities/loan_result.dart';
import '../../l10n/generated/app_localizations.dart';

/// 本金 / 利息占比饼图卡片
class PieChartCard extends StatelessWidget {
  /// 计算结果
  final LoanResult result;

  const PieChartCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final principal = result.total.principal;
    final interest = result.total.totalInterest;
    if (principal <= 0) return const SizedBox.shrink();

    final total = principal + interest;
    final interestPct = total > 0 ? interest / total * 100 : 0.0;
    final principalPct = total > 0 ? principal / total * 100 : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pieChartTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 32,
                        sectionsSpace: 2,
                        sections: [
                          PieChartSectionData(
                            value: principal,
                            color: scheme.primary,
                            radius: 28,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: interest,
                            color: scheme.tertiary,
                            radius: 28,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PieLegend(
                          color: scheme.primary,
                          label:
                              '${l10n.totalPrincipalLabel} ${principalPct.toStringAsFixed(1)}%',
                          value: Formatters.currency(principal),
                        ),
                        const SizedBox(height: 12),
                        _PieLegend(
                          color: scheme.tertiary,
                          label:
                              '${l10n.resultTotalInterest} ${interestPct.toStringAsFixed(1)}%',
                          value: Formatters.currency(interest),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _PieLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
