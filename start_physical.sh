#!/usr/bin/env bash
set -euo pipefail

PROJECT="OneMinuteColor.xcodeproj"
SCHEME="OneMinuteColor"
BUNDLE_ID="com.ramseykhalaf.oneminutecolor"
DEFAULT_DERIVED_DATA="/tmp/oneminutecolor-device-dd"
BUILD_LOG="/tmp/oneminutecolor-device-xcodebuild.log"

usage() {
  cat <<USAGE
Usage: ./start_physical.sh [device-name|udid|identifier]

Examples:
  ./start_physical.sh
  ./start_physical.sh "iphone13-ramsey"
  ./start_physical.sh "00008110-0010486A0292801E"

Options:
  --list-devices   Show connected devices and exit
  -h, --help       Show this help

Environment overrides:
  PROJECT_PATH       (default: ${PROJECT})
  SCHEME_NAME        (default: ${SCHEME})
  BUNDLE_IDENTIFIER  (default: ${BUNDLE_ID})
  DERIVED_DATA_PATH  (default: ${DEFAULT_DERIVED_DATA})
USAGE
}

for cmd in xcrun xcodebuild jq find; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--list-devices" ]]; then
  xcrun devicectl list devices
  exit 0
fi

PROJECT_PATH="${PROJECT_PATH:-$PROJECT}"
SCHEME_NAME="${SCHEME_NAME:-$SCHEME}"
BUNDLE_IDENTIFIER="${BUNDLE_IDENTIFIER:-$BUNDLE_ID}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$DEFAULT_DERIVED_DATA}"
DEVICE_QUERY="${1:-${DEVICE_QUERY:-}}"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "Project not found: $PROJECT_PATH" >&2
  exit 1
fi

DEVICES_JSON="/tmp/oneminutecolor-devices.$$.json"
trap 'rm -f "$DEVICES_JSON"' EXIT
xcrun devicectl list devices --json-output "$DEVICES_JSON" >/dev/null

CONNECTED_COUNT="$(jq '[.result.devices[] | select(.connectionProperties.tunnelState == "connected")] | length' "$DEVICES_JSON")"
if [[ "$CONNECTED_COUNT" -eq 0 ]]; then
  echo "No connected iOS devices found." >&2
  echo "Connect and unlock your iPhone, trust this Mac, and enable Developer Mode." >&2
  exit 1
fi

if [[ -z "$DEVICE_QUERY" ]]; then
  DEVICE_NAME="$(jq -r '.result.devices[] | select(.connectionProperties.tunnelState == "connected") | .deviceProperties.name' "$DEVICES_JSON" | head -n1)"
else
  DEVICE_NAME="$(jq -r --arg q "$DEVICE_QUERY" '
    .result.devices[]
    | select(.connectionProperties.tunnelState == "connected")
    | select(
        .deviceProperties.name == $q
        or .hardwareProperties.udid == $q
        or .identifier == $q
      )
    | .deviceProperties.name
  ' "$DEVICES_JSON" | head -n1)"
fi

if [[ -z "$DEVICE_NAME" ]]; then
  echo "No connected device matched: ${DEVICE_QUERY}" >&2
  echo "Run ./start_physical.sh --list-devices to see available devices." >&2
  exit 1
fi

DEVICE_UDID="$(jq -r --arg name "$DEVICE_NAME" '
  .result.devices[]
  | select(.connectionProperties.tunnelState == "connected")
  | select(.deviceProperties.name == $name)
  | .hardwareProperties.udid
' "$DEVICES_JSON" | head -n1)"

DEVICE_IDENTIFIER="$(jq -r --arg name "$DEVICE_NAME" '
  .result.devices[]
  | select(.connectionProperties.tunnelState == "connected")
  | select(.deviceProperties.name == $name)
  | .identifier
' "$DEVICES_JSON" | head -n1)"

DEVELOPER_MODE_STATUS="$(jq -r --arg name "$DEVICE_NAME" '
  .result.devices[]
  | select(.connectionProperties.tunnelState == "connected")
  | select(.deviceProperties.name == $name)
  | .deviceProperties.developerModeStatus
' "$DEVICES_JSON" | head -n1)"

if [[ -z "$DEVICE_UDID" || -z "$DEVICE_IDENTIFIER" ]]; then
  echo "Failed to resolve device metadata for: $DEVICE_NAME" >&2
  exit 1
fi

echo "Using device: $DEVICE_NAME"
echo "UDID: $DEVICE_UDID"

if [[ "$DEVELOPER_MODE_STATUS" != "enabled" ]]; then
  echo "Warning: Developer Mode is '$DEVELOPER_MODE_STATUS'. App launch/install may fail until enabled." >&2
fi

echo "Building $SCHEME_NAME for device..."
if ! xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME_NAME" \
  -destination "id=$DEVICE_UDID" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build >"$BUILD_LOG" 2>&1; then
  echo "Build failed. Showing tail of $BUILD_LOG:" >&2
  tail -n 80 "$BUILD_LOG" >&2
  exit 1
fi

APP_PATH="$(find "$DERIVED_DATA_PATH/Build/Products/Debug-iphoneos" -maxdepth 1 -type d -name '*.app' | head -n1)"
if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
  echo "Built .app not found under $DERIVED_DATA_PATH/Build/Products/Debug-iphoneos" >&2
  exit 1
fi

echo "Installing app on $DEVICE_NAME..."
xcrun devicectl device install app --device "$DEVICE_IDENTIFIER" "$APP_PATH" >/dev/null

echo "Launching $BUNDLE_IDENTIFIER..."
xcrun devicectl device process launch --device "$DEVICE_IDENTIFIER" --terminate-existing "$BUNDLE_IDENTIFIER" >/dev/null

echo "Success: app installed and launched on $DEVICE_NAME"
echo "Build log: $BUILD_LOG"
