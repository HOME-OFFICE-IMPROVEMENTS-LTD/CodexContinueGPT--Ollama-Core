#!/bin/bash
# generate_logo.sh - Generate a simple placeholder logo for CodexContinueGPT™
# Requires ImageMagick to be installed: apt-get install imagemagick

# Colors
BG_COLOR="#3366FF"
TEXT_COLOR="#FFFFFF"
ACCENT_COLOR="#00CC99"

# Paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"
ASSETS_DIR="$REPO_ROOT/assets/CodexContinueGPT"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is required but not installed. Please install it first:"
    echo "sudo apt-get install imagemagick"
    exit 1
fi

# Create logo
echo "Generating logo for CodexContinueGPT™..."
convert -size 500x500 xc:none -gravity center \
    -pointsize 40 -font Arial -fill "$BG_COLOR" \
    -draw "roundrectangle 0,0 500,500 20,20" \
    -fill "$TEXT_COLOR" -annotate 0 "CodexContinue\nGPT™" \
    -stroke "$ACCENT_COLOR" -strokewidth 5 -draw "line 100,350 400,350" \
    "$ASSETS_DIR/logo.png"

# Create small logo
convert "$ASSETS_DIR/logo.png" -resize 100x100 "$ASSETS_DIR/logo_small.png"

# Create favicon
convert "$ASSETS_DIR/logo.png" -resize 32x32 "$ASSETS_DIR/favicon.png"
convert "$ASSETS_DIR/favicon.png" "$ASSETS_DIR/favicon.ico"

echo "Logo generation complete. Files saved to $ASSETS_DIR"
echo "Note: This is a placeholder logo. Replace with professional design when available."
