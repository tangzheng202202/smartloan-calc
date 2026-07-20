import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 金额输入组件：滑块 + 输入框双模式
///
/// 单位万元，滑块与输入框双向同步；输入过程中不重排文本。
class AmountInput extends StatefulWidget {
  /// 当前值（万元）
  final double valueWan;

  /// 变化回调（万元）
  final ValueChanged<double> onChanged;

  /// 最小值（万元）
  final double minWan;

  /// 最大值（万元）
  final double maxWan;

  /// 标签
  final String label;

  /// 单位文案
  final String unit;

  /// 输入框 Key（测试定位用），默认 input.amount
  final Key fieldKey;

  const AmountInput({
    super.key,
    required this.valueWan,
    required this.onChanged,
    required this.label,
    required this.unit,
    this.minWan = 1,
    this.maxWan = 2000,
    this.fieldKey = const Key('input.amount'),
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.valueWan));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double wan) {
    // 整数去小数点，保留 1 位小数的非整数
    if (wan == wan.roundToDouble()) return wan.round().toString();
    return wan.toStringAsFixed(1);
  }

  @override
  void didUpdateWidget(covariant AmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 仅当外部值与输入框解析值不一致时同步，避免打断输入
    final parsed = double.tryParse(_controller.text);
    if (parsed == null || (parsed - widget.valueWan).abs() > 1e-9) {
      final text = _format(widget.valueWan);
      if (_controller.text != text) {
        _controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }
  }

  void _onTextChanged(String raw) {
    final v = double.tryParse(raw);
    if (v == null || v < 0) return;
    widget.onChanged(v.clamp(0, widget.maxWan));
  }

  @override
  Widget build(BuildContext context) {
    final sliderValue = widget.valueWan.clamp(widget.minWan, widget.maxWan);
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
              width: 140,
              child: TextField(
                key: widget.fieldKey,
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                textAlign: TextAlign.end,
                onChanged: _onTextChanged,
                decoration: InputDecoration(suffixText: widget.unit),
              ),
            ),
          ],
        ),
        Slider(
          value: sliderValue,
          min: widget.minWan,
          max: widget.maxWan,
          divisions: (widget.maxWan - widget.minWan).round(),
          label: '${_format(widget.valueWan)} ${widget.unit}',
          onChanged: (v) => widget.onChanged(v),
        ),
      ],
    );
  }
}
