import 'package:equatable/equatable.dart';

/// 提前还款模式
enum PrepaymentMode {
  /// 缩短期限：月供保持不变，缩短还款期数
  reduceTerm,

  /// 减少月供：剩余期限不变，降低月供
  reducePayment,
}

/// 提前还款模拟结果
class PrepaymentResult extends Equatable {
  /// 模式
  final PrepaymentMode mode;

  /// 提前还款金额（元）
  final double prepayAmount;

  /// 已还期数
  final int monthsPaid;

  /// 提前还款时点的剩余本金（元）
  final double remainingBefore;

  /// 提前还款后的新本金（元）
  final double newPrincipal;

  /// 新月供（元）。缩短期限模式下与原月供相同
  final double newMonthlyPayment;

  /// 原剩余期数
  final int originalRemainingMonths;

  /// 新剩余期数（减少月供模式下与原剩余期数相同）
  final int newMonths;

  /// 节省的利息（元，相对剩余期限口径）
  final double interestSaved;

  /// 新方案总利息（剩余期限口径，元）
  final double newTotalInterest;

  /// 原方案剩余利息（元）
  final double originalRemainingInterest;

  const PrepaymentResult({
    required this.mode,
    required this.prepayAmount,
    required this.monthsPaid,
    required this.remainingBefore,
    required this.newPrincipal,
    required this.newMonthlyPayment,
    required this.originalRemainingMonths,
    required this.newMonths,
    required this.interestSaved,
    required this.newTotalInterest,
    required this.originalRemainingInterest,
  });

  /// 节省的期数（减少月供模式下为 0）
  int get monthsSaved => originalRemainingMonths - newMonths;

  @override
  List<Object?> get props => [
    mode,
    prepayAmount,
    monthsPaid,
    remainingBefore,
    newPrincipal,
    newMonthlyPayment,
    originalRemainingMonths,
    newMonths,
    interestSaved,
    newTotalInterest,
    originalRemainingInterest,
  ];
}
