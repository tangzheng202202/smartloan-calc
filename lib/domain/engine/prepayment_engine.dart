import 'dart:math' as math;

import '../entities/loan_input.dart';
import '../entities/prepayment_result.dart';
import '../entities/repayment_method.dart';
import '../entities/schedule_item.dart';
import 'loan_engine.dart';

/// 提前还款模拟引擎
///
/// 支持两种模式：
/// - [PrepaymentMode.reduceTerm] 缩短期限：月供（或月还本金）不变
/// - [PrepaymentMode.reducePayment] 减少月供：剩余期限不变
///
/// 节省利息口径：相对「提前还款时点之后」的剩余利息，
/// 即 原剩余利息 − 新方案利息（新本金计），已还部分利息不参与比较。
class PrepaymentEngine {
  PrepaymentEngine._();

  /// 模拟提前还款
  ///
  /// [input] 原贷款输入（单贷；组合贷请先拆分后分别模拟），
  /// [monthsPaid] 已还期数（0 ≤ monthsPaid < 总期数），
  /// [prepayAmount] 提前还款金额（元），[mode] 还款模式。
  ///
  /// 返回 null 表示输入无效（如已还期数超出范围、金额非正）。
  static PrepaymentResult? simulate({
    required LoanInput input,
    required int monthsPaid,
    required double prepayAmount,
    required PrepaymentMode mode,
  }) {
    final totalMonths = input.months;
    if (input.principal <= 0 || totalMonths <= 0) return null;
    if (monthsPaid < 0 || monthsPaid >= totalMonths) return null;
    if (prepayAmount <= 0) return null;

    final schedule = LoanEngine.schedulePart(
      principal: input.principal,
      annualRate: input.annualRate,
      months: totalMonths,
      method: input.method,
    );
    if (schedule.isEmpty) return null;

    // 提前还款时点剩余本金（已还 0 期时为原始本金）
    final remainingBefore = monthsPaid == 0
        ? input.principal
        : schedule[monthsPaid - 1].remainingPrincipal;

    // 原方案剩余利息 = 剩余各期利息之和
    final originalRemainingInterest = schedule
        .skip(monthsPaid)
        .fold<double>(0, (sum, item) => sum + item.interest);

    final newPrincipal = math.max(0.0, remainingBefore - prepayAmount);
    final remainingMonths = totalMonths - monthsPaid;

    // 提前还款金额覆盖全部剩余本金：直接结清
    if (newPrincipal <= 0) {
      return PrepaymentResult(
        mode: mode,
        prepayAmount: prepayAmount,
        monthsPaid: monthsPaid,
        remainingBefore: remainingBefore,
        newPrincipal: 0,
        newMonthlyPayment: 0,
        originalRemainingMonths: remainingMonths,
        newMonths: 0,
        interestSaved: originalRemainingInterest,
        newTotalInterest: 0,
        originalRemainingInterest: originalRemainingInterest,
      );
    }

    final r = input.annualRate / 12;

    switch (mode) {
      case PrepaymentMode.reduceTerm:
        return _reduceTerm(
          input: input,
          r: r,
          prepayAmount: prepayAmount,
          monthsPaid: monthsPaid,
          remainingBefore: remainingBefore,
          newPrincipal: newPrincipal,
          remainingMonths: remainingMonths,
          originalRemainingInterest: originalRemainingInterest,
          schedule: schedule,
        );
      case PrepaymentMode.reducePayment:
        return _reducePayment(
          input: input,
          r: r,
          prepayAmount: prepayAmount,
          monthsPaid: monthsPaid,
          remainingBefore: remainingBefore,
          newPrincipal: newPrincipal,
          remainingMonths: remainingMonths,
          originalRemainingInterest: originalRemainingInterest,
        );
    }
  }

