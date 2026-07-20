import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/loan_result.dart';
import '../../domain/entities/repayment_method.dart';
import '../../domain/entities/schedule_item.dart';
import '../../l10n/generated/app_localizations.dart';

/// 结果汇总卡片：超大字体月供 + 总利息 + 总还款
class ResultSummaryCard extends StatelessWidget {
  /// 计算结果
  final LoanResult result;

  /// 还款方式（影响"月供"口径展示）
  final RepaymentMethod method;

  /// 还款计划（用于取末月月供）
  final List<ScheduleItem> schedule;

  /// 附加行：首付 · 购房/车总成本（null 不展示）
  final String? costLine;

  const ResultSummaryCard({
    super.key,
    required this.result,
    required this.method,
    required this.schedule,
    this.costLine,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // 主数字标签：等额本金为首月月供，先息后本为每月利息
    final mainLabel = switch (method) {
      RepaymentMethod.equalPayment => l10n.resultMonthly,
      RepaymentMethod.equalPrincipal => l10n.resultFirstMonth,
      RepaymentMethod.interestFirst => l10n.resultMonthlyInterest,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mainLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            // 大数字优先
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Formatters.currency(result.total.monthlyPayment),
                key: const Key('result.monthlyPayment'),
                style: AppTheme.bigNumber(context),
              ),
            ),
            if (method == RepaymentMethod.equalPrincipal &&
                schedule.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.resultLastMonth}: '
                '${Formatters.currency(schedule.last.payment)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (result.isCombined) ...[
              const SizedBox(height: 8),
              _PartLine(
                label: l10n.resultFundPart,
                value: result.fund.monthlyPayment,
              ),
              _PartLine(
                label: l10n.resultCommercialPart,
                value: result.commercial.monthlyPayment,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: l10n.resultTotalInterest,
                    value: result.total.totalInterest,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: l10n.resultTotalPayment,
                    value: result.total.totalPayment,
                  ),
                ),
              ],
            ),
            if (costLine != null) ...[
              const SizedBox(height: 10),
              Text(
                costLine!,
                key: const Key('result.costLine'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PartLine extends StatelessWidget {
  final String label;
  final double value;

  const _PartLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            Formatters.currency(value),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final double value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.currency(value),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
