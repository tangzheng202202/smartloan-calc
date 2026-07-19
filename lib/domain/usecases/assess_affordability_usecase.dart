import '../engine/dsr_engine.dart';
import '../entities/dsr_assessment.dart';

/// 还款能力评估用例
class AssessAffordabilityUseCase {
  const AssessAffordabilityUseCase();

  DsrAssessment call({
    required double monthlyIncome,
    required double existingMonthlyDebt,
    required double newMonthlyPayment,
    double annualRate = 0.035,
    int months = 360,
  }) => DsrEngine.assess(
    monthlyIncome: monthlyIncome,
    existingMonthlyDebt: existingMonthlyDebt,
    newMonthlyPayment: newMonthlyPayment,
    annualRate: annualRate,
    months: months,
  );
}
