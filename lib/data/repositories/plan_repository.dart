import '../../domain/entities/saved_plan.dart';
import '../datasources/hive_datasource.dart';

/// 方案库仓库：贷款方案的增删改查（Hive JSON 存储）
class PlanRepository {
  /// 读取全部方案（按创建时间倒序）
  List<SavedPlan> getAll() {
    final list = HiveDataSource.plans.values
        .map((m) => SavedPlan.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// 保存（新增或覆盖同 id）
  Future<void> save(SavedPlan plan) async {
    await HiveDataSource.plans.put(plan.id, plan.toJson());
  }

  /// 重命名
  Future<void> rename(String id, String newName) async {
    final raw = HiveDataSource.plans.get(id);
    if (raw == null) return;
    final plan = SavedPlan.fromJson(Map<String, dynamic>.from(raw));
    await HiveDataSource.plans.put(id, plan.copyWith(name: newName).toJson());
  }

  /// 删除
  Future<void> delete(String id) async {
    await HiveDataSource.plans.delete(id);
  }

  /// 清空
  Future<void> clear() async {
    await HiveDataSource.plans.clear();
  }
}
