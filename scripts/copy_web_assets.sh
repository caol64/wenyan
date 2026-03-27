#!/bin/bash
set -e

BUILD_DIR="build"
BUNDLE_DIR="WenYan/Resources.bundle"

echo "=== Cleaning old assets ==="
find "$BUNDLE_DIR" -mindepth 1 ! -name '.keep' -exec rm -rf {} +

echo "=== Copying assets to Resources.bundle ==="
cp -R "$BUILD_DIR"/* "$BUNDLE_DIR"

echo "=== Done ==="
