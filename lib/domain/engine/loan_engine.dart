import 'dart:math' as math;

import '../entities/loan_input.dart';
import '../entities/loan_result.dart';
import '../entities/repayment_method.dart';
import '../entities/schedule_item.dart';

/// 贷款计算引擎
///
/// 与原 Swift 版 `CalculationEngineV2` 业务语义一致：
/// 月利率 = 年利率 / 12，年利率为小数（0.034 表示 3.4%）。
///
/// 相对 Swift 版的改进：
/// - 年利率为 0 时等额本息月供退化为 本金/期数（Swift 版会产生 NaN）。
/// - 无效输入（本金 ≤ 0 或期数 ≤ 0）返回全零结果而不是 NaN。
class LoanEngine {
  LoanEngine._();

  /// 内部单期明细
  static final List<ScheduleItem> _empty = List.unmodifiable([]);

  // ---------------------------------------------------------------------------
  // 汇总计算
  // ---------------------------------------------------------------------------

  /// 计算单笔贷款汇总结果
  ///
  /// [principal] 本金（元），[annualRate] 年利率（小数），
  /// [months] 期数（月），[method] 还款方式。
  /// 本金 ≤ 0 或期数 ≤ 0 时返回 [LoanPartResult.zero]。
  static LoanPartResult calculatePart({
    required double principal,
    required double annualRate,
    required int months,
    required RepaymentMethod method,
  }) {
    if (principal <= 0 || months <= 0) return LoanPartResult.zero;

    final r = annualRate / 12;

    switch (method) {
      case RepaymentMethod.equalPayment:
        // 等额本息：M = P·r·(1+r)^n / ((1+r)^n − 1)
        final double monthlyPayment;
        if (r == 0) {
          monthlyPayment = principal / months;
        } else {
          final power = math.pow(1 + r, months).toDouble();
          monthlyPayment = principal * r * power / (power - 1);
        }
        final totalPayment = monthlyPayment * months;
        return LoanPartResult(
          monthlyPayment: monthlyPayment,
          totalPayment: totalPayment,
          totalInterest: totalPayment - principal,
          principal: principal,
        );

      case RepaymentMethod.equalPrincipal:
        // 等额本金：每月固定本金 P/n + 剩余本金利息
        final monthlyPrincipal = principal / months;
        var totalInterest = 0.0;
        var remaining = principal;
        for (var i = 0; i < months; i++) {
          totalInterest += remaining * r;
          remaining -= monthlyPrincipal;
        }
        final firstPayment = monthlyPrincipal + principal * r;
        return LoanPartResult(
          monthlyPayment: firstPayment,
          totalPayment: principal + totalInterest,
          totalInterest: totalInterest,
          principal: principal,
        );

      case RepaymentMethod.interestFirst:
        // 先息后本：每月还息，期末还本
        final monthlyInterest = principal * r;
        final totalInterest = monthlyInterest * months;
        return LoanPartResult(
          monthlyPayment: monthlyInterest,
          totalPayment: principal + totalInterest,
          totalInterest: totalInterest,
          principal: principal,
        );
    }
  }

  /// 主计算入口：按输入计算汇总结果（支持组合贷）
  static LoanResult calculate(LoanInput input) {
    final months = input.months;
    if (!input.isCombined) {
      final part = calculatePart(
        principal: input.principal,
        annualRate: input.annualRate,
        months: months,
        method: input.method,
      );
      return LoanResult(total: part, months: months);
    }

    // 组合贷：公积金部分 + 商贷部分分别计算后合并
    final fund = calculatePart(
      principal: input.fundPrincipal,
      annualRate: input.fundAnnualRate,
      months: months,
      method: input.method,
    );
    final commercial = calculatePart(
      principal: input.commercialPrincipal,
      annualRate: input.commercialAnnualRate,
      months: months,
      method: input.method,
    );
    return LoanResult(
      total: LoanPartResult(
        monthlyPayment: fund.monthlyPayment + commercial.monthlyPayment,
        totalPayment: fund.totalPayment + commercial.totalPayment,
        totalInterest: fund.totalInterest + commercial.totalInterest,
        principal: fund.principal + commercial.principal,
      ),
      fund: fund,
      commercial: commercial,
      isCombined: true,
      months: months,
    );
  }

