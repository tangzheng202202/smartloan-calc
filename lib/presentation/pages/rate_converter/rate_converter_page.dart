import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/engine/city_policies.dart';
import '../../../domain/engine/rate_converter.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/calculator/calculator_cubit.dart';
import '../../widgets/l10n_helpers.dart';

/// 利率换算页：LPR ± BP 换算 + 固定/浮动利息对比 + 城市利率参考
class RateConverterPage extends StatefulWidget {
  const RateConverterPage({super.key});

  @override
  State<RateConverterPage> createState() => _RateConverterPageState();
}

class _RateConverterPageState extends State<RateConverterPage> {
  final _lprController = TextEditingController(text: '3.50');
  final _bpController = TextEditingController(text: '-60');
  final _fixedController = TextEditingController(text: '3.60');
  final _floatingController = TextEditingController();

  @override
  void dispose() {
    _lprController.dispose();
    _bpController.dispose();
    _fixedController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  double get _lpr => (double.tryParse(_lprController.text) ?? 3.5) / 100;
  double get _bp => double.tryParse(_bpController.text) ?? 0;

  double get _actualRate => RateConverter.fromLpr(_lpr, _bp);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final calcState = context.read<CalculatorCubit>().state;
    final actualPct = _actualRate * 100;

    // 浮动利率输入框默认跟随 LPR±BP（用户可改）
    if (_floatingController.text.isEmpty) {
      _floatingController.text = actualPct.toStringAsFixed(2);
    }

    final comparison = RateConverter.compareFixedVsFloating(
      principal: calcState.input.principal,
      months: calcState.input.months,
      fixedRate: (double.tryParse(_fixedController.text) ?? 0) / 100,
      floatingRate:
          (double.tryParse(_floatingController.text) ?? actualPct) / 100,
      method: calcState.input.method,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rateToolTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ---- LPR ± BP ----
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _lprController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          decoration: InputDecoration(labelText: l10n.lprLabel),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _bpController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[-0-9.]'),
                            ),
                          ],
                          decoration: InputDecoration(labelText: l10n.bpLabel),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.resultRateLabel,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        Formatters.percent(_actualRate),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.bpHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ---- 固定 vs 浮动 ----
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.fixedVsFloatingTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fixedController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.fixedRateLabel,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _floatingController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.floatingRateLabel,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _line(
                    l10n.compareResultLabel,
                    Formatters.currency(comparison.interestDiff),
                  ),
                  const SizedBox(height: 4),
                  _line(
                    l10n.monthlyDiffLabel,
                    Formatters.currency2(comparison.monthlyDiff),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ---- 城市利率参考 ----
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.cityPresetTitle, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(l10n.beijingRateNote, style: theme.textTheme.bodyMedium),
                  const Divider(height: 16),
                  for (final city in CityPolicy.cities.where((c) => c.key != 'beijing'))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 64,
                            child: Text(
                              l10n.cityName(city.key),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${Formatters.percent(city.commercialRate(HouseType.first)!)} / '
                              '${Formatters.percent(city.commercialRate(HouseType.second)!)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '${l10n.fundRateRef} '
                            '${Formatters.percent(city.housingFundRateFirst)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
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
      ),
    );
  }

  Widget _line(String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
