# Helper Scripts

This directory contains bash scripts that automate common git workflows and support AI-assisted development.

## Overview

These scripts are designed to work together to streamline git operations, particularly when working with AI agents that generate commits and run quality checks.

## Available Scripts

### git-branch-setup.sh

Automated git branch setup for beads workflow - ensures proper branch management before starting tasks.

**Usage:**
```bash
./scripts/git-branch-setup.sh
```

**Features:**
- Auto-detects default branch (main/master) using `git rev-parse --abbrev-ref origin/HEAD`
- Handles three scenarios:
  - **On default branch:** Updates from origin, creates feature branch, sets upstream tracking
  - **On clean feature branch:** Validates no conflicts with default branch
  - **On diverged branch:** Detects conflicts (common with squash merges), offers resolution options
- Interactive prompts for branch naming
- Handles uncommitted changes (offers stashing)
- Sets upstream tracking automatically with `-u` flag
- Stops on errors with clear messages for manual intervention

**Workflow:**
1. Detects current and default branch
2. Checks for uncommitted changes (offers to stash)
3. Executes appropriate scenario:
   - **Scenario A (Default branch):** Pull → Create feature branch → Push with tracking
   - **Scenario B (Clean branch):** Test merge → No conflicts → Ready
   - **Scenario C (Diverged):** Test merge → Conflicts detected → Offer resolution

**Branch Naming:**
- Convention: `feature/<description>`
- Examples: `feature/user-profile-api`, `feature/fix-login-bug`

**Exit Codes:**
- `0` - Success (branch ready for work)
- `1` - Error (git operations failed, network issues, invalid input)

**Example:**
```bash
# Starting from main branch
./scripts/git-branch-setup.sh
# ℹ️  Default branch: main
# ℹ️  Current branch: main
# ℹ️  On default branch - updating from origin...
# ✅ Default branch updated
# 
# Enter feature branch name (without 'feature/' prefix): user-profile-api
# ℹ️  Creating branch: feature/user-profile-api
# ✅ Ready to work on feature/user-profile-api
```

**Integration with Beads:**
Git branch setup is **infrastructure preparation**, not tracked work. Run this BEFORE creating beads issues. See [beads-workflow.md](../agents/beads-workflow.md) for full workflow integration.

---

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

### validate-beads-state.sh

Validates beads task state before pushing code - ensures task tracking hygiene.

**Usage:**
```bash
./scripts/validate-beads-state.sh
```

**Features:**
- Checks beads initialization (`bd ready`)
- Detects uncommitted `.beads/` changes
- Finds tasks stuck in `in_progress` state
- Reviews open tasks summary
- Color-coded output (green=pass, yellow=warning, red=error)
- Returns appropriate exit codes for CI/CD integration

**Checks Performed:**
1. **Beads Initialization** - Verifies `bd init` was run
2. **Uncommitted Changes** - Checks for modified `.beads/*.jsonl` files
3. **Stale Tasks** - Finds tasks stuck in `in_progress` from previous sessions
4. **Open Tasks Review** - Summarizes pending work (informational)

**Exit Codes:**
- `0` - All validations passed
- `1` - Warnings found (review recommended)
- `2` - Critical errors (must fix before push)

**Example Output (All Pass):**
```bash
╔═══════════════════════════════════════════╗
║  Beads State Validation                   ║
╚═══════════════════════════════════════════╝

[1/4] Checking beads initialization...
✓ Beads initialized

[2/4] Checking for uncommitted beads changes...
✓ No uncommitted beads changes

[3/4] Checking for tasks stuck in 'in_progress'...
✓ No tasks stuck in 'in_progress'

[4/4] Reviewing open tasks...
✓ No open tasks

╔═══════════════════════════════════════════╗
║  Validation Summary                       ║
╚═══════════════════════════════════════════╝
✓ All validations passed!
  Safe to proceed with git push.
```

**Example Output (Warnings):**
```bash
[2/4] Checking for uncommitted beads changes...
⚠ WARNING: Uncommitted changes in .beads/
  Modified files:
     M .beads/issues.jsonl
  
  Action required:
    1. Run: bd sync --flush-only
    2. Run: git add .beads/issues.jsonl .beads/interactions.jsonl
    3. Run: git commit -m 'chore: sync beads tracking for [feature-name]'

[3/4] Checking for tasks stuck in 'in_progress'...
⚠ WARNING: 2 task(s) still in 'in_progress' state

  - planit-api-123: Implement user authentication
  - planit-api-124: Write tests for auth flow
  
  Action required:
    - If complete: bd close <id> --reason='...'
    - If partial: bd update <id> --notes='Progress: ...'
    - If blocked: bd update <id> --status=blocked
```

**Integration with Session Completion:**
```bash
# Include in session completion checklist
bd close beads-123 --reason="Feature complete"
bd sync --flush-only
git add .beads/issues.jsonl
git commit -m "chore: sync beads tracking"

# Run validation before pushing
./scripts/validate-beads-state.sh
git push
```

**When to Use:**
- Before `git push` (part of session completion protocol)
- After `bd sync --flush-only`
- When returning to a project after interruption
- As part of CI/CD pre-push hooks

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

### Pattern 1: Beads + Git Branch Setup

```bash
# 1. Setup git branch (infrastructure - not tracked)
./scripts/git-branch-setup.sh
# Creates feature/user-profile-api with upstream tracking

# 2. Create beads issue (tracking begins)
bd create --title="Add user profile API" --type=feature --priority=2 --json
# Returns: beads-102

# 3. Claim work
bd update beads-102 --status=in_progress --json

# 4. Make code changes
vim src/api/profile.ts

# 5. Run checks and commit
./scripts/run-precommit.sh
git add .
./scripts/create-commit.sh "feat: add user profile endpoint [beads-102]"

# 6. Close beads issue
bd close beads-102 --reason="Implemented GET /api/profile endpoint" --json
```

### Pattern 2: AI-Generated Commits

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

### Pattern 2: AI-Generated Commits

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

### Pattern 3: Pre-commit Validation

```bash
# For rapid development when tests are slow
./scripts/run-precommit.sh --skip-tests
git add .
git commit -m "wip: implementing feature X"
```

### Pattern 4: Fast Iteration (Skip Tests)

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
