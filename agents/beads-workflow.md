---
Version: 1.2.0
Last Updated: 2026-02-09
Changelog:
- 1.2.0 (2026-02-09): Added Git Branch Setup checklist with upstream tracking and automation script
- 1.1.0 (2026-02-09): Added "Before You Start" section with bd init instructions
- 1.0.0 (2026-02-08): Initial creation - extracted from project AGENTS.md
---

# Beads Workflow - Universal Task Tracking

## 🚀 Before You Start

**IMPORTANT:** Beads must be initialized before use.

### Check if beads is initialized
```bash
bd ready --json
```

If you see `Error: no beads database found`, run:

```bash
bd init
```

This creates a `.beads/` directory with your task database. You only need to do this once per project.

---

## 🚨 Mandatory Usage Policy

**CRITICAL:** This guide applies to ALL projects using beads.

### Rules
- ✅ ALL agents MUST use beads for task tracking
- ❌ PROHIBITED: TodoWrite, TaskCreate, markdown TODO files, comments with TODO
- ❌ PROHIBITED: Starting code changes without a beads task
- ⚠️  CONSEQUENCE: Work without beads tracking may be lost between sessions

### Why Beads is Mandatory
1. **Session continuity**: Recover context after interruptions
2. **Collaboration**: Other agents/developers see your work
3. **Project health**: `bd stats` shows progress metrics
4. **Git integration**: Task IDs in commits enable traceability

---

## Core Commands Reference

### Finding Work
```bash
bd ready --json                    # Show issues ready to work (no blockers)
bd list --status=open --json       # All open issues
bd show <id> --json                # Detailed issue view with dependencies
bd blocked --json                  # Show blocked issues
```

### Creating & Updating
```bash
bd create --title="..." --type=task|bug|feature --priority=0-4 --json
  # Priority: 0=critical, 1=high, 2=medium, 3=low, 4=backlog
  # NOT "high"/"medium"/"low" strings

bd update <id> --status=in_progress --json
bd update <id> --assignee=username --json
bd update <id> --notes="Progress update" --json
bd close <id> --reason="Explanation" --json
bd close <id1> <id2> ... --reason="Batch close" --json  # More efficient
```

### Dependencies & Blocking
```bash
bd dep add <issue> <depends-on> --json
  # Reads as: <issue> depends on <depends-on>
  # Or: <depends-on> blocks <issue>

bd show <id> --json  # See dependency graph
```

### Sync & Export
```bash
bd sync --flush-only  # Export to JSONL (run at session end)
```

---

## 🌿 Git Branch Setup - Pre-Task Checklist

**CRITICAL:** Run this checklist BEFORE claiming any beads task.

### Why This Matters
- Prevents working on stale code
- Avoids merge conflicts later
- Keeps feature branches isolated
- Ensures clean pull request history

### 📘 Is Git Setup Tracked in Beads?

**No.** Git branch setup is **infrastructure preparation**, not tracked work.

**What IS tracked:**
- The bug fix, feature, or refactor you're implementing
- Progress notes on that work
- Completion reason for that work

**What is NOT tracked:**
- Running `bd init` to initialize beads
- Running `bd ready` to check available work
- Running `git-branch-setup.sh` to prepare your branch

**Workflow:**
1. Complete git branch setup ← infrastructure (not tracked)
2. Create beads issue for the actual work ← tracking begins here
3. Make code changes ← tracked work
4. Close beads issue ← tracking ends here

**Exception:** If git setup FAILS and requires investigation/debugging, THEN create a beads issue for "Debug git branch setup failure" because that's actual work.

### Step-by-Step Process

#### Step 1: Detect Default Branch
```bash
# Detect the default branch name (main/master/etc)
DEFAULT_BRANCH=$(git rev-parse --abbrev-ref origin/HEAD | sed 's|origin/||')
CURRENT_BRANCH=$(git branch --show-current)
echo "Default branch: $DEFAULT_BRANCH"
echo "Current branch: $CURRENT_BRANCH"
```

#### Step 2: Check Branch Status & Take Action

**Scenario A: On Default Branch**
```bash
# If CURRENT_BRANCH == DEFAULT_BRANCH:
git fetch origin
git pull origin $DEFAULT_BRANCH

# If pull fails with merge conflicts:
# ⚠️ STOP: Resolve conflicts manually, then retry

# Create feature branch with descriptive name
git checkout -b feature/<descriptive-name>
git push -u origin feature/<descriptive-name>

# Example: 
# git checkout -b feature/user-profile-api
# git push -u origin feature/user-profile-api
```

