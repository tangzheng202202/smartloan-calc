import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'智贷计算器'**
  String get appTitle;

  /// No description provided for @tabCalculator.
  ///
  /// In zh, this message translates to:
  /// **'计算器'**
  String get tabCalculator;

  /// No description provided for @tabPlans.
  ///
  /// In zh, this message translates to:
  /// **'方案库'**
  String get tabPlans;

  /// No description provided for @tabSettings.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get tabSettings;

  /// No description provided for @ok.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @rename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename;

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get clear;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @disclaimerBanner.
  ///
  /// In zh, this message translates to:
  /// **'计算结果仅供参考，以银行实际审批为准'**
  String get disclaimerBanner;

  /// No description provided for @disclaimerDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'免责声明'**
  String get disclaimerDialogTitle;

  /// No description provided for @disclaimerDialogBody.
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用智贷计算器。\n\n本应用提供的所有计算结果（包括但不限于月供、总利息、还款计划、可贷额度评估）均为基于公开公式的理论测算，仅供参考，不构成任何贷款建议或金融咨询意见。实际贷款审批结果、利率、费用以银行及金融机构的最终审批为准。\n\n本应用纯离线运行，您的全部数据仅存储于本机，不会上传至任何服务器。\n\n继续使用即表示您已阅读并同意本声明。'**
  String get disclaimerDialogBody;

  /// No description provided for @disclaimerAgree.
  ///
  /// In zh, this message translates to:
  /// **'我已阅读并同意'**
  String get disclaimerAgree;

  /// No description provided for @monthsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 期'**
  String monthsCount(int count);

  /// No description provided for @yearsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 年'**
  String yearsCount(int count);

  /// No description provided for @categoryMortgage.
  ///
  /// In zh, this message translates to:
  /// **'房贷'**
  String get categoryMortgage;

  /// No description provided for @categoryCar.
  ///
  /// In zh, this message translates to:
  /// **'车贷'**
  String get categoryCar;

  /// No description provided for @categoryConsumer.
  ///
  /// In zh, this message translates to:
  /// **'消费贷'**
  String get categoryConsumer;

  /// No description provided for @methodEqualPayment.
  ///
  /// In zh, this message translates to:
  /// **'等额本息'**
  String get methodEqualPayment;

  /// No description provided for @methodEqualPrincipal.
  ///
  /// In zh, this message translates to:
  /// **'等额本金'**
  String get methodEqualPrincipal;

  /// No description provided for @methodInterestFirst.
  ///
  /// In zh, this message translates to:
  /// **'先息后本'**
  String get methodInterestFirst;

  /// No description provided for @calculatorTitle.
  ///
  /// In zh, this message translates to:
  /// **'贷款计算器'**
  String get calculatorTitle;

  /// No description provided for @loanAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'贷款金额'**
  String get loanAmountLabel;

  /// No description provided for @houseTotalPriceLabel.
  ///
  /// In zh, this message translates to:
  /// **'房屋总价'**
  String get houseTotalPriceLabel;

  /// No description provided for @carTotalPriceLabel.
  ///
  /// In zh, this message translates to:
  /// **'车辆总价'**
  String get carTotalPriceLabel;

  /// No description provided for @downPaymentRatioLabel.
  ///
  /// In zh, this message translates to:
  /// **'首付比例'**
  String get downPaymentRatioLabel;

  /// No description provided for @downPaymentAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'首付金额'**
  String get downPaymentAmountLabel;

  /// No description provided for @costSummaryMortgage.
  ///
  /// In zh, this message translates to:
  /// **'首付 {down} · 购房总成本 {cost}'**
  String costSummaryMortgage(Object cost, Object down);

  /// No description provided for @costSummaryCar.
  ///
  /// In zh, this message translates to:
  /// **'首付 {down} · 购车总成本 {cost}'**
  String costSummaryCar(Object cost, Object down);

  /// No description provided for @zeroLoanHint.
  ///
  /// In zh, this message translates to:
  /// **'首付已覆盖总价，无需贷款'**
  String get zeroLoanHint;

  /// No description provided for @unitWan.
  ///
  /// In zh, this message translates to:
  /// **'万元'**
  String get unitWan;

  /// No description provided for @unitYear.
  ///
  /// In zh, this message translates to:
  /// **'年'**
  String get unitYear;

  /// No description provided for @unitPercent.
  ///
  /// In zh, this message translates to:
  /// **'%'**
  String get unitPercent;

  /// No description provided for @termLabel.
  ///
  /// In zh, this message translates to:
  /// **'贷款期限'**
  String get termLabel;

  /// No description provided for @rateLabel.
  ///
  /// In zh, this message translates to:
  /// **'年利率'**
  String get rateLabel;

  /// No description provided for @combinedSwitch.
  ///
  /// In zh, this message translates to:
  /// **'组合贷款（公积金 + 商贷）'**
  String get combinedSwitch;

  /// No description provided for @fundAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'公积金贷款金额'**
  String get fundAmountLabel;

  /// No description provided for @fundRateLabel.
  ///
  /// In zh, this message translates to:
  /// **'公积金利率'**
  String get fundRateLabel;

  /// No description provided for @commercialAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'商贷金额'**
  String get commercialAmountLabel;

  /// No description provided for @commercialRateLabel.
  ///
  /// In zh, this message translates to:
  /// **'商贷利率'**
  String get commercialRateLabel;

  /// No description provided for @resultMonthly.
  ///
  /// In zh, this message translates to:
  /// **'月供'**
  String get resultMonthly;

  /// No description provided for @resultFirstMonth.
  ///
  /// In zh, this message translates to:
  /// **'首月月供'**
  String get resultFirstMonth;

  /// No description provided for @resultLastMonth.
  ///
  /// In zh, this message translates to:
  /// **'末月月供'**
  String get resultLastMonth;

  /// No description provided for @resultMonthlyInterest.
  ///
  /// In zh, this message translates to:
  /// **'每月利息'**
  String get resultMonthlyInterest;

  /// No description provided for @resultTotalInterest.
  ///
  /// In zh, this message translates to:
  /// **'总利息'**
  String get resultTotalInterest;

  /// No description provided for @resultTotalPayment.
  ///
  /// In zh, this message translates to:
  /// **'总还款'**
  String get resultTotalPayment;

  /// No description provided for @resultFundPart.
  ///
  /// In zh, this message translates to:
  /// **'公积金部分'**
  String get resultFundPart;

  /// No description provided for @resultCommercialPart.
  ///
  /// In zh, this message translates to:
  /// **'商贷部分'**
  String get resultCommercialPart;

  /// No description provided for @viewSchedule.
  ///
  /// In zh, this message translates to:
  /// **'查看还款计划表'**
  String get viewSchedule;

  /// No description provided for @savePlan.
  ///
  /// In zh, this message translates to:
  /// **'保存方案'**
  String get savePlan;

  /// No description provided for @planNameHint.
  ///
  /// In zh, this message translates to:
  /// **'方案名称'**
  String get planNameHint;

  /// No description provided for @planSaved.
  ///
  /// In zh, this message translates to:
  /// **'方案已保存'**
  String get planSaved;

  /// No description provided for @trendChartTitle.
  ///
  /// In zh, this message translates to:
  /// **'还款趋势'**
  String get trendChartTitle;

  /// No description provided for @legendPrincipal.
  ///
  /// In zh, this message translates to:
  /// **'本金'**
  String get legendPrincipal;

  /// No description provided for @legendInterest.
  ///
  /// In zh, this message translates to:
  /// **'利息'**
  String get legendInterest;

  /// No description provided for @pieChartTitle.
  ///
  /// In zh, this message translates to:
  /// **'本金 / 利息占比'**
  String get pieChartTitle;

  /// No description provided for @totalPrincipalLabel.
  ///
  /// In zh, this message translates to:
  /// **'贷款本金'**
  String get totalPrincipalLabel;

  /// No description provided for @toolsTitle.
  ///
  /// In zh, this message translates to:
  /// **'贷款工具'**
  String get toolsTitle;

  /// No description provided for @prepaymentTool.
  ///
  /// In zh, this message translates to:
  /// **'提前还款模拟'**
  String get prepaymentTool;

  /// No description provided for @affordabilityTool.
  ///
  /// In zh, this message translates to:
  /// **'还款能力评估'**
  String get affordabilityTool;

  /// No description provided for @rateTool.
  ///
  /// In zh, this message translates to:
  /// **'利率换算'**
  String get rateTool;

  /// No description provided for @invalidInput.
  ///
  /// In zh, this message translates to:
  /// **'输入参数无效，请检查'**
  String get invalidInput;

  /// No description provided for @scheduleTitle.
  ///
  /// In zh, this message translates to:
  /// **'还款计划表'**
  String get scheduleTitle;

  /// No description provided for @colMonth.
  ///
  /// In zh, this message translates to:
  /// **'期数'**
  String get colMonth;

  /// No description provided for @colPayment.
  ///
  /// In zh, this message translates to:
  /// **'月供'**
  String get colPayment;

  /// No description provided for @colPrincipal.
  ///
  /// In zh, this message translates to:
  /// **'本金'**
  String get colPrincipal;

  /// No description provided for @colInterest.
  ///
  /// In zh, this message translates to:
  /// **'利息'**
  String get colInterest;

  /// No description provided for @colRemaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余本金'**
  String get colRemaining;

  /// No description provided for @jumpHint.
  ///
  /// In zh, this message translates to:
  /// **'输入期数跳转'**
  String get jumpHint;

  /// No description provided for @exportPdf.
  ///
  /// In zh, this message translates to:
  /// **'导出 PDF'**
  String get exportPdf;

  /// No description provided for @exportCsv.
  ///
  /// In zh, this message translates to:
  /// **'导出 CSV'**
  String get exportCsv;

  /// No description provided for @scheduleEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无还款计划'**
  String get scheduleEmpty;

  /// No description provided for @prepaymentTitle.
  ///
  /// In zh, this message translates to:
  /// **'提前还款模拟'**
  String get prepaymentTitle;

  /// No description provided for @monthsPaidLabel.
  ///
  /// In zh, this message translates to:
  /// **'已还期数'**
  String get monthsPaidLabel;

  /// No description provided for @prepayAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'提前还款金额（元）'**
  String get prepayAmountLabel;

  /// No description provided for @simulate.
  ///
  /// In zh, this message translates to:
  /// **'开始模拟'**
  String get simulate;

  /// No description provided for @remainingNow.
  ///
  /// In zh, this message translates to:
  /// **'当前剩余本金'**
  String get remainingNow;

  /// No description provided for @modeReduceTerm.
  ///
  /// In zh, this message translates to:
  /// **'缩短期限（月供不变）'**
  String get modeReduceTerm;

  /// No description provided for @modeReducePayment.
  ///
  /// In zh, this message translates to:
  /// **'减少月供（期限不变）'**
  String get modeReducePayment;

  /// No description provided for @interestSavedLabel.
  ///
  /// In zh, this message translates to:
  /// **'节省利息'**
  String get interestSavedLabel;

  /// No description provided for @newMonthlyPaymentLabel.
  ///
  /// In zh, this message translates to:
  /// **'新月供'**
  String get newMonthlyPaymentLabel;

  /// No description provided for @newTermLabel.
  ///
  /// In zh, this message translates to:
  /// **'新剩余期限'**
  String get newTermLabel;

  /// No description provided for @monthsSavedLabel.
  ///
  /// In zh, this message translates to:
  /// **'缩短期数'**
  String get monthsSavedLabel;

  /// No description provided for @originalInterestLabel.
  ///
  /// In zh, this message translates to:
  /// **'原剩余利息'**
  String get originalInterestLabel;

  /// No description provided for @chartLabelOriginal.
  ///
  /// In zh, this message translates to:
  /// **'原利息'**
  String get chartLabelOriginal;

  /// No description provided for @chartLabelReduceTerm.
  ///
  /// In zh, this message translates to:
  /// **'缩期限'**
  String get chartLabelReduceTerm;

  /// No description provided for @chartLabelReducePayment.
  ///
  /// In zh, this message translates to:
  /// **'减月供'**
  String get chartLabelReducePayment;

  /// No description provided for @newInterestLabel.
  ///
  /// In zh, this message translates to:
  /// **'新利息'**
  String get newInterestLabel;

  /// No description provided for @compareModesTitle.
  ///
  /// In zh, this message translates to:
  /// **'两种模式对比'**
  String get compareModesTitle;

  /// No description provided for @prepayInvalidHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的已还期数与提前还款金额'**
  String get prepayInvalidHint;

  /// No description provided for @paidOffTip.
  ///
  /// In zh, this message translates to:
  /// **'提前还款已覆盖全部剩余本金，贷款结清'**
  String get paidOffTip;

  /// No description provided for @affordabilityTitle.
  ///
  /// In zh, this message translates to:
  /// **'还款能力评估'**
  String get affordabilityTitle;

  /// No description provided for @incomeLabel.
  ///
  /// In zh, this message translates to:
  /// **'月收入（元）'**
  String get incomeLabel;

  /// No description provided for @existingDebtLabel.
  ///
  /// In zh, this message translates to:
  /// **'既有月供负债（元）'**
  String get existingDebtLabel;

  /// No description provided for @newPaymentLabel.
  ///
  /// In zh, this message translates to:
  /// **'拟新增月供（元）'**
  String get newPaymentLabel;

  /// No description provided for @assessButton.
  ///
  /// In zh, this message translates to:
  /// **'开始评估'**
  String get assessButton;

  /// No description provided for @dsrLabel.
  ///
  /// In zh, this message translates to:
  /// **'负债率 DSR'**
  String get dsrLabel;

  /// No description provided for @ratingLabel.
  ///
  /// In zh, this message translates to:
  /// **'还款压力评级'**
  String get ratingLabel;

  /// No description provided for @suggestedPaymentLabel.
  ///
  /// In zh, this message translates to:
  /// **'建议最高月供'**
  String get suggestedPaymentLabel;

  /// No description provided for @suggestedLoanLabel.
  ///
  /// In zh, this message translates to:
  /// **'建议最高可贷额度'**
  String get suggestedLoanLabel;

  /// No description provided for @ratingExcellent.
  ///
  /// In zh, this message translates to:
  /// **'极优'**
  String get ratingExcellent;

  /// No description provided for @ratingGood.
  ///
  /// In zh, this message translates to:
  /// **'良好'**
  String get ratingGood;

  /// No description provided for @ratingModerate.
  ///
  /// In zh, this message translates to:
  /// **'适中'**
  String get ratingModerate;

  /// No description provided for @ratingCaution.
  ///
  /// In zh, this message translates to:
  /// **'偏高'**
  String get ratingCaution;

  /// No description provided for @ratingDanger.
  ///
  /// In zh, this message translates to:
  /// **'过高'**
  String get ratingDanger;

  /// No description provided for @adviceExcellent.
  ///
  /// In zh, this message translates to:
  /// **'还款压力极小，财务状况非常健康'**
  String get adviceExcellent;

  /// No description provided for @adviceGood.
  ///
  /// In zh, this message translates to:
  /// **'还款压力适中，财务状况良好'**
  String get adviceGood;

  /// No description provided for @adviceModerate.
  ///
  /// In zh, this message translates to:
  /// **'还款压力中等，建议预留流动资金'**
  String get adviceModerate;

  /// No description provided for @adviceCaution.
  ///
  /// In zh, this message translates to:
  /// **'还款压力偏高，需谨慎规划其他开支'**
  String get adviceCaution;

  /// No description provided for @adviceDanger.
  ///
  /// In zh, this message translates to:
  /// **'还款压力过大，建议降低贷款额度'**
  String get adviceDanger;

  /// No description provided for @dsrHint.
  ///
  /// In zh, this message translates to:
  /// **'DSR =（月供 + 既有负债）÷ 月收入，银行一般要求 ≤ 50%'**
  String get dsrHint;

  /// No description provided for @rateToolTitle.
  ///
  /// In zh, this message translates to:
  /// **'利率换算'**
  String get rateToolTitle;

  /// No description provided for @lprLabel.
  ///
  /// In zh, this message translates to:
  /// **'LPR 基准利率（%）'**
  String get lprLabel;

  /// No description provided for @bpLabel.
  ///
  /// In zh, this message translates to:
  /// **'基点（BP）'**
  String get bpLabel;

  /// No description provided for @resultRateLabel.
  ///
  /// In zh, this message translates to:
  /// **'实际利率'**
  String get resultRateLabel;

  /// No description provided for @fixedVsFloatingTitle.
  ///
  /// In zh, this message translates to:
  /// **'固定 vs 浮动总利息对比'**
  String get fixedVsFloatingTitle;

  /// No description provided for @fixedRateLabel.
  ///
  /// In zh, this message translates to:
  /// **'固定利率（%）'**
  String get fixedRateLabel;

  /// No description provided for @floatingRateLabel.
  ///
  /// In zh, this message translates to:
  /// **'浮动利率（%）'**
  String get floatingRateLabel;

  /// No description provided for @compareResultLabel.
  ///
  /// In zh, this message translates to:
  /// **'利息差（固定 − 浮动）'**
  String get compareResultLabel;

  /// No description provided for @monthlyDiffLabel.
  ///
  /// In zh, this message translates to:
  /// **'月供差（浮动 − 固定）'**
  String get monthlyDiffLabel;

  /// No description provided for @cityPresetTitle.
  ///
  /// In zh, this message translates to:
  /// **'各城市商贷利率参考（首套 / 二套）'**
  String get cityPresetTitle;

  /// No description provided for @beijingRateNote.
  ///
  /// In zh, this message translates to:
  /// **'北京：商贷自2025-12-24起由银行逐笔定价，不再区分首套/二套利率；2025-05-08起新发放的5年以上公积金贷款，首套2.6%、二套3.075%。来源：北京市住建委等部门、北京住房公积金管理中心。'**
  String get beijingRateNote;

  /// No description provided for @cityBeijing.
  ///
  /// In zh, this message translates to:
  /// **'北京'**
  String get cityBeijing;

  /// No description provided for @cityShanghai.
  ///
  /// In zh, this message translates to:
  /// **'上海'**
  String get cityShanghai;

  /// No description provided for @cityGuangzhou.
  ///
  /// In zh, this message translates to:
  /// **'广州'**
  String get cityGuangzhou;

  /// No description provided for @cityShenzhen.
  ///
  /// In zh, this message translates to:
  /// **'深圳'**
  String get cityShenzhen;

  /// No description provided for @cityChengdu.
  ///
  /// In zh, this message translates to:
  /// **'成都'**
  String get cityChengdu;

  /// No description provided for @cityChongqing.
  ///
  /// In zh, this message translates to:
  /// **'重庆'**
  String get cityChongqing;

  /// No description provided for @fundRateRef.
  ///
  /// In zh, this message translates to:
  /// **'公积金利率参考'**
  String get fundRateRef;

  /// No description provided for @bpHint.
  ///
  /// In zh, this message translates to:
  /// **'1 BP = 0.01%，如 LPR 3.5% − 60BP = 2.9%'**
  String get bpHint;

  /// No description provided for @plansTitle.
  ///
  /// In zh, this message translates to:
  /// **'方案库'**
  String get plansTitle;

  /// No description provided for @emptyPlans.
  ///
  /// In zh, this message translates to:
  /// **'还没有保存的方案，去计算器保存一个吧'**
  String get emptyPlans;

  /// No description provided for @compareButton.
  ///
  /// In zh, this message translates to:
  /// **'对比'**
  String get compareButton;

  /// No description provided for @compareNeedTwo.
  ///
  /// In zh, this message translates to:
  /// **'请选择 2-3 个方案进行对比'**
  String get compareNeedTwo;

  /// No description provided for @compareTitle.
  ///
  /// In zh, this message translates to:
  /// **'方案对比'**
  String get compareTitle;

  /// No description provided for @planNameColumn.
  ///
  /// In zh, this message translates to:
  /// **'方案'**
  String get planNameColumn;

  /// No description provided for @deletePlanTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除方案'**
  String get deletePlanTitle;

  /// No description provided for @deletePlanBody.
  ///
  /// In zh, this message translates to:
  /// **'确定删除该方案吗？'**
  String get deletePlanBody;

  /// No description provided for @renamePlanTitle.
  ///
  /// In zh, this message translates to:
  /// **'重命名方案'**
  String get renamePlanTitle;

  /// No description provided for @historySection.
  ///
  /// In zh, this message translates to:
  /// **'历史记录'**
  String get historySection;

  /// No description provided for @historyEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无历史记录'**
  String get historyEmpty;

  /// No description provided for @clearHistoryButton.
  ///
  /// In zh, this message translates to:
  /// **'清空历史'**
  String get clearHistoryButton;

  /// No description provided for @historyCleared.
  ///
  /// In zh, this message translates to:
  /// **'历史记录已清空'**
  String get historyCleared;

  /// No description provided for @loadPlan.
  ///
  /// In zh, this message translates to:
  /// **'载入计算器'**
  String get loadPlan;

  /// No description provided for @planLoaded.
  ///
  /// In zh, this message translates to:
  /// **'已载入计算器'**
  String get planLoaded;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get settingsTitle;

  /// No description provided for @appearanceSection.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get appearanceSection;

  /// No description provided for @themeLabel.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @currencyLabel.
  ///
  /// In zh, this message translates to:
  /// **'货币符号'**
  String get currencyLabel;

  /// No description provided for @languageLabel.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get languageLabel;

  /// No description provided for @langZhCN.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get langZhCN;

  /// No description provided for @langZhTW.
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get langZhTW;

  /// No description provided for @langEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @dataSection.
  ///
  /// In zh, this message translates to:
  /// **'数据'**
  String get dataSection;

  /// No description provided for @clearHistory.
  ///
  /// In zh, this message translates to:
  /// **'清除历史记录'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In zh, this message translates to:
  /// **'将删除全部历史记录，是否继续？'**
  String get clearHistoryConfirm;

  /// No description provided for @aboutSection.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get aboutSection;

  /// No description provided for @aboutButton.
  ///
  /// In zh, this message translates to:
  /// **'关于智贷计算器'**
  String get aboutButton;

  /// No description provided for @privacyButton.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacyButton;

  /// No description provided for @disclaimerButton.
  ///
  /// In zh, this message translates to:
  /// **'免责声明'**
  String get disclaimerButton;

  /// No description provided for @versionLabel.
  ///
  /// In zh, this message translates to:
  /// **'版本 1.0.0'**
  String get versionLabel;

  /// No description provided for @aboutContent.
  ///
  /// In zh, this message translates to:
  /// **'智贷计算器（SmartLoan Calc）是一款极简、离线优先的个人贷款规划工具。\n\n支持等额本息、等额本金、先息后本三种还款方式，覆盖房贷、车贷、消费贷场景，并提供组合贷款、提前还款模拟、还款能力评估与 LPR 利率换算等实用工具。\n\n核心理念：输入即算、大数字优先、深色模式、数据不出机。'**
  String get aboutContent;

  /// No description provided for @privacyContent.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策要点\n\n1. 不收集：本应用不收集任何个人信息、设备信息或使用数据。\n2. 不上传：无任何网络请求，全部计算在本机完成。\n3. 本地存储：您保存的方案与历史记录仅存储于本机应用沙盒（Hive 数据库），卸载应用即被删除。\n4. 无账号：无需注册登录，无第三方 SDK 埋点。\n5. 导出文件：还款计划 PDF / CSV 仅在您主动分享时经系统分享面板发出，内容由您完全控制。\n\n如未来版本引入任何网络功能，我们将更新本政策并在应用内显著提示。'**
  String get privacyContent;

  /// No description provided for @disclaimerContent.
  ///
  /// In zh, this message translates to:
  /// **'免责声明\n\n本应用提供的所有计算结果（包括但不限于月供、总利息、还款计划表、提前还款测算、可贷额度评估、利率换算）均为基于公开金融公式的理论测算，仅供参考，不构成任何贷款建议、投资建议或金融咨询意见。\n\n实际贷款的可贷额度、利率、费用、审批结果以银行及持牌金融机构的最终审批为准。城市房贷与公积金政策数据为静态快照，可能与最新政策存在差异，请以当地住房公积金管理中心及银行公布为准。\n\n因使用本应用计算结果作出的任何决策，风险由使用者自行承担。'**
  String get disclaimerContent;

  /// No description provided for @offlineBadge.
  ///
  /// In zh, this message translates to:
  /// **'纯离线 · 数据仅存本机'**
  String get offlineBadge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
