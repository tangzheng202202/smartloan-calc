import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/schedule_item.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/export_service.dart';
import '../../cubits/calculator/calculator_cubit.dart';

/// 还款计划表页
///
/// 固定行高 + ListView.builder 虚拟滚动，支持 360+ 期流畅浏览；
/// 支持按期数跳转；支持导出 PDF / CSV。
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  /// 固定行高，便于跳转计算与虚拟滚动优化
  static const double _rowExtent = 44;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _jumpController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _jumpController.dispose();
    super.dispose();
  }

  void _jumpToMonth(List<ScheduleItem> schedule) {
    final m = int.tryParse(_jumpController.text);
    if (m == null || m < 1 || m > schedule.length) return;
    _scrollController.animateTo(
      (m - 1) * _rowExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    FocusScope.of(context).unfocus();
  }

  Future<void> _exportPdf(CalculatorState state) async {
    final l10n = AppLocalizations.of(context);
    await ExportService.exportSchedulePdf(
      input: state.input,
      result: state.result,
      schedule: state.schedule,
      labels: [
        l10n.scheduleTitle,
        l10n.colMonth,
        l10n.colPayment,
        l10n.colPrincipal,
        l10n.colInterest,
        l10n.colRemaining,
        l10n.resultMonthly,
        l10n.resultTotalInterest,
        l10n.resultTotalPayment,
        l10n.disclaimerBanner,
      ],
    );
  }

  Future<void> _exportCsv(CalculatorState state) async {
    final l10n = AppLocalizations.of(context);
    await ExportService.exportScheduleCsv(
      schedule: state.schedule,
      headers: [
        l10n.colMonth,
        l10n.colPayment,
        l10n.colPrincipal,
        l10n.colInterest,
        l10n.colRemaining,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scheduleTitle),
        actions: [
          IconButton(
            tooltip: l10n.exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              final state = context.read<CalculatorCubit>().state;
              _exportPdf(state);
            },
          ),
          IconButton(
            tooltip: l10n.exportCsv,
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: () {
              final state = context.read<CalculatorCubit>().state;
              _exportCsv(state);
            },
          ),
        ],
      ),
      body: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          final schedule = state.schedule;
          if (schedule.isEmpty) {
            return Center(child: Text(l10n.scheduleEmpty));
          }
          return Column(
            children: [
              // ---- 跳转栏 ----
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _jumpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: '${l10n.jumpHint} (1-${schedule.length})',
                          prefixIcon: const Icon(Icons.search, size: 20),
                        ),
                        onSubmitted: (_) => _jumpToMonth(schedule),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () => _jumpToMonth(schedule),
                      child: Text(l10n.ok),
                    ),
                  ],
                ),
              ),

              // ---- 表头 ----
              Container(
                height: 40,
                color: theme.colorScheme.surfaceContainerHighest,
                child: _RowCells(
                  cells: [
                    l10n.colMonth,
                    l10n.colPayment,
                    l10n.colPrincipal,
                    l10n.colInterest,
                    l10n.colRemaining,
                  ],
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // ---- 虚拟滚动明细 ----
              Expanded(
                child: ListView.builder(
                  key: const Key('schedule.list'),
                  controller: _scrollController,
                  itemExtent: _rowExtent,
                  itemCount: schedule.length,
                  itemBuilder: (context, i) {
                    final e = schedule[i];
                    final highlight = e.month % 12 == 0;
                    return Container(
                      color: highlight
                          ? theme.colorScheme.primaryContainer.withValues(
                              alpha: 0.25,
                            )
                          : (i.isOdd
                                ? theme.colorScheme.surfaceContainerLowest
                                : null),
                      child: _RowCells(
                        cells: [
                          '${e.month}',
                          Formatters.thousands(e.payment),
                          Formatters.thousands(e.principal),
                          Formatters.thousands(e.interest),
                          Formatters.thousands(e.remainingPrincipal),
                        ],
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),

              // ---- 常驻免责声明 ----
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  l10n.disclaimerBanner,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RowCells extends StatelessWidget {
  final List<String> cells;
  final TextStyle? style;

  const _RowCells({required this.cells, required this.style});

  @override
  Widget build(BuildContext context) {
    // 期数列窄，数值列宽
    const flexes = [2, 3, 3, 3, 3];
    return Row(
      children: [
        for (var i = 0; i < cells.length; i++)
          Expanded(
            flex: flexes[i],
            child: Text(
              cells[i],
              style: style,
              textAlign: i == 0 ? TextAlign.center : TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(width: 16),
      ],
    );
  }
}
