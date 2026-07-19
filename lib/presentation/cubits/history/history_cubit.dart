import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/history_repository.dart';
import '../../../domain/entities/saved_plan.dart';

/// 历史记录状态
class HistoryState extends Equatable {
  /// 当前展示的记录
  final List<HistoryEntry> entries;

  /// 搜索关键词
  final String keyword;

  const HistoryState({this.entries = const [], this.keyword = ''});

  HistoryState copyWith({List<HistoryEntry>? entries, String? keyword}) {
    return HistoryState(
      entries: entries ?? this.entries,
      keyword: keyword ?? this.keyword,
    );
  }

  @override
  List<Object?> get props => [entries, keyword];
}

/// 历史记录 Cubit
class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _repo;

  HistoryCubit({HistoryRepository? repo})
    : _repo = repo ?? HistoryRepository(),
      super(const HistoryState()) {
    refresh();
  }

  /// 刷新
  void refresh() {
    emit(state.copyWith(entries: _repo.search(state.keyword)));
  }

  /// 搜索
  void search(String keyword) {
    emit(HistoryState(entries: _repo.search(keyword), keyword: keyword));
  }

  /// 清空
  Future<void> clear() async {
    await _repo.clear();
    refresh();
  }
}
