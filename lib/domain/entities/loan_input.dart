import 'package:equatable/equatable.dart';

import 'loan_category.dart';
import 'repayment_method.dart';

/// 贷款计算输入
///
/// 金额单位为元，年利率为小数（如 0.034 表示 3.4%）。
/// 组合贷模式下 [fundPrincipal]/[fundAnnualRate] 与
/// [commercialPrincipal]/[commercialAnnualRate] 分别描述两笔贷款。
///
/// 首付（仅房贷/车贷）：[totalPrice] − [downPaymentAmount] = [principal]，
/// 三者（含 [downPaymentRatio]）通过 with* 联动方法保持恒等；
/// 消费贷三个字段均为 null。旧 JSON 无这三个键时反序列化为 null（兼容）。
class LoanInput extends Equatable {
  /// 贷款类别
  final LoanCategory category;

  /// 单笔贷款本金（元），组合贷模式下为两部分之和
  final double principal;

  /// 贷款期限（年）
  final int years;

  /// 单笔贷款年利率（小数）
  final double annualRate;

  /// 还款方式
  final RepaymentMethod method;

  /// 是否为组合贷（仅房贷可选）
  final bool isCombined;

  /// 公积金贷款本金（元）
  final double fundPrincipal;

  /// 公积金贷款年利率（小数）
  final double fundAnnualRate;

  /// 商业贷款本金（元）
  final double commercialPrincipal;

  /// 商业贷款年利率（小数）
  final double commercialAnnualRate;

  /// 总价（元，房贷=房屋总价、车贷=车辆总价）；消费贷为 null
  final double? totalPrice;

  /// 首付金额（元）；消费贷为 null
  final double? downPaymentAmount;

  /// 首付比例（0–0.8）；消费贷为 null
  final double? downPaymentRatio;

  const LoanInput({
    this.category = LoanCategory.mortgage,
    this.principal = 1000000,
    this.years = 30,
    this.annualRate = 0.034,
    this.method = RepaymentMethod.equalPayment,
    this.isCombined = false,
    this.fundPrincipal = 0,
    this.fundAnnualRate = 0.0285,
    this.commercialPrincipal = 0,
    this.commercialAnnualRate = 0.0345,
    this.totalPrice = 1250000,
    this.downPaymentAmount = 250000,
    this.downPaymentRatio = 0.2,
  });

  /// 总期数（月）
  int get months => years * 12;

  /// 校验输入是否有效
  ///
  /// 返回错误信息列表，空列表表示校验通过。
  /// 规则与原 Swift 版 `LoanInputV2.validate()` 对齐：
  /// 期限 1-35 年，金额与利率非负。
  List<String> validate() {
    final errors = <String>[];
    if (years < 1 || years > 35) {
      errors.add('贷款期限应在1-35年之间');
    }
    if (!isCombined) {
      if (principal < 0) errors.add('贷款金额不能为负');
      if (annualRate < 0 || annualRate > 0.36) {
        errors.add('年利率应在0%-36%之间');
      }
    } else {
      if (fundPrincipal < 0 || commercialPrincipal < 0) {
        errors.add('贷款金额不能为负');
      }
      if (fundPrincipal + commercialPrincipal <= 0) {
        errors.add('组合贷总金额应大于0');
      }
      if (fundAnnualRate < 0 || fundAnnualRate > 0.36) {
        errors.add('公积金年利率应在0%-36%之间');
      }
      if (commercialAnnualRate < 0 || commercialAnnualRate > 0.36) {
        errors.add('商贷年利率应在0%-36%之间');
      }
    }
    return errors;
  }

  /// 参数签名（历史记录去重用）
  String get signature => [
    category.key,
    principal.toStringAsFixed(2),
    years,
    annualRate.toStringAsFixed(6),
    method.key,
    isCombined,
    fundPrincipal.toStringAsFixed(2),
    fundAnnualRate.toStringAsFixed(6),
    commercialPrincipal.toStringAsFixed(2),
    commercialAnnualRate.toStringAsFixed(6),
    (totalPrice ?? -1).toStringAsFixed(2),
    (downPaymentAmount ?? -1).toStringAsFixed(2),
    (downPaymentRatio ?? -1).toStringAsFixed(6),
  ].join('|');

  // ---------- 首付联动（仅房贷/车贷） ----------

  /// 首付比例上限
  static const double maxDownPaymentRatio = 0.8;

  /// 首付比例下限（2024-09 起全国商贷最低首付统一为 15%）
  static const double minDownPaymentRatio = 0.15;

