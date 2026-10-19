#!/usr/bin/env bash
# Runs Twang in the Android emulator on a Mac, with Google's command-line tools only (no Android Studio).
# The first run downloads the tools, an Android 16 emulator image and the build dependencies (a few GB).
#
#   android/scripts/emulator.sh          # build, start the emulator, install and launch
#   android/scripts/emulator.sh --demo   # launch with a fixed reading (a flat A string) instead of the microphone
set -euo pipefail
cd "$(dirname "$0")/.."

command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh" >&2; exit 1; }

# Gradle and the SDK tools need Java 17 or later.
if ! /usr/libexec/java_home -v 17+ >/dev/null 2>&1; then brew install --cask temurin@21; fi
export JAVA_HOME
JAVA_HOME=$(/usr/libexec/java_home -v 17+)

ANDROID_HOME="$(brew --prefix)/share/android-commandlinetools"
[ -d "$ANDROID_HOME" ] || brew install --cask android-commandlinetools
export ANDROID_HOME ANDROID_SDK_ROOT="$ANDROID_HOME"
SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
AVDMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager"
ADB="$ANDROID_HOME/platform-tools/adb"
EMULATOR="$ANDROID_HOME/emulator/emulator"

ABI=$([ "$(uname -m)" = arm64 ] && echo arm64-v8a || echo x86_64)
IMAGE="system-images;android-36;google_apis;$ABI"
yes | "$SDKMANAGER" --licenses >/dev/null || true # Gradle downloads the rest (platform, build tools) once these are accepted
"$SDKMANAGER" "platform-tools" "emulator" "$IMAGE"
"$EMULATOR" -list-avds | grep -qx twang || echo no | "$AVDMANAGER" create avd -n twang -k "$IMAGE" -d pixel_8

if ! "$ADB" devices | grep -q '^emulator-'; then
  echo "Starting the emulator…"
  "$EMULATOR" -avd twang -no-snapshot-save >/dev/null 2>&1 &
  "$ADB" wait-for-device
  until [ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; do sleep 2; done
fi
# Let the tuner hear the Mac's microphone (off by default in the emulator).
"$ADB" emu avd hostmicon >/dev/null 2>&1 || echo "Turn on the mic in the emulator: ⋯ → Microphone → Virtual microphone uses host audio input"

./gradlew :app:installDebug
if [ "${1:-}" = --demo ]; then
  "$ADB" shell am start -S -n com.yonaharel.cadencedemo/.MainActivity --ef demoFrequency 108.9
else
  "$ADB" shell am start -S -n com.yonaharel.cadencedemo/.MainActivity
fi
