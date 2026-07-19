import 'package:equatable/equatable.dart';

/// DSR（债务收入比）评级
///
/// 与原 Swift 版 `DSRRating` 五级口径一致。
enum DsrRating {
  /// 极优：DSR < 20%
  excellent,

  /// 良好：20% ≤ DSR < 30%
  good,

  /// 适中：30% ≤ DSR < 40%
  moderate,

  /// 偏高：40% ≤ DSR < 50%
  caution,

  /// 过高：DSR ≥ 50%
  danger,
}

/// DSR 评级扩展
extension DsrRatingX on DsrRating {
  /// 从 DSR 数值判定评级
  static DsrRating from(double dsr) {
    if (dsr < 0.20) return DsrRating.excellent;
    if (dsr < 0.30) return DsrRating.good;
    if (dsr < 0.40) return DsrRating.moderate;
    if (dsr < 0.50) return DsrRating.caution;
    return DsrRating.danger;
  }
}

/// 还款能力评估结果
class DsrAssessment extends Equatable {
  /// 债务收入比（0-1+，含既有负债）
  final double dsr;

  /// 评级
  final DsrRating rating;

  /// 建议最高月供（元/月，收入 × 40% − 既有负债）
  final double suggestedMaxMonthlyPayment;

  /// 建议最高可贷额度（元，按给定利率与期限反推）
  final double suggestedMaxLoan;

  /// 月收入（元）
  final double monthlyIncome;

  /// 既有月供负债（元/月）
  final double existingMonthlyDebt;

  /// 新增贷款月供（元/月）
  final double newMonthlyPayment;

  const DsrAssessment({
    required this.dsr,
    required this.rating,
    required this.suggestedMaxMonthlyPayment,
    required this.suggestedMaxLoan,
    required this.monthlyIncome,
    required this.existingMonthlyDebt,
    required this.newMonthlyPayment,
  });

  @override
  List<Object?> get props => [
    dsr,
    rating,
    suggestedMaxMonthlyPayment,
    suggestedMaxLoan,
    monthlyIncome,
    existingMonthlyDebt,
    newMonthlyPayment,
  ];
}
