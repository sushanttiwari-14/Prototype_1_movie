#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$ROOT_DIR/Prototype_1_movie.xcodeproj"
SCHEME="Prototype_1_movie"
DERIVED_DATA="$ROOT_DIR/.build"
DEVICE_ID="${SYNC_TABLE_DEVICE_ID:-17F91CC9-BF29-4DDB-9E4C-7C501A880A6D}"
APP="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/Prototype_1_movie.app"
BUNDLE_ID="aniket.Prototype-1-movie"

build() {
  xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -derivedDataPath "$DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO \
    build
}

launch() {
  xcrun simctl boot "$DEVICE_ID" >/dev/null 2>&1 || true
  open -a Simulator
  xcrun simctl bootstatus "$DEVICE_ID" -b
  xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl install "$DEVICE_ID" "$APP"
  xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
}

case "$MODE" in
  run)
    build
    launch
    ;;
  --verify|verify)
    build
    launch
    xcrun simctl get_app_container "$DEVICE_ID" "$BUNDLE_ID" app >/dev/null
    ;;
  --logs|logs|--telemetry|telemetry)
    build
    launch
    xcrun simctl spawn "$DEVICE_ID" log stream --level info --style compact --predicate "process == \"Prototype_1_movie\""
    ;;
  --debug|debug)
    build
    launch
    echo "App launched. Attach LLDB to Prototype_1_movie from Xcode."
    ;;
  *)
    echo "usage: $0 [run|--verify|--logs|--telemetry|--debug]" >&2
    exit 2
    ;;
esac
