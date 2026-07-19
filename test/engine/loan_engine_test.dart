import 'package:flutter_test/flutter_test.dart';
import 'package:loan_calculator/domain/entities/loan_category.dart';
import 'package:loan_calculator/domain/entities/loan_input.dart';
import 'package:loan_calculator/domain/entities/loan_result.dart';
import 'package:loan_calculator/domain/entities/repayment_method.dart';
import 'package:loan_calculator/domain/engine/loan_engine.dart';

/// 核心引擎测试
///
/// 期望值由 Python 按同一公式独立计算（容差 0.01）：
/// - 等额本息 100万 3.6% 360期：M=4546.453502, TP=1636723.260811, TI=636723.260811
/// - 等额本金 100万 3.6% 360期：first=5777.777778, last=2786.111111,
///   TP=1541500, TI=541500
/// - 先息后本 100万 3.6% 360期：MI=3000, TP=2080000, TI=1080000
void main() {
  const P = 1000000.0;
  const rate = 0.036;
  const months = 360;
  const tol = 0.01;

  group('等额本息', () {
    test('月供 / 总利息 / 总还款', () {
      final r = LoanEngine.calculatePart(
        principal: P,
        annualRate: rate,
        months: months,
        method: RepaymentMethod.equalPayment,
      );
      expect(r.monthlyPayment, closeTo(4546.453502, tol));
      expect(r.totalPayment, closeTo(1636723.260811, tol));
      expect(r.totalInterest, closeTo(636723.260811, tol));
      // 总利息 = 总还款 − 本金
      expect(r.totalInterest, closeTo(r.totalPayment - P, tol));
    });

    test('还款计划逐月校验', () {
      final s = LoanEngine.schedulePart(
        principal: P,
        annualRate: rate,
        months: months,
        method: RepaymentMethod.equalPayment,
      );
      // 期数正确
      expect(s.length, months);
      // 每月 本金 + 利息 = 月供
      for (final e in s) {
        expect(e.principal + e.interest, closeTo(e.payment, 1e-6));
      }
      // 剩余本金单调递减至 0
      for (var i = 1; i < s.length; i++) {
        expect(
          s[i].remainingPrincipal,
          lessThanOrEqualTo(s[i - 1].remainingPrincipal + 1e-9),
        );
      }
      // 最后一期强制归零
      expect(s.last.remainingPrincipal, 0);
      // 本金合计 = 原始本金
      final principalSum = s.fold<double>(0, (sum, e) => sum + e.principal);
      expect(principalSum, closeTo(P, 0.01));
      // 利息合计 = 汇总口径总利息
      final interestSum = s.fold<double>(0, (sum, e) => sum + e.interest);
      expect(interestSum, closeTo(636723.260811, 0.5));
    });
  });

  group('等额本金', () {
    test('首月/末月/总利息/总还款', () {
      final r = LoanEngine.calculatePart(
        principal: P,
        annualRate: rate,
        months: months,
        method: RepaymentMethod.equalPrincipal,
      );
      // 首月月供
      expect(r.monthlyPayment, closeTo(5777.777778, tol));
      expect(r.totalPayment, closeTo(1541500.0, tol));
      expect(r.totalInterest, closeTo(541500.0, tol));
    });

    test('还款计划：月供递减、月还本金恒定、末期归零', () {
      final s = LoanEngine.schedulePart(
        principal: P,
        annualRate: rate,
        months: months,
        method: RepaymentMethod.equalPrincipal,
      );
      expect(s.length, months);
      // 首月 > 末月
      expect(s.first.payment, greaterThan(s.last.payment));
      expect(s.last.payment, closeTo(2786.111111, tol));
      // 每月本金恒定
      final monthlyPrincipal = P / months;
      for (final e in s) {
        expect(e.principal, closeTo(monthlyPrincipal, 1e-6));
        expect(e.principal + e.interest, closeTo(e.payment, 1e-6));
      }
      // 月供单调递减
      for (var i = 1; i < s.length; i++) {
        expect(s[i].payment, lessThan(s[i - 1].payment));
      }
      // 末期剩余为 0
      expect(s.last.remainingPrincipal, 0);
    });
  });

  group('先息后本', () {
    test('每月利息 / 总利息 / 总还款', () {
      final r = LoanEngine.calculatePart(
        principal: P,
        annualRate: rate,
        months: months,
        method: RepaymentMethod.interestFirst,
      );
      expect(r.monthlyPayment, closeTo(3000.0, tol));
      expect(r.totalPayment, closeTo(2080000.0, tol));
      expect(r.totalInterest, closeTo(1080000.0, tol));
    });

    test('还款计划：前期只还息，末期一次性还本', () {
      final s = LoanEngine.schedulePart(
        principal: P,
        annualRate: rate,
        months: months,
        method: RepaymentMethod.interestFirst,
      );
      expect(s.length, months);
      for (var i = 0; i < months - 1; i++) {
        expect(s[i].principal, 0);
        expect(s[i].payment, closeTo(3000.0, tol));
        expect(s[i].remainingPrincipal, P);
      }
      // 末期：利息 + 全部本金
      expect(s.last.payment, closeTo(3000.0 + P, tol));
      expect(s.last.principal, P);
      expect(s.last.remainingPrincipal, 0);
    });
  });

  group('组合贷款', () {
    final input = const LoanInput(
      isCombined: true,
      years: 30,
      method: RepaymentMethod.equalPayment,
      fundPrincipal: 800000,
      fundAnnualRate: 0.0285,
      commercialPrincipal: 1200000,
      commercialAnnualRate: 0.0345,
    );

    test('合并汇总 = 两部分之和', () {
      final r = LoanEngine.calculate(input);
      expect(r.isCombined, isTrue);
      expect(r.fund.monthlyPayment, closeTo(3308.459076, tol));
      expect(r.commercial.monthlyPayment, closeTo(5355.099539, tol));
      expect(r.total.monthlyPayment, closeTo(8663.558615, tol));
      expect(r.total.totalInterest, closeTo(1118881.101460, tol));
      expect(r.total.totalPayment, closeTo(3118881.101460, tol));
      // 汇总恒等式
      expect(
        r.total.monthlyPayment,
        closeTo(r.fund.monthlyPayment + r.commercial.monthlyPayment, 1e-6),
      );
      expect(
        r.total.totalInterest,
        closeTo(r.fund.totalInterest + r.commercial.totalInterest, 1e-6),
      );
    });

    test('合并明细 = 两部分逐月之和', () {
      final s = LoanEngine.schedule(input);
      expect(s.length, 360);
      for (final e in s) {
        expect(e.payment, closeTo(e.fundPayment + e.commercialPayment, 1e-6));
        expect(
          e.principal,
          closeTo(e.fundPrincipal + e.commercialPrincipal, 1e-6),
        );
        expect(
          e.interest,
          closeTo(e.fundInterest + e.commercialInterest, 1e-6),
        );
      }
      expect(s.last.remainingPrincipal, lessThan(1));
    });

    test('公积金部分为 0 时退化为纯商贷', () {
      final r = LoanEngine.calculate(input.copyWith(fundPrincipal: 0));
      expect(r.fund, LoanPartResult.zero);
      expect(
        r.total.monthlyPayment,
        closeTo(r.commercial.monthlyPayment, 1e-9),
      );
      final s = LoanEngine.schedule(input.copyWith(fundPrincipal: 0));
      expect(s.length, 360);
      for (final e in s) {
        expect(e.fundPayment, 0);
        expect(e.payment, closeTo(e.commercialPayment, 1e-9));
      }
    });
  });

  group('边界用例', () {
    test('0 本金返回零值', () {
      for (final m in RepaymentMethod.values) {
        final r = LoanEngine.calculatePart(
          principal: 0,
          annualRate: rate,
          months: months,
          method: m,
        );
        expect(r, LoanPartResult.zero);
      }
    });

    test('0 期数返回零值', () {
      final r = LoanEngine.calculatePart(
        principal: P,
        annualRate: rate,
        months: 0,
        method: RepaymentMethod.equalPayment,
      );
      expect(r, LoanPartResult.zero);
      final s = LoanEngine.schedulePart(
        principal: P,
        annualRate: rate,
        months: 0,
        method: RepaymentMethod.equalPayment,
      );
      expect(s, isEmpty);
    });

    test('0 利率：等额本息月供 = 本金/期数，总利息为 0', () {
      final r = LoanEngine.calculatePart(
        principal: 120000,
        annualRate: 0,
        months: 12,
        method: RepaymentMethod.equalPayment,
      );
      expect(r.monthlyPayment, closeTo(10000.0, tol));
      expect(r.totalInterest, closeTo(0, tol));
      expect(r.totalPayment, closeTo(120000.0, tol));

      final s = LoanEngine.schedulePart(
        principal: 120000,
        annualRate: 0,
        months: 12,
        method: RepaymentMethod.equalPayment,
      );
      expect(s.length, 12);
      expect(s.last.remainingPrincipal, 0);
      for (final e in s) {
        expect(e.interest, 0);
      }
    });

    test('1 年期：10万 6% 等额本息', () {
      final r = LoanEngine.calculatePart(
        principal: 100000,
        annualRate: 0.06,
        months: 12,
        method: RepaymentMethod.equalPayment,
      );
      expect(r.monthlyPayment, closeTo(8606.642971, tol));
      expect(r.totalPayment, closeTo(103279.715648, tol));
      expect(r.totalInterest, closeTo(3279.715648, tol));
    });

    test('负本金按计划返回全零条目', () {
      final s = LoanEngine.schedulePart(
        principal: -1,
        annualRate: rate,
        months: 12,
        method: RepaymentMethod.equalPayment,
      );
      expect(s.length, 12);
      for (final e in s) {
        expect(e.payment, 0);
        expect(e.remainingPrincipal, 0);
      }
    });
  });

  group('输入校验', () {
    test('默认输入有效', () {
      expect(const LoanInput().validate(), isEmpty);
    });

    test('期限越界报错', () {
      expect(const LoanInput(years: 0).validate(), isNotEmpty);
      expect(const LoanInput(years: 36).validate(), isNotEmpty);
    });

    test('组合贷两部分全 0 报错', () {
      const input = LoanInput(
        isCombined: true,
        fundPrincipal: 0,
        commercialPrincipal: 0,
      );
      expect(input.validate(), isNotEmpty);
    });

    test('签名稳定性：同参数同签名，异参数异签名', () {
      const a = LoanInput();
      const b = LoanInput();
      expect(a.signature, b.signature);
      expect(a.copyWith(years: 20).signature, isNot(a.signature));
    });

    test('JSON 往返', () {
      const input = LoanInput(
        category: LoanCategory.mortgage,
        principal: 1234567,
        years: 25,
        annualRate: 0.0315,
        method: RepaymentMethod.equalPrincipal,
        isCombined: true,
        fundPrincipal: 500000,
        fundAnnualRate: 0.0285,
        commercialPrincipal: 734567,
        commercialAnnualRate: 0.0345,
      );
      final decoded = LoanInput.fromJson(input.toJson());
      expect(decoded, input);
    });
  });
}
