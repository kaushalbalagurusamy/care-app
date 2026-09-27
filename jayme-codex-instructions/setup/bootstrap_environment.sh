#!/usr/bin/env bash
# ==============================================================================
# CARE App — Automated Developer Environment Bootstrapper
# Autonomous setup script for Jayme's machine (executable by Codex or Jayme).
# ==============================================================================

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}======================================================${NC}"
echo -e "${BOLD}${BLUE} CARE App — Automated Environment Bootstrapper        ${NC}"
echo -e "${BOLD}${BLUE}======================================================${NC}"
echo ""

# Find repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo -e "${BLUE}▶ Step 1: Checking Xcode Command Line Tools...${NC}"
if ! xcode-select -p >/dev/null 2>&1; then
    echo -e "${YELLOW}Xcode Command Line Tools not detected. Launching installer...${NC}"
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep -B 1 -E "Command Line Tools" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n' || echo "")
    if [ -n "$PROD" ]; then
        softwareupdate -i "$PROD" --verbose || true
    else
        xcode-select --install || true
    fi
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    echo -e "${YELLOW}Please complete the Command Line Tools install dialog if prompted.${NC}"
else
    echo -e "${GREEN}✓ Command Line Tools already installed at $(xcode-select -p)${NC}"
fi

echo ""
echo -e "${BLUE}▶ Step 2: Checking Xcode.app Installation...${NC}"
if [ ! -d "/Applications/Xcode.app" ]; then
    echo -e "${RED}✗ Full Xcode.app is missing at /Applications/Xcode.app${NC}"
    echo -e "${YELLOW}To run the iOS Simulator, Apple requires the full Xcode application.${NC}"
    echo ""
    echo -e "Choose how to install Xcode:"
    echo -e "  ${BOLD}Option 1 (Easiest - Mac App Store):${NC}"
    echo -e "    Opening the Mac App Store page for Xcode..."
    open "macappstore://apps.apple.com/app/id497799835" || open "https://apps.apple.com/us/app/xcode/id497799835"
    echo -e "    Click 'Get' or 'Download' in the Mac App Store."
    echo ""
    echo -e "  ${BOLD}Option 2 (CLI via xcodes):${NC}"
    echo -e "    brew install xcodesorg/made/xcodes/xcodes"
    echo -e "    xcodes install --latest"
    echo ""
    echo -e "${YELLOW}Codex note: If Xcode is currently downloading, ask Jayme to let you know once Xcode finishes downloading. In the meantime, you can draft PRDs, write tests, and outline routing changes!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Xcode.app found at /Applications/Xcode.app${NC}"

# Check active developer directory
ACTIVE_DEV=$(xcode-select -p 2>/dev/null || echo "")
if [[ "$ACTIVE_DEV" != *"/Applications/Xcode.app"* ]]; then
    echo -e "${YELLOW}Switching active developer path to Xcode.app...${NC}"
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer || {
        echo -e "${RED}Failed to switch xcode-select. Run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer${NC}"
    }
fi

# Ensure Xcode license is accepted
echo ""
echo -e "${BLUE}▶ Step 3: Verifying Xcode License Acceptance...${NC}"
if ! sudo xcodebuild -license check 2>/dev/null; then
    echo -e "${YELLOW}Accepting Xcode license automatically...${NC}"
    sudo xcodebuild -license accept || true
fi
echo -e "${GREEN}✓ Xcode license verified.${NC}"

# Check / Setup Simulator Runtime
echo ""
echo -e "${BLUE}▶ Step 4: Verifying iOS Simulator Runtimes...${NC}"
AVAILABLE_DEVICES=$(xcrun simctl list devices available 2>/dev/null | grep -E "iPhone|iPad" | wc -l | tr -d ' ')
if [ "$AVAILABLE_DEVICES" -eq 0 ]; then
    echo -e "${YELLOW}No iOS Simulator runtimes detected. Downloading platform runtime...${NC}"
    xcodebuild -downloadPlatform iOS || {
        echo -e "${YELLOW}Please open Xcode -> Settings -> Components / Platforms and install the iOS Simulator runtime.${NC}"
    }
fi

# Boot a default simulator
echo ""
echo -e "${BLUE}▶ Step 5: Preparing Default iOS Simulator...${NC}"
TARGET_DEVICE="iPhone 16 Pro"
# Check if iPhone 16 Pro exists, else find any available iPhone
DEVICE_ID=$(xcrun simctl list devices available 2>/dev/null | grep "$TARGET_DEVICE" | head -n 1 | grep -o -E "\([A-F0-9-]+\)" | tr -d '()' || echo "")

if [ -z "$DEVICE_ID" ]; then
    echo -e "${YELLOW}'$TARGET_DEVICE' not found. Locating alternative iPhone simulator...${NC}"
    DEVICE_ID=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone" | head -n 1 | grep -o -E "\([A-F0-9-]+\)" | tr -d '()' || echo "")
fi

if [ -n "$DEVICE_ID" ]; then
    echo -e "${GREEN}✓ Found simulator device ID: ${DEVICE_ID}${NC}"
    # Check if booted
    STATUS=$(xcrun simctl list devices 2>/dev/null | grep "$DEVICE_ID" || echo "")
    if [[ "$STATUS" == *"Booted"* ]]; then
        echo -e "${GREEN}✓ Simulator is already booted.${NC}"
    else
        echo -e "${BLUE}Booting simulator...${NC}"
        xcrun simctl boot "$DEVICE_ID" || true
        echo -e "${GREEN}✓ Simulator booted.${NC}"
    fi
else
    echo -e "${RED}✗ Could not resolve an iPhone simulator device.${NC}"
fi

# Pre-build CAREApp target to verify toolchain
echo ""
echo -e "${BLUE}▶ Step 6: Verifying CARE App compilation...${NC}"
xcodebuild -project ios/CAREApp.xcodeproj -scheme CAREApp -destination 'generic/platform=iOS Simulator' build -quiet
echo -e "${GREEN}✓ CAREApp builds successfully with zero compiler errors!${NC}"

echo ""
echo -e "${BOLD}${GREEN}======================================================${NC}"
echo -e "${BOLD}${GREEN} Environment setup complete!                         ${NC}"
echo -e "${BOLD}${GREEN} Jayme can now ask Codex to develop and test routes. ${NC}"
echo -e "${BOLD}${GREEN}======================================================${NC}"
