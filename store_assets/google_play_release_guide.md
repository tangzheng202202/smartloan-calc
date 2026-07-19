# 智贷计算器 — Google Play 上架指南

> 版本：1.0.0+1（versionName 1.0.0 / versionCode 1）｜ 包名：`com.smartloan.loan_calculator`
> 更新日期：2026-07-19 ｜ 构建环境：Flutter 3.44.6 / compileSdk=targetSdk=36

---

## ⚠️ 密钥备份警告（最重要，先读这条）

本应用的 Play 上传密钥对文件：

- `android/app/upload-keystore.jks`（密钥库）
- `android/key.properties`（storePassword / keyPassword / alias / storeFile）

**两个文件已加入 `.gitignore`，不会随 Git 提交。请立即将二者复制到至少两处安全位置**（加密云盘 + 离线硬盘/U 盘）。

- **丢失后果**：无法再对本应用发布更新，只能向 Google Play 申请「重置上传密钥」（需人工审核，约数个工作日；应用签名密钥本身由 Google Play App Signing 托管，不受影响）。
- **泄露后果**：任何持有者可冒充本应用签名更新包（仍须过 Play Console 账号权限），发现泄露应立即在 Play Console 申请更换上传密钥。
- 本仓库生成的密钥库为 **PKCS12 格式**（扩展名 .jks 仅是命名习惯），其密钥口令与库口令必须相同，`key.properties` 中 `storePassword` 与 `keyPassword` 因此为同一值——这是 PKCS12 的格式限制，不是笔误。

---

## 1. 构建发布 AAB

```bash
# 环境（每个新 shell 都要 export）
export PATH="<workspace>/.tools/flutter/bin:$PATH"
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export ANDROID_HOME=<workspace>/.tools/android-sdk
export PATH="$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH"
export LANG=en_US.UTF-8

cd loan_calculator_app
flutter pub get
flutter build appbundle --release
```

产物：`build/app/outputs/bundle/release/app-release.aab`

**本次已验证产物（2026-07-19）**：

| 项目 | 值 |
|---|---|
| AAB 大小 | **61,049,091 字节（61.0 MB）** |
| ABI | `arm64-v8a`（Play 必需）、`armeabi-v7a`、`x86_64`，均含 `libflutter.so` 与 `libapp.so` |
| 签名 | 上传密钥（alias `upload`，RSA 2048，有效期 10000 天） |
| release 合并清单权限 | 无 `INTERNET`（纯离线成立）；仅 AGP 自动注入的 `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`（签名级、对外不可见，属正常） |
| 版本 | versionName `1.0.0` / versionCode `1` |

> 说明：debug APK 中的 `INTERNET` 权限是 Flutter 调试模式注入的（供 VM Service 使用），release 构建已确认不含该权限。数据安全表单按「不收集数据」如实填写即可。

辅助验证命令：

```bash
unzip -l build/app/outputs/bundle/release/app-release.aab | grep '\.so$'   # 查 ABI
# 查 release 合并清单权限：
grep uses-permission build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml
```

版本升级：改 `pubspec.yaml` 的 `version: x.y.z+n`（z=versionName，n=versionCode，Play 要求 versionCode 单调递增）。

---

## 2. Play App Signing（应用签名托管）

首次上传 AAB 时，Play Console 会引导加入 **Play App Signing**：

1. Google 生成并托管「应用签名密钥」（App Signing Key），用户设备上安装的 APK 由它签名。
2. 你本地的上传密钥（Upload Key）仅用于向 Play 提交包时验证身份，可重置。
3. 加入方式选 **「让 Google 生成新密钥」（推荐）**。
4. 加入后可在「设置 → 应用完整性」查看两个证书指纹（MD5/SHA-1/SHA-256）：应用签名证书 + 上传证书。

本应用无任何第三方 SDK、无 Google 服务依赖，**无需**把证书指纹登记到任何第三方平台。

---

## 3. Play Console 上传步骤

前置：Google Play 开发者账号（一次性 $25）。

1. **创建应用**：Play Console → 创建应用 → 名称「智贷计算器 - 房贷车贷月供计算」→ 默认语言「中文（简体）」→ 应用类型「应用」→ 免费。
2. **设置应用内容**（左侧「政策 → 应用内容」）：依次完成隐私政策、广告声明（**不含广告**）、内容分级、目标受众、新闻应用（否）、COVID 类（否）等问卷。
3. **商店设置 → 主要商店详情**：填简短说明、完整说明（文案见 `store_assets/store_metadata.md` Google Play 一节），上传：
   - 应用图标：`store_assets/icon_512.png`（512×512）
   - 置顶大图：`store_assets/feature_graphic_1024x500.png`（1024×500）
   - 手机截图 2–8 张（可直接复用 `screenshots/` 目录的 8 张页面图；Play 接受 1080×2400 等手机尺寸）
   - 应用类别：财务 / 工具；标签：贷款、计算器、房贷。
4. **创建正式版发布**：发布 → 正式版 → 创建新版本 → 上传 `app-release.aab` → 填写版本说明（如「首个版本」）→ 检查发布 → 开始发布。
5. **送审**：完成所有「政策」问卷且商店详情无缺失项后才能送审；首次审核通常 3–7 天。

