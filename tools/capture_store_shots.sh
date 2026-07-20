#!/bin/bash
# 商店截图捕获：simctl 外观 + flutter test 巡游 + 标记驱动定时截图
# 用法: capture.sh <UDID> <combo目录名> <light|dark>
set -u
UDID="$1"; COMBO="$2"; APPEAR="$3"
export PATH="/Users/mac/Documents/Kimi/Workspaces/LoanCalculator/.tools/flutter/bin:$PATH"
export LANG=en_US.UTF-8
APP=/Users/mac/Documents/Kimi/Workspaces/LoanCalculator/loan_calculator_app
OUT=/tmp/store_shots/$COMBO
LOG=/tmp/store_shots/${COMBO}.log
mkdir -p "$OUT"
rm -f "$OUT"/*.png "$LOG"

xcrun simctl boot "$UDID" 2>/dev/null
xcrun simctl ui "$UDID" appearance "$APPEAR"
# 商店级干净状态栏：9:41、满电、满信号
xcrun simctl status_bar "$UDID" override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4 --operatorName "" 2>/dev/null

cd "$APP"
flutter test integration_test/screenshot_test.dart -d "$UDID" > "$LOG" 2>&1 &
TPID=$!

ok=1
for page in 01_calculator 02_charts 03_schedule 04_prepayment 05_settings; do
  n=0
  while ! grep -q "SHOT_PAGE:$page" "$LOG" 2>/dev/null; do
    n=$((n+1)); [ $n -gt 100 ] && { echo "TIMEOUT waiting $page"; ok=0; break; }
    kill -0 $TPID 2>/dev/null || { echo "TEST_EXITED before $page"; ok=0; break; }
    sleep 1
  done
  [ $ok -eq 0 ] && break
  sleep 3   # 动画稳定
  xcrun simctl io "$UDID" screenshot "$OUT/$page.png" && echo "SHOT $page"
done

# 等测试自然结束（最多 120s）
n=0
while kill -0 $TPID 2>/dev/null; do
  n=$((n+1)); [ $n -gt 120 ] && { kill $TPID 2>/dev/null; echo "TEST_KILLED"; break; }
  sleep 1
done
grep -E "SHOT_DONE|All tests passed|Some tests failed" "$LOG" | head -3
xcrun simctl status_bar "$UDID" clear 2>/dev/null
ls -la "$OUT"
[ $ok -eq 1 ] && echo "CAPTURE_OK $COMBO" || echo "CAPTURE_FAIL $COMBO"
