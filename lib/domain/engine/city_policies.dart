import 'dart:math' as math;

/// 房屋类型（首套 / 二套）
enum HouseType { first, second }

/// 城市房贷/公积金政策
///
/// 数据移植自原 Swift 版 `LoanType.swift` 的 `City` 枚举，
/// 用于公积金可贷额度试算与各城市商贷利率参考。
/// 注意：政策数据为静态快照（2026 年 3 月口径），仅供参考。
class CityPolicy {
  /// 城市键
  final String key;

  /// 中文名
  final String nameZh;

  /// 公积金最高额度 - 首套（万元）
  final double maxHousingFundLoanFirst;

  /// 公积金最高额度 - 二套（万元）
  final double maxHousingFundLoanSecond;

  /// 公积金利率（5 年以上）- 首套
  final double housingFundRateFirst;

  /// 公积金利率（5 年以上）- 二套
  final double housingFundRateSecond;

  /// 首付比例下限 - 首套
  final double minDownPaymentRatioFirst;

  /// 首付比例下限 - 二套
  final double minDownPaymentRatioSecond;

  /// 最高贷款成数 - 首套
  final double maxLoanRatioFirst;

  /// 最高贷款成数 - 二套
  final double maxLoanRatioSecond;

  /// 公积金余额计算倍数
  final double balanceMultiplier;

  /// 商贷首套浮动（相对 LPR，小数）
  final double commercialFloatingFirst;

  /// 商贷二套浮动（相对 LPR，小数）
  final double commercialFloatingSecond;

  const CityPolicy({
    required this.key,
    required this.nameZh,
    required this.maxHousingFundLoanFirst,
    required this.maxHousingFundLoanSecond,
    required this.housingFundRateFirst,
    required this.housingFundRateSecond,
    required this.minDownPaymentRatioFirst,
    required this.minDownPaymentRatioSecond,
    required this.maxLoanRatioFirst,
    required this.maxLoanRatioSecond,
    required this.balanceMultiplier,
    required this.commercialFloatingFirst,
    required this.commercialFloatingSecond,
  });

  /// 5 年期 LPR 基准（2026 年 3 月口径 3.5%）
  static const double lprBase = 0.035;

  /// 支持的城市列表（与原 Swift 版一致）
  static const List<CityPolicy> cities = [
    CityPolicy(
      key: 'beijing',
      nameZh: '北京',
      maxHousingFundLoanFirst: 120,
      maxHousingFundLoanSecond: 100,
      housingFundRateFirst: 0.0285,
      housingFundRateSecond: 0.03075,
      minDownPaymentRatioFirst: 0.15,
      minDownPaymentRatioSecond: 0.25,
      maxLoanRatioFirst: 0.85,
      maxLoanRatioSecond: 0.75,
      balanceMultiplier: 15,
      commercialFloatingFirst: -0.005,
      commercialFloatingSecond: 0.005,
    ),
    CityPolicy(
      key: 'shanghai',
      nameZh: '上海',
      maxHousingFundLoanFirst: 120,
      maxHousingFundLoanSecond: 100,
      housingFundRateFirst: 0.0285,
      housingFundRateSecond: 0.03075,
      minDownPaymentRatioFirst: 0.15,
      minDownPaymentRatioSecond: 0.50,
      maxLoanRatioFirst: 0.85,
      maxLoanRatioSecond: 0.50,
      balanceMultiplier: 15,
      commercialFloatingFirst: -0.006,
      commercialFloatingSecond: 0.006,
    ),
    CityPolicy(
      key: 'guangzhou',
      nameZh: '广州',
      maxHousingFundLoanFirst: 120,
      maxHousingFundLoanSecond: 100,
      housingFundRateFirst: 0.0285,
      housingFundRateSecond: 0.03075,
      minDownPaymentRatioFirst: 0.15,
      minDownPaymentRatioSecond: 0.30,
      maxLoanRatioFirst: 0.85,
      maxLoanRatioSecond: 0.70,
      balanceMultiplier: 8,
      commercialFloatingFirst: -0.005,
      commercialFloatingSecond: 0.006,
    ),
    CityPolicy(
      key: 'shenzhen',
      nameZh: '深圳',
      maxHousingFundLoanFirst: 120,
      maxHousingFundLoanSecond: 90,
      housingFundRateFirst: 0.0285,
      housingFundRateSecond: 0.03075,
      minDownPaymentRatioFirst: 0.15,
      minDownPaymentRatioSecond: 0.30,
      maxLoanRatioFirst: 0.85,
      maxLoanRatioSecond: 0.70,
      balanceMultiplier: 14,
      commercialFloatingFirst: -0.005,
      commercialFloatingSecond: 0.006,
    ),
    CityPolicy(
      key: 'chengdu',
      nameZh: '成都',
      maxHousingFundLoanFirst: 120,
      maxHousingFundLoanSecond: 80,
      housingFundRateFirst: 0.026,
      housingFundRateSecond: 0.03075,
      minDownPaymentRatioFirst: 0.15,
      minDownPaymentRatioSecond: 0.30,
      maxLoanRatioFirst: 0.85,
      maxLoanRatioSecond: 0.70,
      balanceMultiplier: 25,
      commercialFloatingFirst: -0.005,
      commercialFloatingSecond: 0.006,
    ),
    CityPolicy(
      key: 'chongqing',
      nameZh: '重庆',
      maxHousingFundLoanFirst: 80,
      maxHousingFundLoanSecond: 80,
      housingFundRateFirst: 0.026,
      housingFundRateSecond: 0.03075,
      minDownPaymentRatioFirst: 0.15,
      minDownPaymentRatioSecond: 0.30,
      maxLoanRatioFirst: 0.85,
      maxLoanRatioSecond: 0.70,
      balanceMultiplier: 25,
      commercialFloatingFirst: -0.005,
      commercialFloatingSecond: 0.006,
    ),
  ];

  /// 按键查找城市
  static CityPolicy byKey(String key) =>
      cities.firstWhere((c) => c.key == key, orElse: () => cities.first);

  /// 公积金利率（按房屋类型）
  double housingFundRate(HouseType houseType) => houseType == HouseType.first
      ? housingFundRateFirst
      : housingFundRateSecond;

  /// 商贷利率 = LPR + 浮动（与原 Swift 版 `calculateCommercialRate` 一致）
  double commercialRate(HouseType houseType) {
    final floating = houseType == HouseType.first
        ? commercialFloatingFirst
        : commercialFloatingSecond;
    return lprBase + floating;
  }

  /// 计算公积金可贷额度（元）
  ///
  /// 与原 Swift 版 `City.calculateHousingFundLoanable` 一致：
  /// min(余额合计 × 倍数 × 1万, 房价 × 最高贷款成数, 政策上限 × 1万)
  double housingFundLoanable({
    required double balance,
    double spouseBalance = 0,
    required double housePrice,
    required HouseType houseType,
  }) {
    final totalBalance = balance + spouseBalance;
    final maxByBalance = totalBalance * balanceMultiplier * 10000;
    final maxByPrice =
        housePrice *
        (houseType == HouseType.first ? maxLoanRatioFirst : maxLoanRatioSecond);
    final maxByPolicy =
        (houseType == HouseType.first
            ? maxHousingFundLoanFirst
            : maxHousingFundLoanSecond) *
        10000;
    return math.min(maxByBalance, math.min(maxByPrice, maxByPolicy));
  }
}
