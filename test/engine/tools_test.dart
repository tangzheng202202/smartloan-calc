import 'package:flutter_test/flutter_test.dart';
import 'package:loan_calculator/domain/entities/dsr_assessment.dart';
import 'package:loan_calculator/domain/engine/dsr_engine.dart';
import 'package:loan_calculator/domain/engine/rate_converter.dart';
import 'package:loan_calculator/domain/engine/city_policies.dart';
import 'package:loan_calculator/domain/entities/repayment_method.dart';

/// DSR / 利率换算 / 城市政策测试
void main() {
  group('DSR 还款能力评估', () {
    test('DSR 计算与五级评级边界', () {
      // 与原 Swift 版 DSRRating 阈值一致
      expect(DsrRatingX.from(0.0), DsrRating.excellent);
      expect(DsrRatingX.from(0.1999), DsrRating.excellent);
      expect(DsrRatingX.from(0.20), DsrRating.good);
      expect(DsrRatingX.from(0.2999), DsrRating.good);
      expect(DsrRatingX.from(0.30), DsrRating.moderate);
      expect(DsrRatingX.from(0.3999), DsrRating.moderate);
      expect(DsrRatingX.from(0.40), DsrRating.caution);
      expect(DsrRatingX.from(0.4999), DsrRating.caution);
      expect(DsrRatingX.from(0.50), DsrRating.danger);
      expect(DsrRatingX.from(0.9), DsrRating.danger);
    });

    test('综合评估：收入3万、负债2千、月供8千 → 适中', () {
      final a = DsrEngine.assess(
        monthlyIncome: 30000,
        existingMonthlyDebt: 2000,
        newMonthlyPayment: 8000,
      );
      expect(a.dsr, closeTo(1 / 3, 1e-6));
      expect(a.rating, DsrRating.moderate);
      // 建议最高月供 = 收入 × 40% − 既有负债
      expect(a.suggestedMaxMonthlyPayment, closeTo(10000, 0.01));
      // 建议最高可贷（3.5% / 360期等额本息反推）
      expect(a.suggestedMaxLoan, closeTo(2226949.85, 1));
    });

    test('收入为 0 时 DSR = 1（过高）', () {
      final a = DsrEngine.assess(
        monthlyIncome: 0,
        existingMonthlyDebt: 0,
        newMonthlyPayment: 1000,
      );
      expect(a.dsr, 1.0);
      expect(a.rating, DsrRating.danger);
    });

    test('年金反推公式：0 利率退化为线性', () {
      expect(DsrEngine.loanFromMonthlyPayment(5000, 0, 120), 600000);
      expect(DsrEngine.loanFromMonthlyPayment(0, 0.035, 360), 0);
    });
  });

  group('利率换算', () {
    test('LPR ± BP 换算', () {
      expect(RateConverter.fromLpr(0.035, -60), closeTo(0.029, 1e-12));
      expect(RateConverter.fromLpr(0.035, 55), closeTo(0.0405, 1e-12));
      expect(RateConverter.toBp(0.035, 0.029), closeTo(-60, 1e-9));
    });

    test('固定 vs 浮动利息对比：低利率省息为正', () {
      final c = RateConverter.compareFixedVsFloating(
        principal: 1000000,
        months: 360,
        fixedRate: 0.036,
        floatingRate: 0.029,
        method: RepaymentMethod.equalPayment,
      );
      // 固定 3.6% 总利息 636723.26（与前述引擎测试一致）
      expect(c.fixedTotalInterest, closeTo(636723.260811, 0.01));
      // 浮动利率更低 → 固定 − 浮动 > 0
      expect(c.interestDiff, greaterThan(0));
      expect(c.monthlyDiff, lessThan(0));
    });
  });

  group('城市政策（移植自 Swift 版测试口径）', () {
    test('北京：公积金上限120万、利率2.85%、首付15%', () {
      final bj = CityPolicy.byKey('beijing');
      expect(bj.maxHousingFundLoanFirst, 120);
      expect(bj.housingFundRateFirst, 0.0285);
      expect(bj.minDownPaymentRatioFirst, 0.15);
    });

    test('成都：上限120万、优惠利率2.6%', () {
      final cd = CityPolicy.byKey('chengdu');
      expect(cd.maxHousingFundLoanFirst, 120);
      expect(cd.housingFundRateFirst, 0.026);
    });

    test('重庆：上限80万、余额×25倍', () {
      final cq = CityPolicy.byKey('chongqing');
      expect(cq.maxHousingFundLoanFirst, 80);
      expect(cq.balanceMultiplier, 25);
    });

    test('公积金可贷额度：北京 余额10万 房价450万 → 120万', () {
      // 与 Swift 测试一致：min(余额×15, 450万×0.85, 120万) = 120万
      final loanable = CityPolicy.byKey('beijing').housingFundLoanable(
        balance: 100000,
        housePrice: 4500000,
        houseType: HouseType.first,
      );
      expect(loanable, closeTo(1200000, 0.01));
    });

    test('配偶余额合并计算（上海）', () {
      final loanable = CityPolicy.byKey('shanghai').housingFundLoanable(
        balance: 50000,
        spouseBalance: 50000,
        housePrice: 7200000,
        houseType: HouseType.first,
      );
      expect(loanable, greaterThan(0));
      // min(10万×15, 720万×0.85, 120万) = 120万
      expect(loanable, closeTo(1200000, 0.01));
    });

    test('低余额按元乘倍数，配偶余额只加一次', () {
      final city = CityPolicy.byKey('beijing');
      expect(
        city.housingFundLoanable(
          balance: 1000,
          housePrice: 4500000,
          houseType: HouseType.first,
        ),
        15000,
      );
      expect(
        city.housingFundLoanable(
          balance: 1000,
          spouseBalance: 1000,
          housePrice: 4500000,
          houseType: HouseType.first,
        ),
        30000,
      );
    });

    test('商贷利率 = LPR + 浮动', () {
      // 严格保留原 Swift 代码语义：浮动值为小数（-0.005 = -50BP）。
      // 注意：原代码注释 "-5BP = 3.45%" 与其实际数值不一致
      // （-0.005 实为 -50BP，结果 3.0%），此处按代码行为断言。
      expect(
        CityPolicy.byKey('beijing').commercialRate(HouseType.first),
        closeTo(0.030, 1e-12),
      );
      expect(
        CityPolicy.byKey('beijing').commercialRate(HouseType.second),
        closeTo(0.040, 1e-12),
      );
      expect(
        CityPolicy.byKey('shanghai').commercialRate(HouseType.first),
        closeTo(0.029, 1e-12),
      );
    });
  });
}
