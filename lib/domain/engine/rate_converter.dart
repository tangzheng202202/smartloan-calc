import 'loan_engine.dart';
import '../entities/repayment_method.dart';

/// 利率换算工具
///
/// - LPR ± BP（基点）→ 实际年利率（1 BP = 0.01% = 0.0001）
/// - 固定利率 vs LPR 浮动利率总利息对比（假设利率全期不变）
class RateConverter {
  RateConverter._();

  /// LPR（小数）加基点浮动，返回实际年利率（小数）
  ///
  /// 例：lpr 0.035，bp -60 → 0.029（2.9%）
  static double fromLpr(double lpr, double bp) {
    return lpr + bp / 10000;
  }

  /// 实际年利率相对 LPR 的基点差
  ///
  /// 例：lpr 0.035，actual 0.029 → -60 BP
  static double toBp(double lpr, double actualRate) {
    return (actualRate - lpr) * 10000;
  }

  /// 固定 vs 浮动利率总利息对比结果
  static RateComparison compareFixedVsFloating({
    required double principal,
    required int months,
    required double fixedRate,
    required double floatingRate,
    RepaymentMethod method = RepaymentMethod.equalPayment,
  }) {
    final fixed = LoanEngine.calculatePart(
      principal: principal,
      annualRate: fixedRate,
      months: months,
      method: method,
    );
    final floating = LoanEngine.calculatePart(
      principal: principal,
      annualRate: floatingRate,
      months: months,
      method: method,
    );
    return RateComparison(
      fixedMonthlyPayment: fixed.monthlyPayment,
      fixedTotalInterest: fixed.totalInterest,
      floatingMonthlyPayment: floating.monthlyPayment,
      floatingTotalInterest: floating.totalInterest,
    );
  }
}

/// 固定 vs 浮动利率对比结果
class RateComparison {
  /// 固定利率月供（元）
  final double fixedMonthlyPayment;

  /// 固定利率总利息（元）
  final double fixedTotalInterest;

  /// 浮动利率月供（元）
  final double floatingMonthlyPayment;

  /// 浮动利率总利息（元）
  final double floatingTotalInterest;

  const RateComparison({
    required this.fixedMonthlyPayment,
    required this.fixedTotalInterest,
    required this.floatingMonthlyPayment,
    required this.floatingTotalInterest,
  });

  /// 浮动相对固定节省的利息（元，负值表示多付）
  double get interestDiff => fixedTotalInterest - floatingTotalInterest;

  /// 月供差（元，浮动 − 固定）
  double get monthlyDiff => floatingMonthlyPayment - fixedMonthlyPayment;
}