**Scenario B: On Existing Feature Branch - Check if Clean**
```bash
# Check if branch has diverged from main
git fetch origin

# Attempt test merge to detect conflicts
git merge --no-commit --no-ff origin/$DEFAULT_BRANCH

# If merge succeeds (no conflicts):
git merge --abort  # We were just testing
# ✅ Proceed with work

# If merge has conflicts:
# Go to Scenario C
```

**Scenario C: On Feature Branch - Diverged with Conflicts**
```bash
# Branch has conflicts with main (common with squash merges)
git merge --abort  # Abort the test merge

# ⚠️ STOP: Choose resolution strategy:

# Option 1: Start fresh (RECOMMENDED for squash-merged branches)
git checkout $DEFAULT_BRANCH
git pull origin $DEFAULT_BRANCH
git checkout -b feature/<new-descriptive-name>
git push -u origin feature/<new-descriptive-name>

# Option 2: Resolve conflicts on current branch
# (Only if this branch has unmerged work you want to keep)
git merge origin/$DEFAULT_BRANCH
# Resolve conflicts manually:
# 1. Fix conflicts in files
# 2. git add <resolved-files>
# 3. git commit -m "Merge main into feature branch"
# 4. git push
```

### 📘 Understanding Squash Merges

**Why does my merged branch show conflicts?**

When using **squash merging** (common in GitHub/GitLab):
1. Your feature branch commits: `A → B → C`
2. PR merged to main as single commit: `D` (combines A+B+C)
3. Your feature branch still has `A → B → C` in history
4. Main now has `D` but doesn't know it's the same as `A+B+C`
5. Git sees diverged history → reports conflicts

**Solution:** Start a fresh feature branch from updated main. The old feature branch served its purpose and can be deleted.

```bash
# After PR is merged via squash:
git checkout main
git pull origin main
git branch -D old-feature-branch  # Safe to delete
git checkout -b feature/next-task
```

### Branch Naming Convention
```bash
feature/<brief-description>

# Good examples:
feature/user-profile-api
feature/fix-login-null-pointer
feature/refactor-validation-utils

# Bad examples:
beads-102                    # Missing context
fix                          # Too vague
feature/beads-102-user-api   # Don't need beads ID in branch name
                            # (beads ID goes in commit messages instead)
```

### Remote Branch Tracking
```bash
# Always set upstream tracking when creating new branches
git push -u origin feature/<branch-name>

# This enables:
# - Simple 'git push' without specifying remote/branch
# - 'git pull' to fetch updates
# - Branch status in 'git status'
```

### Quick Decision Tree
```
Start
  │
  ├─ On default branch?
  │  YES → git pull → Create feature branch → git push -u → ✅ Ready
  │  NO ↓
  │
  ├─ Test merge with main (git merge --no-commit --no-ff)
  │  │
  │  ├─ No conflicts?
  │  │  YES → git merge --abort → ✅ Ready
  │  │  NO ↓
  │  │
  │  └─ Has conflicts
  │     │
  │     └─ ⚠️ STOP - Choose:
  │        • Start fresh branch (recommended for squash merges)
  │        • Resolve conflicts manually (if branch has unmerged work)
```

### Error Handling

**Uncommitted Changes:**
```bash
# If git pull/checkout fails due to uncommitted changes:
git stash push -m "WIP: switching branches"
# ... complete branch setup ...
git stash pop  # After switching branches
```

**Merge Conflicts:**
```bash
# ⚠️ STOP and resolve manually:
# 1. Review conflict files: git status
# 2. Edit files to resolve conflicts
# 3. Stage resolved files: git add <file>
# 4. Complete merge: git commit
# OR abort and start fresh: git merge --abort
```

**Network Issues:**
```bash
# If git fetch/pull fails:
# ⚠️ STOP: Check network connection
# Retry: git fetch origin --verbose
# If persists: Cannot proceed safely - resolve network issue first
```

**Origin HEAD Not Set:**
```bash
# If git rev-parse --abbrev-ref origin/HEAD fails:
# Run once to set it:
git remote set-head origin --auto

# Then retry the workflow
```

### 🤖 Automated Script (For Engineers)

A helper script is available at `~/.config/opencode/scripts/git-branch-setup.sh`

**Usage:**
```bash
# Run interactive setup
~/.config/opencode/scripts/git-branch-setup.sh

# The script handles all scenarios automatically
```

