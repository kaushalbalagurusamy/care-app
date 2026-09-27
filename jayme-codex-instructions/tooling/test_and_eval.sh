#!/usr/bin/env bash
# ==============================================================================
# CARE App — Test and Eval Loop Runner
# Autonomous evaluation runner for Codex to verify that all contracts pass.
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

TARGET_TEST="${1:-}"

# Find booted simulator or use first available iPhone
BOOTED_ID=$(xcrun simctl list devices booted 2>/dev/null | grep -E "iPhone|iPad" | head -n 1 | grep -o -E "\([A-F0-9-]+\)" | tr -d '()' || echo "")

if [ -z "$BOOTED_ID" ]; then
    BOOTED_ID=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone 16 Pro" | head -n 1 | grep -o -E "\([A-F0-9-]+\)" | tr -d '()' || echo "")
fi

if [ -z "$BOOTED_ID" ]; then
    BOOTED_ID=$(xcrun simctl list devices available 2>/dev/null | grep -E "iPhone (17|16|15|14)" | head -n 1 | grep -o -E "\([A-F0-9-]+\)" | tr -d '()' || echo "")
fi

if [ -z "$BOOTED_ID" ]; then
    echo -e "${RED}Error: No simulator available for running tests.${NC}"
    exit 1
fi

DESTINATION="id=$BOOTED_ID"
echo -e "${BLUE}Running test evaluation on simulator (${DESTINATION})...${NC}"

CMD=(xcodebuild -project ios/CAREApp.xcodeproj -scheme CAREApp -destination "$DESTINATION")

if [ -n "$TARGET_TEST" ]; then
    echo -e "${BLUE}Targeting specific test: ${BOLD}${TARGET_TEST}${NC}"
    CMD+=("-only-testing:${TARGET_TEST}")
else
    # Default fast test ladder: Model, Component, Screen, Navigation tests
    CMD+=("-only-testing:CAREAppTests/AppRouterTests")
    CMD+=("-only-testing:CAREAppTests/DomainModelAndScoringTests")
    CMD+=("-only-testing:CAREAppTests/AtomicComponentTests")
    CMD+=("-only-testing:CAREAppTests/ScreenViewTests")
fi

CMD+=("test")

# Run xcodebuild and capture output
LOG_FILE="/tmp/care_app_test_eval.log"
set +e
"${CMD[@]}" > "$LOG_FILE" 2>&1
TEST_EXIT_CODE=$?
set -e

# Analyze log for results
if [ $TEST_EXIT_CODE -eq 0 ]; then
    PASSED_COUNT=$(grep -c "✔ Test" "$LOG_FILE" || grep -c "passed after" "$LOG_FILE" || echo "all")
    echo -e "${BOLD}${GREEN}======================================================${NC}"
    echo -e "${BOLD}${GREEN} ✓ EVALUATION PASSED: All tests green (${PASSED_COUNT} passed) ${NC}"
    echo -e "${BOLD}${GREEN}======================================================${NC}"
    rm -f "$LOG_FILE"
    exit 0
else
    echo -e "${BOLD}${RED}======================================================${NC}"
    echo -e "${BOLD}${RED} ✗ EVALUATION FAILED: Test regressions detected       ${NC}"
    echo -e "${BOLD}${RED}======================================================${NC}"
    echo -e "${YELLOW}Failure diagnostics:${NC}"
    grep -E "✖ Test|error:|FAILED|failed after|failed with error" "$LOG_FILE" | tail -n 25 || tail -n 25 "$LOG_FILE"
    echo ""
    echo -e "${RED}Codex Rule: Do not exit implementation loop until this returns exit code 0!${NC}"
    rm -f "$LOG_FILE"
    exit 1
fi
