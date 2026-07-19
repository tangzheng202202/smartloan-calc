/// 贷款类别
///
/// 房贷支持组合贷模式（公积金 + 商贷），车贷/消费贷为单笔贷款。
enum LoanCategory {
  /// 住房贷款
  mortgage,

  /// 汽车贷款
  car,

  /// 消费贷款
  consumer,
}

/// 贷款类别扩展
extension LoanCategoryX on LoanCategory {
  /// 存储用稳定键
  String get key => name;

  /// 从存储键解析
  static LoanCategory fromKey(String? key) {
    return LoanCategory.values.firstWhere(
      (c) => c.name == key,
      orElse: () => LoanCategory.mortgage,
    );
  }
}
