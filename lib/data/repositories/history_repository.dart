import '../../core/constants/app_constants.dart';
import '../../domain/entities/loan_category.dart';
import '../../domain/entities/repayment_method.dart';
import '../../domain/entities/saved_plan.dart';
import '../datasources/hive_datasource.dart';

/// 历史记录仓库
///
/// 自动保存每次有效计算：按参数签名去重，超出
/// [AppConstants.historyLimit] 条时淘汰最旧记录。
class HistoryRepository {
  /// 读取全部历史（按时间倒序）
  List<HistoryEntry> getAll() {
    final list = HiveDataSource.history.values
        .map((m) => HistoryEntry.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// 追加一条历史（去重 + 上限淘汰）
  Future<void> add(HistoryEntry entry) async {
    final box = HiveDataSource.history;
    // 去重：同签名先删除旧记录，保证最新时间
    if (box.containsKey(entry.signature)) {
      await box.delete(entry.signature);
    }
    await box.put(entry.signature, entry.toJson());

    // 上限淘汰：删除最旧的记录
    if (box.length > AppConstants.historyLimit) {
      final all = getAll();
      final overflow = box.length - AppConstants.historyLimit;
      // getAll 已按时间倒序，末尾为最旧
      for (final old in all.reversed.take(overflow)) {
        await box.delete(old.signature);
      }
    }
  }

  /// 清空历史
  Future<void> clear() async {
    await HiveDataSource.history.clear();
  }

  /// 按关键词搜索（匹配金额/期限/利率数字串）
  List<HistoryEntry> search(String keyword) {
    if (keyword.trim().isEmpty) return getAll();
    final k = keyword.trim().toLowerCase();
    return getAll().where((e) {
      final input = e.input;
      final hay = [
        input.principal.toStringAsFixed(0),
        (input.principal / 10000).toStringAsFixed(1),
        input.years.toString(),
        (input.annualRate * 100).toStringAsFixed(2),
        input.category.key,
        input.method.key,
      ].join(' ').toLowerCase();
      return hay.contains(k);
    }).toList();
  }
}
