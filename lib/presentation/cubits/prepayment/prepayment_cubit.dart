import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/loan_input.dart';
import '../../../domain/entities/prepayment_result.dart';
import '../../../domain/usecases/simulate_prepayment_usecase.dart';

/// 提前还款模拟状态
class PrepaymentState extends Equatable {
  /// 原始贷款输入（来自计算器当前参数）
  final LoanInput baseInput;

  /// 已还期数
  final int monthsPaid;

  /// 提前还款金额（元）
  final double prepayAmount;

  /// 缩短期限模式结果
  final PrepaymentResult? reduceTerm;

  /// 减少月供模式结果
  final PrepaymentResult? reducePayment;

  /// 输入是否有效
  final bool valid;

  const PrepaymentState({
    required this.baseInput,
    this.monthsPaid = 12,
    this.prepayAmount = 100000,
    this.reduceTerm,
    this.reducePayment,
    this.valid = true,
  });

  PrepaymentState copyWith({
    LoanInput? baseInput,
    int? monthsPaid,
    double? prepayAmount,
    PrepaymentResult? reduceTerm,
    PrepaymentResult? reducePayment,
    bool? valid,
  }) {
    return PrepaymentState(
      baseInput: baseInput ?? this.baseInput,
      monthsPaid: monthsPaid ?? this.monthsPaid,
      prepayAmount: prepayAmount ?? this.prepayAmount,
      reduceTerm: reduceTerm ?? this.reduceTerm,
      reducePayment: reducePayment ?? this.reducePayment,
      valid: valid ?? this.valid,
    );
  }

  @override
  List<Object?> get props => [
    baseInput,
    monthsPaid,
    prepayAmount,
    reduceTerm,
    reducePayment,
    valid,
  ];
}

/// 提前还款模拟 Cubit
class PrepaymentCubit extends Cubit<PrepaymentState> {
  /// 模拟用例（固定实现，便于替换）
  final SimulatePrepaymentUseCase _simulate = const SimulatePrepaymentUseCase();

  PrepaymentCubit({required LoanInput baseInput})
    : super(PrepaymentState(baseInput: baseInput)) {
    run();
  }

  /// 更新已还期数
  void setMonthsPaid(int months) {
    emit(state.copyWith(monthsPaid: months));
    run();
  }

  /// 更新提前还款金额
  void setPrepayAmount(double amount) {
    emit(state.copyWith(prepayAmount: amount));
    run();
  }

  /// 执行模拟（两种模式同时计算）
  void run() {
    final s = state;
    // 组合贷先折算为等效单贷（用总额与加权利率近似），
    // 保证工具在组合贷参数下仍可用。
    final base = _effectiveSingle(s.baseInput);
    final results = _simulate(
      input: base,
      monthsPaid: s.monthsPaid,
      prepayAmount: s.prepayAmount,
    );
    final valid = results.reduceTerm != null || results.reducePayment != null;
    emit(
      s.copyWith(
        reduceTerm: results.reduceTerm,
        reducePayment: results.reducePayment,
        valid: valid,
      ),
    );
  }

  /// 组合贷折算：总本金 + 本金加权平均利率
  LoanInput _effectiveSingle(LoanInput input) {
    if (!input.isCombined) return input;
    final total = input.fundPrincipal + input.commercialPrincipal;
    if (total <= 0) return input.copyWith(isCombined: false, principal: 0);
    final weighted =
        (input.fundPrincipal * input.fundAnnualRate +
            input.commercialPrincipal * input.commercialAnnualRate) /
        total;
    return input.copyWith(
      isCombined: false,
      principal: total,
      annualRate: weighted,
    );
  }
}
