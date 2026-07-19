// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SmartLoan Calc';

  @override
  String get tabCalculator => 'Calculator';

  @override
  String get tabPlans => 'Plans';

  @override
  String get tabSettings => 'Me';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get rename => 'Rename';

  @override
  String get search => 'Search';

  @override
  String get clear => 'Clear';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get disclaimerBanner =>
      'Results are for reference only; final approval is subject to your bank';

  @override
  String get disclaimerDialogTitle => 'Disclaimer';

  @override
  String get disclaimerDialogBody =>
      'Welcome to SmartLoan Calc.\n\nAll results (including but not limited to monthly payments, total interest, repayment schedules and affordability estimates) are theoretical estimates based on public formulas. They are for reference only and do not constitute loan advice or financial consulting. Actual approval, rates and fees are subject to your bank or financial institution.\n\nThis app runs fully offline. All your data stays on this device and is never uploaded.\n\nBy continuing, you acknowledge that you have read and agreed to this disclaimer.';

  @override
  String get disclaimerAgree => 'I have read and agree';

  @override
  String monthsCount(int count) {
    return '$count mo';
  }

  @override
  String yearsCount(int count) {
    return '$count yr';
  }

  @override
  String get categoryMortgage => 'Mortgage';

  @override
  String get categoryCar => 'Car Loan';

  @override
  String get categoryConsumer => 'Consumer';

  @override
  String get methodEqualPayment => 'Equal Payment';

  @override
  String get methodEqualPrincipal => 'Equal Principal';

  @override
  String get methodInterestFirst => 'Interest First';

  @override
  String get calculatorTitle => 'Loan Calculator';

  @override
  String get loanAmountLabel => 'Loan Amount';

  @override
  String get unitWan => '×10k';

  @override
  String get unitYear => 'yr';

  @override
  String get unitPercent => '%';

  @override
  String get termLabel => 'Term';

  @override
  String get rateLabel => 'Annual Rate';

  @override
  String get combinedSwitch => 'Combined loan (Housing Fund + Commercial)';

  @override
  String get fundAmountLabel => 'Housing Fund Amount';

  @override
  String get fundRateLabel => 'Housing Fund Rate';

  @override
  String get commercialAmountLabel => 'Commercial Amount';

  @override
  String get commercialRateLabel => 'Commercial Rate';

  @override
  String get resultMonthly => 'Monthly';

  @override
  String get resultFirstMonth => 'First Month';

  @override
  String get resultLastMonth => 'Last Month';

  @override
  String get resultMonthlyInterest => 'Monthly Interest';

  @override
  String get resultTotalInterest => 'Total Interest';

  @override
  String get resultTotalPayment => 'Total Payment';

  @override
  String get resultFundPart => 'Housing Fund';

  @override
  String get resultCommercialPart => 'Commercial';

  @override
  String get viewSchedule => 'View Schedule';

  @override
  String get savePlan => 'Save Plan';

  @override
  String get planNameHint => 'Plan name';

  @override
  String get planSaved => 'Plan saved';

  @override
  String get trendChartTitle => 'Repayment Trend';

  @override
  String get legendPrincipal => 'Principal';

  @override
  String get legendInterest => 'Interest';

  @override
  String get pieChartTitle => 'Principal / Interest';

  @override
  String get totalPrincipalLabel => 'Loan Principal';

  @override
  String get toolsTitle => 'Tools';

  @override
  String get prepaymentTool => 'Prepayment';

  @override
  String get affordabilityTool => 'Affordability';

  @override
  String get rateTool => 'Rate Converter';

  @override
  String get invalidInput => 'Invalid input, please check';

  @override
  String get scheduleTitle => 'Repayment Schedule';

  @override
  String get colMonth => 'No.';

  @override
  String get colPayment => 'Payment';

  @override
  String get colPrincipal => 'Principal';

  @override
  String get colInterest => 'Interest';

  @override
  String get colRemaining => 'Remaining';

  @override
  String get jumpHint => 'Jump to month';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get scheduleEmpty => 'No schedule';

  @override
  String get prepaymentTitle => 'Prepayment Simulator';

  @override
  String get monthsPaidLabel => 'Months paid';

  @override
  String get prepayAmountLabel => 'Prepay amount';

  @override
  String get simulate => 'Simulate';

  @override
  String get remainingNow => 'Current remaining principal';

  @override
  String get modeReduceTerm => 'Shorter term (same payment)';

  @override
  String get modeReducePayment => 'Lower payment (same term)';

  @override
  String get interestSavedLabel => 'Interest saved';

  @override
  String get newMonthlyPaymentLabel => 'New monthly';

  @override
  String get newTermLabel => 'New remaining term';

  @override
  String get monthsSavedLabel => 'Months saved';

  @override
  String get originalInterestLabel => 'Original remaining interest';

  @override
  String get chartLabelOriginal => 'Original';

  @override
  String get chartLabelReduceTerm => 'Term↓';

  @override
  String get chartLabelReducePayment => 'Pmt↓';

  @override
  String get newInterestLabel => 'New interest';

  @override
  String get compareModesTitle => 'Mode comparison';

  @override
  String get prepayInvalidHint =>
      'Please enter valid months paid and prepay amount';

  @override
  String get paidOffTip =>
      'Prepayment covers all remaining principal. Loan paid off.';

  @override
  String get affordabilityTitle => 'Affordability (DSR)';

  @override
  String get incomeLabel => 'Monthly income';

  @override
  String get existingDebtLabel => 'Existing monthly debt';

  @override
  String get newPaymentLabel => 'New monthly payment';

  @override
  String get assessButton => 'Assess';

  @override
  String get dsrLabel => 'Debt Service Ratio';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get suggestedPaymentLabel => 'Suggested max monthly';

  @override
  String get suggestedLoanLabel => 'Suggested max loan';

  @override
  String get ratingExcellent => 'Excellent';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingModerate => 'Moderate';

  @override
  String get ratingCaution => 'High';

  @override
  String get ratingDanger => 'Too High';

  @override
  String get adviceExcellent =>
      'Minimal repayment pressure. Very healthy finances.';

  @override
  String get adviceGood => 'Comfortable repayment pressure. Healthy finances.';

  @override
  String get adviceModerate => 'Moderate pressure. Keep liquid reserves.';

  @override
  String get adviceCaution =>
      'Pressure is high. Plan other spending carefully.';

  @override
  String get adviceDanger => 'Pressure is too high. Consider a smaller loan.';

  @override
  String get dsrHint =>
      'DSR = (payment + existing debt) ÷ income. Banks usually require ≤ 50%';

  @override
  String get rateToolTitle => 'Rate Converter';

  @override
  String get lprLabel => 'LPR base rate (%)';

  @override
  String get bpLabel => 'Basis points (BP)';

  @override
  String get resultRateLabel => 'Actual rate';

  @override
  String get fixedVsFloatingTitle => 'Fixed vs Floating total interest';

  @override
  String get fixedRateLabel => 'Fixed rate (%)';

  @override
  String get floatingRateLabel => 'Floating rate (%)';

  @override
  String get compareResultLabel => 'Interest diff (fixed − floating)';

  @override
  String get monthlyDiffLabel => 'Monthly diff (floating − fixed)';

  @override
  String get cityPresetTitle =>
      'City commercial rate reference (1st / 2nd home)';

  @override
  String get cityBeijing => 'Beijing';

  @override
  String get cityShanghai => 'Shanghai';

  @override
  String get cityGuangzhou => 'Guangzhou';

  @override
  String get cityShenzhen => 'Shenzhen';

  @override
  String get cityChengdu => 'Chengdu';

  @override
  String get cityChongqing => 'Chongqing';

  @override
  String get fundRateRef => 'Housing fund rate reference';

  @override
  String get bpHint => '1 BP = 0.01%, e.g. LPR 3.5% − 60BP = 2.9%';

  @override
  String get plansTitle => 'Saved Plans';

  @override
  String get emptyPlans => 'No saved plans yet. Save one from the calculator.';

  @override
  String get compareButton => 'Compare';

  @override
  String get compareNeedTwo => 'Select 2-3 plans to compare';

  @override
  String get compareTitle => 'Plan Comparison';

  @override
  String get planNameColumn => 'Plan';

  @override
  String get deletePlanTitle => 'Delete plan';

  @override
  String get deletePlanBody => 'Delete this plan?';

  @override
  String get renamePlanTitle => 'Rename plan';

  @override
  String get historySection => 'History';

  @override
  String get historyEmpty => 'No history yet';

  @override
  String get clearHistoryButton => 'Clear history';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get loadPlan => 'Load';

  @override
  String get planLoaded => 'Loaded into calculator';

  @override
  String get settingsTitle => 'Me';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get languageLabel => 'Language';

  @override
  String get langZhCN => '简体中文';

  @override
  String get langZhTW => '繁體中文';

  @override
  String get langEn => 'English';

  @override
  String get dataSection => 'Data';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get clearHistoryConfirm => 'All history will be deleted. Continue?';

  @override
  String get aboutSection => 'About';

  @override
  String get aboutButton => 'About SmartLoan Calc';

  @override
  String get privacyButton => 'Privacy Policy';

  @override
  String get disclaimerButton => 'Disclaimer';

  @override
  String get versionLabel => 'Version 1.0.0';

  @override
  String get aboutContent =>
      'SmartLoan Calc is a minimalist, offline-first personal loan planning tool.\n\nIt supports Equal Payment, Equal Principal and Interest-First repayment methods across mortgage, car and consumer loan scenarios, plus combined loans, prepayment simulation, affordability assessment and LPR rate conversion.\n\nCore principles: instant results, big numbers first, dark mode, data never leaves your device.';

  @override
  String get privacyContent =>
      'Privacy Policy Highlights\n\n1. No collection: this app collects no personal, device or usage data.\n2. No upload: zero network requests; all computation happens on-device.\n3. Local storage: saved plans and history live only in the on-device app sandbox (Hive database) and are removed when the app is uninstalled.\n4. No account: no sign-up, no third-party analytics SDKs.\n5. Exported files: schedule PDF / CSV files leave the device only through the system share sheet when you explicitly share them.\n\nIf any network feature is introduced in the future, this policy will be updated with prominent in-app notice.';

  @override
  String get disclaimerContent =>
      'Disclaimer\n\nAll results provided by this app (including but not limited to monthly payments, total interest, repayment schedules, prepayment estimates, affordability assessment and rate conversion) are theoretical estimates based on public financial formulas. They are for reference only and do not constitute loan, investment or financial advice.\n\nActual loan amounts, rates, fees and approvals are subject to the final decision of banks and licensed financial institutions. City mortgage and housing fund policy data are static snapshots and may differ from the latest policies; please refer to your local housing fund center and banks.\n\nDecisions made using results from this app are at your own risk.';

  @override
  String get offlineBadge => 'Offline only · Data stays on device';
}
