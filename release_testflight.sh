#!/usr/bin/env bash
set -euo pipefail

PROJECT="OneMinuteColor.xcodeproj"
SCHEME="OneMinuteColor"
EXPORT_OPTIONS="ExportOptions.plist"
ARCHIVE_PATH="/tmp/OneMinuteColor.xcarchive"
EXPORT_PATH="/tmp/OneMinuteColorExport"
LOG="/tmp/oneminutecolor-release.log"

usage() {
  cat <<USAGE
Usage: ./release_testflight.sh --api-key <key-id> --issuer <issuer-id>

Builds, archives, exports, and uploads to TestFlight.

Prerequisites:
  1. Create an API key at App Store Connect > Users and Access > Integrations
  2. Save the .p8 file to ~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8

Options:
  --api-key   App Store Connect API Key ID
  --issuer    App Store Connect Issuer ID

Environment overrides:
  API_KEY_ID        (or pass --api-key)
  API_ISSUER_ID     (or pass --issuer)
USAGE
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
esac

if [[ -f .env ]]; then
  set -a; source .env; set +a
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --api-key) API_KEY_ID="$2"; shift 2 ;;
    --issuer)  API_ISSUER_ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

API_KEY_ID="${API_KEY_ID:-}"
API_ISSUER_ID="${API_ISSUER_ID:-}"
[[ -n "$API_KEY_ID" ]]   || { echo "Pass --api-key <key-id> or set API_KEY_ID" >&2; exit 1; }
[[ -n "$API_ISSUER_ID" ]] || { echo "Pass --issuer <issuer-id> or set API_ISSUER_ID" >&2; exit 1; }

KEY_FILE="$HOME/.appstoreconnect/private_keys/AuthKey_${API_KEY_ID}.p8"
[[ -f "$KEY_FILE" ]] || { echo "API key not found: $KEY_FILE" >&2; exit 1; }

for cmd in xcodebuild xcrun; do
  command -v "$cmd" >/dev/null || { echo "Missing: $cmd" >&2; exit 1; }
done

[[ -f "$EXPORT_OPTIONS" ]] || { echo "Missing $EXPORT_OPTIONS" >&2; exit 1; }

rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"

echo "Archiving..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$KEY_FILE" \
  -authenticationKeyID "$API_KEY_ID" \
  -authenticationKeyIssuerID "$API_ISSUER_ID" \
  archive >"$LOG" 2>&1 \
  || { echo "Archive failed. Tail of $LOG:" >&2; tail -n 40 "$LOG" >&2; exit 1; }

echo "Exporting..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$KEY_FILE" \
  -authenticationKeyID "$API_KEY_ID" \
  -authenticationKeyIssuerID "$API_ISSUER_ID" \
  >>"$LOG" 2>&1 \
  || { echo "Export failed. Tail of $LOG:" >&2; tail -n 40 "$LOG" >&2; exit 1; }

IPA="$(find "$EXPORT_PATH" -name '*.ipa' | head -n1)"
[[ -f "$IPA" ]] || { echo "No .ipa found in $EXPORT_PATH" >&2; exit 1; }

echo "Uploading $IPA..."
xcrun altool --upload-app \
  -f "$IPA" \
  -t ios \
  --apiKey "$API_KEY_ID" \
  --apiIssuer "$API_ISSUER_ID" \
  || { echo "Upload failed." >&2; exit 1; }

echo "Done. Build uploaded to TestFlight."
echo "Log: $LOG"