---

## 4. 数据安全表单（Data safety）

| 问题 | 回答 |
|---|---|
| 应用是否收集或共享所需的用户数据类型？ | **否** |
| （展开后）收集的任何数据类型 | 全部不勾选 |
| 数据是否加密传输 | 不适用（不传输） |
| 是否提供删除数据途径 | 是（应用内「清除历史记录」+ 卸载即删） |

依据：release 清单无 `INTERNET` 权限；无分析/广告 SDK；Hive 仅本机沙盒存储。若未来版本加入任何网络功能，必须同步更新本表单与隐私政策。

## 5. 内容分级（IARC 问卷）

全部答「否」（无暴力/性/赌博/受控物品/用户互动/位置共享）→ 结果应为 **PEGI 3 / ESRB Everyone / 通用分级「所有人」**。工具类财务应用无年龄限制内容。

## 6. 目标用户与内容设置

- 目标受众：**18 岁及以上**（金融工具建议选成人受众，避免触发家庭政策审查）。
- 非「主要为儿童设计」应用。
- 广告声明：**不含广告**。
- 财务功能声明（如被问到）：本应用为计算工具，不提供贷款、不撮合交易——在描述与免责声明中已写明「计算结果仅供参考，以银行实际审批为准」。

## 7. 隐私政策 URL（必填项）

Play Console 要求提供**可公开访问的隐私政策 URL**。零成本托管方案 **GitHub Pages**，本站已备好：

**现成站点：`docs/` 目录（三语静态页，无需生成）**

1. 将本项目推送到 GitHub 仓库（公开）。
2. 仓库 Settings → Pages → Source 选 `Deploy from a branch` → 分支 `main`、目录 `/docs` → Save。
3. 约 1 分钟后得到 URL `https://<你的用户名>.github.io/<仓库名>/`，填入 Play Console「商店设置 → 隐私政策」与「应用内容 → 隐私政策声明」两处；同一 URL 也可用于 iOS App Store Connect。
4. 站点特性：单文件 `docs/index.html`，简体中文/繁體中文/English 按浏览器语言自动切换（可点顶部按钮手动切，URL 支持 `#zh-CN` / `#zh-TW` / `#en`），自适应深浅色，已用无头 Chrome 三语渲染验证；`docs/.nojekyll` 已放置。
5. ⚠️ **发布前务必替换页面中的占位邮箱** `support@smartloan.example`（`docs/index.html` 中共 3 处，每语一处）为你的真实支持邮箱。

### 附录：隐私政策全文（与应用内一致，可直接发布）

**生效日期：2026-07-19**

**智贷计算器隐私政策**

**简体中文**

1. 不收集：本应用不收集任何个人信息、设备信息或使用数据。
2. 不上传：无任何网络请求，全部计算在本机完成。
3. 本地存储：您保存的方案与历史记录仅存储于本机应用沙盒（Hive 数据库），卸载应用即被删除。
4. 无账号：无需注册登录，无第三方 SDK 埋点。
5. 导出文件：还款计划 PDF / CSV 仅在您主动分享时经系统分享面板发出，内容由您完全控制。

如未来版本引入任何网络功能，我们将更新本政策并在应用内显著提示。

**English**

1. No collection: this app collects no personal, device or usage data.
2. No upload: zero network requests; all computation happens on-device.
3. Local storage: saved plans and history live only in the on-device app sandbox (Hive database) and are removed when the app is uninstalled.
4. No account: no sign-up, no third-party analytics SDKs.
5. Exported files: schedule PDF / CSV files leave the device only through the system share sheet when you explicitly share them.

If any network feature is introduced in the future, this policy will be updated with prominent in-app notice.

**繁體中文**

1. 不收集：本應用不收集任何個人資訊、裝置資訊或使用資料。
2. 不上傳：無任何網路請求，全部計算在本機完成。
3. 本地儲存：您儲存的方案與歷史記錄僅儲存於本機應用沙盒（Hive 資料庫），解除安裝應用即被刪除。
4. 無帳號：無需註冊登入，無第三方 SDK 埋點。
5. 匯出檔案：還款計劃 PDF / CSV 僅在您主動分享時經系統分享面板發出，內容由您完全控制。

如未來版本引入任何網路功能，我們將更新本政策並在應用內顯著提示。

联系与支持：请将支持邮箱替换为你的真实邮箱后一并发布（当前占位：support@smartloan.example）。

---

## 8. 送审前自查清单

- [ ] 密钥两文件已离线备份（见顶部警告）
- [ ] `flutter analyze` 零 issue / `flutter test` 49 例全过 / `dart format` 无 diff
- [ ] AAB 用最新代码重新构建（versionCode 递增）
- [ ] 隐私政策 URL 已部署且公开可访问
- [ ] Play Console 各政策问卷全部完成
- [ ] 商店图标、置顶大图、≥2 张手机截图已上传
- [ ] 应用内容问卷：广告「否」、目标受众 18+、内容分级全「否」
