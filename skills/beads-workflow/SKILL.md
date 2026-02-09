---
name: beads-workflow
description: Comprehensive beads task tracking workflows, git branch setup procedures, and troubleshooting guide
compatibility: opencode
---

# Beads Workflow - Detailed Guide

## What I do

I provide comprehensive, step-by-step workflows for beads task tracking including:

- **Git branch setup procedures** - Three scenarios (default branch, clean feature branch, diverged branch) with decision trees
- **Workflow patterns** - Simple bug fixes, multi-step features (epics), refactoring, emergency hotfixes
- **Beads + Git integration** - Commit conventions, sync procedures, validation scripts
- **Stale task recovery** - Four recovery options for interrupted sessions
- **Technology-specific guidance** - Integration points for backend, frontend, and DevOps work
- **Troubleshooting** - Complete list of common mistakes and fixes

## When to use me

Load this skill when you need:

- **Git branch setup** - Detailed procedures for setting up branches before claiming beads tasks
- **Workflow patterns** - Step-by-step guides for implementing Pattern 1-4 (bug fix, epic, refactor, hotfix)
- **Squash merge conflicts** - Understanding and resolving diverged branch issues
- **Session recovery** - Dealing with stale or orphaned tasks from interrupted sessions
- **Validation procedures** - Running beads state validation before pushing
- **Technology integration** - Specific guidance for backend/frontend/DevOps workflows
- **Troubleshooting** - Full list of common mistakes and how to fix them

---

## 🌿 Git Branch Setup - Pre-Task Checklist

**CRITICAL:** Complete this checklist BEFORE claiming any beads task.

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

### Committing Beads Changes

**CRITICAL:** Beads JSONL files should be committed separately from feature work for clarity.

```bash
# After feature work is committed:
git log -1 --oneline
# 9343930 refactor(test): complete service test migration to MockK and fixtures

# Sync beads to JSONL and commit separately:
bd sync --flush-only
git add .beads/issues.jsonl .beads/interactions.jsonl
git commit -m "chore: sync beads tracking for service test refactoring

- Closed: planit-assortment-scenarios-api-6gj (test fixtures)
- Closed: planit-assortment-scenarios-api-3no (assertion helpers)
- Closed: planit-assortment-scenarios-api-yua (service test conversion)
- Closed: planit-assortment-scenarios-api-7gs (quality gates)"

# Now push everything together:
git push origin feature/<branch-name>
```

**Why separate commits?**
- ✅ Feature commits = code changes (reviewable in PR)
- ✅ Beads commits = task tracking metadata (informational)
- ✅ Keeps PR diffs focused on actual code changes
- ✅ Makes it easy to see which tasks were completed in each feature

**Common mistake:** Forgetting to commit beads changes at all, leaving `.beads/issues.jsonl` modified but uncommitted.

### When to Sync
```bash
# MANDATORY: At session end (before git push)
bd sync --flush-only
git add .beads/issues.jsonl .beads/interactions.jsonl
git commit -m "chore: sync beads tracking for [feature-name]"

# After major milestone (multiple tasks closed)
bd sync --flush-only

# Before long break (lunch, end of day)
bd sync --flush-only
```

### Validate Beads State Before Pushing

**Run validation script (recommended):**
```bash
~/.config/opencode/scripts/validate-beads-state.sh
```

**What it checks:**
- ✅ Beads initialization
- ✅ Uncommitted `.beads/` changes
- ✅ Tasks stuck in `in_progress` state
- ✅ Summary of open tasks

**Manual validation (if script unavailable):**
```bash
# Check for uncommitted beads changes
git status .beads/

# Check for open or in_progress tasks (might indicate incomplete work)
bd list --status=open,in_progress --json

# If tasks are still open or in_progress:
# ⚠️ EVALUATE: Is the work truly incomplete, or did you forget to close them?
# - If complete: Close them now with bd close
# - If incomplete: Document in task notes why they remain open
# - If blocked: Add blockers with bd dep add
```

**When to run:**
- Before `git push` (part of session completion)
- After `bd sync --flush-only`
- When unsure if beads state is clean

---

## Dealing with Stale or Orphaned Tasks

**Scenario:** You start a session and find tasks stuck in `in_progress` from a previous session (interrupted, crash, forgot to close).

```bash
# At session start, check for tasks stuck "in_progress"
bd list --status=in_progress --json

# Evaluate each stale task:
```

### Option 1: Continue the work
```bash
bd update <id> --notes="Resuming work from previous session" --json
# ... do the work ...
bd close <id> --reason="Completed: [what was done]" --json
```

