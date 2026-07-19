import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/loan_input.dart';
import '../../../domain/entities/loan_result.dart';
import '../../../domain/entities/saved_plan.dart';
import '../../../domain/entities/schedule_item.dart';
import '../../../domain/usecases/calculate_loan_usecase.dart';
import '../../../data/repositories/history_repository.dart';

/// 计算器状态
class CalculatorState extends Equatable {
  /// 当前输入
  final LoanInput input;

  /// 汇总结果
  final LoanResult result;

  /// 还款计划（完整期数）
  final List<ScheduleItem> schedule;

  /// 输入校验错误
  final List<String> errors;

  const CalculatorState({
    required this.input,
    required this.result,
    required this.schedule,
    this.errors = const [],
  });

  CalculatorState copyWith({
    LoanInput? input,
    LoanResult? result,
    List<ScheduleItem>? schedule,
    List<String>? errors,
  }) {
    return CalculatorState(
      input: input ?? this.input,
      result: result ?? this.result,
      schedule: schedule ?? this.schedule,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [input, result, schedule, errors];
}

/// 计算器 Cubit：输入即算，无"计算"按钮
///
/// 任意输入变化立即重算汇总与还款计划；
/// 输入停顿 800ms 后自动写入历史记录（签名去重）。
class CalculatorCubit extends Cubit<CalculatorState> {
  final CalculateLoanUseCase _calculate;
  final HistoryRepository _historyRepo;

  Timer? _historyTimer;
  String _lastSavedSignature = '';

  CalculatorCubit({
    CalculateLoanUseCase calculate = const CalculateLoanUseCase(),
    HistoryRepository? historyRepo,
  }) : _calculate = calculate,
       _historyRepo = historyRepo ?? HistoryRepository(),
       super(_initialState(calculate));

  static CalculatorState _initialState(CalculateLoanUseCase calculate) {
    const input = LoanInput();
    return CalculatorState(
      input: input,
      result: calculate(input),
      schedule: calculate.schedule(input),
    );
  }

  /// 更新输入并即时重算
  void updateInput(LoanInput input) {
    final errors = input.validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(input: input, errors: errors));
      return;
    }
    emit(
      CalculatorState(
        input: input,
        result: _calculate(input),
        schedule: _calculate.schedule(input),
      ),
    );
    _scheduleHistorySave();
  }

  /// 便捷更新：按字段修改
  void update(LoanInput Function(LoanInput) transform) {
    updateInput(transform(state.input));
  }

  /// 从方案库/历史载入参数
  void loadInput(LoanInput input) {
    updateInput(input);
  }

  /// 输入停顿后自动保存历史（去重）
  void _scheduleHistorySave() {
    _historyTimer?.cancel();
    _historyTimer = Timer(const Duration(milliseconds: 800), () {
      final s = state;
      if (s.errors.isNotEmpty) return;
      if (s.input.signature == _lastSavedSignature) return;
      _lastSavedSignature = s.input.signature;
      _historyRepo.add(
        HistoryEntry(
          signature: s.input.signature,
          input: s.input,
          monthlyPayment: s.result.total.monthlyPayment,
          totalInterest: s.result.total.totalInterest,
          totalPayment: s.result.total.totalPayment,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _historyTimer?.cancel();
    return super.close();
  }
}
