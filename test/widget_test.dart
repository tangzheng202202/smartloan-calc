import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:loan_calculator/app.dart';
import 'package:loan_calculator/core/constants/app_constants.dart';
import 'package:loan_calculator/data/repositories/history_repository.dart';
import 'package:loan_calculator/data/repositories/settings_repository.dart';
import 'package:loan_calculator/domain/entities/saved_plan.dart';
import 'package:loan_calculator/presentation/cubits/calculator/calculator_cubit.dart';
import 'package:loan_calculator/presentation/cubits/history/history_cubit.dart';
import 'package:loan_calculator/presentation/cubits/plans/plans_cubit.dart';
import 'package:loan_calculator/presentation/cubits/settings/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 测试用空操作历史仓库：避免防抖写盘阻塞测试进程退出
class _NoopHistoryRepo extends HistoryRepository {
  @override
  Future<void> add(HistoryEntry entry) async {}

  @override
  List<HistoryEntry> getAll() => const [];
}

/// App 冒烟测试：启动 → 三个 Tab → 计算器结果区渲染
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_widget_test');
    Hive.init(tempDir.path);
    await Hive.openBox<Map<dynamic, dynamic>>(AppConstants.plansBox);
    await Hive.openBox<Map<dynamic, dynamic>>(AppConstants.historyBox);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefDisclaimerConfirmed: true,
    });
    final settingsRepo = await SettingsRepository.load();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsCubit(settingsRepo)),
          BlocProvider(
            create: (_) => CalculatorCubit(historyRepo: _NoopHistoryRepo()),
          ),
          BlocProvider(create: (_) => PlansCubit()),
          BlocProvider(create: (_) => HistoryCubit()),
        ],
        child: const SmartLoanApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('启动后展示三个 Tab 与计算结果', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    await pumpApp(tester);

    // 底部三个 Tab
    expect(find.text('计算器'), findsOneWidget);
    expect(find.text('方案库'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    // 计算器结果区（默认 100万 30年 3.4% 等额本息）
    expect(find.text('月供'), findsWidgets);
    expect(find.text('总利息'), findsWidgets);
    expect(find.text('总还款'), findsWidgets);

    // 常驻免责声明
    expect(find.text('计算结果仅供参考，以银行实际审批为准'), findsWidgets);
  });

  testWidgets('房贷显示首付区，消费贷隐藏', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    await pumpApp(tester);

    // 默认房贷：总价 / 首付比例 / 首付金额 / 派生贷款金额 / 成本行
    expect(find.text('房屋总价'), findsOneWidget);
    expect(find.text('首付比例'), findsOneWidget);
    expect(find.text('首付金额'), findsOneWidget);
    expect(find.byKey(const Key('input.derivedLoanAmount')), findsOneWidget);
    expect(find.text('100 万元'), findsWidgets); // 派生贷款金额
    expect(find.byKey(const Key('result.costLine')), findsOneWidget);

    // 切到车贷：标签变为车辆总价
    await tester.tap(find.text('车贷'));
    await tester.pumpAndSettle();
    expect(find.text('车辆总价'), findsOneWidget);
    expect(find.text('17.5 万元'), findsWidgets); // 25万×70%

    // 切到消费贷：首付区与成本行消失，回到直输贷款金额
    await tester.tap(find.text('消费贷'));
    await tester.pumpAndSettle();
    expect(find.text('房屋总价'), findsNothing);
    expect(find.text('首付比例'), findsNothing);
    expect(find.byKey(const Key('result.costLine')), findsNothing);
    expect(find.byKey(const Key('input.amount')), findsOneWidget);

    // 排空 800ms 历史保存防抖 Timer（fake async 下避免测试结束挂起）
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('切换到我的 Tab 展示设置项', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    await pumpApp(tester);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    expect(find.text('主题模式'), findsOneWidget);
    expect(find.text('语言'), findsOneWidget);
    expect(find.text('隐私政策'), findsOneWidget);
    expect(find.text('免责声明'), findsWidgets);
  });
}
