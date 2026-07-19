# 商店截图套装（screenshots_store）

> 生成日期：2026-07-19 ｜ 应用版本：1.0.0+1
> 默认参数：100 万元 / 3.40% / 30 年 / 等额本息（月供 ¥4,435），全部画面数字一致。

## 目录与规格

```
screenshots_store/
├── iphone6.9/          # iPhone 17 Pro Max 模拟器原生截图
│   ├── light/  01..05.png（1320×2868）+ 01..05_caption.png（同尺寸，带文案带）
│   └── dark/   同上
├── ipad13/             # iPad Pro 13-inch (M5) 模拟器原生截图
│   ├── light/  01..05.png（2064×2752）+ caption 版
│   └── dark/   同上
└── android/            # 由 iPhone 原图派生（见下方来源说明）
    ├── light/  01..05.png（1080×2160，严格 2:1）+ caption 版
    └── dark/   同上
```

## 画面清单（每套 5 张）

| 文件 | 画面 | 文案带文字（caption 版） | 商店用途 |
|---|---|---|---|
| 01_calculator | 计算器主页：输入区 + 月供大数字 | 月供利息，一算便知 | 首图（门面） |
| 02_charts | 还款趋势折线 + 本金/利息占比环形图 | 本金利息，一目了然 | 第 2 图 |
| 03_schedule | 还款计划表五列明细（可跳期） | 360 期还款计划，尽在掌握 | 第 3 图 |
| 04_prepayment | 提前还款双模式对比柱状图 + 节省利息 | 提前还款，省多少一眼看懂 | 第 4 图 |
| 05_settings | 我的/设置（主题/货币/语言/隐私） | 深色模式，护眼随行 | 第 5 图（深色套效果最佳） |

## 对应商店档位

- **App Store iPhone 6.9" 档**：直接传 `iphone6.9/{light,dark}/`。6.9" 图可被 App Store 自动缩配到 6.5"/5.5" 等小屏档位（App Store Connect 选择「使用 6.9 英寸截图」即可），无需逐尺寸重做。
- **App Store iPad 13" 档**：传 `ipad13/{light,dark}/`（工程为 Universal，iPad 原生全屏运行，无兼容模式黑边）。
- **Google Play 手机截图**：传 `android/{light,dark}/`（1080×2160，比例 2:1，满足 Play「最短边 ≥320px、比例 16:9–2:1」要求，2–8 张）。
- 每页面均有**无文案版**（`NN_name.png`，纯截图）与**文案版**（`NN_name_caption.png`），按商店风格二选一混排即可；文案带为品牌深蓝（浅色套 #1B3A6B / 深色套 #2E5FA3），白字 PingFang SC，letterbox 居中不遮挡任何应用内容。

## android 版来源说明（重要）

本机未安装 Android 系统镜像（体积大，按任务要求不下载），`android/` 目录由 **iPhone 17 Pro Max 原生截图**派生：

1. 裁掉 iOS 状态栏（顶部 170px）与 Home 指示条安全区（底部 58px），得 1320×2640；
2. 等比缩放至 **1080×2160**（严格 2:1）。

应用为 Flutter 双端同构 UI，除状态栏/Home 条外两平台画面一致，派生图可真实代表 Android 视觉效果。**上架后建议**：有 Android 真机时在真机（1080×2400 或更高）按同 5 画面重截替换——重截只需：装 release 包 → 同意免责声明 → 按 01–05 顺序截图，再按本目录同名覆盖即可（caption 版用 `tools/postprocess_store_shots.py` 的 letterbox 逻辑可复用）。

## 制作管线（可复现）

1. `integration_test/screenshot_test.dart`：巡游用例，逐页停留 15s 并打印 `SHOT_PAGE:<页名>` 标记；
2. `tools/capture_store_shots.sh <UDID> <组合名> <light|dark>`：设外观 → 状态栏覆盖（09:41/满电/满信号）→ 后台跑巡游 → 按标记定时 `simctl io screenshot`；
3. `tools/postprocess_store_shots.py`：分发原图 → 派生 android 尺寸 → 生成 letterbox caption 版。
