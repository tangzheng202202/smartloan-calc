import '../engine/loan_engine.dart';
import '../entities/loan_input.dart';
import '../entities/loan_result.dart';
import '../entities/schedule_item.dart';

/// 计算贷款用例
///
/// 对 [LoanEngine] 的薄封装，便于将来替换实现或加缓存。
class CalculateLoanUseCase {
  const CalculateLoanUseCase();

  /// 计算汇总结果
  LoanResult call(LoanInput input) => LoanEngine.calculate(input);

  /// 生成还款计划
  List<ScheduleItem> schedule(LoanInput input) => LoanEngine.schedule(input);
}
