#!/bin/bash

# create-commit.sh - Create a git commit with the given message
# Usage: create-commit.sh "commit message"
# Exit codes: 0 = success, 1 = no message, 2 = no staged changes, 5 = commit failed

set -o pipefail

COMMIT_MESSAGE="$1"

# Guard: need a commit message
[ -z "$COMMIT_MESSAGE" ] && { echo "❌ Error: no commit message provided"; exit 1; }

# Guard: must have staged changes
[ -z "$(git diff --cached --name-only)" ] && { echo "❌ Error: no staged changes to commit"; exit 2; }

echo "📝 Creating commit..."
echo "----------------------------------------"
echo "$COMMIT_MESSAGE"
echo "----------------------------------------"

if git commit -m "$COMMIT_MESSAGE"; then
    echo "✅ Commit created successfully!"
    exit 0
else
    echo "❌ Error: git commit failed"
    exit 5
fi