  /// 该类别是否带首付设置（房贷/车贷有，消费贷无）
  bool get hasDownPayment =>
      category == LoanCategory.mortgage || category == LoanCategory.car;

  /// 旧记录归一化：房贷/车贷但无首付字段时，视为 0% 首付（总价=贷款金额）
  LoanInput normalizeDownPayment() {
    if (!hasDownPayment || totalPrice != null) return this;
    return copyWith(
      totalPrice: principal,
      downPaymentAmount: 0,
      downPaymentRatio: 0,
    );
  }

  /// 组合贷重拆：公积金 40% + 商贷 60%（按新本金，保留各自利率）
  LoanInput _resplitCombined(LoanInput base) {
    if (!base.isCombined) return base;
    final fund = (base.principal * 0.4 / 10000).round() * 10000.0;
    final clampedFund = fund.clamp(0.0, base.principal);
    return base.copyWith(
      fundPrincipal: clampedFund,
      commercialPrincipal: base.principal - clampedFund,
    );
  }

  /// 联动：改总价 → 首付金额按比例重算 → 贷款金额派生
  LoanInput withTotalPrice(double yuan) {
    if (!hasDownPayment) return this;
    final total = yuan < 0 ? 0.0 : yuan;
    final ratio = (downPaymentRatio ?? 0).clamp(
      minDownPaymentRatio,
      maxDownPaymentRatio,
    );
    final down = (total * ratio).clamp(0.0, total);
    return _resplitCombined(
      copyWith(
        totalPrice: total,
        downPaymentRatio: ratio,
        downPaymentAmount: down,
        principal: total - down,
      ),
    );
  }

  /// 联动：改首付比例 → 首付金额重算（钳制 15%–80%）
  LoanInput withDownPaymentRatio(double ratio) {
    if (!hasDownPayment) return this;
    final total = totalPrice ?? principal;
    final r = ratio.clamp(minDownPaymentRatio, maxDownPaymentRatio);
    final down = (total * r).clamp(0.0, total);
    return _resplitCombined(
      copyWith(
        downPaymentRatio: r,
        downPaymentAmount: down,
        principal: total - down,
      ),
    );
  }

  /// 联动：改首付金额 → 比例重算（钳制 15%·总价 ≤ 首付 ≤ 总价）
  LoanInput withDownPaymentAmount(double yuan) {
    if (!hasDownPayment) return this;
    final total = totalPrice ?? principal;
    final down = yuan.clamp(total * minDownPaymentRatio, total);
    final ratio = total > 0 ? down / total : 0.0;
    return _resplitCombined(
      copyWith(
        downPaymentAmount: down,
        downPaymentRatio: ratio.clamp(0.0, maxDownPaymentRatio),
        principal: total - down,
      ),
    );
  }

  /// 联动：编辑派生贷款金额 → 反推首付金额与比例
  LoanInput withDerivedLoanAmount(double yuan) {
    if (!hasDownPayment) {
      return copyWith(principal: yuan < 0 ? 0.0 : yuan);
    }
    final total = totalPrice ?? principal;
    final loan = yuan.clamp(0.0, total * (1 - minDownPaymentRatio));
    final down = total - loan;
    final ratio = total > 0 ? down / total : 0.0;
    return _resplitCombined(
      copyWith(
        principal: loan,
        downPaymentAmount: down,
        downPaymentRatio: ratio.clamp(0.0, maxDownPaymentRatio),
      ),
    );
  }

  /// 组合贷两段金额变化后：本金=两段之和，首付字段反推保持恒等
  LoanInput withCombinedAmounts({double? fundYuan, double? commercialYuan}) {
    final fund = fundYuan ?? fundPrincipal;
    final commercial = commercialYuan ?? commercialPrincipal;
    final sum = (fund < 0 ? 0.0 : fund) + (commercial < 0 ? 0.0 : commercial);
    var next = copyWith(
      fundPrincipal: fund < 0 ? 0.0 : fund,
      commercialPrincipal: commercial < 0 ? 0.0 : commercial,
      principal: sum,
    );
    if (hasDownPayment && next.totalPrice != null) {
      final total = next.totalPrice!;
      final down = (total - sum).clamp(0.0, total);
      next = next.copyWith(
        downPaymentAmount: down,
        downPaymentRatio: total > 0
            ? (down / total).clamp(0.0, maxDownPaymentRatio)
            : 0.0,
      );
    }
    return next;
  }

