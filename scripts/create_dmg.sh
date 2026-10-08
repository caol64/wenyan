#!/usr/bin/env bash

set -euo pipefail

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly APP_PATH="${APP_PATH:-$ROOT_DIR/target/Release/文颜.app}"
readonly OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/dist}"
readonly VOLUME_NAME="文颜"
readonly APP_NAME="文颜"

if [[ ! -d "$APP_PATH" ]]; then
    echo "App bundle not found: $APP_PATH" >&2
    echo "Run 'pnpm build' before creating the DMG." >&2
    exit 1
fi

readonly VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")"
readonly OUTPUT_PATH="$OUTPUT_DIR/WenYan-$VERSION-macOS.dmg"
readonly TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/wenyan-dmg.XXXXXX")"
readonly RW_DMG="$TEMP_DIR/WenYan-rw.dmg"
readonly APP_SIZE_MB="$(du -sm "$APP_PATH" | awk '{ print $1 + 20 }')"
MOUNT_POINT=""
mounted=0

cleanup() {
    if ((mounted)); then
        hdiutil detach "$MOUNT_POINT" -quiet || echo "Warning: could not detach $MOUNT_POINT" >&2
    fi
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_PATH"

# An ad-hoc signature keeps the unsigned release self-contained without requiring an Apple Developer certificate.
codesign --force --deep --sign - "$APP_PATH"

hdiutil create \
    -size "${APP_SIZE_MB}m" \
    -fs HFS+ \
    -volname "$VOLUME_NAME" \
    -quiet \
    "$RW_DMG"

MOUNT_POINT="$(hdiutil attach "$RW_DMG" -noverify | awk '/Apple_HFS/ { print $3; exit }')"
if [[ -z "$MOUNT_POINT" ]]; then
    echo "Could not determine the DMG mount point." >&2
    exit 1
fi
mounted=1

ditto "$APP_PATH" "$MOUNT_POINT/$APP_NAME.app"
ln -s /Applications "$MOUNT_POINT/Applications"

osascript <<EOF
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set bounds of container window to {100, 100, 720, 430}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 96
        set position of item "$APP_NAME.app" to {160, 180}
        set position of item "Applications" to {460, 180}
        close
    end tell
end tell
EOF

sync
sleep 1
hdiutil detach "$MOUNT_POINT" -quiet
mounted=0

hdiutil convert "$RW_DMG" -format UDZO -imagekey zlib-level=9 -o "$OUTPUT_PATH" -quiet
echo "Created $OUTPUT_PATH"
