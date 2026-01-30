#!/bin/bash

# Chrome Remote Pro - Quick Installer
# One-line install: curl -fsSL https://raw.githubusercontent.com/Agentik-OS/chrome-remote-pro/main/install.sh | bash

set -e

echo "═══════════════════════════════════════════════════════"
echo "  Chrome Remote Pro - Installer"
echo "═══════════════════════════════════════════════════════"
echo ""

# Check macOS version
if [[ $(sw_vers -productVersion | cut -d '.' -f 1) -lt 11 ]]; then
    echo "❌ Chrome Remote Pro requires macOS 11.0 or later"
    exit 1
fi

# Check if Chrome is installed
if [ ! -d "/Applications/Google Chrome.app" ]; then
    echo "⚠️  Google Chrome not found. Please install Chrome first:"
    echo "   https://www.google.com/chrome/"
    exit 1
fi

echo "📥 Downloading Chrome Remote Pro..."
echo ""

# Download latest DMG
DOWNLOAD_URL="https://github.com/Agentik-OS/chrome-remote-pro/releases/download/v2.1.2/ChromeRemotePro-v2.1.2.dmg"
TMP_DMG="/tmp/ChromeRemotePro.dmg"

# Try to download
if ! curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DMG" 2>/dev/null; then
    echo "❌ Failed to download. Trying alternative method..."

    # Fallback: Use previous version
    DOWNLOAD_URL="https://github.com/Agentik-OS/chrome-remote-pro/releases/download/v2.1.1/ChromeRemotePro-v2.1.1.dmg"

    if ! curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DMG"; then
        echo "❌ Download failed. Please check:"
        echo "   1. Your internet connection"
        echo "   2. GitHub releases: https://github.com/Agentik-OS/chrome-remote-pro/releases"
        exit 1
    fi
fi

echo "✅ Download complete!"
echo ""

# Mount DMG
echo "📦 Installing Chrome Remote Pro..."
MOUNT_POINT=$(hdiutil attach "$TMP_DMG" -nobrowse | tail -n 1 | awk '{print $3}')

if [ -z "$MOUNT_POINT" ]; then
    echo "❌ Failed to mount DMG"
    rm -f "$TMP_DMG"
    exit 1
fi

# Copy app to Applications
if [ -d "$MOUNT_POINT/Chrome Remote Pro.app" ]; then
    # Remove old version if exists
    if [ -d "/Applications/Chrome Remote Pro.app" ]; then
        echo "🗑️  Removing old version..."
        rm -rf "/Applications/Chrome Remote Pro.app"
    fi

    echo "📍 Copying to Applications..."
    cp -R "$MOUNT_POINT/Chrome Remote Pro.app" /Applications/

    # Set permissions
    chmod -R 755 "/Applications/Chrome Remote Pro.app"
    xattr -cr "/Applications/Chrome Remote Pro.app"

    echo "✅ Installation complete!"
else
    echo "❌ Chrome Remote Pro.app not found in DMG"
    hdiutil detach "$MOUNT_POINT" -quiet
    rm -f "$TMP_DMG"
    exit 1
fi

# Cleanup
hdiutil detach "$MOUNT_POINT" -quiet
rm -f "$TMP_DMG"

# Refresh Launchpad
killall Dock 2>/dev/null || true

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅ Chrome Remote Pro installed successfully!"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "🚀 To launch:"
echo "   • Open Launchpad"
echo "   • Search for 'Chrome Remote Pro'"
echo "   • Click to launch"
echo ""
echo "Or run: open '/Applications/Chrome Remote Pro.app'"
echo ""
echo "📚 Documentation: https://github.com/Agentik-OS/chrome-remote-pro"
echo ""
echo "═══════════════════════════════════════════════════════"

# Optionally launch the app
read -p "Launch Chrome Remote Pro now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "/Applications/Chrome Remote Pro.app"
    echo "✅ Chrome Remote Pro launched!"
else
    echo "👍 You can launch it later from Launchpad"
fi

echo ""
echo "Thank you for using Chrome Remote Pro! ⭐"
