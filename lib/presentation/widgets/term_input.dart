import 'package:flutter/material.dart';

/// 期限输入组件：滑块 + 加减按钮（年）
class TermInput extends StatelessWidget {
  /// 当前期限（年）
  final int years;

  /// 变化回调
  final ValueChanged<int> onChanged;

  /// 标签
  final String label;

  /// 年单位文案
  final String unit;

  /// 最小年限
  final int minYears;

  /// 最大年限
  final int maxYears;

  const TermInput({
    super.key,
    required this.years,
    required this.onChanged,
    required this.label,
    required this.unit,
    this.minYears = 1,
    this.maxYears = 35,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleSmall),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: years > minYears ? () => onChanged(years - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '$years $unit',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: years < maxYears ? () => onChanged(years + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        Slider(
          value: years.toDouble().clamp(
            minYears.toDouble(),
            maxYears.toDouble(),
          ),
          min: minYears.toDouble(),
          max: maxYears.toDouble(),
          divisions: maxYears - minYears,
          label: '$years $unit',
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
