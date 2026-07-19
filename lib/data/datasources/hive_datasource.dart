import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

/// Hive 本地数据源
///
/// 唯一与 Hive 直接交互的层：Box 初始化与访问。
/// 全部数据仅存本机，不上传。
class HiveDataSource {
  HiveDataSource._();

  static bool _initialized = false;

  /// 初始化 Hive 并打开所有 Box（幂等）
  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter('smartloan_storage');
    await Hive.openBox<Map<dynamic, dynamic>>(AppConstants.plansBox);
    await Hive.openBox<Map<dynamic, dynamic>>(AppConstants.historyBox);
    _initialized = true;
  }

  /// 方案库 Box（值为 JSON Map）
  static Box<Map<dynamic, dynamic>> get plans =>
      Hive.box<Map<dynamic, dynamic>>(AppConstants.plansBox);

  /// 历史记录 Box（值为 JSON Map）
  static Box<Map<dynamic, dynamic>> get history =>
      Hive.box<Map<dynamic, dynamic>>(AppConstants.historyBox);
}
