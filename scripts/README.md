# Helper Scripts

This directory contains bash scripts that automate common git workflows and support AI-assisted development.

## Overview

These scripts are designed to work together to streamline git operations, particularly when working with AI agents that generate commits and run quality checks.

## Available Scripts

### create-commit.sh

Creates a git commit with the provided message.

**Usage:**
```bash
./scripts/create-commit.sh "commit message"
```

**Features:**
- Validates commit message is provided
- Checks for staged changes before committing
- Creates commit with clear success/failure messaging
- Returns meaningful exit codes for automation

**Exit Codes:**
- `0` - Success
- `1` - No commit message provided
- `2` - No staged changes to commit
- `5` - Git commit failed

**Example:**
```bash
git add src/
./scripts/create-commit.sh "feat: add user authentication"
# ✅ Commit created successfully!
```

---

### get-git-context.sh

Extracts git context (diffs, file changes) for AI commit message generation.

**Usage:**
```bash
./scripts/get-git-context.sh [--staged-only]
```

**Options:**
- `--staged-only` - Only show staged changes (default: all changes)

**Features:**
- Outputs structured git context in text format
- Includes file changes and diffs
- Detects and includes commitlint configuration if present
- Warns on large changesets (>1000 lines)
- Guards against running outside git repository

**Exit Codes:**
- `0` - Success
- `1` - Not in a git repository
- `2` - No changes detected

**Output Format:**
```
=== GIT CONTEXT ===

--- FILES CHANGED ---
M  src/auth.ts
A  src/utils.ts

--- DIFF (42 lines) ---
diff --git a/src/auth.ts b/src/auth.ts
...

--- COMMITLINT CONFIG ---
module.exports = { ... }
```

**Example:**
```bash
./scripts/get-git-context.sh --staged-only
# Outputs context for AI to analyze and generate commit message
```

---

### run-precommit.sh

Runs pre-commit checks (format, typecheck, lint, test) before committing.

**Usage:**
```bash
./scripts/run-precommit.sh [--skip-tests]
```

**Options:**
- `--skip-tests` - Skip running tests (faster for quick commits)

**Features:**
- Auto-detects package manager (npm, yarn, pnpm, bun)
- Runs available scripts from package.json:
  - `format` - Auto-formats code (re-stages if changed)
  - `typecheck` - Validates TypeScript types
  - `lint` - Runs linter (re-stages if auto-fixed)
  - `test` - Runs test suite
- Skips checks if no package.json found
- Re-stages files after formatting/linting
- Clear progress and error messaging

**Exit Codes:**
- `0` - All checks passed (or skipped)
- `1` - No package.json found (graceful skip)
- `3` - A check failed

**Example:**
```bash
git add .
./scripts/run-precommit.sh
# 🔍 Running pre-commit checks with bun...
# 🔄 Running format...
# ✅ format passed
# 🔄 Running typecheck...
# ✅ typecheck passed
# ✅ All pre-commit checks passed
```

## Integration Patterns

### Pattern 1: AI-Generated Commits

```bash
# 1. Make code changes
vim src/auth.ts

# 2. Stage changes
git add src/

# 3. Extract context for AI
./scripts/get-git-context.sh --staged-only > /tmp/git-context.txt

# 4. AI analyzes context and generates commit message
# (This happens in OpenCode via git-commit agent)

# 5. Create commit with AI-generated message
./scripts/create-commit.sh "feat: add JWT authentication middleware"
```

### Pattern 2: Pre-commit Validation

```bash
# 1. Make changes
vim src/

# 2. Run checks before committing
./scripts/run-precommit.sh

# 3. Stage changes (including any auto-fixes)
git add .

# 4. Commit
git commit -m "fix: resolve linting issues"
```

### Pattern 3: Fast Iteration (Skip Tests)

```bash
# For rapid development when tests are slow
./scripts/run-precommit.sh --skip-tests
git add .
git commit -m "wip: implementing feature X"
```

## Best Practices

- **Run pre-commit checks before committing** to catch issues early
- **Use staged-only mode** when generating commit messages for cleaner context
- **Re-run checks after AI auto-fixes** to ensure quality
- **Integrate with git hooks** (optional) for automatic validation
- **Keep commits atomic** - each commit should pass all checks

## Adding Custom Scripts

To add new helper scripts:

1. Create a bash script with clear purpose
2. Add usage comments at the top
3. Use guard clauses for error handling
4. Return meaningful exit codes
5. Follow the patterns in existing scripts
6. Document in this README

## Requirements

- Bash shell
- Git installed
- Node.js/Bun (for run-precommit.sh)
- package.json with scripts (for run-precommit.sh)

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on improving scripts or adding new ones.
