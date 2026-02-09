#!/usr/bin/env bash
set -euo pipefail

#==============================================================================
# validate-beads-state.sh - Validate beads task state before session end
#==============================================================================
# Description:
#   Checks for common beads workflow issues before pushing code:
#   - Uncommitted .beads/ changes
#   - Tasks stuck in "in_progress" state
#   - Missing bd sync
#
# Usage:
#   ~/.config/opencode/scripts/validate-beads-state.sh
#
# Exit Codes:
#   0 - All validations passed
#   1 - Validation warnings found (review recommended)
#   2 - Critical errors found (must fix before push)
#==============================================================================

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

EXIT_CODE=0

echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Beads State Validation                   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
echo

#------------------------------------------------------------------------------
# Check 1: Beads initialization
#------------------------------------------------------------------------------
echo -e "${BLUE}[1/4] Checking beads initialization...${NC}"

if ! bd ready --json &>/dev/null; then
    echo -e "${RED}✗ CRITICAL: Beads not initialized${NC}"
    echo -e "  Run: ${YELLOW}bd init${NC}"
    EXIT_CODE=2
else
    echo -e "${GREEN}✓ Beads initialized${NC}"
fi
echo

#------------------------------------------------------------------------------
# Check 2: Uncommitted beads changes
#------------------------------------------------------------------------------
echo -e "${BLUE}[2/4] Checking for uncommitted beads changes...${NC}"

if [ -d .beads ]; then
    # Check if .beads/ has uncommitted changes
    if git status --porcelain .beads/ 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}⚠ WARNING: Uncommitted changes in .beads/${NC}"
        echo -e "  Modified files:"
        git status --porcelain .beads/ | sed 's/^/    /'
        echo
        echo -e "  ${YELLOW}Action required:${NC}"
        echo -e "    1. Run: ${YELLOW}bd sync --flush-only${NC}"
        echo -e "    2. Run: ${YELLOW}git add .beads/issues.jsonl .beads/interactions.jsonl${NC}"
        echo -e "    3. Run: ${YELLOW}git commit -m 'chore: sync beads tracking for [feature-name]'${NC}"
        EXIT_CODE=1
    else
        echo -e "${GREEN}✓ No uncommitted beads changes${NC}"
    fi
else
    echo -e "${YELLOW}⚠ WARNING: No .beads/ directory found${NC}"
    echo -e "  This project may not be using beads, or beads needs initialization."
fi
echo

#------------------------------------------------------------------------------
# Check 3: Tasks stuck in "in_progress"
#------------------------------------------------------------------------------
echo -e "${BLUE}[3/4] Checking for tasks stuck in 'in_progress'...${NC}"

if command -v bd &>/dev/null; then
    IN_PROGRESS=$(bd list --status=in_progress --json 2>/dev/null | jq -r 'length' || echo "0")
    
    if [ "$IN_PROGRESS" -gt 0 ]; then
        echo -e "${YELLOW}⚠ WARNING: $IN_PROGRESS task(s) still in 'in_progress' state${NC}"
        echo
        bd list --status=in_progress --json 2>/dev/null | jq -r '.[] | "  - \(.id): \(.title)"' || true
        echo
        echo -e "  ${YELLOW}Action required:${NC}"
        echo -e "    - If complete: ${YELLOW}bd close <id> --reason='...'${NC}"
        echo -e "    - If partial: ${YELLOW}bd update <id> --notes='Progress: ...'${NC}"
        echo -e "    - If blocked: ${YELLOW}bd update <id> --status=blocked${NC}"
        EXIT_CODE=1
    else
        echo -e "${GREEN}✓ No tasks stuck in 'in_progress'${NC}"
    fi
else
    echo -e "${YELLOW}⚠ WARNING: bd command not found, skipping task check${NC}"
fi
echo

#------------------------------------------------------------------------------
# Check 4: Open tasks review
#------------------------------------------------------------------------------
echo -e "${BLUE}[4/4] Reviewing open tasks...${NC}"

if command -v bd &>/dev/null; then
    OPEN_COUNT=$(bd list --status=open --json 2>/dev/null | jq -r 'length' || echo "0")
    
    if [ "$OPEN_COUNT" -gt 0 ]; then
        echo -e "${BLUE}ℹ INFO: $OPEN_COUNT open task(s) pending${NC}"
        echo -e "  (This is normal - just documenting remaining work)"
        echo
        bd list --status=open --json 2>/dev/null | jq -r '.[] | "  - \(.id): \(.title) (priority: \(.priority))"' | head -5 || true
        if [ "$OPEN_COUNT" -gt 5 ]; then
            echo -e "  ... and $(($OPEN_COUNT - 5)) more"
        fi
    else
        echo -e "${GREEN}✓ No open tasks${NC}"
    fi
else
    echo -e "${YELLOW}⚠ WARNING: bd command not found, skipping open tasks check${NC}"
fi
echo

#------------------------------------------------------------------------------
# Summary
#------------------------------------------------------------------------------
echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Validation Summary                       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    echo -e "  Safe to proceed with git push."
elif [ $EXIT_CODE -eq 1 ]; then
    echo -e "${YELLOW}⚠ Warnings found - review recommended${NC}"
    echo -e "  Fix warnings above before pushing to ensure proper task tracking."
else
    echo -e "${RED}✗ Critical errors found - must fix before push${NC}"
    echo -e "  Address errors above before proceeding."
fi

echo

exit $EXIT_CODE