**What it does:**
- Detects default branch automatically
- Checks current branch status
- Handles all three scenarios (default/clean/diverged)
- Prompts for feature branch name when needed
- Sets upstream tracking automatically
- Stops on errors with clear messages

**Note for Agents:** Use the full manual workflow commands for transparency and better error handling. The script is for human convenience.

---

## Universal Workflow Patterns

### Pattern 1: Simple Bug Fix
```bash
# 0. Git Branch Setup (infrastructure - not tracked in beads)
# ⚠️ Complete BEFORE creating beads issue
# Run: ~/.config/opencode/scripts/git-branch-setup.sh (or follow manual steps above)

# 1. Create or find beads issue (tracking begins here)
bd ready --json
# OR
bd create --title="Fix null pointer in login" --type=bug --priority=1 --json

# 2. Claim work
bd update beads-xxx --status=in_progress --json

# 3. Make code changes
# [Your tech-specific workflow - see project AGENTS.md]

# 4. Close with context
bd close beads-xxx --reason="Fixed null check in AuthHandler.validate()" --json
```

### Pattern 2: Multi-Step Feature (Epic + Tasks)
```bash
# 0. Git Branch Setup (infrastructure - not tracked in beads)
# ⚠️ Complete BEFORE creating beads issue
# Run: ~/.config/opencode/scripts/git-branch-setup.sh (or follow manual steps above)

# 1. Create epic
bd create --title="User profile page" --type=feature --priority=2 --json
# Returns: beads-100

# 2. Create child tasks
bd create --title="Design profile schema" --type=task --priority=2 --json
# Returns: beads-101
bd create --title="Implement profile API" --type=task --priority=2 --json
# Returns: beads-102
bd create --title="Build profile UI" --type=task --priority=2 --json
# Returns: beads-103
bd create --title="Write E2E tests" --type=task --priority=2 --json
# Returns: beads-104

# 3. Set dependencies
bd dep add beads-102 beads-101 --json  # API depends on schema
bd dep add beads-103 beads-102 --json  # UI depends on API
bd dep add beads-104 beads-103 --json  # Tests depend on UI

# 4. Work through ready tasks
bd ready --json  # Shows beads-101 only (no blockers)
bd update beads-101 --status=in_progress --json
# [Work...]
bd close beads-101 --reason="Schema defined in models/" --json

bd ready --json  # Now shows beads-102 (blocker cleared)
# [Continue pattern...]
```

### Pattern 3: Refactoring
```bash
# 0. Git Branch Setup (infrastructure - not tracked in beads)
# ⚠️ Complete BEFORE creating beads issue
# Run: ~/.config/opencode/scripts/git-branch-setup.sh (or follow manual steps above)

# 1. Create scoped task
bd create --title="Extract validation logic to utility" \
  --type=task \
  --priority=3 \
  --description="Move validation from 3 controllers to shared ValidationUtils" \
  --json

# 2. Work with clear scope
bd update beads-xxx --status=in_progress --json

# 3. Document what changed
bd close beads-xxx --reason="Extracted to libs/utils/ValidationUtils.kt, updated 3 controllers" --json
```

### Pattern 4: Emergency Hotfix (Fast-Track)
```bash
# 0. Git Branch Setup (Modified for Hotfixes)
# For urgent production fixes:
# - If on default branch: git checkout -b hotfix/<description>
# - If on feature branch: Consider if this is the right place for a hotfix
# - For true emergencies: May work directly on main (document in beads issue!)

# 1. Create high-priority bug
bd create --title="PROD: Payment processing failing" --type=bug --priority=0 --json

# 2. Immediate claim
bd update beads-xxx --status=in_progress --json

# 3. Fix and close quickly
bd close beads-xxx --reason="Fixed race condition in PaymentProcessor.charge()" --json

# Note: Still tracked, but streamlined for urgency
```

---

## Technology-Specific Integration Points

### Backend (Any Language)
**When to create tasks:**
- Before implementing new endpoint/route
- Before adding service/business logic
- Before database migrations
- One test task per implementation task

**Example task titles:**
- "Add POST /api/users endpoint"
- "Implement UserService.createUser()"
- "Write tests for UserService"

### Frontend (Any Framework)
**When to create tasks:**
- Before creating new component
- Before adding API client method
- Before implementing page/route
- One test task per component

