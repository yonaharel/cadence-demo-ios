#!/usr/bin/env bash
# Stand-in for CI: archive, sign, upload to App Store Connect, and report the build to Cadence.
# Signing is automatic: Xcode creates the distribution certificate and profile through the API key.
#
#   ASC_KEY_PATH=~/.appstoreconnect/private_keys/AuthKey_XXXX.p8 ASC_KEY_ID=XXXX ASC_ISSUER_ID=... \
#   CADENCE_TOKEN=... scripts/ci.sh
# Without CADENCE_TOKEN nothing is reported: on GitHub Actions, Cadence follows the workflow run instead.
set -euo pipefail
: "${ASC_KEY_PATH:?}" "${ASC_KEY_ID:?}" "${ASC_ISSUER_ID:?}"
CADENCE_URL=${CADENCE_URL:-http://127.0.0.1:4100}
CADENCE_APP=${CADENCE_APP:-ios}
cd "$(dirname "$0")/.."

VERSION=$(sed -n 's/^MARKETING_VERSION = //p' Config/Version.xcconfig)
BUILD=${BUILD_NUMBER:-$(date -u +%Y%m%d%H%M)} # must grow with every upload of a version
SHA=$(git rev-parse HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
OUT=$(mktemp -d)

report() {
  [ -n "${CADENCE_TOKEN:-}" ] || return 0
  curl -fsS -X POST "$CADENCE_URL/api/apps/$CADENCE_APP/builds" \
    -H "Authorization: Bearer $CADENCE_TOKEN" -H 'content-type: application/json' \
    -d "{\"version\":\"$VERSION\",\"buildNumber\":\"$BUILD\",\"status\":\"$1\",\"commitSha\":\"$SHA\",\"branch\":\"$BRANCH\"}" >/dev/null
}
trap 'report failed' ERR
report running
echo "Building $VERSION ($BUILD) from $BRANCH @ ${SHA:0:7}"

AUTH=(-allowProvisioningUpdates -authenticationKeyPath "$ASC_KEY_PATH" -authenticationKeyID "$ASC_KEY_ID" -authenticationKeyIssuerID "$ASC_ISSUER_ID")
xcodebuild archive -project Tuner.xcodeproj -scheme Tuner -configuration Release \
  -destination 'generic/platform=iOS' -archivePath "$OUT/Tuner.xcarchive" \
  CURRENT_PROJECT_VERSION="$BUILD" "${AUTH[@]}" -quiet
xcodebuild -exportArchive -archivePath "$OUT/Tuner.xcarchive" \
  -exportOptionsPlist scripts/ExportOptions.plist -exportPath "$OUT/export" "${AUTH[@]}" -quiet

report success
echo "Uploaded $VERSION ($BUILD). App Store Connect processes it in 5–30 minutes before it can be submitted."
