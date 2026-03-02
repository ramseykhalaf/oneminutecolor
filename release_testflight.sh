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
Usage: ./release_testflight.sh [--apple-id <email>]

Builds, archives, exports, and uploads to TestFlight.

Prerequisites:
  Store your app-specific password once:
    xcrun altool --store-password-in-keychain-item AC_PASSWORD \\
      -u you@example.com -p "xxxx-xxxx-xxxx-xxxx"

Environment overrides:
  APPLE_ID   Your Apple ID email (or pass --apple-id)
USAGE
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
esac

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apple-id) APPLE_ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

APPLE_ID="${APPLE_ID:-${APPLE_ID_ENV:-}}"
[[ -n "$APPLE_ID" ]] || { echo "Set APPLE_ID env var or pass --apple-id <email>" >&2; exit 1; }

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
  archive >"$LOG" 2>&1 \
  || { echo "Archive failed. Tail of $LOG:" >&2; tail -n 40 "$LOG" >&2; exit 1; }

echo "Exporting..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  >>"$LOG" 2>&1 \
  || { echo "Export failed. Tail of $LOG:" >&2; tail -n 40 "$LOG" >&2; exit 1; }

IPA="$(find "$EXPORT_PATH" -name '*.ipa' | head -n1)"
[[ -f "$IPA" ]] || { echo "No .ipa found in $EXPORT_PATH" >&2; exit 1; }

echo "Uploading $IPA..."
xcrun altool --upload-app \
  -f "$IPA" \
  -t ios \
  -u "$APPLE_ID" \
  -p @keychain:AC_PASSWORD \
  || { echo "Upload failed." >&2; exit 1; }

echo "Done. Build uploaded to TestFlight."
echo "Log: $LOG"
