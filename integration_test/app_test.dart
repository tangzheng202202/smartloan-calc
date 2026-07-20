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
import 'package:shared_preferences/shared_preferences.dart';

/// 智贷计算器 iOS 模拟器全流程 UI 自动化测试
///
/// 运行：`flutter test integration_test -d <UDID>`（iPhone 17 Pro）
/// 文案基准：lib/l10n/app_zh.arb（默认简体中文）
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Hive 本地存储初始化（幂等）
    await StorageService.init();
  });

  /// 截图（尽力而为）：当前运行方式不支持时吞掉异常，不影响测试
  Future<void> shot(String name) async {
    try {
      await binding.takeScreenshot(name);
    } catch (e) {
      debugPrint('takeScreenshot($name) 不可用，已跳过: $e');
    }
  }

  /// 按 main.dart 同款 Provider 树启动应用
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
    // 模拟器首次启动较慢，给予充足 settle 时间
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
  }

  /// 读取结果区月供大数字文本
  String monthlyText(WidgetTester tester) {
    return tester
        .widget<Text>(find.byKey(const Key('result.monthlyPayment')))
        .data!;
  }

  /// 在懒加载 ListView 中滚动直至目标可见（delta 正数向下、负数向上）
  Future<void> scrollTo(
    WidgetTester tester,
    Finder target, {
    double delta = 300,
  }) async {
    await tester.scrollUntilVisible(
      target,
      delta,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }

  testWidgets('01 首启免责声明弹窗 → 同意 → 进入主界面', (tester) async {
    // 清空偏好，保证首启状态（应用与测试同进程，直接生效）
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await pumpApp(tester);

    // 免责声明弹窗出现
    expect(find.text('免责声明'), findsWidgets);
    expect(find.text('我已阅读并同意'), findsOneWidget);
    await shot('01_disclaimer_dialog');

    // 点击同意 → 弹窗消失
    await tester.tap(find.text('我已阅读并同意'));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.text('我已阅读并同意'), findsNothing);

    // 三个 Tab 可见
    expect(find.text('计算器'), findsOneWidget);
    expect(find.text('方案库'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    await shot('02_home_after_disclaimer');
  });

  testWidgets('02 计算器：默认结果 + 还款方式/首付联动', (tester) async {
    await pumpApp(tester);
    // 全新安装会先弹免责声明（--plain-name 单跑本用例时），先确认
    if (find.text('我已阅读并同意').evaluate().isNotEmpty) {
      await tester.tap(find.text('我已阅读并同意'));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    }

    // 输入区（首屏可见）：总价/首付/派生贷款金额
    expect(find.text('房屋总价'), findsWidgets);
    expect(find.text('首付比例'), findsWidgets);
    expect(find.text('100 万元'), findsWidgets); // 125万 − 20% = 100万

    // 滚动到结果卡：默认月供（100万/3.40%/30年/等额本息）
    await scrollTo(tester, find.byKey(const Key('result.monthlyPayment')));
    expect(find.text('月供'), findsWidgets);
    final m1 = monthlyText(tester);
    expect(m1, isNotEmpty);
    expect(m1, contains('¥'));
    // 结果卡成本行（首付 · 购房总成本）
    expect(find.byKey(const Key('result.costLine')), findsWidgets);

    // 切换还款方式 → 等额本金（位于结果卡上方，向上滚回）：月供数值变化
    await scrollTo(tester, find.text('等额本金'), delta: -300);
    await tester.tap(find.text('等额本金'));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await scrollTo(tester, find.byKey(const Key('result.monthlyPayment')));
    final m2 = monthlyText(tester);
    expect(m2, isNot(m1));

    // 切回等额本息，修改总价 125 → 250 万：首付按 20% 重算，贷款派生 200 万
    await scrollTo(tester, find.text('等额本息'), delta: -300);
    await tester.tap(find.text('等额本息'));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await scrollTo(
      tester,
      find.byKey(const Key('input.totalPrice')),
      delta: -300,
    );
    await tester.enterText(find.byKey(const Key('input.totalPrice')), '250');
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.text('200 万元'), findsWidgets); // 派生贷款金额联动
    await scrollTo(tester, find.byKey(const Key('result.monthlyPayment')));
    final m3 = monthlyText(tester);
    expect(m3, isNot(m1));
    expect(m3, contains('¥'));

    // 修改首付金额 50 → 25 万：贷款回到 225 万，月供再次联动
    await scrollTo(
      tester,
      find.byKey(const Key('input.downPayment')),
      delta: -300,
    );
    await tester.enterText(find.byKey(const Key('input.downPayment')), '25');
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.text('225 万元'), findsWidgets);
    await scrollTo(tester, find.byKey(const Key('result.monthlyPayment')));
    final m4 = monthlyText(tester);
    expect(m4, isNot(m3));
    await shot('03_calculator_result');

    // 常驻免责声明在结果区展示（位于折线图上方的卡片之后，滚动后断言）
    await scrollTo(tester, find.text('计算结果仅供参考，以银行实际审批为准'));
    expect(find.text('计算结果仅供参考，以银行实际审批为准'), findsWidgets);
    await shot('04_disclaimer_banner');
  });

  testWidgets('03 还款计划表：进入、表头与多行明细、返回', (tester) async {
    await pumpApp(tester);

    // 按钮位于图表下方，懒加载列表中先滚动至可见
    await scrollTo(tester, find.text('查看还款计划表'));
    await tester.tap(find.text('查看还款计划表'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // 页面标题 + 表头五列
    expect(find.text('还款计划表'), findsOneWidget);
    expect(find.text('期数'), findsOneWidget);
    expect(find.text('月供'), findsOneWidget);
    expect(find.text('本金'), findsOneWidget);
    expect(find.text('利息'), findsOneWidget);
    expect(find.text('剩余本金'), findsOneWidget);

    // 虚拟滚动列表存在且有多行（前若干期可见）
    expect(find.byKey(const Key('schedule.list')), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('2'), findsWidgets);
    expect(find.text('3'), findsWidgets);
    await shot('05_schedule_page');

    // 返回计算器（中文环境下 Back 按钮 tooltip 已本地化，按类型点击）
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    // 列表停留在下方滚动位置（结果区已回收），断言底部导航仍在即已返回主页
    expect(find.text('计算器'), findsOneWidget);
    expect(find.text('方案库'), findsOneWidget);
  });

  testWidgets('04 工具入口：提前还款模拟页渲染', (tester) async {
    await pumpApp(tester);

    // 工具入口在页面底部，滚动至可见后进入
    await scrollTo(tester, find.text('提前还款模拟'));
    await tester.tap(find.text('提前还款模拟'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // 页标题 + 两种模式对比图 + 节省利息卡片
    // （模式名同时出现在柱状图标签与卡片标题，故用 findsWidgets）
    expect(find.text('提前还款模拟'), findsWidgets);
    expect(find.text('两种模式对比'), findsOneWidget);
    expect(find.text('缩短期限（月供不变）'), findsWidgets);
    expect(find.text('减少月供（期限不变）'), findsWidgets);
    expect(find.textContaining('节省利息'), findsWidgets);
    await shot('06_prepayment_page');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
  });

  testWidgets('05 工具入口：利率换算页渲染', (tester) async {
    await pumpApp(tester);

    await scrollTo(tester, find.text('利率换算'));
    await tester.tap(find.text('利率换算'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // LPR ± BP 换算结果与城市参考
    expect(find.text('实际利率'), findsOneWidget);
    expect(find.text('固定 vs 浮动总利息对比'), findsOneWidget);
    expect(find.text('北京'), findsWidgets);
    await shot('07_rate_converter_page');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
  });

  testWidgets('06 方案库 Tab：页面正常渲染', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('方案库'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // 标题 + 历史记录区块始终存在（方案为空或已有均可）
    expect(find.text('方案库'), findsWidgets);
    expect(find.text('历史记录'), findsOneWidget);
    await shot('08_plans_page');
  });

  testWidgets('07 我的 Tab：设置渲染 + 隐私政策内容页', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // 设置入口
    expect(find.text('主题模式'), findsOneWidget);
    expect(find.text('语言'), findsOneWidget);
    expect(find.text('货币符号'), findsOneWidget);
    await shot('09_settings_page');

    // 打开隐私政策内容页
    await tester.tap(find.text('隐私政策'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.textContaining('不收集'), findsWidgets);
    await shot('10_privacy_page');

    // 返回后免责声明入口仍在
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.text('免责声明'), findsOneWidget);
  });

  testWidgets('99 截图巡游：逐页停留供外部截图', (tester) async {
    await pumpApp(tester);
    // 全新安装的应用会先弹免责声明（--plain-name 单跑本用例时），先确认
    if (find.text('我已阅读并同意').evaluate().isNotEmpty) {
      await tester.tap(find.text('我已阅读并同意'));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    }
    // 计算器首屏（结果区）
    await Future.delayed(const Duration(milliseconds: 2200));

    // 结果区 + 常驻免责声明条
    await scrollTo(tester, find.text('计算结果仅供参考，以银行实际审批为准'));
    await Future.delayed(const Duration(milliseconds: 2200));

    // 还款计划表
    await scrollTo(tester, find.text('查看还款计划表'));
    await tester.tap(find.text('查看还款计划表'));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await Future.delayed(const Duration(milliseconds: 2200));
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // 提前还款模拟
    await scrollTo(tester, find.text('提前还款模拟'));
    await tester.tap(find.text('提前还款模拟'));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await Future.delayed(const Duration(milliseconds: 2200));
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // 利率换算
    await scrollTo(tester, find.text('利率换算'));
    await tester.tap(find.text('利率换算'));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await Future.delayed(const Duration(milliseconds: 2200));
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // 方案库
    await tester.tap(find.text('方案库'));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await Future.delayed(const Duration(milliseconds: 2200));

    // 我的
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await Future.delayed(const Duration(milliseconds: 2200));

    expect(find.text('主题模式'), findsOneWidget);
  });
}
