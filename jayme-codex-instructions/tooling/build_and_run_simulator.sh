#!/usr/bin/env bash
# ==============================================================================
# CARE App — Build and Run on iOS Simulator
# Compiles CAREApp, boots simulator, installs app, and launches it.
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}======================================================${NC}"
echo -e "${BOLD}${BLUE} CARE App — Build & Launch Simulator                  ${NC}"
echo -e "${BOLD}${BLUE}======================================================${NC}"

# Ensure a simulator is booted
echo -e "${BLUE}1. Checking Simulator status...${NC}"
BOOTED_ID=$(xcrun simctl list devices booted 2>/dev/null | grep -E "iPhone|iPad" | head -n 1 | grep -o -E "\([A-F0-9-]+\)" | tr -d '()' || echo "")

if [ -z "$BOOTED_ID" ]; then
    echo -e "${YELLOW}No booted simulator found. Booting default simulator...${NC}"
    "$REPO_ROOT/jayme-codex-instructions/setup/setup_simulator.sh"
    BOOTED_ID=$(xcrun simctl list devices booted 2>/dev/null | grep -E "iPhone|iPad" | head -n 1 | grep -o -E "\([A-F0-9-]+\)" | tr -d '()' || echo "")
fi

echo -e "${GREEN}✓ Active simulator: $BOOTED_ID${NC}"

# Build app for simulator
echo -e "${BLUE}2. Compiling CARE App for iOS Simulator...${NC}"
DERIVED_DATA_PATH="$REPO_ROOT/ios/build"

xcodebuild -project ios/CAREApp.xcodeproj \
    -scheme CAREApp \
    -destination "id=$BOOTED_ID" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -configuration Debug \
    build -quiet

echo -e "${GREEN}✓ Build succeeded!${NC}"

# Locate the .app bundle
APP_BUNDLE=$(find "$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator" -name "CAREApp.app" -type d | head -n 1 || echo "")

if [ -z "$APP_BUNDLE" ]; then
    # Fallback to default DerivedData location
    APP_BUNDLE=$(find ~/Library/Developer/Xcode/DerivedData/CAREApp-*/Build/Products/Debug-iphonesimulator -name "CAREApp.app" -type d 2>/dev/null | head -n 1 || echo "")
fi

if [ -z "$APP_BUNDLE" ] || [ ! -d "$APP_BUNDLE" ]; then
    echo -e "${RED}Error: Could not locate compiled CAREApp.app bundle.${NC}"
    exit 1
fi

echo -e "• App bundle: $APP_BUNDLE"

# Install on booted simulator
echo -e "${BLUE}3. Installing CARE App into simulator...${NC}"
xcrun simctl install booted "$APP_BUNDLE"

# Terminate existing instance if active
xcrun simctl terminate booted com.careapp.CAREApp 2>/dev/null || true

# Launch the app
echo -e "${BLUE}4. Launching CARE App...${NC}"
xcrun simctl launch booted com.careapp.CAREApp

# Bring simulator window to front
open -a Simulator

echo -e "${BOLD}${GREEN}======================================================${NC}"
echo -e "${BOLD}${GREEN} CARE App is running live on the iOS Simulator!      ${NC}"
echo -e "${BOLD}${GREEN} Jayme can now test the screens and routing directly. ${NC}"
echo -e "${BOLD}${GREEN}======================================================${NC}"