  /// 缩短期限：月供负担不变，重新推演期数
  static PrepaymentResult _reduceTerm({
    required LoanInput input,
    required double r,
    required double prepayAmount,
    required int monthsPaid,
    required double remainingBefore,
    required double newPrincipal,
    required int remainingMonths,
    required double originalRemainingInterest,
    required List<ScheduleItem> schedule,
  }) {
    double newMonthlyPayment;
    var newInterest = 0.0;
    var newMonths = 0;
    var remaining = newPrincipal;

    switch (input.method) {
      case RepaymentMethod.equalPayment:
        // 月供不变，逐月摊还直至结清（末期可能不足整月供）
        newMonthlyPayment = schedule[monthsPaid].payment;
        while (remaining > 1e-9 && newMonths < 1200) {
          final interest = remaining * r;
          var principalPaid = newMonthlyPayment - interest;
          if (principalPaid <= 0) {
            // 极端情况：月供不足以覆盖利息（0 利率已排除），终止防御
            principalPaid = remaining;
          }
          principalPaid = math.min(principalPaid, remaining);
          remaining -= principalPaid;
          newInterest += interest;
          newMonths++;
        }

      case RepaymentMethod.equalPrincipal:
        // 月还本金不变 → 新期限 = ceil(新本金 / 月还本金)
        final monthlyPrincipal = input.principal / input.months;
        newMonths = (newPrincipal / monthlyPrincipal).ceil();
        // 新首月月供 = 月还本金 + 新本金首月利息
        newMonthlyPayment = monthlyPrincipal + newPrincipal * r;
        var rem = newPrincipal;
        for (var i = 0; i < newMonths; i++) {
          newInterest += rem * r;
          rem = math.max(0, rem - monthlyPrincipal);
        }

      case RepaymentMethod.interestFirst:
        // 每月还款额不变（原每月利息），超出利息部分冲抵本金 → 期限缩短
        newMonthlyPayment = input.principal * r;
        while (remaining > 1e-9 && newMonths < 1200) {
          final interest = remaining * r;
          var principalPaid = math.min(newMonthlyPayment - interest, remaining);
          if (principalPaid < 0) principalPaid = remaining;
          remaining -= principalPaid;
          newInterest += interest;
          newMonths++;
        }
    }

    return PrepaymentResult(
      mode: PrepaymentMode.reduceTerm,
      prepayAmount: prepayAmount,
      monthsPaid: monthsPaid,
      remainingBefore: remainingBefore,
      newPrincipal: newPrincipal,
      newMonthlyPayment: newMonthlyPayment,
      originalRemainingMonths: remainingMonths,
      newMonths: newMonths,
      interestSaved: originalRemainingInterest - newInterest,
      newTotalInterest: newInterest,
      originalRemainingInterest: originalRemainingInterest,
    );
  }

  /// 减少月供：剩余期限不变，按新本金重新计算
  static PrepaymentResult _reducePayment({
    required LoanInput input,
    required double r,
    required double prepayAmount,
    required int monthsPaid,
    required double remainingBefore,
    required double newPrincipal,
    required int remainingMonths,
    required double originalRemainingInterest,
  }) {
    double newMonthlyPayment;
    double newInterest;

    switch (input.method) {
      case RepaymentMethod.equalPayment:
        if (r == 0) {
          newMonthlyPayment = newPrincipal / remainingMonths;
        } else {
          final power = math.pow(1 + r, remainingMonths).toDouble();
          newMonthlyPayment = newPrincipal * r * power / (power - 1);
        }
        newInterest = newMonthlyPayment * remainingMonths - newPrincipal;

      case RepaymentMethod.equalPrincipal:
        final monthlyPrincipal = newPrincipal / remainingMonths;
        newMonthlyPayment = monthlyPrincipal + newPrincipal * r;
        var interest = 0.0;
        var rem = newPrincipal;
        for (var i = 0; i < remainingMonths; i++) {
          interest += rem * r;
          rem -= monthlyPrincipal;
        }
        newInterest = interest;

      case RepaymentMethod.interestFirst:
        newMonthlyPayment = newPrincipal * r;
        newInterest = newMonthlyPayment * remainingMonths;
    }

    return PrepaymentResult(
      mode: PrepaymentMode.reducePayment,
      prepayAmount: prepayAmount,
      monthsPaid: monthsPaid,
      remainingBefore: remainingBefore,
      newPrincipal: newPrincipal,
      newMonthlyPayment: newMonthlyPayment,
      originalRemainingMonths: remainingMonths,
      newMonths: remainingMonths,
      interestSaved: originalRemainingInterest - newInterest,
      newTotalInterest: newInterest,
      originalRemainingInterest: originalRemainingInterest,
    );
  }
}
