import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/dsr_assessment.dart';
import '../../../domain/usecases/assess_affordability_usecase.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/l10n_helpers.dart';

/// 还款能力评估页（DSR）
class AffordabilityPage extends StatefulWidget {
  const AffordabilityPage({super.key});

  @override
  State<AffordabilityPage> createState() => _AffordabilityPageState();
}

class _AffordabilityPageState extends State<AffordabilityPage> {
  final _incomeController = TextEditingController(text: '30000');
  final _debtController = TextEditingController(text: '2000');
  final _paymentController = TextEditingController(text: '8000');

  static const _useCase = AssessAffordabilityUseCase();
  DsrAssessment? _result;

  @override
  void initState() {
    super.initState();
    _assess();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _debtController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  void _assess() {
    setState(() {
      _result = _useCase(
        monthlyIncome: double.tryParse(_incomeController.text) ?? 0,
        existingMonthlyDebt: double.tryParse(_debtController.text) ?? 0,
        newMonthlyPayment: double.tryParse(_paymentController.text) ?? 0,
      );
    });
  }

  Color _ratingColor(DsrRating r) => switch (r) {
    DsrRating.excellent => AppTheme.success,
    DsrRating.good => Colors.teal,
    DsrRating.moderate => AppTheme.warning,
    DsrRating.caution => Colors.deepOrange,
    DsrRating.danger => AppTheme.danger,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.affordabilityTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.incomeLabel),
            onChanged: (_) => _assess(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _debtController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.existingDebtLabel),
            onChanged: (_) => _assess(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _paymentController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.newPaymentLabel),
            onChanged: (_) => _assess(),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.dsrHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          if (result != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dsrLabel, style: theme.textTheme.titleSmall),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Formatters.percent(result.dsr, decimals: 1),
                        style: AppTheme.bigNumber(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // DSR 进度条（50% 为红线）
                    LinearProgressIndicator(
                      value: result.dsr.clamp(0, 1),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: _ratingColor(result.rating),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(
                          label: Text(l10n.ratingName(result.rating)),
                          backgroundColor: _ratingColor(
                            result.rating,
                          ).withValues(alpha: 0.15),
                          side: BorderSide.none,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.ratingAdvice(result.rating),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _line(
                      context,
                      l10n.suggestedPaymentLabel,
                      Formatters.currency(result.suggestedMaxMonthlyPayment),
                    ),
                    const Divider(height: 16),
                    _line(
                      context,
                      l10n.suggestedLoanLabel,
                      Formatters.currency(result.suggestedMaxLoan),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.disclaimerBanner,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