  // ---------------------------------------------------------------------------
  // 还款计划
  // ---------------------------------------------------------------------------

  /// 生成单笔贷款还款计划
  ///
  /// 本金 ≤ 0 或期数 ≤ 0 时返回空列表；组合贷零金额子部分
  /// 由调用方按 [zeroSchedule] 补齐。
  static List<ScheduleItem> schedulePart({
    required double principal,
    required double annualRate,
    required int months,
    required RepaymentMethod method,
  }) {
    if (months <= 0) return _empty;
    if (principal <= 0) return zeroSchedule(months);

    final r = annualRate / 12;
    final items = <ScheduleItem>[];

    switch (method) {
      case RepaymentMethod.equalPayment:
        final double monthlyPayment;
        if (r == 0) {
          monthlyPayment = principal / months;
        } else {
          final power = math.pow(1 + r, months).toDouble();
          monthlyPayment = principal * r * power / (power - 1);
        }
        var remaining = principal;
        for (var month = 1; month <= months; month++) {
          final interest = remaining * r;
          final principalPaid = monthlyPayment - interest;
          remaining -= principalPaid;
          if (month == months) remaining = 0; // 末期强制归零
          items.add(
            ScheduleItem(
              month: month,
              payment: monthlyPayment,
              principal: principalPaid,
              interest: interest,
              remainingPrincipal: math.max(0, remaining),
            ),
          );
        }

      case RepaymentMethod.equalPrincipal:
        final monthlyPrincipal = principal / months;
        for (var month = 1; month <= months; month++) {
          final interest = (principal - monthlyPrincipal * (month - 1)) * r;
          final payment = monthlyPrincipal + interest;
          final remaining = month == months
              ? 0.0
              : principal - monthlyPrincipal * month;
          items.add(
            ScheduleItem(
              month: month,
              payment: payment,
              principal: monthlyPrincipal,
              interest: interest,
              remainingPrincipal: math.max(0, remaining),
            ),
          );
        }

      case RepaymentMethod.interestFirst:
        final monthlyInterest = principal * r;
        for (var month = 1; month <= months; month++) {
          final isLast = month == months;
          items.add(
            ScheduleItem(
              month: month,
              payment: isLast ? monthlyInterest + principal : monthlyInterest,
              principal: isLast ? principal : 0,
              interest: monthlyInterest,
              remainingPrincipal: isLast ? 0 : principal,
            ),
          );
        }
    }
    return items;
  }

  /// 全零还款计划（组合贷中本金为 0 的子部分使用）
  static List<ScheduleItem> zeroSchedule(int months) {
    return List.generate(months, (i) => ScheduleItem.zero(i + 1));
  }

  /// 主入口：生成还款计划（组合贷逐月合并两部分明细）
  static List<ScheduleItem> schedule(LoanInput input) {
    final months = input.months;
    if (months <= 0) return _empty;

    if (!input.isCombined) {
      return schedulePart(
        principal: input.principal,
        annualRate: input.annualRate,
        months: months,
        method: input.method,
      );
    }

    // 组合贷：分别生成两部分明细再逐月合并
    final fundItems = schedulePart(
      principal: input.fundPrincipal,
      annualRate: input.fundAnnualRate,
      months: months,
      method: input.method,
    );
    final cmItems = schedulePart(
      principal: input.commercialPrincipal,
      annualRate: input.commercialAnnualRate,
      months: months,
      method: input.method,
    );

    final hasFund = input.fundPrincipal > 0;
    final hasCm = input.commercialPrincipal > 0;

    return List.generate(months, (i) {
      final f = fundItems[i];
      final c = cmItems[i];
      return ScheduleItem(
        month: i + 1,
        payment: f.payment + c.payment,
        principal: f.principal + c.principal,
        interest: f.interest + c.interest,
        remainingPrincipal: math.max(
          0,
          f.remainingPrincipal + c.remainingPrincipal,
        ),
        fundPayment: hasFund ? f.payment : 0,
        fundPrincipal: hasFund ? f.principal : 0,
        fundInterest: hasFund ? f.interest : 0,
        commercialPayment: hasCm ? c.payment : 0,
        commercialPrincipal: hasCm ? c.principal : 0,
        commercialInterest: hasCm ? c.interest : 0,
      );
    });
  }
}
