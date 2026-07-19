import '../../domain/entities/dsr_assessment.dart';
import '../../domain/entities/loan_category.dart';
import '../../domain/entities/repayment_method.dart';
import '../../l10n/generated/app_localizations.dart';

/// 枚举 → 本地化文案辅助
extension L10nEnumNames on AppLocalizations {
  /// 贷款类别名
  String categoryName(LoanCategory c) => switch (c) {
    LoanCategory.mortgage => categoryMortgage,
    LoanCategory.car => categoryCar,
    LoanCategory.consumer => categoryConsumer,
  };

  /// 还款方式名
  String methodName(RepaymentMethod m) => switch (m) {
    RepaymentMethod.equalPayment => methodEqualPayment,
    RepaymentMethod.equalPrincipal => methodEqualPrincipal,
    RepaymentMethod.interestFirst => methodInterestFirst,
  };

  /// DSR 评级名
  String ratingName(DsrRating r) => switch (r) {
    DsrRating.excellent => ratingExcellent,
    DsrRating.good => ratingGood,
    DsrRating.moderate => ratingModerate,
    DsrRating.caution => ratingCaution,
    DsrRating.danger => ratingDanger,
  };

  /// DSR 评级建议
  String ratingAdvice(DsrRating r) => switch (r) {
    DsrRating.excellent => adviceExcellent,
    DsrRating.good => adviceGood,
    DsrRating.moderate => adviceModerate,
    DsrRating.caution => adviceCaution,
    DsrRating.danger => adviceDanger,
  };

  /// 城市名
  String cityName(String key) => switch (key) {
    'beijing' => cityBeijing,
    'shanghai' => cityShanghai,
    'guangzhou' => cityGuangzhou,
    'shenzhen' => cityShenzhen,
    'chengdu' => cityChengdu,
    'chongqing' => cityChongqing,
    _ => key,
  };
}
