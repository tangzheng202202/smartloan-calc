import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:loan_calculator/app.dart';
import 'package:loan_calculator/core/constants/app_constants.dart';
import 'package:loan_calculator/data/repositories/settings_repository.dart';
import 'package:loan_calculator/presentation/cubits/calculator/calculator_cubit.dart';
import 'package:loan_calculator/presentation/cubits/history/history_cubit.dart';
import 'package:loan_calculator/presentation/cubits/plans/plans_cubit.dart';
import 'package:loan_calculator/presentation/cubits/settings/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          BlocProvider(create: (_) => CalculatorCubit()),
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
