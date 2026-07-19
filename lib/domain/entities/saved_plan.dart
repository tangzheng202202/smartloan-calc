import 'package:equatable/equatable.dart';

import 'loan_input.dart';
import 'loan_result.dart';

/// 已保存的贷款方案（方案库条目）
class SavedPlan extends Equatable {
  /// 唯一标识
  final String id;

  /// 方案名称（用户可重命名）
  final String name;

  /// 输入参数
  final LoanInput input;

  /// 结果快照
  final LoanResult result;

  /// 创建时间（毫秒时间戳）
  final int createdAt;

  const SavedPlan({
    required this.id,
    required this.name,
    required this.input,
    required this.result,
    required this.createdAt,
  });

  SavedPlan copyWith({String? name}) => SavedPlan(
    id: id,
    name: name ?? this.name,
    input: input,
    result: result,
    createdAt: createdAt,
  );

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'input': input.toJson(),
    'result': {
      'monthlyPayment': result.total.monthlyPayment,
      'totalPayment': result.total.totalPayment,
      'totalInterest': result.total.totalInterest,
      'principal': result.total.principal,
      'fundMonthlyPayment': result.fund.monthlyPayment,
      'fundTotalInterest': result.fund.totalInterest,
      'commercialMonthlyPayment': result.commercial.monthlyPayment,
      'commercialTotalInterest': result.commercial.totalInterest,
      'isCombined': result.isCombined,
      'months': result.months,
    },
    'createdAt': createdAt,
  };

  /// 从 JSON 反序列化
  factory SavedPlan.fromJson(Map<String, dynamic> json) {
    final r = json['result'] as Map<String, dynamic>? ?? {};
    final isCombined = r['isCombined'] as bool? ?? false;
    final fund = LoanPartResult(
      monthlyPayment: (r['fundMonthlyPayment'] as num?)?.toDouble() ?? 0,
      totalPayment: 0,
      totalInterest: (r['fundTotalInterest'] as num?)?.toDouble() ?? 0,
      principal: 0,
    );
    final commercial = LoanPartResult(
      monthlyPayment: (r['commercialMonthlyPayment'] as num?)?.toDouble() ?? 0,
      totalPayment: 0,
      totalInterest: (r['commercialTotalInterest'] as num?)?.toDouble() ?? 0,
      principal: 0,
    );
    return SavedPlan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      input: LoanInput.fromJson(
        Map<String, dynamic>.from(json['input'] as Map? ?? {}),
      ),
      result: LoanResult(
        total: LoanPartResult(
          monthlyPayment: (r['monthlyPayment'] as num?)?.toDouble() ?? 0,
          totalPayment: (r['totalPayment'] as num?)?.toDouble() ?? 0,
          totalInterest: (r['totalInterest'] as num?)?.toDouble() ?? 0,
          principal: (r['principal'] as num?)?.toDouble() ?? 0,
        ),
        fund: fund,
        commercial: commercial,
        isCombined: isCombined,
        months: (r['months'] as num?)?.toInt() ?? 0,
      ),
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, input, result, createdAt];
}

/// 历史记录条目（自动保存的计算快照）
class HistoryEntry extends Equatable {
  /// 参数签名（去重键）
  final String signature;

  /// 输入参数
  final LoanInput input;

  /// 月供快照（元）
  final double monthlyPayment;

  /// 总利息快照（元）
  final double totalInterest;

  /// 总还款快照（元）
  final double totalPayment;

  /// 记录时间（毫秒时间戳）
  final int createdAt;

  const HistoryEntry({
    required this.signature,
    required this.input,
    required this.monthlyPayment,
    required this.totalInterest,
    required this.totalPayment,
    required this.createdAt,
  });

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
    'signature': signature,
    'input': input.toJson(),
    'monthlyPayment': monthlyPayment,
    'totalInterest': totalInterest,
    'totalPayment': totalPayment,
    'createdAt': createdAt,
  };

  /// 从 JSON 反序列化
  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    signature: json['signature'] as String? ?? '',
    input: LoanInput.fromJson(
      Map<String, dynamic>.from(json['input'] as Map? ?? {}),
    ),
    monthlyPayment: (json['monthlyPayment'] as num?)?.toDouble() ?? 0,
    totalInterest: (json['totalInterest'] as num?)?.toDouble() ?? 0,
    totalPayment: (json['totalPayment'] as num?)?.toDouble() ?? 0,
    createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
  );

  @override
  List<Object?> get props => [
    signature,
    input,
    monthlyPayment,
    totalInterest,
    totalPayment,
    createdAt,
  ];
}
