import 'package:equatable/equatable.dart';

/// 单笔贷款计算结果
class LoanPartResult extends Equatable {
  /// 月供（元）。等额本金为首月月供，先息后本为每月利息
  final double monthlyPayment;

  /// 总还款额（元）
  final double totalPayment;

  /// 总利息（元）
  final double totalInterest;

  /// 本金（元）
  final double principal;

  const LoanPartResult({
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
    required this.principal,
  });

  /// 全零结果（无效输入时返回）
  static const zero = LoanPartResult(
    monthlyPayment: 0,
    totalPayment: 0,
    totalInterest: 0,
    principal: 0,
  );

  @override
  List<Object?> get props => [
    monthlyPayment,
    totalPayment,
    totalInterest,
    principal,
  ];
}

/// 贷款计算汇总结果
///
/// 单贷时仅 [total] 有效；组合贷时 [fund]/[commercial] 分别
/// 描述公积金与商贷部分，[total] 为两部分之和。
class LoanResult extends Equatable {
  /// 汇总结果
  final LoanPartResult total;

  /// 公积金部分结果（非组合贷时为 [LoanPartResult.zero]）
  final LoanPartResult fund;

  /// 商贷部分结果（非组合贷时为 [LoanPartResult.zero]）
  final LoanPartResult commercial;

  /// 是否组合贷
  final bool isCombined;

  /// 总期数（月）
  final int months;

  const LoanResult({
    required this.total,
    this.fund = LoanPartResult.zero,
    this.commercial = LoanPartResult.zero,
    this.isCombined = false,
    required this.months,
  });

  @override
  List<Object?> get props => [total, fund, commercial, isCombined, months];
}
