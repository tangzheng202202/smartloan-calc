import 'dart:math' as math;

import '../entities/dsr_assessment.dart';

/// 还款能力评估引擎（DSR：Debt Service Ratio）
///
/// 口径与原 Swift 版 `CalculationEngineV2.assessDSR` 一致：
/// - DSR =（新增月供 + 既有月供负债）/ 月收入
/// - 建议最高月供 = 月收入 × 40% − 既有负债
/// - 建议最高可贷额度按等额本息年金公式反推
class DsrEngine {
  DsrEngine._();

  /// 建议月供上限占收入比例（银行常用红线 40%）
  static const double maxMonthlyRatio = 0.40;

  /// 评估还款能力
  ///
  /// [monthlyIncome] 月收入（元），[existingMonthlyDebt] 既有月供负债（元），
  /// [newMonthlyPayment] 拟新增贷款月供（元），
  /// [annualRate]/[months] 用于反推建议最高可贷额度（默认 3.5% / 360 期）。
  static DsrAssessment assess({
    required double monthlyIncome,
    required double existingMonthlyDebt,
    required double newMonthlyPayment,
    double annualRate = 0.035,
    int months = 360,
  }) {
    final totalDebt = existingMonthlyDebt + newMonthlyPayment;
    final dsr = monthlyIncome > 0 ? totalDebt / monthlyIncome : 1.0;
    final rating = DsrRatingX.from(dsr);

    final suggestedMaxMonthly = math.max(
      0.0,
      monthlyIncome * maxMonthlyRatio - existingMonthlyDebt,
    );
    final suggestedMaxLoan = loanFromMonthlyPayment(
      suggestedMaxMonthly,
      annualRate,
      months,
    );

    return DsrAssessment(
      dsr: dsr,
      rating: rating,
      suggestedMaxMonthlyPayment: suggestedMaxMonthly,
      suggestedMaxLoan: suggestedMaxLoan,
      monthlyIncome: monthlyIncome,
      existingMonthlyDebt: existingMonthlyDebt,
      newMonthlyPayment: newMonthlyPayment,
    );
  }

  /// 等额本息年金公式：由月供反推可贷本金
  ///
  /// P = M · ((1+r)^n − 1) / (r · (1+r)^n)
  static double loanFromMonthlyPayment(
    double monthlyPayment,
    double annualRate,
    int months,
  ) {
    if (monthlyPayment <= 0 || months <= 0) return 0;
    final r = annualRate / 12;
    if (r == 0) return monthlyPayment * months;
    final power = math.pow(1 + r, months).toDouble();
    return monthlyPayment * (power - 1) / (r * power);
  }
}
