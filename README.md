# 智贷计算器 SmartLoan Calc

极简、离线优先的个人贷款规划与财务决策辅助工具（iOS + Android）。
由原 SwiftUI 版 `LoanCalculator` 重构为商用级 Flutter 应用，核心计算语义与原实现保持一致。

## 功能清单

| 模块 | 功能 |
|---|---|
| 计算器 | 房贷 / 车贷 / 消费贷；金额（滑块+输入框，万元）、期限（1-35 年）、年利率输入；**输入即算，无"计算"按钮** |
| 还款方式 | 等额本息 / 等额本金 / 先息后本（分段控件切换） |
| 组合贷款 | 房贷下可选：公积金 + 商贷两笔金额、两档利率分别计算，逐月合并还款计划 |
| 结果区 | 超大字体月供 + 总利息 + 总还款；还款趋势折线图；本金/利息占比饼图（fl_chart） |
| 还款计划表 | ListView.builder 虚拟滚动（360+ 期）、按期跳转、导出 **PDF** / **CSV** 分享 |
| 提前还款模拟 | 缩短期限（月供不变）/ 减少月供（期限不变）两种模式对比，节省利息柱状图 |
| 还款能力评估 | DSR 负债率五级评级（极优/良好/适中/偏高/过高）+ 建议最高可贷额度 |
| 利率换算 | LPR ± BP（基点）→ 实际利率；固定 vs 浮动总利息对比；6 城市利率参考表 |
| 方案库 | Hive 本地存储：保存 / 删除 / 重命名 / 多选（2-3 个）并排对比 |
| 历史记录 | 有效计算自动入库（签名去重、上限 100 条）、可搜索、可清空 |
| 我的 | 主题（跟随系统/浅色/深色）、货币符号（¥/$/€）、语言（简中/繁中/English）、清除历史、关于 / 隐私政策 / 免责声明 |
| 合规 | 首启免责声明弹窗（确认后进入）+ 计算器结果区常驻免责声明 |
| 隐私 | **纯离线**：零网络请求，全部数据仅存本机（Hive + shared_preferences） |

## 架构

```
┌────────────────────────────────────────────────────────┐
│                   presentation/                        │
│  pages (计算器/计划表/提前还款/DSR/换算/方案库/我的)   │
│  widgets (输入滑块/结果卡/图表卡/免责声明条)            │
│  cubits  (Calculator / Plans / History / Settings …)   │
├────────────────────────────────────────────────────────┤
│                    domain/                             │
│  entities (LoanInput / LoanResult / ScheduleItem …)    │
│  engine   (LoanEngine / Prepayment / DSR / Rate / 城市)│
│  usecases (Calculate / SimulatePrepayment / AssessDSR) │
├────────────────────────────────────────────────────────┤
│            data/                 services/             │
│  repositories (Plan / History /   storage_service(Hive)│
│   Settings)  datasources(Hive)    export_service(PDF/  │
│                                    CSV 分享)           │
└────────────────────────────────────────────────────────┘
        计算引擎为纯 Dart，零 Flutter 依赖，可独立测试
```

## 目录结构

```
loan_calculator_app/
├── lib/
│   ├── main.dart                  # 入口：初始化 Hive / prefs，注入 Cubit
│   ├── app.dart                   # MaterialApp + 首启免责声明门
│   ├── router.dart                # 声明式路由（onGenerateRoute）
│   ├── core/                      # constants / theme / utils / extensions
│   ├── domain/
│   │   ├── entities/              # 输入、结果、计划条目、DSR、方案等
│   │   ├── engine/                # 计算引擎（纯 Dart）
│   │   └── usecases/              # 用例薄封装
│   ├── data/
│   │   ├── repositories/          # 方案 / 历史 / 设置仓库
│   │   └── datasources/           # HiveDataSource（Hive 唯一访问层）
│   ├── services/                  # Hive 初始化、PDF/CSV 导出
│   ├── l10n/                      # ARB：app_zh / app_zh_TW / app_en
│   └── presentation/
│       ├── cubits/                # flutter_bloc Cubit 状态管理
│       ├── pages/                 # 8 个页面
│       └── widgets/               # 可复用组件
├── test/
│   ├── engine/                    # 引擎测试（期望值经 Python 独立核算）
│   ├── data/                      # 仓库测试（真实 Hive，临时目录）
│   └── widget_test.dart           # App 冒烟测试
├── store_assets/store_metadata.md # 双平台商店元数据
├── assets/fonts/                  # NotoSansSC 子集字体（PDF 中文渲染）
└── l10n.yaml                      # 本地化配置
```

