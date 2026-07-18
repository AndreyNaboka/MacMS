#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    echo "Usage: ./scripts/build-dmg.sh <version>"
    echo "Example: ./scripts/build-dmg.sh 1.0.0"
    exit 1
fi

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
    echo "Error: version must look like 1.0.0 or 1.0.0-beta.1"
    exit 1
fi

for command_name in swift plutil codesign diskutil hdiutil shasum sips iconutil; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Error: required command '$command_name' was not found"
        exit 1
    fi
done

ARCHITECTURE="$(uname -m)"
DIST_DIR="$PROJECT_DIR/dist"
APP_PATH="$DIST_DIR/MacMS.app"
DMG_PATH="$DIST_DIR/MacMS-${VERSION}-macOS-${ARCHITECTURE}.dmg"
PLIST_PATH="$APP_PATH/Contents/Info.plist"
ICON_SOURCE="$PROJECT_DIR/Assets/AppIcon.png"
WORK_DIR="$(mktemp -d)"
DMG_ROOT="$WORK_DIR/dmg-root"
ICONSET_DIR="$WORK_DIR/AppIcon.iconset"

cleanup() {
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

cd "$PROJECT_DIR"

echo "Building MacMS ${VERSION} for ${ARCHITECTURE}..."
swift build -c release
BIN_PATH="$(swift build --show-bin-path -c release)"

if [[ ! -x "$BIN_PATH/MacMS" ]]; then
    echo "Error: release executable was not found at $BIN_PATH/MacMS"
    exit 1
fi

if [[ ! -f "$ICON_SOURCE" ]]; then
    echo "Error: app icon was not found at $ICON_SOURCE"
    exit 1
fi

mkdir -p "$DIST_DIR"
rm -rf "$APP_PATH"
rm -f "$DMG_PATH"
mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources"

cp "$BIN_PATH/MacMS" "$APP_PATH/Contents/MacOS/MacMS"
chmod +x "$APP_PATH/Contents/MacOS/MacMS"

echo "Generating AppIcon.icns..."
mkdir -p "$ICONSET_DIR"
sips -z 16 16 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -z 64 64 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -z 128 128 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -z 512 512 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
sips -z 1024 1024 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null
iconutil -c icns "$ICONSET_DIR" -o "$APP_PATH/Contents/Resources/AppIcon.icns"

plutil -create xml1 "$PLIST_PATH"
plutil -insert CFBundleExecutable -string "MacMS" "$PLIST_PATH"
plutil -insert CFBundleIdentifier -string "com.andreynaboka.MacMS" "$PLIST_PATH"
plutil -insert CFBundleName -string "MacMS" "$PLIST_PATH"
plutil -insert CFBundleDisplayName -string "MacMS" "$PLIST_PATH"
plutil -insert CFBundleIconFile -string "AppIcon" "$PLIST_PATH"
plutil -insert CFBundlePackageType -string "APPL" "$PLIST_PATH"
plutil -insert CFBundleShortVersionString -string "$VERSION" "$PLIST_PATH"
plutil -insert CFBundleVersion -string "1" "$PLIST_PATH"
plutil -insert LSMinimumSystemVersion -string "13.0" "$PLIST_PATH"
plutil -insert LSUIElement -bool true "$PLIST_PATH"
plutil -insert NSHighResolutionCapable -bool true "$PLIST_PATH"

plutil -lint "$PLIST_PATH"

echo "Applying an ad-hoc signature..."
codesign --force --deep --sign - "$APP_PATH"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

mkdir -p "$DMG_ROOT"
cp -R "$APP_PATH" "$DMG_ROOT/MacMS.app"
ln -s /Applications "$DMG_ROOT/Applications"

echo "Creating disk image..."
diskutil image create from \
    --volumeName "MacMS" \
    --format UDZO \
    "$DMG_ROOT" \
    "$DMG_PATH"

hdiutil verify "$DMG_PATH"

echo
echo "DMG created successfully:"
echo "$DMG_PATH"
echo
shasum -a 256 "$DMG_PATH"
echo
echo "To publish it as a GitHub Release asset, run:"
echo "gh release create v${VERSION} \"$DMG_PATH\" --title \"MacMS ${VERSION}\" --generate-notes"
