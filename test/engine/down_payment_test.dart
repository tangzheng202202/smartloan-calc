import 'package:flutter_test/flutter_test.dart';
import 'package:loan_calculator/domain/entities/loan_category.dart';
import 'package:loan_calculator/domain/entities/loan_input.dart';
import 'package:loan_calculator/domain/entities/loan_result.dart';
import 'package:loan_calculator/domain/entities/saved_plan.dart';

/// 首付（总价/比例/金额/派生贷款）联动与数据兼容测试
void main() {
  group('默认值与恒等式', () {
    test('默认房贷：总价125万 首付20% → 贷款100万', () {
      const i = LoanInput();
      expect(i.category, LoanCategory.mortgage);
      expect(i.hasDownPayment, isTrue);
      expect(i.totalPrice, 1250000);
      expect(i.downPaymentAmount, 250000);
      expect(i.downPaymentRatio, 0.2);
      expect(i.principal, i.totalPrice! - i.downPaymentAmount!);
    });

    test('车贷默认：总价25万 首付30% → 贷款17.5万', () {
      final i = const LoanInput().withCategoryDefaults(LoanCategory.car);
      expect(i.totalPrice, 250000);
      expect(i.downPaymentAmount, 75000);
      expect(i.downPaymentRatio, 0.3);
      expect(i.principal, 175000);
      expect(i.isCombined, isFalse);
    });

    test('消费贷默认：首付字段为 null，直输20万', () {
      final i = const LoanInput().withCategoryDefaults(LoanCategory.consumer);
      expect(i.hasDownPayment, isFalse);
      expect(i.totalPrice, isNull);
      expect(i.downPaymentAmount, isNull);
      expect(i.downPaymentRatio, isNull);
      expect(i.principal, 200000);
    });
  });

  group('三者联动', () {
    test('改总价 → 首付金额按比例重算', () {
      final i = const LoanInput().withTotalPrice(2000000);
      expect(i.totalPrice, 2000000);
      expect(i.downPaymentAmount, 400000); // 20%
      expect(i.principal, 1600000);
    });

    test('改比例 → 首付金额重算；超出 15%–80% 被钳制', () {
      final i = const LoanInput().withDownPaymentRatio(0.5);
      expect(i.downPaymentAmount, 625000);
      expect(i.principal, 625000);

      final clamped = const LoanInput().withDownPaymentRatio(0.95);
      expect(clamped.downPaymentRatio, 0.8);
      expect(clamped.downPaymentAmount, 1000000);
      expect(clamped.principal, 250000);

      final low = const LoanInput().withDownPaymentRatio(0.05);
      expect(low.downPaymentRatio, 0.15); // 低于 15% 被钳到下限
      expect(low.downPaymentAmount, 187500);
      expect(low.principal, 1062500);
    });

    test('改首付金额 → 比例重算；超过总价被钳制为零贷款', () {
      final i = const LoanInput().withDownPaymentAmount(500000);
      expect(i.downPaymentAmount, 500000);
      expect(i.downPaymentRatio, closeTo(0.4, 1e-9));
      expect(i.principal, 750000);

      final full = const LoanInput().withDownPaymentAmount(9999999);
      expect(full.downPaymentAmount, 1250000);
      expect(full.principal, 0);
      expect(full.downPaymentRatio, 0.8); // 100% 被钳到上限

      final low = const LoanInput().withDownPaymentAmount(100000);
      expect(low.downPaymentAmount, 187500); // 低于 15% 总价被钳到下限
      expect(low.principal, 1062500);
    });

    test('编辑派生贷款金额 → 反推首付金额与比例', () {
      final i = const LoanInput().withDerivedLoanAmount(900000);
      expect(i.principal, 900000);
      expect(i.downPaymentAmount, 350000);
      expect(i.downPaymentRatio, closeTo(0.28, 1e-9));

      final over = const LoanInput().withDerivedLoanAmount(2000000);
      expect(over.principal, 1062500); // 钳到总价 85%（最低首付 15%）
      expect(over.downPaymentAmount, 187500);
    });

    test('消费贷调用联动方法无副作用', () {
      final i = const LoanInput().withCategoryDefaults(LoanCategory.consumer);
      expect(i.withTotalPrice(999999).principal, 200000);
      expect(i.withDownPaymentRatio(0.5).principal, 200000);
    });
  });

  group('组合贷联动', () {
    LoanInput combined() => const LoanInput().copyWith(
      isCombined: true,
      fundPrincipal: 400000,
      commercialPrincipal: 600000,
    );

    test('组合贷改总价 → 本金派生后按 40/60 重拆', () {
      final i = combined().withTotalPrice(2500000); // 贷款 200万
      expect(i.principal, 2000000);
      expect(i.fundPrincipal, 800000);
      expect(i.commercialPrincipal, 1200000);
      expect(i.fundPrincipal + i.commercialPrincipal, i.principal);
    });

    test('组合贷改两段金额 → 本金求和且首付反推恒等', () {
      final i = combined().withCombinedAmounts(fundYuan: 500000);
      expect(i.principal, 1100000);
      expect(i.downPaymentAmount, 150000); // 125万 − 110万
      expect(i.downPaymentRatio, closeTo(0.12, 1e-9));
    });
  });

  group('归一化与旧记录兼容', () {
    test('旧记录无首付字段：反序列化为 null，归一化为 0% 首付', () {
      final legacy = <String, dynamic>{
        'category': 'mortgage',
        'principal': 1000000.0,
        'years': 30,
        'annualRate': 0.034,
        'method': 'equalPayment',
        'isCombined': false,
        'fundPrincipal': 0.0,
        'fundAnnualRate': 0.0285,
        'commercialPrincipal': 0.0,
        'commercialAnnualRate': 0.0345,
      };
      final i = LoanInput.fromJson(legacy);
      expect(i.totalPrice, isNull);
      expect(i.downPaymentAmount, isNull);

      final n = i.normalizeDownPayment();
      expect(n.totalPrice, 1000000);
      expect(n.downPaymentAmount, 0);
      expect(n.downPaymentRatio, 0);
      expect(n.principal, 1000000); // 数字不变
      // 归一化后联动正常
      final edited = n.withDownPaymentRatio(0.3);
      expect(edited.downPaymentAmount, 300000);
      expect(edited.principal, 700000);
    });

    test('新字段 JSON 往返无损', () {
      const i = LoanInput();
      final j = i.toJson();
      expect(j['totalPrice'], 1250000);
      expect(j['downPaymentAmount'], 250000);
      expect(j['downPaymentRatio'], 0.2);
      final back = LoanInput.fromJson(j);
      expect(back, i);
    });

    test('消费贷 JSON 不写首付键，往返后仍为 null', () {
      final i = const LoanInput().withCategoryDefaults(LoanCategory.consumer);
      final j = i.toJson();
      expect(j.containsKey('totalPrice'), isFalse);
      final back = LoanInput.fromJson(j);
      expect(back.totalPrice, isNull);
      expect(back.hasDownPayment, isFalse);
    });

    test('SavedPlan / HistoryEntry 旧 JSON（无首付字段）反序列化不炸', () {
      // 构造真实序列化结果，再移除首付键模拟旧记录
      final legacyInput =
          (const LoanInput().copyWith(clearDownPayment: true).toJson())
            ..remove('totalPrice')
            ..remove('downPaymentAmount')
            ..remove('downPaymentRatio');
      expect(legacyInput.containsKey('totalPrice'), isFalse);

      final modernPlan = SavedPlan(
        id: '1',
        name: '旧方案',
        input: const LoanInput().copyWith(clearDownPayment: true),
        result: const LoanResult(
          total: LoanPartResult(
            monthlyPayment: 4435,
            totalPayment: 1596532,
            totalInterest: 596532,
            principal: 1000000,
          ),
          fund: LoanPartResult.zero,
          commercial: LoanPartResult.zero,
          isCombined: false,
          months: 360,
        ),
        createdAt: 1,
      );
      final planJson = modernPlan.toJson();
      (planJson['input'] as Map<String, dynamic>)
        ..remove('totalPrice')
        ..remove('downPaymentAmount')
        ..remove('downPaymentRatio');
      final plan = SavedPlan.fromJson(planJson);
      expect(plan.input.totalPrice, isNull);
      expect(plan.input.principal, 1000000);

      final historyJson = <String, dynamic>{
        'signature': 's',
        'input': legacyInput,
        'monthlyPayment': 4435.0,
        'totalInterest': 596532.0,
        'totalPayment': 1596532.0,
        'createdAt': 1,
      };
      final entry = HistoryEntry.fromJson(historyJson);
      expect(entry.input.totalPrice, isNull);
      expect(entry.input.principal, 1000000);
    });

    test('签名包含首付字段（新旧记录不冲突）', () {
      const a = LoanInput();
      final b = const LoanInput().copyWith(clearDownPayment: true);
      expect(a.signature, isNot(b.signature));
    });
  });
}
