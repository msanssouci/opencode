#!/bin/bash

# get-git-context.sh - Outputs git context for commit message generation
# Usage: get-git-context.sh [--staged-only]
# Output: JSON with diff, files changed, and commitlint config

set -o pipefail

STAGED_ONLY=false
[[ "$1" == "--staged-only" ]] && STAGED_ONLY=true

# Guard: must be in a git repository
git rev-parse --git-dir >/dev/null 2>&1 || { echo '{"error": "not a git repository"}'; exit 1; }

# Get diff based on mode
if [ "$STAGED_ONLY" = true ]; then
    DIFF=$(git diff --cached --diff-filter=d --text 2>/dev/null || echo "")
    FILES=$(git diff --cached --name-status 2>/dev/null || echo "")
else
    DIFF=$(git diff --diff-filter=d --text 2>/dev/null || echo "")
    STAGED_DIFF=$(git diff --cached --diff-filter=d --text 2>/dev/null || echo "")
    [ -n "$STAGED_DIFF" ] && DIFF="${STAGED_DIFF}"$'\n'"${DIFF}"
    FILES=$(git status --porcelain 2>/dev/null || echo "")
fi

# Check for changes
[ -z "$DIFF" ] && [ -z "$FILES" ] && { echo '{"error": "no changes detected"}'; exit 2; }

# Get commitlint config if exists
COMMITLINT_CONFIG=""
for config_file in commitlint.config.ts commitlint.config.js commitlint.config.json .commitlintrc.ts .commitlintrc.js .commitlintrc.json; do
    if [ -f "$config_file" ]; then
        COMMITLINT_CONFIG=$(cat "$config_file" 2>/dev/null || echo "")
        break
    fi
done

# Count lines for warning
DIFF_LINES=$(echo "$DIFF" | wc -l | tr -d ' ')

# Output as structured text (easier for Claude to parse)
echo "=== GIT CONTEXT ==="
echo ""
echo "--- FILES CHANGED ---"
echo "$FILES"
echo ""
echo "--- DIFF (${DIFF_LINES} lines) ---"
echo "$DIFF"

if [ -n "$COMMITLINT_CONFIG" ]; then
    echo ""
    echo "--- COMMITLINT CONFIG ---"
    echo "$COMMITLINT_CONFIG"
fi

[ "$DIFF_LINES" -gt 1000 ] && echo "" && echo "⚠️ WARNING: Large changeset ($DIFF_LINES lines)"

exit 0
