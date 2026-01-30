#!/bin/bash

# Chrome Remote Pro - Universal Installer
# Version 2.0
# https://github.com/yourusername/chrome-remote-pro

set -e

echo "═══════════════════════════════════════════════════════"
echo "  Chrome Remote Pro - Universal Installer"
echo "═══════════════════════════════════════════════════════"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}❌ This installer only works on macOS${NC}"
    exit 1
fi

# Check if Google Chrome is installed
if [ ! -d "/Applications/Google Chrome.app" ]; then
    echo -e "${RED}❌ Google Chrome is not installed${NC}"
    echo "Please install Google Chrome first: https://www.google.com/chrome/"
    exit 1
fi

echo -e "${BLUE}📍 Checking Chrome profiles...${NC}"

# Detect Chrome profiles
CHROME_DIR="$HOME/Library/Application Support/Google/Chrome"

if [ ! -d "$CHROME_DIR" ]; then
    echo -e "${RED}❌ Chrome profiles directory not found${NC}"
    exit 1
fi

# List all profiles with their Google accounts
echo ""
echo -e "${GREEN}✓ Found Chrome profiles:${NC}"
echo ""

PROFILES=()
PROFILE_EMAILS=()

# Check Default profile
if [ -d "$CHROME_DIR/Default" ]; then
    EMAIL=$(python3 -c "
import json, os, sys
try:
    with open('$CHROME_DIR/Default/Preferences') as f:
        data = json.load(f)
        accounts = data.get('account_info', [])
        if accounts:
            print(accounts[0]['email'])
        else:
            print('No Google account')
except:
    print('No Google account')
" 2>/dev/null)
    PROFILES+=("Default")
    PROFILE_EMAILS+=("$EMAIL")
    echo "  1. Default → $EMAIL"
fi

# Check numbered profiles
COUNT=2
for profile in "$CHROME_DIR"/Profile*; do
    if [ -d "$profile" ]; then
        PROFILE_NAME=$(basename "$profile")
        EMAIL=$(python3 -c "
import json, os, sys
try:
    with open('$profile/Preferences') as f:
        data = json.load(f)
        accounts = data.get('account_info', [])
        if accounts:
            print(accounts[0]['email'])
        else:
            print('No Google account')
except:
    print('No Google account')
" 2>/dev/null)
        PROFILES+=("$PROFILE_NAME")
        PROFILE_EMAILS+=("$EMAIL")
        echo "  $COUNT. $PROFILE_NAME → $EMAIL"
        ((COUNT++))
    fi
done

if [ ${#PROFILES[@]} -eq 0 ]; then
    echo -e "${RED}❌ No Chrome profiles found${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo ""

# Ask user which profiles to use
echo -e "${BLUE}How many projects do you want to configure? (1-10)${NC}"
read -p "Number of projects: " NUM_PROJECTS

if ! [[ "$NUM_PROJECTS" =~ ^[0-9]+$ ]] || [ "$NUM_PROJECTS" -lt 1 ] || [ "$NUM_PROJECTS" -gt 10 ]; then
    echo -e "${RED}❌ Invalid number${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Select profiles for your projects:${NC}"
echo ""

SELECTED_PROJECTS=()
START_PORT=9222

for i in $(seq 1 $NUM_PROJECTS); do
    echo "Project $i:"
    read -p "  Project name: " PROJECT_NAME

    echo "  Available profiles:"
    for idx in "${!PROFILES[@]}"; do
        echo "    $((idx+1)). ${PROFILES[$idx]} (${PROFILE_EMAILS[$idx]})"
    done

    read -p "  Select profile number: " PROFILE_IDX
    PROFILE_IDX=$((PROFILE_IDX-1))

    if [ $PROFILE_IDX -lt 0 ] || [ $PROFILE_IDX -ge ${#PROFILES[@]} ]; then
        echo -e "${RED}❌ Invalid profile number${NC}"
        exit 1
    fi

    PORT=$((START_PORT + i - 1))

    SELECTED_PROJECTS+=("$PROJECT_NAME|${PROFILES[$PROFILE_IDX]}|$PORT")
    echo -e "${GREEN}  ✓ $PROJECT_NAME → ${PROFILES[$PROFILE_IDX]} (Port $PORT)${NC}"
    echo ""
done

# Ask for VPS configuration
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}VPS Configuration (optional - press Enter to skip):${NC}"
read -p "VPS Host (e.g., 72.61.197.216): " VPS_HOST
VPS_HOST=${VPS_HOST:-"localhost"}

read -p "VPS SSH Port (default: 22): " VPS_PORT
VPS_PORT=${VPS_PORT:-22}

read -p "VPS User (default: $USER): " VPS_USER
VPS_USER=${VPS_USER:-$USER}

read -p "SSH Key Path (default: ~/.ssh/id_rsa): " SSH_KEY
SSH_KEY=${SSH_KEY:-"~/.ssh/id_rsa"}

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📍 Downloading Chrome Remote Pro...${NC}"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download source files (you'll host these on your website)
SOURCE_URL="https://your-website.com/chrome-remote-pro"

echo "Downloading from $SOURCE_URL..."

# For now, copy from local if available
if [ -d "$HOME/ChromeRemotePro" ]; then
    echo "Using local source files..."
    cp -r "$HOME/ChromeRemotePro" .
else
    echo -e "${RED}❌ Source files not found${NC}"
    echo "Please download manually from: $SOURCE_URL"
    exit 1
fi

echo ""
echo -e "${BLUE}📍 Compiling...${NC}"

cd ChromeRemotePro
swiftc -o ChromeRemotePro \
    -framework SwiftUI \
    -framework AppKit \
    -framework Combine \
    AppDelegate.swift \
    ContentView.swift \
    AddProjectView.swift \
    Models.swift \
    ProjectManager.swift \
    SessionSyncManager.swift 2>&1 | grep -v warning

if [ ! -f "ChromeRemotePro" ]; then
    echo -e "${RED}❌ Compilation failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Compilation successful${NC}"

# Create .app bundle
echo ""
echo -e "${BLUE}📍 Creating application bundle...${NC}"

APP_NAME="Chrome Remote Pro"
APP_PATH="$HOME/Applications/$APP_NAME.app"

rm -rf "$APP_PATH" 2>/dev/null

mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

cp ChromeRemotePro "$APP_PATH/Contents/MacOS/"
chmod +x "$APP_PATH/Contents/MacOS/ChromeRemotePro"

# Create Info.plist
cat > "$APP_PATH/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ChromeRemotePro</string>
    <key>CFBundleIdentifier</key>
    <string>com.chromeremotepro.app</string>
    <key>CFBundleName</key>
    <string>Chrome Remote Pro</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>2.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

xattr -cr "$APP_PATH"
chmod -R 755 "$APP_PATH"

echo -e "${GREEN}✅ Application bundle created${NC}"

# Create configuration file
echo ""
echo -e "${BLUE}📍 Creating configuration...${NC}"

CONFIG_PATH="$HOME/.chrome_remote_pro_config.json"

cat > "$CONFIG_PATH" << EOF
{
  "sshKeyPath": "$SSH_KEY",
  "sshPort": $VPS_PORT,
  "sshHost": "$VPS_HOST",
  "sshUser": "$VPS_USER",
  "projects": [
EOF

# Add projects to config
for idx in "${!SELECTED_PROJECTS[@]}"; do
    IFS='|' read -r NAME PROFILE PORT <<< "${SELECTED_PROJECTS[$idx]}"

    if [ $idx -eq 0 ]; then
        COMMA=""
    else
        COMMA=","
    fi

    cat >> "$CONFIG_PATH" << EOF
$COMMA    {
      "id": "$(uuidgen)",
      "name": "$NAME",
      "chromeProfile": "$PROFILE",
      "port": $PORT,
      "isActive": false,
      "chromeStatus": "inactive",
      "tunnelStatus": "inactive",
      "vpsStatus": "inactive"
    }
EOF
done

cat >> "$CONFIG_PATH" << 'EOF'
  ]
}
EOF

echo -e "${GREEN}✅ Configuration created${NC}"

# Clean up
cd "$HOME"
rm -rf "$TEMP_DIR"

# Refresh LaunchPad
killall Dock 2>/dev/null || true

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}🎉 Installation complete!${NC}"
echo ""
echo "Your projects:"
for idx in "${!SELECTED_PROJECTS[@]}"; do
    IFS='|' read -r NAME PROFILE PORT <<< "${SELECTED_PROJECTS[$idx]}"
    echo "  • $NAME ($PROFILE) → Port $PORT"
done
echo ""
echo "To launch:"
echo "  1. Open LaunchPad"
echo "  2. Search for 'Chrome Remote Pro'"
echo "  3. Click to launch"
echo ""
echo "Or run: open '$APP_PATH'"
echo ""
echo -e "${BLUE}📖 Documentation: https://your-website.com/chrome-remote-pro/docs${NC}"
echo ""

# Ask to launch
read -p "Launch Chrome Remote Pro now? (y/n) " LAUNCH
if [[ "$LAUNCH" =~ ^[Yy]$ ]]; then
    open "$APP_PATH"
    echo ""
    echo -e "${GREEN}✅ Chrome Remote Pro launched!${NC}"
    echo "Look for the icon in your menu bar (top right)"
fi

echo ""
echo "Happy automating! 🚀"
echo ""
