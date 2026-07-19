/// 还款方式枚举
///
/// 与原 Swift 版 `RepaymentMethod` 语义一致。
enum RepaymentMethod {
  /// 等额本息：月供固定，前期利息占比高
  equalPayment,

  /// 等额本金：月供递减，每月偿还固定本金 + 剩余本金利息
  equalPrincipal,

  /// 先息后本：每月只还利息，期末一次性归还本金
  interestFirst,
}

/// 还款方式扩展：序列化键与描述
extension RepaymentMethodX on RepaymentMethod {
  /// 存储用稳定键
  String get key => name;

  /// 从存储键解析
  static RepaymentMethod fromKey(String? key) {
    return RepaymentMethod.values.firstWhere(
      (m) => m.name == key,
      orElse: () => RepaymentMethod.equalPayment,
    );
  }
}
