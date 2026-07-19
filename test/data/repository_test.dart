import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:loan_calculator/core/constants/app_constants.dart';
import 'package:loan_calculator/data/repositories/history_repository.dart';
import 'package:loan_calculator/data/repositories/plan_repository.dart';
import 'package:loan_calculator/domain/entities/loan_input.dart';
import 'package:loan_calculator/domain/entities/repayment_method.dart';
import 'package:loan_calculator/domain/entities/saved_plan.dart';
import 'package:loan_calculator/domain/engine/loan_engine.dart';

/// 本地存储仓库测试（真实 Hive，临时目录）
void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_repo_test');
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

  setUp(() async {
    await Hive.box<Map<dynamic, dynamic>>(AppConstants.plansBox).clear();
    await Hive.box<Map<dynamic, dynamic>>(AppConstants.historyBox).clear();
  });

  HistoryEntry makeEntry(String signature, int createdAt) => HistoryEntry(
    signature: signature,
    input: LoanInput(principal: (double.tryParse(signature) ?? 0) * 10000),
    monthlyPayment: 1000,
    totalInterest: 2000,
    totalPayment: 3000,
    createdAt: createdAt,
  );

  group('HistoryRepository', () {
    test('同签名去重：重复添加只保留最新', () async {
      final repo = HistoryRepository();
      await repo.add(makeEntry('100', 1));
      await repo.add(makeEntry('100', 2));
      final all = repo.getAll();
      expect(all.length, 1);
      expect(all.first.createdAt, 2);
    });

    test('上限 100 条：超出淘汰最旧记录', () async {
      final repo = HistoryRepository();
      for (var i = 1; i <= 105; i++) {
        await repo.add(makeEntry('$i', i));
      }
      final all = repo.getAll();
      expect(all.length, AppConstants.historyLimit);
      // 最旧的 1-5 已被淘汰，最新为 105
      expect(all.first.createdAt, 105);
      expect(all.last.createdAt, 6);
    });

    test('按时间倒序返回', () async {
      final repo = HistoryRepository();
      await repo.add(makeEntry('1', 100));
      await repo.add(makeEntry('2', 300));
      await repo.add(makeEntry('3', 200));
      final all = repo.getAll();
      expect(all.map((e) => e.createdAt).toList(), [300, 200, 100]);
    });

    test('清空', () async {
      final repo = HistoryRepository();
      await repo.add(makeEntry('1', 1));
      await repo.clear();
      expect(repo.getAll(), isEmpty);
    });

    test('搜索命中金额', () async {
      final repo = HistoryRepository();
      await repo.add(makeEntry('123', 1));
      await repo.add(makeEntry('456', 2));
      expect(repo.search('123').length, 1);
      expect(repo.search('').length, 2);
      expect(repo.search('999').length, 0);
    });
  });

  group('PlanRepository', () {
    SavedPlan makePlan(String id, String name, int createdAt) {
      const input = LoanInput(
        principal: 1000000,
        years: 30,
        annualRate: 0.036,
        method: RepaymentMethod.equalPayment,
      );
      return SavedPlan(
        id: id,
        name: name,
        input: input,
        result: LoanEngine.calculate(input),
        createdAt: createdAt,
      );
    }

    test('保存 / 读取 / 删除', () async {
      final repo = PlanRepository();
      await repo.save(makePlan('a', '方案A', 1));
      await repo.save(makePlan('b', '方案B', 2));
      var all = repo.getAll();
      expect(all.length, 2);
      // 倒序：b 在前
      expect(all.first.id, 'b');

      await repo.delete('a');
      all = repo.getAll();
      expect(all.length, 1);
      expect(all.first.id, 'b');
    });

    test('重命名', () async {
      final repo = PlanRepository();
      await repo.save(makePlan('a', '旧名', 1));
      await repo.rename('a', '新名');
      expect(repo.getAll().first.name, '新名');
    });

    test('JSON 往返保持关键字段', () async {
      final plan = makePlan('x', '测试方案', 12345);
      final decoded = SavedPlan.fromJson(plan.toJson());
      expect(decoded.id, plan.id);
      expect(decoded.name, plan.name);
      expect(decoded.input, plan.input);
      expect(
        decoded.result.total.monthlyPayment,
        closeTo(plan.result.total.monthlyPayment, 1e-9),
      );
      expect(decoded.createdAt, plan.createdAt);
    });

    test('HistoryEntry JSON 往返', () {
      final e = makeEntry('sig', 999);
      final decoded = HistoryEntry.fromJson(e.toJson());
      expect(decoded.signature, e.signature);
      expect(decoded.input, e.input);
      expect(decoded.monthlyPayment, e.monthlyPayment);
      expect(decoded.createdAt, e.createdAt);
    });
  });
}
