import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 利率输入组件：输入框（%）+ 滑块
class RateInput extends StatefulWidget {
  /// 当前值（百分数，如 3.45 表示 3.45%）
  final double valuePercent;

  /// 变化回调（百分数）
  final ValueChanged<double> onChanged;

  /// 标签
  final String label;

  /// 最小值（%）
  final double minPercent;

  /// 最大值（%）
  final double maxPercent;

  const RateInput({
    super.key,
    required this.valuePercent,
    required this.onChanged,
    required this.label,
    this.minPercent = 0,
    this.maxPercent = 15,
  });

  @override
  State<RateInput> createState() => _RateInputState();
}

class _RateInputState extends State<RateInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.valuePercent.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RateInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final parsed = double.tryParse(_controller.text);
    if (parsed == null || (parsed - widget.valuePercent).abs() > 1e-9) {
      final text = widget.valuePercent.toStringAsFixed(2);
      if (_controller.text != text) {
        _controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SizedBox(
              width: 120,
              child: TextField(
                key: const Key('input.rate'),
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                textAlign: TextAlign.end,
                decoration: const InputDecoration(suffixText: '%'),
                onChanged: (raw) {
                  final v = double.tryParse(raw);
                  if (v == null || v < 0) return;
                  widget.onChanged(v.clamp(0, widget.maxPercent));
                },
              ),
            ),
          ],
        ),
        Slider(
          value: widget.valuePercent.clamp(
            widget.minPercent,
            widget.maxPercent,
          ),
          min: widget.minPercent,
          max: widget.maxPercent,
          divisions: ((widget.maxPercent - widget.minPercent) * 20).round(),
          label: '${widget.valuePercent.toStringAsFixed(2)}%',
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
