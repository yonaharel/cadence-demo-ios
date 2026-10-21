#!/usr/bin/env bash
# Retakes the App Store screenshots in metadata/screenshots/en-US on the 6.9" and 6.3" simulators,
# then frames each one with a headline (scripts/frame-screenshot.swift).
# Each shot launches the app with `-demoFrequency`, so no microphone is needed.
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=metadata/screenshots/en-US
DD=$(mktemp -d)
BUNDLE=com.yonaharel.cadencedemo
export CLANG_MODULE_CACHE_PATH="$DD/ModuleCache"

xcodebuild build -project Tuner.xcodeproj -scheme Tuner -configuration Debug \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath "$DD" -skipMacroValidation -quiet
APP="$DD/Build/Products/Debug-iphonesimulator/Tuner.app"
swiftc -O -module-cache-path "$CLANG_MODULE_CACHE_PATH" scripts/frame-screenshot.swift -o "$DD/frame"

# file|frequency|tuning|open settings|headline|subtitle
SHOTS=(
  "01-tune|108.9|standard|NO|Tune in seconds|Play a string and see which way to turn the peg"
  "02-in-tune|82.5|standard|NO|Know when you're in tune|A steady needle with a clear in-tune zone"
  "03-instruments|440.0|ukuleleStandard|NO|Not just guitar|Ukulele, banjo, mandolin, 7- and 12-string"
  "04-tunings|146.8|dropD|YES|29 tunings|Drop D, DADGAD, open tunings and more"
  "05-sharp|199.0|standard|NO|Sharp or flat?|See the exact cents and which way to tune"
)

shoot() { # device, file suffix
  local udid
  udid=$(xcrun simctl list devices available | grep -F "    $1 (" | head -1 | grep -oE '[0-9A-F-]{36}')
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
  xcrun simctl ui "$udid" appearance light
  xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charged --batteryLevel 100 \
    --wifiBars 3 --cellularMode active --cellularBars 4 --dataNetwork wifi
  xcrun simctl install "$udid" "$APP"
  for shot in "${SHOTS[@]}"; do
    IFS='|' read -r file frequency tuning settings headline subtitle <<<"$shot"
    xcrun simctl launch --terminate-running-process "$udid" "$BUNDLE" \
      -demoFrequency "$frequency" -tuning "$tuning" -demoSettings "$settings" >/dev/null
    sleep 3 # let the needle spring and the sheet settle
    xcrun simctl io "$udid" screenshot --type=png "$DD/shot.png" >/dev/null
    "$DD/frame" "$DD/shot.png" "$OUT/$file$suffix.jpg" "$headline" "$subtitle"
  done
}

rm -f "$OUT"/*.jpg
suffix=""        shoot "iPhone 17 Pro Max"  # 6.9", 1320×2868
suffix="-medium" shoot "iPhone 17 Pro"      # 6.3", 1206×2622
ls -1 "$OUT"
