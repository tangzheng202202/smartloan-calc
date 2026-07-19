import '../engine/prepayment_engine.dart';
import '../entities/loan_input.dart';
import '../entities/prepayment_result.dart';

/// 提前还款模拟用例
class SimulatePrepaymentUseCase {
  const SimulatePrepaymentUseCase();

  /// 同时返回两种模式的模拟结果（缩短期限 / 减少月供）
  ({PrepaymentResult? reduceTerm, PrepaymentResult? reducePayment}) call({
    required LoanInput input,
    required int monthsPaid,
    required double prepayAmount,
  }) {
    return (
      reduceTerm: PrepaymentEngine.simulate(
        input: input,
        monthsPaid: monthsPaid,
        prepayAmount: prepayAmount,
        mode: PrepaymentMode.reduceTerm,
      ),
      reducePayment: PrepaymentEngine.simulate(
        input: input,
        monthsPaid: monthsPaid,
        prepayAmount: prepayAmount,
        mode: PrepaymentMode.reducePayment,
      ),
    );
  }
}
