import 'package:equatable/equatable.dart';

import 'loan_category.dart';
import 'repayment_method.dart';

/// 贷款计算输入
///
/// 金额单位为元，年利率为小数（如 0.034 表示 3.4%）。
/// 组合贷模式下 [fundPrincipal]/[fundAnnualRate] 与
/// [commercialPrincipal]/[commercialAnnualRate] 分别描述两笔贷款。
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
  ].join('|');

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
  };

  /// 从 JSON 反序列化
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
  ];
}
