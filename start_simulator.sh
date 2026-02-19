#!/usr/bin/env bash
set -euo pipefail

PROJECT="OneMinuteColor.xcodeproj"
SCHEME="OneMinuteColor"
BUNDLE_ID="com.ramseykhalaf.oneminutecolor"
DEFAULT_DEVICE="iPhone 16"
DEFAULT_DERIVED_DATA="/tmp/oneminutecolor-dd"

usage() {
  cat <<USAGE
Usage: ./run_simulator.sh [device-name]

Examples:
  ./run_simulator.sh
  ./run_simulator.sh "iPhone 16 Pro"

Environment overrides:
  PROJECT_PATH       (default: ${PROJECT})
  SCHEME_NAME        (default: ${SCHEME})
  BUNDLE_IDENTIFIER  (default: ${BUNDLE_ID})
  DERIVED_DATA_PATH  (default: ${DEFAULT_DERIVED_DATA})
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

DEVICE_NAME="${1:-$DEFAULT_DEVICE}"
PROJECT_PATH="${PROJECT_PATH:-$PROJECT}"
SCHEME_NAME="${SCHEME_NAME:-$SCHEME}"
BUNDLE_IDENTIFIER="${BUNDLE_IDENTIFIER:-$BUNDLE_ID}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$DEFAULT_DERIVED_DATA}"

for cmd in xcrun xcodebuild open awk sed; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "Project not found: $PROJECT_PATH" >&2
  exit 1
fi

DEVICE_LINE="$(xcrun simctl list devices available | awk -v name="$DEVICE_NAME" '$0 ~ name" \\(" { print; exit }')"
if [[ -z "$DEVICE_LINE" ]]; then
  echo "No available simulator found matching: $DEVICE_NAME" >&2
  echo "Available devices:" >&2
  xcrun simctl list devices available >&2
  exit 1
fi

UDID="$(printf '%s\n' "$DEVICE_LINE" | sed -n 's/.*(\([0-9A-F-][0-9A-F-]*\)).*/\1/p')"
if [[ -z "$UDID" ]]; then
  echo "Failed to parse simulator UDID from: $DEVICE_LINE" >&2
  exit 1
fi

echo "Using simulator: $DEVICE_NAME ($UDID)"

if ! xcrun simctl list devices | grep -F "$UDID" | grep -q "(Booted)"; then
  echo "Booting simulator..."
  xcrun simctl boot "$UDID" >/dev/null 2>&1 || true
fi

open -a Simulator
xcrun simctl bootstatus "$UDID" -b

echo "Building $SCHEME_NAME for simulator..."
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME_NAME" \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build >/tmp/oneminutecolor-xcodebuild.log

APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/OneMinuteColor.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Built app not found at: $APP_PATH" >&2
  echo "See build log: /tmp/oneminutecolor-xcodebuild.log" >&2
  exit 1
fi

echo "Installing app..."
xcrun simctl install "$UDID" "$APP_PATH"

echo "Launching app..."
xcrun simctl launch "$UDID" "$BUNDLE_IDENTIFIER"

echo "Done."
