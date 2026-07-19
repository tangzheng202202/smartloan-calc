import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/plan_repository.dart';
import '../../../domain/entities/saved_plan.dart';

/// 方案库状态
class PlansState extends Equatable {
  /// 全部方案（创建时间倒序）
  final List<SavedPlan> plans;

  /// 多选对比中的方案 id
  final Set<String> selectedIds;

  const PlansState({this.plans = const [], this.selectedIds = const {}});

  PlansState copyWith({List<SavedPlan>? plans, Set<String>? selectedIds}) {
    return PlansState(
      plans: plans ?? this.plans,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  List<Object?> get props => [plans, selectedIds];
}

/// 方案库 Cubit
class PlansCubit extends Cubit<PlansState> {
  final PlanRepository _repo;

  PlansCubit({PlanRepository? repo})
    : _repo = repo ?? PlanRepository(),
      super(const PlansState()) {
    refresh();
  }

  /// 刷新列表
  void refresh() {
    emit(state.copyWith(plans: _repo.getAll()));
  }

  /// 保存方案
  Future<void> savePlan(SavedPlan plan) async {
    await _repo.save(plan);
    refresh();
  }

  /// 删除方案
  Future<void> deletePlan(String id) async {
    await _repo.delete(id);
    final selected = Set<String>.from(state.selectedIds)..remove(id);
    emit(state.copyWith(selectedIds: selected));
    refresh();
  }

  /// 重命名方案
  Future<void> renamePlan(String id, String newName) async {
    if (newName.trim().isEmpty) return;
    await _repo.rename(id, newName.trim());
    refresh();
  }

  /// 切换对比选中态
  void toggleSelect(String id) {
    final selected = Set<String>.from(state.selectedIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else if (selected.length < 3) {
      selected.add(id);
    }
    emit(state.copyWith(selectedIds: selected));
  }

  /// 清空对比选择
  void clearSelection() {
    emit(state.copyWith(selectedIds: const {}));
  }

  /// 选中的方案列表
  List<SavedPlan> selectedPlans() {
    return state.plans.where((p) => state.selectedIds.contains(p.id)).toList();
  }
}
