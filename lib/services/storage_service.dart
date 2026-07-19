import '../../data/datasources/hive_datasource.dart';

/// 本地存储服务
///
/// 存储初始化编排入口（main.dart 启动时调用）。
/// 实际 Box 访问下沉至 [HiveDataSource]。
class StorageService {
  StorageService._();

  /// 初始化本地存储
  static Future<void> init() => HiveDataSource.init();

  /// 清空全部数据（调试用）
  static Future<void> clearAll() async {
    await HiveDataSource.plans.clear();
    await HiveDataSource.history.clear();
  }
}
