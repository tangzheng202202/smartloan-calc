import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/cubits/calculator/calculator_cubit.dart';
import 'presentation/cubits/history/history_cubit.dart';
import 'presentation/cubits/plans/plans_cubit.dart';
import 'presentation/cubits/settings/settings_cubit.dart';
import 'services/storage_service.dart';

/// 应用入口：初始化本地存储后启动
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  final settingsRepo = await SettingsRepository.load();

  runApp(
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
}
