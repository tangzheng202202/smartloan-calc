import 'package:flutter/material.dart';

import '../presentation/pages/affordability/affordability_page.dart';
import '../presentation/pages/prepayment/prepayment_page.dart';
import '../presentation/pages/rate_converter/rate_converter_page.dart';
import '../presentation/pages/schedule/schedule_page.dart';
import '../presentation/pages/settings/content_pages.dart';
import '../presentation/pages/shell/home_shell.dart';

/// 声明式路由表
class AppRoutes {
  AppRoutes._();

  /// 主框架（底部 Tab）
  static const String home = '/';

  /// 还款计划表
  static const String schedule = '/schedule';

  /// 提前还款模拟
  static const String prepayment = '/prepayment';

  /// 还款能力评估
  static const String affordability = '/affordability';

  /// 利率换算
  static const String rateConverter = '/rate-converter';

  /// 关于
  static const String about = '/about';

  /// 隐私政策
  static const String privacy = '/privacy';

  /// 免责声明
  static const String disclaimer = '/disclaimer';

  /// 路由生成器
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _page(const HomeShell(), settings);
      case schedule:
        return _page(const SchedulePage(), settings);
      case prepayment:
        return _page(const PrepaymentPage(), settings);
      case affordability:
        return _page(const AffordabilityPage(), settings);
      case rateConverter:
        return _page(const RateConverterPage(), settings);
      case about:
        return _page(const AboutPage(), settings);
      case privacy:
        return _page(const PrivacyPage(), settings);
      case disclaimer:
        return _page(const DisclaimerPage(), settings);
      default:
        return _page(const HomeShell(), settings);
    }
  }

  static MaterialPageRoute<T> _page<T>(Widget child, RouteSettings s) {
    return MaterialPageRoute<T>(builder: (_) => child, settings: s);
  }
}
