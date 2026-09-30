// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '智贷计算器';

  @override
  String get tabCalculator => '计算器';

  @override
  String get tabPlans => '方案库';

  @override
  String get tabSettings => '我的';

  @override
  String get ok => '确定';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get rename => '重命名';

  @override
  String get search => '搜索';

  @override
  String get clear => '清除';

  @override
  String get close => '关闭';

  @override
  String get confirm => '确认';

  @override
  String get disclaimerBanner => '计算结果仅供参考，以银行实际审批为准';

  @override
  String get disclaimerDialogTitle => '免责声明';

  @override
  String get disclaimerDialogBody =>
      '欢迎使用智贷计算器。\n\n本应用提供的所有计算结果（包括但不限于月供、总利息、还款计划、可贷额度评估）均为基于公开公式的理论测算，仅供参考，不构成任何贷款建议或金融咨询意见。实际贷款审批结果、利率、费用以银行及金融机构的最终审批为准。\n\n本应用纯离线运行，您的全部数据仅存储于本机，不会上传至任何服务器。\n\n继续使用即表示您已阅读并同意本声明。';

  @override
  String get disclaimerAgree => '我已阅读并同意';

  @override
  String monthsCount(int count) {
    return '$count 期';
  }

  @override
  String yearsCount(int count) {
    return '$count 年';
  }

  @override
  String get categoryMortgage => '房贷';

  @override
  String get categoryCar => '车贷';

  @override
  String get categoryConsumer => '消费贷';

  @override
  String get methodEqualPayment => '等额本息';

  @override
  String get methodEqualPrincipal => '等额本金';

  @override
  String get methodInterestFirst => '先息后本';

  @override
  String get calculatorTitle => '贷款计算器';

  @override
  String get loanAmountLabel => '贷款金额';

  @override
  String get houseTotalPriceLabel => '房屋总价';

  @override
  String get carTotalPriceLabel => '车辆总价';

  @override
  String get downPaymentRatioLabel => '首付比例';

  @override
  String get downPaymentAmountLabel => '首付金额';

  @override
  String costSummaryMortgage(Object cost, Object down) {
    return '首付 $down · 购房总成本 $cost';
  }

  @override
  String costSummaryCar(Object cost, Object down) {
    return '首付 $down · 购车总成本 $cost';
  }

  @override
  String get zeroLoanHint => '首付已覆盖总价，无需贷款';

  @override
  String get unitWan => '万元';

  @override
  String get unitYear => '年';

  @override
  String get unitPercent => '%';

  @override
  String get termLabel => '贷款期限';

  @override
  String get rateLabel => '年利率';

  @override
  String get combinedSwitch => '组合贷款（公积金 + 商贷）';

  @override
  String get fundAmountLabel => '公积金贷款金额';

  @override
  String get fundRateLabel => '公积金利率';

  @override
  String get commercialAmountLabel => '商贷金额';

  @override
  String get commercialRateLabel => '商贷利率';

  @override
  String get resultMonthly => '月供';

  @override
  String get resultFirstMonth => '首月月供';

  @override
  String get resultLastMonth => '末月月供';

  @override
  String get resultMonthlyInterest => '每月利息';

  @override
  String get resultTotalInterest => '总利息';

  @override
  String get resultTotalPayment => '总还款';

  @override
  String get resultFundPart => '公积金部分';

  @override
  String get resultCommercialPart => '商贷部分';

  @override
  String get viewSchedule => '查看还款计划表';

  @override
  String get savePlan => '保存方案';

  @override
  String get planNameHint => '方案名称';

  @override
  String get planSaved => '方案已保存';

  @override
  String get trendChartTitle => '还款趋势';

  @override
  String get legendPrincipal => '本金';

  @override
  String get legendInterest => '利息';

  @override
  String get pieChartTitle => '本金 / 利息占比';

  @override
  String get totalPrincipalLabel => '贷款本金';

  @override
  String get toolsTitle => '贷款工具';

  @override
  String get prepaymentTool => '提前还款模拟';

  @override
  String get affordabilityTool => '还款能力评估';

  @override
  String get rateTool => '利率换算';

  @override
  String get invalidInput => '输入参数无效，请检查';

  @override
  String get scheduleTitle => '还款计划表';

  @override
  String get colMonth => '期数';

  @override
  String get colPayment => '月供';

  @override
  String get colPrincipal => '本金';

  @override
  String get colInterest => '利息';

  @override
  String get colRemaining => '剩余本金';

  @override
  String get jumpHint => '输入期数跳转';

  @override
  String get exportPdf => '导出 PDF';

  @override
  String get exportCsv => '导出 CSV';

  @override
  String get scheduleEmpty => '暂无还款计划';

  @override
  String get prepaymentTitle => '提前还款模拟';

  @override
  String get monthsPaidLabel => '已还期数';

  @override
  String get prepayAmountLabel => '提前还款金额（元）';

  @override
  String get simulate => '开始模拟';

  @override
  String get remainingNow => '当前剩余本金';

  @override
  String get modeReduceTerm => '缩短期限（月供不变）';

  @override
  String get modeReducePayment => '减少月供（期限不变）';

  @override
  String get interestSavedLabel => '节省利息';

  @override
  String get newMonthlyPaymentLabel => '新月供';

  @override
  String get newTermLabel => '新剩余期限';

  @override
  String get monthsSavedLabel => '缩短期数';

  @override
  String get originalInterestLabel => '原剩余利息';

  @override
  String get chartLabelOriginal => '原利息';

  @override
  String get chartLabelReduceTerm => '缩期限';

  @override
  String get chartLabelReducePayment => '减月供';

  @override
  String get newInterestLabel => '新利息';

  @override
  String get compareModesTitle => '两种模式对比';

  @override
  String get prepayInvalidHint => '请输入有效的已还期数与提前还款金额';

  @override
  String get paidOffTip => '提前还款已覆盖全部剩余本金，贷款结清';

  @override
  String get affordabilityTitle => '还款能力评估';

  @override
  String get incomeLabel => '月收入（元）';

  @override
  String get existingDebtLabel => '既有月供负债（元）';

  @override
  String get newPaymentLabel => '拟新增月供（元）';

  @override
  String get assessButton => '开始评估';

  @override
  String get dsrLabel => '负债率 DSR';

  @override
  String get ratingLabel => '还款压力评级';

  @override
  String get suggestedPaymentLabel => '建议最高月供';

  @override
  String get suggestedLoanLabel => '建议最高可贷额度';

  @override
  String get ratingExcellent => '极优';

  @override
  String get ratingGood => '良好';

  @override
  String get ratingModerate => '适中';

  @override
  String get ratingCaution => '偏高';

  @override
  String get ratingDanger => '过高';

  @override
  String get adviceExcellent => '还款压力极小，财务状况非常健康';

  @override
  String get adviceGood => '还款压力适中，财务状况良好';

  @override
  String get adviceModerate => '还款压力中等，建议预留流动资金';

  @override
  String get adviceCaution => '还款压力偏高，需谨慎规划其他开支';

  @override
  String get adviceDanger => '还款压力过大，建议降低贷款额度';

  @override
  String get dsrHint => 'DSR =（月供 + 既有负债）÷ 月收入，银行一般要求 ≤ 50%';

  @override
  String get rateToolTitle => '利率换算';

  @override
  String get lprLabel => 'LPR 基准利率（%）';

  @override
  String get bpLabel => '基点（BP）';

  @override
  String get resultRateLabel => '实际利率';

  @override
  String get fixedVsFloatingTitle => '固定 vs 浮动总利息对比';

  @override
  String get fixedRateLabel => '固定利率（%）';

  @override
  String get floatingRateLabel => '浮动利率（%）';

  @override
  String get compareResultLabel => '利息差（固定 − 浮动）';

  @override
  String get monthlyDiffLabel => '月供差（浮动 − 固定）';

  @override
  String get cityPresetTitle => '各城市商贷利率参考（首套 / 二套）';

  @override
  String get beijingRateNote =>
      '北京：商贷自2025-12-24起由银行逐笔定价，不再区分首套/二套利率；2025-05-08起新发放的5年以上公积金贷款，首套2.6%、二套3.075%。来源：北京市住建委等部门、北京住房公积金管理中心。';

  @override
  String get cityBeijing => '北京';

  @override
  String get cityShanghai => '上海';

  @override
  String get cityGuangzhou => '广州';

  @override
  String get cityShenzhen => '深圳';

  @override
  String get cityChengdu => '成都';

  @override
  String get cityChongqing => '重庆';

  @override
  String get fundRateRef => '公积金利率参考';

  @override
  String get bpHint => '1 BP = 0.01%，如 LPR 3.5% − 60BP = 2.9%';

  @override
  String get plansTitle => '方案库';

  @override
  String get emptyPlans => '还没有保存的方案，去计算器保存一个吧';

  @override
  String get compareButton => '对比';

  @override
  String get compareNeedTwo => '请选择 2-3 个方案进行对比';

  @override
  String get compareTitle => '方案对比';

  @override
  String get planNameColumn => '方案';

  @override
  String get deletePlanTitle => '删除方案';

  @override
  String get deletePlanBody => '确定删除该方案吗？';

  @override
  String get renamePlanTitle => '重命名方案';

  @override
  String get historySection => '历史记录';

  @override
  String get historyEmpty => '暂无历史记录';

  @override
  String get clearHistoryButton => '清空历史';

  @override
  String get historyCleared => '历史记录已清空';

  @override
  String get loadPlan => '载入计算器';

  @override
  String get planLoaded => '已载入计算器';

  @override
  String get settingsTitle => '我的';

  @override
  String get appearanceSection => '外观';

  @override
  String get themeLabel => '主题模式';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get currencyLabel => '货币符号';

  @override
  String get languageLabel => '语言';

  @override
  String get langZhCN => '简体中文';

  @override
  String get langZhTW => '繁體中文';

  @override
  String get langEn => 'English';

  @override
  String get dataSection => '数据';

  @override
  String get clearHistory => '清除历史记录';

  @override
  String get clearHistoryConfirm => '将删除全部历史记录，是否继续？';

  @override
  String get aboutSection => '关于';

  @override
  String get aboutButton => '关于智贷计算器';

  @override
  String get privacyButton => '隐私政策';

  @override
  String get disclaimerButton => '免责声明';

  @override
  String get versionLabel => '版本 1.0.0';

  @override
  String get aboutContent =>
      '智贷计算器（SmartLoan Calc）是一款极简、离线优先的个人贷款规划工具。\n\n支持等额本息、等额本金、先息后本三种还款方式，覆盖房贷、车贷、消费贷场景，并提供组合贷款、提前还款模拟、还款能力评估与 LPR 利率换算等实用工具。\n\n核心理念：输入即算、大数字优先、深色模式、数据不出机。';

  @override
  String get privacyContent =>
      '隐私政策要点\n\n1. 不收集：本应用不收集任何个人信息、设备信息或使用数据。\n2. 不上传：无任何网络请求，全部计算在本机完成。\n3. 本地存储：您保存的方案与历史记录仅存储于本机应用沙盒（Hive 数据库），卸载应用即被删除。\n4. 无账号：无需注册登录，无第三方 SDK 埋点。\n5. 导出文件：还款计划 PDF / CSV 仅在您主动分享时经系统分享面板发出，内容由您完全控制。\n\n如未来版本引入任何网络功能，我们将更新本政策并在应用内显著提示。';

  @override
  String get disclaimerContent =>
      '免责声明\n\n本应用提供的所有计算结果（包括但不限于月供、总利息、还款计划表、提前还款测算、可贷额度评估、利率换算）均为基于公开金融公式的理论测算，仅供参考，不构成任何贷款建议、投资建议或金融咨询意见。\n\n实际贷款的可贷额度、利率、费用、审批结果以银行及持牌金融机构的最终审批为准。城市房贷与公积金政策数据为静态快照，可能与最新政策存在差异，请以当地住房公积金管理中心及银行公布为准。\n\n因使用本应用计算结果作出的任何决策，风险由使用者自行承担。';

  @override
  String get offlineBadge => '纯离线 · 数据仅存本机';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '智貸計算機';

  @override
  String get tabCalculator => '計算機';

  @override
  String get tabPlans => '方案庫';

  @override
  String get tabSettings => '我的';

  @override
  String get ok => '確定';

  @override
  String get cancel => '取消';

  @override
  String get save => '儲存';

  @override
  String get delete => '刪除';

  @override
  String get rename => '重新命名';

  @override
  String get search => '搜尋';

  @override
  String get clear => '清除';

  @override
  String get close => '關閉';

  @override
  String get confirm => '確認';

  @override
  String get disclaimerBanner => '計算結果僅供參考，以銀行實際審批為準';

  @override
  String get disclaimerDialogTitle => '免責聲明';

  @override
  String get disclaimerDialogBody =>
      '歡迎使用智貸計算機。\n\n本應用提供的所有計算結果（包括但不限於月供、總利息、還款計劃、可貸額度評估）均為基於公開公式的理論測算，僅供參考，不構成任何貸款建議或金融諮詢意見。實際貸款審批結果、利率、費用以銀行及金融機構的最終審批為準。\n\n本應用純離線運行，您的全部資料僅儲存於本機，不會上傳至任何伺服器。\n\n繼續使用即表示您已閱讀並同意本聲明。';

  @override
  String get disclaimerAgree => '我已閱讀並同意';

  @override
  String monthsCount(int count) {
    return '$count 期';
  }

  @override
  String yearsCount(int count) {
    return '$count 年';
  }

  @override
  String get categoryMortgage => '房貸';

  @override
  String get categoryCar => '車貸';

  @override
  String get categoryConsumer => '消費貸';

  @override
  String get methodEqualPayment => '等額本息';

  @override
  String get methodEqualPrincipal => '等額本金';

  @override
  String get methodInterestFirst => '先息後本';

  @override
  String get calculatorTitle => '貸款計算機';

  @override
  String get loanAmountLabel => '貸款金額';

  @override
  String get houseTotalPriceLabel => '房屋總價';

  @override
  String get carTotalPriceLabel => '車輛總價';

  @override
  String get downPaymentRatioLabel => '首付比例';

  @override
  String get downPaymentAmountLabel => '首付金額';

  @override
  String costSummaryMortgage(Object cost, Object down) {
    return '首付 $down · 購屋總成本 $cost';
  }

  @override
  String costSummaryCar(Object cost, Object down) {
    return '首付 $down · 購車總成本 $cost';
  }

  @override
  String get zeroLoanHint => '首付已涵蓋總價，無需貸款';

  @override
  String get unitWan => '萬元';

  @override
  String get unitYear => '年';

  @override
  String get unitPercent => '%';

  @override
  String get termLabel => '貸款期限';

  @override
  String get rateLabel => '年利率';

  @override
  String get combinedSwitch => '組合貸款（公積金 + 商貸）';

  @override
  String get fundAmountLabel => '公積金貸款金額';

  @override
  String get fundRateLabel => '公積金利率';

  @override
  String get commercialAmountLabel => '商貸金額';

  @override
  String get commercialRateLabel => '商貸利率';

  @override
  String get resultMonthly => '月供';

  @override
  String get resultFirstMonth => '首月月供';

  @override
  String get resultLastMonth => '末月月供';

  @override
  String get resultMonthlyInterest => '每月利息';

  @override
  String get resultTotalInterest => '總利息';

  @override
  String get resultTotalPayment => '總還款';

  @override
  String get resultFundPart => '公積金部分';

  @override
  String get resultCommercialPart => '商貸部分';

  @override
  String get viewSchedule => '查看還款計劃表';

  @override
  String get savePlan => '儲存方案';

  @override
  String get planNameHint => '方案名稱';

  @override
  String get planSaved => '方案已儲存';

  @override
  String get trendChartTitle => '還款趨勢';

  @override
  String get legendPrincipal => '本金';

  @override
  String get legendInterest => '利息';

  @override
  String get pieChartTitle => '本金 / 利息佔比';

  @override
  String get totalPrincipalLabel => '貸款本金';

  @override
  String get toolsTitle => '貸款工具';

  @override
  String get prepaymentTool => '提前還款模擬';

  @override
  String get affordabilityTool => '還款能力評估';

  @override
  String get rateTool => '利率換算';

  @override
  String get invalidInput => '輸入參數無效，請檢查';

  @override
  String get scheduleTitle => '還款計劃表';

  @override
  String get colMonth => '期數';

  @override
  String get colPayment => '月供';

  @override
  String get colPrincipal => '本金';

  @override
  String get colInterest => '利息';

  @override
  String get colRemaining => '剩餘本金';

  @override
  String get jumpHint => '輸入期數跳轉';

  @override
  String get exportPdf => '匯出 PDF';

  @override
  String get exportCsv => '匯出 CSV';

  @override
  String get scheduleEmpty => '暫無還款計劃';

  @override
  String get prepaymentTitle => '提前還款模擬';

  @override
  String get monthsPaidLabel => '已還期數';

  @override
  String get prepayAmountLabel => '提前還款金額（元）';

  @override
  String get simulate => '開始模擬';

  @override
  String get remainingNow => '當前剩餘本金';

  @override
  String get modeReduceTerm => '縮短期限（月供不變）';

  @override
  String get modeReducePayment => '減少月供（期限不變）';

  @override
  String get interestSavedLabel => '節省利息';

  @override
  String get newMonthlyPaymentLabel => '新月供';

  @override
  String get newTermLabel => '新剩餘期限';

  @override
  String get monthsSavedLabel => '縮短期數';

  @override
  String get originalInterestLabel => '原剩餘利息';

  @override
  String get chartLabelOriginal => '原利息';

  @override
  String get chartLabelReduceTerm => '縮期限';

  @override
  String get chartLabelReducePayment => '減月供';

  @override
  String get newInterestLabel => '新利息';

  @override
  String get compareModesTitle => '兩種模式對比';

  @override
  String get prepayInvalidHint => '請輸入有效的已還期數與提前還款金額';

  @override
  String get paidOffTip => '提前還款已覆蓋全部剩餘本金，貸款結清';

  @override
  String get affordabilityTitle => '還款能力評估';

  @override
  String get incomeLabel => '月收入（元）';

  @override
  String get existingDebtLabel => '既有月供負債（元）';

  @override
  String get newPaymentLabel => '擬新增月供（元）';

  @override
  String get assessButton => '開始評估';

  @override
  String get dsrLabel => '負債率 DSR';

  @override
  String get ratingLabel => '還款壓力評級';

  @override
  String get suggestedPaymentLabel => '建議最高月供';

  @override
  String get suggestedLoanLabel => '建議最高可貸額度';

  @override
  String get ratingExcellent => '極優';

  @override
  String get ratingGood => '良好';

  @override
  String get ratingModerate => '適中';

  @override
  String get ratingCaution => '偏高';

  @override
  String get ratingDanger => '過高';

  @override
  String get adviceExcellent => '還款壓力極小，財務狀況非常健康';

  @override
  String get adviceGood => '還款壓力適中，財務狀況良好';

  @override
  String get adviceModerate => '還款壓力中等，建議預留流動資金';

  @override
  String get adviceCaution => '還款壓力偏高，需謹慎規劃其他開支';

  @override
  String get adviceDanger => '還款壓力過大，建議降低貸款額度';

  @override
  String get dsrHint => 'DSR =（月供 + 既有負債）÷ 月收入，銀行一般要求 ≤ 50%';

  @override
  String get rateToolTitle => '利率換算';

  @override
  String get lprLabel => 'LPR 基準利率（%）';

  @override
  String get bpLabel => '基點（BP）';

  @override
  String get resultRateLabel => '實際利率';

  @override
  String get fixedVsFloatingTitle => '固定 vs 浮動總利息對比';

  @override
  String get fixedRateLabel => '固定利率（%）';

  @override
  String get floatingRateLabel => '浮動利率（%）';

  @override
  String get compareResultLabel => '利息差（固定 − 浮動）';

  @override
  String get monthlyDiffLabel => '月供差（浮動 − 固定）';

  @override
  String get cityPresetTitle => '各城市商貸利率參考（首套 / 二套）';

  @override
  String get beijingRateNote =>
      '北京：商貸自2025-12-24起由銀行逐筆定價，不再區分首套/二套利率；2025-05-08起新發放的5年以上公積金貸款，首套2.6%、二套3.075%。來源：北京市住建委等部門、北京住房公積金管理中心。';

  @override
  String get cityBeijing => '北京';

  @override
  String get cityShanghai => '上海';

  @override
  String get cityGuangzhou => '廣州';

  @override
  String get cityShenzhen => '深圳';

  @override
  String get cityChengdu => '成都';

  @override
  String get cityChongqing => '重慶';

  @override
  String get fundRateRef => '公積金利率參考';

  @override
  String get bpHint => '1 BP = 0.01%，如 LPR 3.5% − 60BP = 2.9%';

  @override
  String get plansTitle => '方案庫';

  @override
  String get emptyPlans => '還沒有儲存的方案，去計算機儲存一個吧';

  @override
  String get compareButton => '對比';

  @override
  String get compareNeedTwo => '請選擇 2-3 個方案進行對比';

  @override
  String get compareTitle => '方案對比';

  @override
  String get planNameColumn => '方案';

  @override
  String get deletePlanTitle => '刪除方案';

  @override
  String get deletePlanBody => '確定刪除該方案嗎？';

  @override
  String get renamePlanTitle => '重新命名方案';

  @override
  String get historySection => '歷史記錄';

  @override
  String get historyEmpty => '暫無歷史記錄';

  @override
  String get clearHistoryButton => '清空歷史';

  @override
  String get historyCleared => '歷史記錄已清空';

  @override
  String get loadPlan => '載入計算機';

  @override
  String get planLoaded => '已載入計算機';

  @override
  String get settingsTitle => '我的';

  @override
  String get appearanceSection => '外觀';

  @override
  String get themeLabel => '主題模式';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get currencyLabel => '貨幣符號';

  @override
  String get languageLabel => '語言';

  @override
  String get langZhCN => '简体中文';

  @override
  String get langZhTW => '繁體中文';

  @override
  String get langEn => 'English';

  @override
  String get dataSection => '資料';

  @override
  String get clearHistory => '清除歷史記錄';

  @override
  String get clearHistoryConfirm => '將刪除全部歷史記錄，是否繼續？';

  @override
  String get aboutSection => '關於';

  @override
  String get aboutButton => '關於智貸計算機';

  @override
  String get privacyButton => '隱私政策';

  @override
  String get disclaimerButton => '免責聲明';

  @override
  String get versionLabel => '版本 1.0.0';

  @override
  String get aboutContent =>
      '智貸計算機（SmartLoan Calc）是一款極簡、離線優先的個人貸款規劃工具。\n\n支援等額本息、等額本金、先息後本三種還款方式，覆蓋房貸、車貸、消費貸場景，並提供組合貸款、提前還款模擬、還款能力評估與 LPR 利率換算等實用工具。\n\n核心理念：輸入即算、大數字優先、深色模式、資料不出機。';

  @override
  String get privacyContent =>
      '隱私政策要點\n\n1. 不收集：本應用不收集任何個人資訊、裝置資訊或使用資料。\n2. 不上傳：無任何網路請求，全部計算在本機完成。\n3. 本地儲存：您儲存的方案與歷史記錄僅儲存於本機應用沙盒（Hive 資料庫），解除安裝應用即被刪除。\n4. 無帳號：無需註冊登入，無第三方 SDK 埋點。\n5. 匯出檔案：還款計劃 PDF / CSV 僅在您主動分享時經系統分享面板發出，內容由您完全控制。\n\n如未來版本引入任何網路功能，我們將更新本政策並在應用內顯著提示。';

  @override
  String get disclaimerContent =>
      '免責聲明\n\n本應用提供的所有計算結果（包括但不限於月供、總利息、還款計劃表、提前還款測算、可貸額度評估、利率換算）均為基於公開金融公式的理論測算，僅供參考，不構成任何貸款建議、投資建議或金融諮詢意見。\n\n實際貸款的可貸額度、利率、費用、審批結果以銀行及持牌金融機構的最終審批為準。城市房貸與公積金政策資料為靜態快照，可能與最新政策存在差異，請以當地住房公積金管理中心及銀行公佈為準。\n\n因使用本應用計算結果作出的任何決策，風險由使用者自行承擔。';

  @override
  String get offlineBadge => '純離線 · 資料僅存本機';
}
