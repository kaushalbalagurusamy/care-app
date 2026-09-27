#!/usr/bin/env bash
# ==============================================================================
# CARE App — Simulator Screen Capture Utility
# Takes a high-resolution screenshot from the active iOS Simulator.
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

OUTPUT_DIR="$REPO_ROOT/jayme-codex-instructions/screenshots"
mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="${1:-screen_${TIMESTAMP}.png}"
TARGET_PATH="$OUTPUT_DIR/$FILENAME"

# Verify simulator is booted
BOOTED_ID=$(xcrun simctl list devices booted 2>/dev/null | grep -E "iPhone|iPad" | head -n 1 | grep -o -E "\([A-F0-9-]+\)" | tr -d '()' || echo "")

if [ -z "$BOOTED_ID" ]; then
    echo "Error: No booted simulator found. Run ./jayme-codex-instructions/setup/setup_simulator.sh first."
    exit 1
fi

echo "Capturing simulator screen from device ($BOOTED_ID)..."
xcrun simctl io booted screenshot "$TARGET_PATH"

echo "Screenshot saved successfully:"
echo "$TARGET_PATH"