## 构建与运行

```bash
flutter pub get        # 安装依赖
flutter gen-l10n       # 生成多语言代码（pub get 时亦会自动触发）
flutter run            # 运行（需模拟器/真机）
flutter analyze        # 静态分析（当前：No issues found!）
flutter test           # 单元测试（当前：49 个用例全部通过）
dart format lib test   # 代码格式化
```

## Android 构建（Google Play 发布版）

```bash
# 环境（每个新 shell 都要 export）
export PATH="<workspace>/.tools/flutter/bin:$PATH"
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export ANDROID_HOME=<workspace>/.tools/android-sdk
export PATH="$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH"

flutter build apk --debug            # 冒烟（无需签名）
flutter build appbundle --release    # 发布包：build/app/outputs/bundle/release/app-release.aab
```

- **签名**：`android/key.properties`（`storeFile=upload-keystore.jks`，alias `upload`）→ `android/app/build.gradle.kts` 读取并配置 release signingConfig。两文件均在 `.gitignore` 中，**务必离线备份**，丢失只能向 Google 申请重置上传密钥。
- **图标**：`flutter_launcher_icons` 已配置（`pubspec.yaml`），母图在 `assets/icon/`（PIL 生成，脚本 `tools/generate_icons.py`）；改图后重跑 `dart run flutter_launcher_icons`。
- **权限**：release 合并清单无 `INTERNET`（纯离线卖点成立）；debug 包带 INTERNET 属调试模式正常注入。
- **完整上架流程**：见 `store_assets/google_play_release_guide.md`。

## 与原 Swift 版的语义对齐说明

- 月利率 = 年利率 / 12；等额本息 `M = P·r·(1+r)^n/((1+r)^n−1)`，与原公式逐字对齐。
- 还款计划末期剩余本金强制归零；等额本金末期剩余为 0。
- 组合贷逐月合并（月供/本金/利息/剩余本金 = 两部分之和），公积金或商贷为 0 时对应列为 0。
- 城市政策表（6 城市公积金上限/倍数/首付成数/商贷浮动）与 DSR 五级阈值（20/30/40/50%）完整移植。
- **已修复的原始缺陷**：① 原实现 0% 利率时等额本息公式产生 NaN，本版退化为 本金/期数；② 原 `City` 商贷浮动注释（如 "-5BP=3.45%"）与其数值（-0.005 实为 -50BP）不一致，本版严格保留数值行为并在测试与报告中标注。

## 上架准备清单

- [x] 双平台显示名：iOS `CFBundleDisplayName` / Android `android:label` = 智贷计算器
- [x] 商店元数据：`store_assets/store_metadata.md`（名称/副标题/关键词/描述/分级/数据安全表单建议）
- [x] 免责声明：首启弹窗 + 结果区常驻 + 独立页面
- [x] 隐私政策：应用内页面 + 商店要点文案（不收集/不上传/本地存储）
- [x] 应用图标：`flutter_launcher_icons` 已生成 Android（adaptive + legacy）与 iOS 全套；母图 `assets/icon/`
- [ ] 启动画面品牌图（可选）
- [x] Android 签名：`android/app/upload-keystore.jks` + `android/key.properties`（已入 .gitignore，需离线备份）；iOS 证书与描述文件待办
- [x] Android 截图：`screenshots/` 8 张（iOS 模拟器巡游截图，Play 可复用）
- [ ] 隐私政策 URL 部署并在 App Store Connect / Play Console 填写（托管方案见 `store_assets/google_play_release_guide.md` 第 7 节）
- [x] `flutter build appbundle` 已产出 `build/app/outputs/bundle/release/app-release.aab`（61.0 MB，三 ABI）；`flutter build ipa` 待办
