import 'package:flutter/material.dart';

import '../../domain/entities/loan_category.dart';
import '../../domain/entities/loan_input.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cubits/calculator/calculator_cubit.dart';
import 'amount_input.dart';

/// 首付输入区（仅房贷/车贷展示）
///
/// 总价 → 首付比例（0–80%）→ 首付金额 三者联动，
/// 贷款金额为派生值（总价 − 首付金额），醒目展示、不可直接编辑。
class DownPaymentSection extends StatelessWidget {
  final LoanInput input;
  final CalculatorCubit cubit;

  const DownPaymentSection({
    super.key,
    required this.input,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isCar = input.category == LoanCategory.car;
    final totalWan = (input.totalPrice ?? input.principal) / 10000;
    final downWan = (input.downPaymentAmount ?? 0) / 10000;
    final ratioPct = ((input.downPaymentRatio ?? 0) * 100);
    final loanWan = input.principal / 10000;

    String fmtWan(double wan) => wan == wan.roundToDouble()
        ? wan.round().toString()
        : wan.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- 总价 ----
        AmountInput(
          fieldKey: const Key('input.totalPrice'),
          label: isCar ? l10n.carTotalPriceLabel : l10n.houseTotalPriceLabel,
          unit: l10n.unitWan,
          valueWan: totalWan,
          onChanged: (wan) =>
              cubit.update((i) => i.withTotalPrice(wan * 10000)),
        ),

        // ---- 首付比例 ----
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.downPaymentRatioLabel,
                style: theme.textTheme.titleSmall,
              ),
            ),
            Text(
              '${ratioPct.round()}%',
              key: const Key('input.downPaymentRatioText'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Slider(
          key: const Key('input.downPaymentRatio'),
          value: ratioPct.clamp(0.0, 80.0),
          min: 0,
          max: 80,
          divisions: 80,
          label: '${ratioPct.round()}%',
          onChanged: (pct) =>
              cubit.update((i) => i.withDownPaymentRatio(pct / 100)),
        ),

        // ---- 首付金额 ----
        AmountInput(
          fieldKey: const Key('input.downPayment'),
          label: l10n.downPaymentAmountLabel,
          unit: l10n.unitWan,
          valueWan: downWan,
          minWan: 0,
          onChanged: (wan) =>
              cubit.update((i) => i.withDownPaymentAmount(wan * 10000)),
        ),

        // ---- 贷款金额（派生，只读） ----
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.loanAmountLabel, style: theme.textTheme.titleSmall),
              Text(
                '${fmtWan(loanWan)} ${l10n.unitWan}',
                key: const Key('input.derivedLoanAmount'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