  /// 切换类别时的默认值（含首付字段初始化）
  ///
  /// 房贷：总价 125 万 / 首付 20% → 贷款 100 万；
  /// 车贷：总价 25 万 / 首付 30% → 贷款 17.5 万；
  /// 消费贷：直输 20 万，首付字段置 null。
  LoanInput withCategoryDefaults(LoanCategory c) {
    switch (c) {
      case LoanCategory.mortgage:
        return copyWith(
          category: c,
          totalPrice: 1250000,
          downPaymentRatio: 0.2,
          downPaymentAmount: 250000,
          principal: 1000000,
        );
      case LoanCategory.car:
        return copyWith(
          category: c,
          isCombined: false,
          totalPrice: 250000,
          downPaymentRatio: 0.3,
          downPaymentAmount: 75000,
          principal: 175000,
        );
      case LoanCategory.consumer:
        return copyWith(
          category: c,
          isCombined: false,
          clearDownPayment: true,
          principal: 200000,
        );
    }
  }

  LoanInput copyWith({
    LoanCategory? category,
    double? principal,
    int? years,
    double? annualRate,
    RepaymentMethod? method,
    bool? isCombined,
    double? fundPrincipal,
    double? fundAnnualRate,
    double? commercialPrincipal,
    double? commercialAnnualRate,
    double? totalPrice,
    double? downPaymentAmount,
    double? downPaymentRatio,
    bool clearDownPayment = false,
  }) {
    return LoanInput(
      category: category ?? this.category,
      principal: principal ?? this.principal,
      years: years ?? this.years,
      annualRate: annualRate ?? this.annualRate,
      method: method ?? this.method,
      isCombined: isCombined ?? this.isCombined,
      fundPrincipal: fundPrincipal ?? this.fundPrincipal,
      fundAnnualRate: fundAnnualRate ?? this.fundAnnualRate,
      commercialPrincipal: commercialPrincipal ?? this.commercialPrincipal,
      commercialAnnualRate: commercialAnnualRate ?? this.commercialAnnualRate,
      totalPrice: clearDownPayment ? null : (totalPrice ?? this.totalPrice),
      downPaymentAmount: clearDownPayment
          ? null
          : (downPaymentAmount ?? this.downPaymentAmount),
      downPaymentRatio: clearDownPayment
          ? null
          : (downPaymentRatio ?? this.downPaymentRatio),
    );
  }

  /// 序列化为 JSON（Hive 存储用）
  Map<String, dynamic> toJson() => {
    'category': category.key,
    'principal': principal,
    'years': years,
    'annualRate': annualRate,
    'method': method.key,
    'isCombined': isCombined,
    'fundPrincipal': fundPrincipal,
    'fundAnnualRate': fundAnnualRate,
    'commercialPrincipal': commercialPrincipal,
    'commercialAnnualRate': commercialAnnualRate,
    if (totalPrice != null) 'totalPrice': totalPrice,
    if (downPaymentAmount != null) 'downPaymentAmount': downPaymentAmount,
    if (downPaymentRatio != null) 'downPaymentRatio': downPaymentRatio,
  };

  /// 从 JSON 反序列化（旧记录无首付字段时为 null，向后兼容）
  factory LoanInput.fromJson(Map<String, dynamic> json) => LoanInput(
    category: LoanCategoryX.fromKey(json['category'] as String?),
    principal: (json['principal'] as num?)?.toDouble() ?? 0,
    years: (json['years'] as num?)?.toInt() ?? 30,
    annualRate: (json['annualRate'] as num?)?.toDouble() ?? 0,
    method: RepaymentMethodX.fromKey(json['method'] as String?),
    isCombined: json['isCombined'] as bool? ?? false,
    fundPrincipal: (json['fundPrincipal'] as num?)?.toDouble() ?? 0,
    fundAnnualRate: (json['fundAnnualRate'] as num?)?.toDouble() ?? 0,
    commercialPrincipal: (json['commercialPrincipal'] as num?)?.toDouble() ?? 0,
    commercialAnnualRate:
        (json['commercialAnnualRate'] as num?)?.toDouble() ?? 0,
    totalPrice: (json['totalPrice'] as num?)?.toDouble(),
    downPaymentAmount: (json['downPaymentAmount'] as num?)?.toDouble(),
    downPaymentRatio: (json['downPaymentRatio'] as num?)?.toDouble(),
  );

  @override
  List<Object?> get props => [
    category,
    principal,
    years,
    annualRate,
    method,
    isCombined,
    fundPrincipal,
    fundAnnualRate,
    commercialPrincipal,
    commercialAnnualRate,
    totalPrice,
    downPaymentAmount,
    downPaymentRatio,
  ];
}
