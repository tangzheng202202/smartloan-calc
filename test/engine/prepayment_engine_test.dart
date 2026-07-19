import 'package:flutter_test/flutter_test.dart';
import 'package:loan_calculator/domain/entities/loan_input.dart';
import 'package:loan_calculator/domain/entities/repayment_method.dart';
import 'package:loan_calculator/domain/engine/prepayment_engine.dart';
import 'package:loan_calculator/domain/entities/prepayment_result.dart';

/// 提前还款引擎测试
///
/// 参考值（Python 独立计算）：100万 3.6% 360期等额本息，已还 12 期，
/// 提前还款 20 万：
/// - 还款时点剩余本金 981133.277434
/// - 缩短期限：新期限 242 期，节省利息 282545.735073
/// - 减少月供：新月供 3619.677578，节省利息 122518.021797
void main() {
  const input = LoanInput(
    principal: 1000000,
    years: 30,
    annualRate: 0.036,
    method: RepaymentMethod.equalPayment,
  );
  const tol = 0.01;

  group('等额本息提前还款', () {
    test('缩短期限：月供不变，期数减少，节省利息 > 0', () {
      final r = PrepaymentEngine.simulate(
        input: input,
        monthsPaid: 12,
        prepayAmount: 200000,
        mode: PrepaymentMode.reduceTerm,
      )!;
      expect(r.remainingBefore, closeTo(981133.277434, tol));
      expect(r.newPrincipal, closeTo(781133.277434, tol));
      expect(r.newMonths, 242);
      expect(r.monthsSaved, 360 - 12 - 242);
      expect(r.interestSaved, closeTo(282545.735073, tol));
      expect(r.interestSaved, greaterThan(0));
      // 月供不变
      expect(r.newMonthlyPayment, closeTo(4546.453502, tol));
    });

    test('减少月供：期限不变，月供降低，节省利息 > 0', () {
      final r = PrepaymentEngine.simulate(
        input: input,
        monthsPaid: 12,
        prepayAmount: 200000,
        mode: PrepaymentMode.reducePayment,
      )!;
      expect(r.newMonths, 348);
      expect(r.newMonthlyPayment, closeTo(3619.677578, tol));
      expect(r.interestSaved, closeTo(122518.021797, tol));
      expect(r.interestSaved, greaterThan(0));
      // 缩短期限模式比减少月供模式省更多利息
      final r2 = PrepaymentEngine.simulate(
        input: input,
        monthsPaid: 12,
        prepayAmount: 200000,
        mode: PrepaymentMode.reduceTerm,
      )!;
      expect(r2.interestSaved, greaterThan(r.interestSaved));
    });

    test('已还 0 期：剩余本金 = 原始本金', () {
      final r = PrepaymentEngine.simulate(
        input: input,
        monthsPaid: 0,
        prepayAmount: 100000,
        mode: PrepaymentMode.reducePayment,
      )!;
      expect(r.remainingBefore, closeTo(1000000, tol));
      expect(r.newPrincipal, closeTo(900000, tol));
      expect(r.interestSaved, greaterThan(0));
    });

    test('提前还款金额覆盖全部剩余本金：直接结清', () {
      final r = PrepaymentEngine.simulate(
        input: input,
        monthsPaid: 12,
        prepayAmount: 2000000,
        mode: PrepaymentMode.reduceTerm,
      )!;
      expect(r.newPrincipal, 0);
      expect(r.newMonths, 0);
      expect(r.newMonthlyPayment, 0);
      expect(r.interestSaved, closeTo(r.originalRemainingInterest, tol));
    });

    test('非法输入返回 null', () {
      expect(
        PrepaymentEngine.simulate(
          input: input,
          monthsPaid: 360,
          prepayAmount: 100000,
          mode: PrepaymentMode.reduceTerm,
        ),
        isNull,
      );
      expect(
        PrepaymentEngine.simulate(
          input: input,
          monthsPaid: -1,
          prepayAmount: 100000,
          mode: PrepaymentMode.reduceTerm,
        ),
        isNull,
      );
      expect(
        PrepaymentEngine.simulate(
          input: input,
          monthsPaid: 12,
          prepayAmount: 0,
          mode: PrepaymentMode.reduceTerm,
        ),
        isNull,
      );
      expect(
        PrepaymentEngine.simulate(
          input: input.copyWith(principal: 0),
          monthsPaid: 12,
          prepayAmount: 100000,
          mode: PrepaymentMode.reduceTerm,
        ),
        isNull,
      );
    });
  });

  group('等额本金提前还款', () {
    const ep = LoanInput(
      principal: 1000000,
      years: 30,
      annualRate: 0.036,
      method: RepaymentMethod.equalPrincipal,
    );

    test('两种模式节省利息均 > 0 且逻辑正确', () {
      final rt = PrepaymentEngine.simulate(
        input: ep,
        monthsPaid: 24,
        prepayAmount: 200000,
        mode: PrepaymentMode.reduceTerm,
      )!;
      expect(rt.interestSaved, greaterThan(0));
      expect(rt.newMonths, lessThan(rt.originalRemainingMonths));
      // 月还本金不变
      expect(
        rt.newMonthlyPayment,
        closeTo(1000000 / 360 + rt.newPrincipal * 0.003, 0.01),
      );

      final rp = PrepaymentEngine.simulate(
        input: ep,
        monthsPaid: 24,
        prepayAmount: 200000,
        mode: PrepaymentMode.reducePayment,
      )!;
      expect(rp.interestSaved, greaterThan(0));
      expect(rp.newMonths, rp.originalRemainingMonths);
      // 新月供低于原当前月供
      expect(rp.newMonthlyPayment, lessThan(1000000 / 360 + 1000000 * 0.003));
    });
  });

  group('先息后本提前还款', () {
    const inf = LoanInput(
      principal: 500000,
      years: 3,
      annualRate: 0.05,
      method: RepaymentMethod.interestFirst,
    );

    test('减少月供：新月供 = 新本金 × 月利率', () {
      final r = PrepaymentEngine.simulate(
        input: inf,
        monthsPaid: 12,
        prepayAmount: 100000,
        mode: PrepaymentMode.reducePayment,
      )!;
      expect(r.newMonthlyPayment, closeTo(400000 * 0.05 / 12, 0.01));
      expect(r.interestSaved, greaterThan(0));
      expect(r.newMonths, r.originalRemainingMonths);
    });
  });
}
