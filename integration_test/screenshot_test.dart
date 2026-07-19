import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:loan_calculator/app.dart';
import 'package:loan_calculator/data/repositories/settings_repository.dart';
import 'package:loan_calculator/presentation/cubits/calculator/calculator_cubit.dart';
import 'package:loan_calculator/presentation/cubits/history/history_cubit.dart';
import 'package:loan_calculator/presentation/cubits/plans/plans_cubit.dart';
import 'package:loan_calculator/presentation/cubits/settings/settings_cubit.dart';
import 'package:loan_calculator/services/storage_service.dart';

/// 商店截图巡游：逐页停留并打印 SHOT_PAGE 标记，外层脚本按标记截图。
///
/// 用法：
///   flutter test integration_test/screenshot_test.dart -d `<UDID>` &
///   外层轮询日志中的 `SHOT_PAGE:<name>` 标记，出现后用 simctl 截图。
/// 覆盖页面：01 计算器主页 / 02 图表区 / 03 还款计划表 / 04 提前还款 / 05 我的。
/// 外观（浅色/深色）由外层在启动前用 simctl ui appearance 控制。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await StorageService.init();
  });

  /// 与 main.dart 相同的 Provider 树
  Future<void> pumpApp(WidgetTester tester) async {
    final settingsRepo = await SettingsRepository.load();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsCubit(settingsRepo)),
          BlocProvider(create: (_) => CalculatorCubit()),
          BlocProvider(create: (_) => PlansCubit()),
          BlocProvider(create: (_) => HistoryCubit()),
        ],
        child: const SmartLoanApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
  }

  /// 在懒加载 ListView 中向下滚动直至目标可见
  Future<void> scrollTo(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }

  /// 打印页面标记并停留，供外层 simctl 截图
  Future<void> dwell(String page) async {
    debugPrint('SHOT_PAGE:$page');
    await Future.delayed(const Duration(seconds: 15));
  }

  testWidgets('商店截图巡游', (tester) async {
    await pumpApp(tester);
    // 全新安装会先弹免责声明，先同意
    if (find.text('我已阅读并同意').evaluate().isNotEmpty) {
      await tester.tap(find.text('我已阅读并同意'));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    }

    // 01 计算器主页（输入区 + 月供大数字）
    await dwell('01_calculator');

    // 02 图表区（还款趋势 + 本金/利息占比）
    await scrollTo(tester, find.text('计算结果仅供参考，以银行实际审批为准'));
    await dwell('02_charts');

    // 03 还款计划表
    await scrollTo(tester, find.text('查看还款计划表'));
    await tester.tap(find.text('查看还款计划表'));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await dwell('03_schedule');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // 04 提前还款模拟
    await scrollTo(tester, find.text('提前还款模拟'));
    await tester.tap(find.text('提前还款模拟'));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await dwell('04_prepayment');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // 05 我的（设置项 + 主题模式）
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await dwell('05_settings');

    expect(find.text('主题模式'), findsOneWidget);
    debugPrint('SHOT_DONE');
  });
}
