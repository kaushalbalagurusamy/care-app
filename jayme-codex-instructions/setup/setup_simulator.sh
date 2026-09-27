#!/usr/bin/env bash
# ==============================================================================
# CARE App — Simulator Setup & Boot Script
# Boots the iOS Simulator and brings the window to the front.
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "Checking available iOS Simulator devices..."

# Prefer iPhone 16 Pro, else find any available iPhone simulator
DEVICE_NAME="iPhone 16 Pro"
DEVICE_ID=$(xcrun simctl list devices available 2>/dev/null | grep "$DEVICE_NAME" | head -n 1 | grep -o -E "\([A-F0-9-]+\)" | tr -d '()' || echo "")

if [ -z "$DEVICE_ID" ]; then
    DEVICE_NAME="iPhone"
    DEVICE_ID=$(xcrun simctl list devices available 2>/dev/null | grep -E "iPhone (16|17|15|14)" | head -n 1 | grep -o -E "\([A-F0-9-]+\)" | tr -d '()' || echo "")
fi

if [ -z "$DEVICE_ID" ]; then
    echo "Error: No iOS simulator devices found. Run ./jayme-codex-instructions/setup/doctor.sh"
    exit 1
fi

echo "Selected Simulator: $DEVICE_NAME ($DEVICE_ID)"

# Check if already booted
IS_BOOTED=$(xcrun simctl list devices 2>/dev/null | grep "$DEVICE_ID" | grep -c "Booted" || true)

if [ "$IS_BOOTED" -eq 0 ]; then
    echo "Booting simulator ($DEVICE_ID)..."
    xcrun simctl boot "$DEVICE_ID"
else
    echo "Simulator ($DEVICE_ID) is already booted."
fi

# Open Simulator GUI application
echo "Opening Simulator.app on your desktop..."
open -a Simulator

# Wait for simulator to be fully ready
xcrun simctl bootstatus "$DEVICE_ID" -b

echo "Simulator is booted, ready, and visible on screen!"
