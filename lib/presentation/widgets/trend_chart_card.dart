import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../domain/entities/schedule_item.dart';
import '../../l10n/generated/app_localizations.dart';

/// 还款趋势折线图卡片：本金 / 利息随时间变化
class TrendChartCard extends StatelessWidget {
  /// 还款计划
  final List<ScheduleItem> schedule;

  const TrendChartCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (schedule.isEmpty) return const SizedBox.shrink();

    // 采样：最多 120 个点，保证渲染流畅
    final step = (schedule.length / 120).ceil();
    final sampled = [
      for (var i = 0; i < schedule.length; i += step) schedule[i],
      if ((schedule.length - 1) % step != 0) schedule.last,
    ];

    final principalSpots = [
      for (final e in sampled) FlSpot(e.month.toDouble(), e.principal),
    ];
    final interestSpots = [
      for (final e in sampled) FlSpot(e.month.toDouble(), e.interest),
    ];
    final maxY = sampled
        .map((e) => e.payment)
        .fold<double>(0, (a, b) => b > a ? b : a);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.trendChartTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                _Legend(color: scheme.primary, text: l10n.legendPrincipal),
                const SizedBox(width: 16),
                _Legend(color: scheme.tertiary, text: l10n.legendInterest),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY > 0 ? maxY * 1.1 : 1,
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
                        interval: maxY > 0 ? maxY / 2 : 1,
                        getTitlesWidget: (v, meta) => Text(
                          Formatters.compactYuan(v),
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: (schedule.length / 4).ceilToDouble(),
                        getTitlesWidget: (v, meta) => Text(
                          '${v.round()}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: principalSpots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: scheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: interestSpots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: scheme.tertiary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
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

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
