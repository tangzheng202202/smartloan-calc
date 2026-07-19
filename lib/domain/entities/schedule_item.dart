import 'package:equatable/equatable.dart';

/// 单月还款计划条目
///
/// 组合贷时同时携带公积金与商贷两部分明细，
/// 单贷时两部分字段为 0，仅汇总字段有效。
class ScheduleItem extends Equatable {
  /// 期数（从 1 开始）
  final int month;

  /// 当月月供合计（元）
  final double payment;

  /// 当月偿还本金合计（元）
  final double principal;

  /// 当月偿还利息合计（元）
  final double interest;

  /// 当月还款后剩余本金（元），最后一期强制为 0
  final double remainingPrincipal;

  /// 公积金部分月供（元）
  final double fundPayment;

  /// 公积金部分本金（元）
  final double fundPrincipal;

  /// 公积金部分利息（元）
  final double fundInterest;

  /// 商贷部分月供（元）
  final double commercialPayment;

  /// 商贷部分本金（元）
  final double commercialPrincipal;

  /// 商贷部分利息（元）
  final double commercialInterest;

  const ScheduleItem({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.remainingPrincipal,
    this.fundPayment = 0,
    this.fundPrincipal = 0,
    this.fundInterest = 0,
    this.commercialPayment = 0,
    this.commercialPrincipal = 0,
    this.commercialInterest = 0,
  });

  /// 全零条目（本金为 0 的组合贷子部分使用）
  factory ScheduleItem.zero(int month) => ScheduleItem(
    month: month,
    payment: 0,
    principal: 0,
    interest: 0,
    remainingPrincipal: 0,
  );

  @override
  List<Object?> get props => [
    month,
    payment,
    principal,
    interest,
    remainingPrincipal,
    fundPayment,
    fundPrincipal,
    fundInterest,
    commercialPayment,
    commercialPrincipal,
    commercialInterest,
  ];
}
