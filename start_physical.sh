#!/usr/bin/env bash
set -euo pipefail

PROJECT="OneMinuteColor.xcodeproj"
SCHEME="OneMinuteColor"
BUNDLE_ID="com.ramseykhalaf.oneminutecolor"
DD="/tmp/oneminutecolor-device-dd"
LOG="/tmp/oneminutecolor-device-xcodebuild.log"
DO_LAUNCH=1

case "${1:-}" in
  -h|--help)    echo "Usage: ./deploy.sh [device-name|udid|identifier] [--no-launch]"; exit 0 ;;
  --list-devices) xcrun devicectl list devices; exit 0 ;;
esac

for arg in "$@"; do
  case "$arg" in
    --no-launch) DO_LAUNCH=0 ;;
    -*) echo "Unknown option: $arg" >&2; exit 1 ;;
    *)  DEVICE_QUERY="$arg" ;;
  esac
done

DJ="/tmp/omc-devices.$$.json"
trap 'rm -f "$DJ"' EXIT
xcrun devicectl list devices --json-output "$DJ" >/dev/null

JQ_CONNECTED='.result.devices[] | select(.connectionProperties.tunnelState == "connected")'

if [[ -z "${DEVICE_QUERY:-}" ]]; then
  read -r DEVICE_NAME DEVICE_UDID DEVICE_ID < <(
    jq -r "[$JQ_CONNECTED] | first | [.deviceProperties.name, .hardwareProperties.udid, .identifier] | @tsv" "$DJ"
  )
else
  read -r DEVICE_NAME DEVICE_UDID DEVICE_ID < <(
    jq -r --arg q "${DEVICE_QUERY}" \
      "[$JQ_CONNECTED | select(.deviceProperties.name==\$q or .hardwareProperties.udid==\$q or .identifier==\$q)] | first | [.deviceProperties.name, .hardwareProperties.udid, .identifier] | @tsv" "$DJ"
  )
fi

[[ -n "${DEVICE_NAME:-}" && "$DEVICE_NAME" != "null" ]] || { echo "No connected device found${DEVICE_QUERY:+ matching: $DEVICE_QUERY}" >&2; exit 1; }

echo "Device: $DEVICE_NAME ($DEVICE_UDID)"

echo "Uninstalling..."
xcrun devicectl device uninstall app --device "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true

echo "Clean building..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination "id=$DEVICE_UDID" -derivedDataPath "$DD" clean build >"$LOG" 2>&1 \
  || { echo "Build failed. Tail of $LOG:" >&2; tail -n 80 "$LOG" >&2; exit 1; }

APP="$(find "$DD/Build/Products/Debug-iphoneos" -maxdepth 1 -type d -name '*.app' | head -n1)"
[[ -d "${APP:-}" ]] || { echo "No .app found in $DD/Build/Products/Debug-iphoneos" >&2; exit 1; }

echo "Installing..."
xcrun devicectl device install app --device "$DEVICE_ID" "$APP" >/dev/null

if [[ "$DO_LAUNCH" -eq 1 ]]; then
  echo "Launching..."
  xcrun devicectl device process launch --device "$DEVICE_ID" --terminate-existing "$BUNDLE_ID" >/dev/null
fi

echo "Done. Log: $LOG"
