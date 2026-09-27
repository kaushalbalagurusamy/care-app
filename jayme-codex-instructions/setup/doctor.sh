#!/usr/bin/env bash
# ==============================================================================
# CARE App — Jayme & Codex Environment Doctor
# Evaluates local macOS system readiness for native iOS development & simulator testing.
# ==============================================================================

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}======================================================${NC}"
echo -e "${BOLD}${BLUE} CARE App — Environment Health Check & Diagnostics    ${NC}"
echo -e "${BOLD}${BLUE}======================================================${NC}"
echo ""

ALL_PASS=true

# 1. OS & Architecture Check
OS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "Unknown")
ARCH=$(uname -m)
echo -e "• macOS Version: ${BOLD}${OS_VERSION}${NC} (${ARCH})"

# 2. Command Line Tools
echo -n "• Xcode Command Line Tools: "
if xcode-select -p >/dev/null 2>&1; then
    CLT_PATH=$(xcode-select -p)
    echo -e "${GREEN}✓ Installed (${CLT_PATH})${NC}"
else
    echo -e "${RED}✗ Missing${NC}"
    echo -e "  ${YELLOW}Fix: Run 'xcode-select --install'${NC}"
    ALL_PASS=false
fi

# 3. Xcode.app Full Installation
echo -n "• Full Xcode.app: "
if [ -d "/Applications/Xcode.app" ]; then
    XCODE_BUILD=$(xcodebuild -version 2>/dev/null | head -n 1 || echo "Xcode installed")
    echo -e "${GREEN}✓ Found (${XCODE_BUILD})${NC}"
    
    # Check if xcode-select points to Xcode.app
    ACTIVE_DEV=$(xcode-select -p 2>/dev/null || echo "")
    if [[ "$ACTIVE_DEV" != *"/Applications/Xcode.app"* ]]; then
        echo -e "  ${YELLOW}! Warning: Active developer directory is '${ACTIVE_DEV}'.${NC}"
        echo -e "  ${YELLOW}  Fix: Run 'sudo xcode-select -s /Applications/Xcode.app/Contents/Developer'${NC}"
    fi
else
    echo -e "${RED}✗ Not found at /Applications/Xcode.app${NC}"
    echo -e "  ${YELLOW}Required for iOS Simulator. Install from the Mac App Store or using 'xcodes'.${NC}"
    ALL_PASS=false
fi

# 4. Swift Compiler
echo -n "• Swift Compiler: "
if command -v swift >/dev/null 2>&1; then
    SWIFT_VER=$(swift --version 2>/dev/null | head -n 1)
    echo -e "${GREEN}✓ Available (${SWIFT_VER})${NC}"
else
    echo -e "${RED}✗ Not found in PATH${NC}"
    ALL_PASS=false
fi

# 5. iOS Simulator & simctl
echo -n "• iOS Simulator Runtime: "
if command -v xcrun >/dev/null 2>&1 && xcrun simctl list devices >/dev/null 2>&1; then
    DEVICE_COUNT=$(xcrun simctl list devices available 2>/dev/null | grep -E "iPhone|iPad" | wc -l | tr -d ' ')
    if [ "$DEVICE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✓ Available (${DEVICE_COUNT} simulator devices ready)${NC}"
        BOOTED_DEVICE=$(xcrun simctl list devices booted 2>/dev/null | grep -E "iPhone|iPad" | head -n 1 || echo "")
        if [ -n "$BOOTED_DEVICE" ]; then
            echo -e "  • Booted Simulator: ${GREEN}${BOOTED_DEVICE//    /}${NC}"
        else
            echo -e "  • Simulator Status: ${YELLOW}Currently shutdown (can be booted automatically)${NC}"
        fi
    else
        echo -e "${YELLOW}! Installed, but no available iOS devices found.${NC}"
        echo -e "  ${YELLOW}Fix: Open Xcode -> Settings -> Platforms -> Download iOS Simulator.${NC}"
        ALL_PASS=false
    fi
else
    echo -e "${RED}✗ xcrun simctl not functional (Xcode required)${NC}"
    ALL_PASS=false
fi

# 6. Git Status & Identity
echo -n "• Git Version Control: "
if command -v git >/dev/null 2>&1; then
    GIT_VER=$(git --version)
    USER_NAME=$(git config user.name || echo "Not configured")
    USER_EMAIL=$(git config user.email || echo "Not configured")
    echo -e "${GREEN}✓ Installed (${GIT_VER})${NC}"
    echo -e "  • Git User: ${BOLD}${USER_NAME} <${USER_EMAIL}>${NC}"
    
    # Check repository state
    REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
    if [ -n "$REPO_ROOT" ]; then
        CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
        echo -e "  • Active Branch: ${BOLD}${CURRENT_BRANCH}${NC}"
    fi
else
    echo -e "${RED}✗ Git missing${NC}"
    ALL_PASS=false
fi

# 7. Monorepo Project Structure
echo -n "• CARE App iOS Project File: "
if [ -f "ios/CAREApp.xcodeproj/project.pbxproj" ]; then
    echo -e "${GREEN}✓ Found (ios/CAREApp.xcodeproj)${NC}"
else
    echo -e "${RED}✗ Missing ios/CAREApp.xcodeproj${NC}"
    ALL_PASS=false
fi

echo ""
echo -e "${BOLD}${BLUE}------------------------------------------------------${NC}"
if [ "$ALL_PASS" = true ]; then
    echo -e "${BOLD}${GREEN}All critical dependencies are present! Jayme & Codex are ready to build.${NC}"
    exit 0
else
    echo -e "${BOLD}${YELLOW}Some components require setup. Run './jayme-codex-instructions/setup/bootstrap_environment.sh' to configure.${NC}"
    exit 1
fi
