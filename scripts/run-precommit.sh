#!/bin/bash

# run-precommit.sh - Run pre-commit checks (format, typecheck, lint, test)
# Usage: run-precommit.sh [--skip-tests]
# Exit codes: 0 = success, 1 = no package.json, 3 = check failed

set -o pipefail

SKIP_TESTS=false
[[ "$1" == "--skip-tests" ]] && SKIP_TESTS=true

# Guard: need package.json
[ -f "package.json" ] || { echo "ℹ️ No package.json found, skipping pre-commit checks"; exit 0; }

# Detect package manager
detect_package_manager() {
    [ -f "package-lock.json" ] && echo "npm" && return
    [ -f "yarn.lock" ] && echo "yarn" && return
    [ -f "pnpm-lock.yaml" ] && echo "pnpm" && return
    [ -f "bun.lockb" ] && echo "bun" && return
    [ -f "package.json" ] && echo "npm" && return
    echo ""
}

PKG_MANAGER=$(detect_package_manager)
[ -z "$PKG_MANAGER" ] && { echo "ℹ️ No package manager detected"; exit 0; }

# Check if script exists in package.json
has_script() {
    local script_name="$1"
    node -e "const p=require('./package.json'); process.exit(p.scripts && p.scripts['$script_name'] ? 0 : 1)" 2>/dev/null
}

# Run a script with error handling
run_script() {
    local script_name="$1"
    local display_name="$2"
    local restage="$3"

    has_script "$script_name" || return 0

    echo "🔄 Running ${display_name}..."
    if ! $PKG_MANAGER run "$script_name"; then
        echo "❌ ${display_name} failed"
        exit 3
    fi

    [ "$restage" = "true" ] && git add .
    echo "✅ ${display_name} passed"
}

echo "🔍 Running pre-commit checks with ${PKG_MANAGER}..."

run_script "format" "format" "true"
run_script "typecheck" "typecheck" "false"
run_script "lint" "lint" "true"

if [ "$SKIP_TESTS" = false ]; then
    run_script "test" "tests" "false"
fi

echo "✅ All pre-commit checks passed"

exit 0