### Option 2: Task is complete but wasn't closed
```bash
# If the code was already committed/pushed:
bd close <id> --reason="Task was completed in previous session - see commit abc1234" --json
```

### Option 3: Task is no longer relevant
```bash
bd close <id> --reason="No longer needed due to [reason: scope change, duplicate, etc.]" --json
```

### Option 4: Task needs to be split or redefined
```bash
# Close the vague/oversized task
bd close <id> --reason="Task too broad - splitting into subtasks" --json

# Create smaller, well-scoped tasks
bd create --title="Implement X" --type=task --priority=2 --description="..." --json
bd create --title="Write tests for X" --type=task --priority=2 --description="..." --json
```

**Why this matters:**
- ❌ Stale `in_progress` tasks pollute `bd ready` output
- ❌ Other developers can't tell if you're actively working on it
- ❌ Project stats (`bd stats`) become inaccurate
- ✅ Clean state = accurate project health metrics

---

## Common Mistakes to Avoid (Complete List)

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
- **Impact**: Task state not exported to JSONL, `.beads/issues.jsonl` left uncommitted
- **Fix**: Add to session completion checklist (see session-completion.md)
- **Fix**: Run `bd sync --flush-only` then commit `.beads/issues.jsonl`

❌ **Not committing .beads/issues.jsonl changes**
- **Impact**: Task tracking history is lost, other developers can't see completed work
- **Fix**: After `bd sync`, run `git add .beads/issues.jsonl && git commit -m "chore: sync beads tracking"`
- **Note**: `.beads/issues.jsonl` IS tracked by git (see `.beads/.gitignore` comments)

❌ **Not checking bd ready at session start**
- **Impact**: Miss available work, duplicate effort
- **Fix**: `bd ready --json` FIRST command each session

❌ **Creating tasks too large**
- **Impact**: Tasks stay in_progress for days, blocking others
- **Fix**: Break into sub-tasks with dependencies

❌ **Using wrong priority values**
- **Impact**: `bd create --priority=high` FAILS (expects 0-4)
- **Fix**: 0=critical, 1=high, 2=medium, 3=low, 4=backlog

❌ **Creating tasks retroactively (after work is done)**
- **Impact**: No real-time tracking, defeats session recovery purpose
- **Fix**: Create tasks at session start, update status as you progress
- **Example of bad timing**: Created at 12:24 PM, closed at 12:27 PM (3 min later) = retroactive
- **Example of good timing**: Created at 9:00 AM, in_progress at 9:15 AM, closed at 11:30 AM = real-time

❌ **Forgetting to add task descriptions**
- **Impact**: Future sessions lack context, can't remember why task exists
- **Fix**: Always use `--description="Detailed context"` when creating tasks
- **Good**: `bd create --title="Fix null pointer" --description="UserService.validate() throws NPE when email is null - add null check before regex validation"`
- **Bad**: `bd create --title="Fix null pointer"` (no description)

❌ **Not handling squash merge conflicts properly**
- **Impact**: Spending hours resolving conflicts that can't be resolved
- **Fix**: Recognize squash merge pattern, start fresh branch from updated main

❌ **Forgetting to set git remote HEAD**
- **Impact**: Automated scripts fail to detect default branch
- **Fix**: Run `git remote set-head origin --auto` once per repo

❌ **Creating git setup beads tasks unnecessarily**
- **Impact**: Inflates task count with infrastructure work
- **Fix**: Only create beads task if git setup FAILS and requires debugging

❌ **Not validating beads state before pushing**
- **Impact**: Push incomplete work, leave tasks stuck in_progress
- **Fix**: Run `validate-beads-state.sh` before every push

❌ **Batch-closing tasks after completing all work**
- **Impact**: No session recovery if interrupted mid-work
- **Fix**: Close each task immediately after completing it

---

## Quick Tips

💡 **Use bd show for dependency debugging**
```bash
bd show <id> --json  # See full dependency graph
```

💡 **Batch close related tasks efficiently**
```bash
bd close beads-101 beads-102 beads-103 --reason="Completed user profile feature" --json
```

💡 **Add progress notes during long tasks**
```bash
bd update <id> --notes="API implemented, starting UI work" --json
```

💡 **Check for blocked work periodically**
```bash
bd blocked --json  # See what's waiting on dependencies
```

💡 **Use descriptive branch names for better context**
```bash
# Good: feature/user-profile-api (clear intent)
# Bad: feature/update (what update?)
```

---

_For core policy and session checklists, see `~/.config/opencode/agents/beads-workflow.md`_