**Example task titles:**
- "Create UserProfile component"
- "Add users.create() API client method"
- "Write Jest tests for UserProfile"
- "Add E2E test for user registration flow"

### DevOps/Infrastructure
**When to create tasks:**
- Before Docker/Kubernetes config changes
- Before CI/CD pipeline modifications
- Before database/cache setup
- Include rollback notes in description

---

## Beads + Git Integration

### Branch Naming & Tracking
```bash
# Create feature branch BEFORE claiming work (part of git branch setup)
git checkout -b feature/<descriptive-name>
git push -u origin feature/<descriptive-name>  # Set upstream tracking

# Examples:
git checkout -b feature/user-profile-api      # For beads-102
git checkout -b feature/fix-auth-null-check   # For beads-87
git checkout -b feature/extract-validation    # For beads-45

# Note: Beads ID goes in commits, not branch names
```

### Commit Message Convention
```bash
# Include beads ID in commit message
git commit -m "feat: add user profile endpoint [beads-102]"
git commit -m "fix: null pointer in auth [beads-87]"
git commit -m "refactor: extract validation utils [beads-45]"

# First commit on feature branch should reference the beads issue
git commit -m "feat: initial implementation of user profile [beads-102]"
git push  # Upstream already set with -u flag
```

### When to Sync
```bash
# At session end (before git push)
bd sync --flush-only

# After major milestone
bd sync --flush-only

# Before long break (lunch, end of day)
bd sync --flush-only
```

---

## Common Mistakes to Avoid

❌ **Starting work without git branch setup**
- **Impact**: Working on stale code, merge conflicts, lost work
- **Fix**: Always complete Git Branch Setup checklist FIRST (or run git-branch-setup.sh)

❌ **Working directly on default branch**
- **Impact**: Cannot create clean pull requests, pollutes main history
- **Fix**: Always work on feature branches (feature/<description>)

❌ **Not setting upstream tracking**
- **Impact**: git push fails, unclear branch status
- **Fix**: Always use `git push -u origin <branch>` for new branches

❌ **Starting code before creating task**
- **Impact**: Lost context if session interrupted
- **Fix**: Always `bd create` BEFORE first file edit

❌ **Closing task without reason**
- **Impact**: No breadcrumbs for future debugging
- **Fix**: Always use `--reason="detailed explanation"`

❌ **Forgetting bd sync before session end**
- **Impact**: Task state not exported to JSONL
- **Fix**: Add to session completion checklist (see session-completion.md)

❌ **Not checking bd ready at session start**
- **Impact**: Miss available work, duplicate effort
- **Fix**: `bd ready --json` FIRST command each session

❌ **Creating tasks too large**
- **Impact**: Tasks stay in_progress for days, blocking others
- **Fix**: Break into sub-tasks with dependencies

❌ **Using wrong priority values**
- **Impact**: `bd create --priority=high` FAILS (expects 0-4)
- **Fix**: 0=critical, 1=high, 2=medium, 3=low, 4=backlog

---

## Quick Reference Card

```
╔══════════════════════════════════════════════════════════════╗
║  BEADS QUICK REFERENCE                                       ║
╠══════════════════════════════════════════════════════════════╣
║  First Time:       bd init                                   ║
║  Git Setup:        git-branch-setup.sh (or manual checklist) ║
║  Start Session:    bd ready --json                           ║
║  Create Task:      bd create --title="..." -t task -p 2      ║
║  Claim Work:       bd update <id> --status=in_progress       ║
║  Add Progress:     bd update <id> --notes="..."              ║
║  Close Task:       bd close <id> --reason="..."              ║
║  End Session:      bd sync --flush-only                      ║
╠══════════════════════════════════════════════════════════════╣
║  Git Workflow:     feature/<name> → git push -u origin       ║
║  Branch Script:    ~/.config/opencode/scripts/git-branch-setup.sh ║
╠══════════════════════════════════════════════════════════════╣
║  Priority Scale:   0=critical  1=high  2=medium              ║
║                    3=low       4=backlog                     ║
╠══════════════════════════════════════════════════════════════╣
║  Task Types:       task | bug | feature                      ║
╚══════════════════════════════════════════════════════════════╝
```

---

## Next Steps

- **Project-specific workflows:** See your project's `.agents/examples/` directory
- **Session completion protocol:** See [session-completion.md](session-completion.md)
- **Setting up new project:** See [project-onboarding.md](project-onboarding.md)

---

_This is a universal guide. For technology-specific integration, see your project's AGENTS.md._
