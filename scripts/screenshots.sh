#!/usr/bin/env bash
# Retakes the App Store screenshots in metadata/screenshots/en-US on the 6.9" and 6.3" simulators.
# Each shot launches the app with `-demoFrequency`, so no microphone is needed.
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=metadata/screenshots/en-US
DD=$(mktemp -d)
BUNDLE=com.yonaharel.cadencedemo

xcodebuild build -project Tuner.xcodeproj -scheme Tuner -configuration Debug \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath "$DD" -skipMacroValidation -quiet
APP="$DD/Build/Products/Debug-iphonesimulator/Tuner.app"

SHOTS=(
  "01-home 108.9"     # A2, flat
  "02-in-tune 82.5"   # low E2, in tune
  "03-sharp 199.0"    # G3, sharp
  "04-high-e 330.0"   # high E4, in tune
)

shoot() { # device, file suffix
  local udid
  udid=$(xcrun simctl list devices available | grep -F "    $1 (" | head -1 | grep -oE '[0-9A-F-]{36}')
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
  xcrun simctl ui "$udid" appearance light
  xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charging --batteryLevel 100 \
    --wifiBars 3 --cellularMode active --cellularBars 4 --dataNetwork wifi
  xcrun simctl install "$udid" "$APP"
  for shot in "${SHOTS[@]}"; do
    set -- $shot
    xcrun simctl launch --terminate-running-process "$udid" "$BUNDLE" -demoFrequency "$2" >/dev/null
    sleep 2 # let the needle spring settle
    xcrun simctl io "$udid" screenshot --type=png "$DD/shot.png" >/dev/null
    sips -s format jpeg -s formatOptions 90 "$DD/shot.png" --out "$OUT/$1$suffix.jpg" >/dev/null
  done
}

suffix=""        shoot "iPhone 17 Pro Max"  # 6.9", 1320×2868
suffix="-medium" shoot "iPhone 17 Pro"      # 6.3", 1206×2622
ls -1 "$OUT"
