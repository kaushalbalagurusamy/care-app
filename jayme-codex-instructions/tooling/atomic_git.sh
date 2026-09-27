#!/usr/bin/env bash
# ==============================================================================
# CARE App — Abstracted Atomic Git Manager
# Automates branch creation, checkpointing, rollback, commits, and pushing.
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

ACTION="${1:-status}"
ARG="${2:-}"

case "$ACTION" in
    start)
        if [ -z "$ARG" ]; then
            echo -e "${RED}Error: Branch feature slug required. Example: ./atomic_git.sh start new-quiz-route${NC}"
            exit 1
        fi
        BRANCH_NAME="jayme/${ARG}"
        echo -e "${BLUE}Creating / switching to branch: ${BOLD}${BRANCH_NAME}${NC}"
        git checkout -B "$BRANCH_NAME"
        echo -e "${GREEN}✓ Active branch is now ${BRANCH_NAME}${NC}"
        ;;

    checkpoint)
        MSG="${ARG:-wip: automatic pre-flight checkpoint}"
        echo -e "${BLUE}Saving local atomic checkpoint: '${MSG}'...${NC}"
        git add -A
        git commit -m "$MSG" --no-verify || echo "No changes to checkpoint."
        echo -e "${GREEN}✓ Checkpoint saved at $(git rev-parse --short HEAD)${NC}"
        ;;

    rollback)
        echo -e "${YELLOW}Executing atomic rollback to previous clean state...${NC}"
        git reset --hard HEAD~1 || git reset --hard HEAD
        git clean -fd
        echo -e "${GREEN}✓ Rolled back successfully to $(git rev-parse --short HEAD)${NC}"
        ;;

    commit)
        if [ -z "$ARG" ]; then
            echo -e "${RED}Error: Commit message required. Example: ./atomic_git.sh commit 'feat(routing): insert calm checkin'${NC}"
            exit 1
        fi
        echo -e "${BLUE}Committing atomic changes: '${ARG}'...${NC}"
        git add -A
        git commit -m "$ARG"
        echo -e "${GREEN}✓ Committed: $(git rev-parse --short HEAD) - ${ARG}${NC}"
        ;;

    push)
        CURRENT_BRANCH=$(git branch --show-current)
        echo -e "${BLUE}Pushing branch '${CURRENT_BRANCH}' to origin...${NC}"
        git push -u origin "$CURRENT_BRANCH"
        echo -e "${GREEN}✓ Pushed '${CURRENT_BRANCH}' to remote repository.${NC}"
        ;;

    status)
        CURRENT_BRANCH=$(git branch --show-current)
        echo -e "• Current branch: ${BOLD}${CURRENT_BRANCH}${NC}"
        echo -e "• Working tree status:"
        git status -s
        ;;

    *)
        echo -e "${RED}Unknown action: $ACTION${NC}"
        echo "Usage: ./atomic_git.sh {start <feature> | checkpoint <msg> | rollback | commit <msg> | push | status}"
        exit 1
        ;;
esac
