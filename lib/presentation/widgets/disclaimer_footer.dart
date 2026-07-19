import 'package:flutter/material.dart';

/// 常驻免责声明条
///
/// 按产品要求，在计算器结果区常驻显示。
class DisclaimerFooter extends StatelessWidget {
  /// 文案
  final String text;

  const DisclaimerFooter({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: scheme.outline),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}
