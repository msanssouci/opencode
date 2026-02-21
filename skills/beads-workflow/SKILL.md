---
name: beads-workflow
description: Comprehensive beads task tracking workflows, git branch setup procedures, and troubleshooting guide
compatibility: opencode
version: 3.0.0
last_updated: 2026-02-21
changelog:
  - 3.0.0 (2026-02-21) - Enhanced with detailed content moved from core policy (decision tree, commit patterns, full mistakes list, quick reference cards)
  - 2.2.0 (2026-02-11) - Updated commit message format to use succinct subject line with Beads Tasks section
  - 2.1.0 (2026-02-09) - Added decision tree for task creation
  - 2.0.0 (2026-02-09) - Split from core policy for on-demand loading
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

- **Decision tree guidance** - Comprehensive flowchart with detailed examples for when to create beads tasks
- **Git branch setup** - Detailed procedures for setting up branches before claiming beads tasks
- **Workflow patterns** - Step-by-step guides for implementing Pattern 1-4 (bug fix, epic, refactor, hotfix)
- **Squash merge conflicts** - Understanding and resolving diverged branch issues
- **Session recovery** - Dealing with stale or orphaned tasks from interrupted sessions
- **Validation procedures** - Running beads state validation before pushing
- **Technology integration** - Specific guidance for backend/frontend/DevOps workflows
- **Troubleshooting** - Full list of common mistakes (15+ items) and how to fix them
- **Quick reference cards** - Multiple formats for different contexts
- **Commit message patterns** - Detailed conventional commit examples and rules

---

## 🤔 Decision Tree: Should I Create a Beads Task? (Complete Guide)

**When you receive a request, ask yourself:**

### ✅ ALWAYS Create a Beads Task For:

1. **File Operations**
   - Creating new files (code, docs, configs)
   - Modifying existing files (bug fixes, features, refactoring)
   - Deleting files (cleanup, removal)

2. **Multi-Step Work**
   - Anything requiring 2+ tool invocations
   - Work spanning multiple files/directories
   - Tasks with dependencies or prerequisites

3. **Substantial Deliverables**
   - Documentation (README, guides, diagrams)
   - Features or enhancements
   - Bug fixes or refactoring
   - Infrastructure changes (CI/CD, Docker, configs)

4. **Work That Will Be Committed**
   - ANY changes that will result in `git commit`
   - Even "simple" docs or "quick" config changes

### ❌ Do NOT Create Beads Tasks For:

1. **Read-Only Information Requests**
   - Explaining how code works
   - Answering questions about architecture
   - Reading files without modification
   - Providing code examples without writing files

2. **One-Off Commands**
   - Running `git status` or `npm test`
   - Single command execution for information
   - Interactive troubleshooting (no file changes)

3. **Pure Conversation**
   - Discussing design approaches
   - Reviewing existing code
   - Planning (before deciding to implement)

### 🔍 Decision Flow

```
┌─────────────────────────────────────┐
│   User makes a request              │
└──────────────┬──────────────────────┘
               │
               ▼
    ┌──────────────────────┐
    │ Will I create/modify │
    │      ANY files?      │
    └──────┬───────┬───────┘
           │       │
         YES      NO
           │       │
           │       ▼
           │  ┌─────────────────────┐
           │  │ Is it multi-step    │
           │  │ work (2+ commands)? │
           │  └──────┬───────┬──────┘
           │         │       │
           │        YES     NO
           │         │       │
           ▼         ▼       ▼
    ┌─────────┐  ┌──────┐  ┌────────────┐
    │ CREATE  │  │CREATE│  │ NO BEADS   │
    │ BEADS   │  │BEADS │  │ TASK       │
    │ TASK    │  │TASK  │  │ NEEDED     │
    └─────────┘  └──────┘  └────────────┘
```

### 📝 Examples

#### ✅ CREATE Beads Task:

```
User: "Generate sequence diagrams for the API"
Agent: → Creates files → NEEDS BEADS TASK

User: "Fix the bug in UserController.kt"
Agent: → Modifies code → NEEDS BEADS TASK

User: "Update the README with new instructions"
Agent: → Modifies docs → NEEDS BEADS TASK

User: "Refactor the authentication logic"
Agent: → Modifies multiple files → NEEDS BEADS TASK

User: "Add a new API endpoint"
Agent: → Creates/modifies files → NEEDS BEADS TASK
```

#### ❌ NO Beads Task:

```
User: "How does the authentication flow work?"
Agent: → Reads files, explains → NO BEADS TASK

User: "What's the current git status?"
Agent: → Runs command → NO BEADS TASK

User: "Show me the UserController code"
Agent: → Reads file → NO BEADS TASK

User: "Should we use Redis or Memcached?"
Agent: → Discussion only → NO BEADS TASK (until decision to implement)

User: "Run the tests"
Agent: → Single command → NO BEADS TASK
```

### 🎯 Key Principle

**"If it will be committed to git, it needs a beads task."**

When in doubt, **default to creating a beads task**. The overhead is minimal, and the benefits (traceability, session recovery, project health) are substantial.

### ⚠️ What If I'm Unsure?

**Option 1: Ask the user**
> "This looks like substantial work. Should I create a beads task for tracking?"

**Option 2: Default to YES**
- Creating an unnecessary task is low-cost
- Missing task tracking can lose work between sessions
- Better safe than sorry

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

# 4. Close beads task with context (DO NOT commit yet)
bd close beads-xxx --reason="Fixed null check in AuthHandler.validate()" --json

# 5. Sync beads to JSONL (DO NOT commit yet)
bd sync --flush-only

# 6. Commit EVERYTHING together (code + beads metadata)
git add <changed-files> .beads/issues.jsonl .beads/interactions.jsonl
git commit -m "fix: prevent null pointer in login validation

Added null check in AuthHandler.validate() before email field access.

Beads Tasks:
- beads-xxx: Fixed null pointer exception in login validation"
git push
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

# 4. Work through ready tasks (DO NOT commit after each task)
bd ready --json  # Shows beads-101 only (no blockers)
bd update beads-101 --status=in_progress --json
# [Work on schema...]
bd close beads-101 --reason="Schema defined in models/" --json

bd ready --json  # Now shows beads-102 (blocker cleared)
bd update beads-102 --status=in_progress --json
# [Work on API...]
bd close beads-102 --reason="API endpoint implemented" --json

bd update beads-103 --status=in_progress --json
# [Work on UI...]
bd close beads-103 --reason="UI component built" --json

bd update beads-104 --status=in_progress --json
# [Work on tests...]
bd close beads-104 --reason="E2E tests passing" --json

# 5. Sync beads to JSONL (DO NOT commit yet)
bd sync --flush-only

# 6. Commit EVERYTHING together (code + beads metadata)
git add <all-changed-files> .beads/issues.jsonl .beads/interactions.jsonl
git commit -m "feat: add user profile page

Complete profile feature with schema, API, UI, and E2E tests.

Beads Tasks:
- beads-100: User profile page epic
- beads-101: Designed profile schema in models/
- beads-102: Implemented GET/POST /api/profile endpoints
- beads-103: Built ProfilePage component with validation
- beads-104: Added E2E tests for profile workflows"
git push

# Alternative: Commit at logical milestones (for very large features)
# If the epic spans multiple days with natural boundaries, you can:
# - Complete API milestone → close beads-101, beads-102 → sync → commit → push
# - Complete UI milestone → close beads-103 → sync → commit → push
# - Complete tests milestone → close beads-104 → sync → commit → push
# Each commit includes both code changes AND beads metadata together.
# This creates 3 commits instead of 1, but each represents a complete milestone.
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
# [Make all refactoring changes...]

# 3. Close beads task (DO NOT commit yet)
bd close beads-xxx --reason="Extracted to libs/utils/ValidationUtils.kt, updated 3 controllers" --json

# 4. Sync beads to JSONL (DO NOT commit yet)
bd sync --flush-only

# 5. Commit EVERYTHING together (code + beads metadata)
git add <changed-files> .beads/issues.jsonl .beads/interactions.jsonl
git commit -m "refactor: extract validation to shared utility

Centralized validation logic to reduce duplication across controllers.

Beads Tasks:
- beads-xxx: Moved validation from 3 controllers to ValidationUtils"
git push
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

# 3. Fix and close beads task
bd close beads-xxx --reason="Fixed race condition in PaymentProcessor.charge()" --json

# 4. Sync beads to JSONL
bd sync --flush-only

# 5. Commit EVERYTHING together and push immediately
git add <changed-files> .beads/issues.jsonl .beads/interactions.jsonl
git commit -m "fix(critical): resolve payment race condition

Added synchronization lock to prevent duplicate charges.

Beads Tasks:
- beads-xxx: Fixed race condition in PaymentProcessor.charge()"
git push

# Note: Hotfixes still follow the close → sync → commit pattern,
# just executed quickly due to urgency
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

### Commit Message Patterns (Detailed)

**CRITICAL:** Follow conventional commit structure with succinct first line.

#### Standard Format

```bash
<type>: <succinct description>           ← 50 chars max, imperative mood
                                         ← blank line
<detailed body - optional>                ← Explains "why" not "what"
                                         ← blank line
Beads Tasks:                              ← Lists each task accomplished
- beads-xxx: <specific accomplishment>
- beads-yyy: <specific accomplishment>
```

#### Commit Types

| Type | Purpose | Example |
|------|---------|---------|
| `feat` | New feature | `feat: add user profile endpoint` |
| `fix` | Bug fix | `fix: prevent null pointer in login` |
| `refactor` | Code restructuring | `refactor: extract validation to utility` |
| `test` | Adding tests | `test: add E2E tests for checkout flow` |
| `docs` | Documentation | `docs: update API reference` |
| `chore` | Maintenance | `chore: update dependencies` |
| `style` | Formatting | `style: fix indentation in models` |
| `perf` | Performance | `perf: optimize database queries` |

#### Detailed Examples

**Example 1: Simple Feature (Single Task)**

```bash
git commit -m "feat: add user profile endpoint

Implemented GET /api/profile endpoint with authentication and validation.

Beads Tasks:
- beads-102: Built profile API with JWT auth and input validation"
```

**Example 2: Multi-Task Feature (Epic)**

```bash
git commit -m "feat: implement user profile management

Complete profile feature with schema, API, UI, and comprehensive testing.

Beads Tasks:
- beads-101: Created User schema in models/User.kt with validation
- beads-102: Built GET/POST /api/profile endpoints with JWT auth
- beads-103: Implemented ProfilePage component with form validation
- beads-104: Added E2E tests for profile workflows with 90% coverage"
```

**Example 3: Bug Fix**

```bash
git commit -m "fix: prevent null pointer in login validation

Added null check in AuthHandler.validate() before accessing email field.
Fixes issue where empty login requests caused server crashes.

Beads Tasks:
- beads-87: Fixed null pointer exception in login validation"
```

**Example 4: Refactoring**

```bash
git commit -m "refactor: extract validation logic to shared utility

Centralized validation logic to reduce duplication across 3 controllers.

Beads Tasks:
- beads-45: Moved validation from UserController, AuthController, ProfileController to ValidationUtils.kt"
```

**Example 5: Emergency Hotfix**

```bash
git commit -m "fix(critical): resolve payment race condition

Added synchronization lock to prevent duplicate charges in high-concurrency scenarios.
Production issue affecting 0.5% of transactions.

Beads Tasks:
- beads-234: Fixed race condition in PaymentProcessor.charge() with ReentrantLock"
```

**Example 6: Milestone Commit (Multi-Day Feature)**

```bash
git commit -m "feat: implement profile API backend (milestone 1)

Backend API implementation complete. UI and E2E tests to follow.

Beads Tasks:
- beads-101: Created User schema with profile fields and validation rules
- beads-102: Implemented GET/POST /api/profile endpoints with JWT auth
- beads-105: Added unit tests for profile service layer"
```

#### Rules & Best Practices

✅ **Subject Line (First Line):**
- Max 50 characters
- Imperative mood: "add" not "added", "fix" not "fixed"
- No period at end
- Lowercase after type prefix
- Descriptive but concise

✅ **Body (Optional):**
- Wrap at 72 characters per line
- Explain "why" not "what" (code shows what)
- Provide context for future maintainers
- Reference related issues/tickets if applicable

✅ **Beads Section:**
- Always include when closing beads tasks
- One line per task
- Include beads ID + specific accomplishment
- Be specific: "Created User schema" not just "Schema work"

❌ **Don't:**
- Put beads IDs in subject line (keeps it clean)
- Write "beads-xxx, beads-yyy, beads-zzz" without descriptions
- Use vague descriptions like "work done" or "finished task"
- Skip the body for complex changes
- Make commits > 80 chars wide (hard to read in terminals)

#### When to Commit

**Single-Commit Pattern (Default/Recommended):**

```bash
# Close all tasks → Sync → Commit everything together
bd close beads-101 beads-102 beads-103 --reason="Feature complete" --json
bd sync --flush-only
git add src/ tests/ .beads/*.jsonl
git commit -m "feat: implement user profile

Complete implementation with schema, API, and tests.

Beads Tasks:
- beads-101: Created User schema
- beads-102: Built profile API endpoints
- beads-103: Added comprehensive tests"
git push
```

**Why:** Clean history, atomic changes, easier reviews

**Milestone-Commit Pattern (Optional, for large features):**

```bash
# Milestone 1: Backend complete
bd close beads-101 beads-102 --reason="Backend milestone" --json
bd sync --flush-only
git add src/backend/ .beads/*.jsonl
git commit -m "feat: implement profile backend (milestone 1)

Beads Tasks:
- beads-101: Created schema
- beads-102: Built API endpoints"
git push

# Days later...
# Milestone 2: Frontend complete
bd close beads-103 beads-104 --reason="Frontend milestone" --json
bd sync --flush-only
git add src/frontend/ .beads/*.jsonl
git commit -m "feat: implement profile frontend (milestone 2)

Beads Tasks:
- beads-103: Built UI components
- beads-104: Added E2E tests"
git push
```

**When:** Feature spans 2+ days with natural breakpoints

---

## Beads + Git Integration (Continued)

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

**CRITICAL:** Follow conventional commit structure with succinct first line.

```bash
# Do NOT commit after each beads task
# Follow this order: Close tasks → Sync beads → Commit everything together

# Example: Single feature with multiple beads tasks
bd close beads-101 --reason="Schema implemented" --json
bd close beads-102 --reason="API implemented" --json
bd close beads-103 --reason="Tests added" --json

# Sync beads to JSONL (DO NOT commit yet)
bd sync --flush-only

# Then make ONE commit with code + beads metadata together
git add <all-changed-files> .beads/issues.jsonl .beads/interactions.jsonl
git commit -m "feat: add user profile endpoint

Implemented profile management with schema, API endpoints, and tests.

Beads Tasks:
- beads-101: Created User schema in models/User.kt
- beads-102: Built GET/POST /api/profile endpoints
- beads-103: Added integration tests with 90% coverage"
git push

# Commit message format (conventional commits):
# <type>: <succinct description>           ← 50 chars max
#
# <detailed body - optional>                ← Explains "why" not "what"
#
# Beads Tasks:                              ← Lists each task accomplished
# - beads-xxx: <what this task did>
# - beads-yyy: <what this task did>

# Commit types: feat, fix, refactor, test, docs, chore, style, perf

# Rules:
# ✅ First line: 50 characters max, imperative mood ("add" not "added")
# ✅ Body: Optional, provides context and reasoning
# ✅ Beads section: Lists each task with specific accomplishment
# ❌ Don't put beads IDs in subject line (keeps it clean)
```

### Committing Beads Changes

**CRITICAL WORKFLOW:** Close tasks → Sync beads → Commit everything together

**The Single-Commit Pattern (Default/Recommended):**

```bash
# Step 1: Close all beads tasks for the feature (DO NOT commit yet)
bd close beads-101 --reason="Implemented user schema" --json
bd close beads-102 --reason="Built profile API" --json
bd close beads-103 --reason="Added tests" --json

# Step 2: Sync beads to JSONL (writes to .beads/*.jsonl, DO NOT commit yet)
bd sync --flush-only

# Step 3: Commit EVERYTHING together (code + beads metadata)
git add src/ tests/ .beads/issues.jsonl .beads/interactions.jsonl
git commit -m "feat: implement user profile management

Complete user profile feature with schema, API, validation, and tests.

Beads Tasks:
- beads-101: Added User schema with profile fields
- beads-102: Implemented GET/POST /api/profile endpoints
- beads-103: Added validation and 90% test coverage"

# Step 4: Push
git push
```

**Why this pattern?**
- ✅ **Simplest workflow**: Close → sync → commit → push
- ✅ **Single commit per feature**: Clean git history
- ✅ **Atomic changes**: Code and tracking metadata together
- ✅ **Easy recovery**: If interrupted, both code and beads state are either committed or not

**The Two-Commit Pattern (Optional, for very large features):**

For features spanning multiple days with natural milestone boundaries:

```bash
# Milestone 1: Complete API work
bd close beads-101 beads-102 --reason="API milestone complete" --json
bd sync --flush-only
git add src/api/ .beads/*.jsonl
git commit -m "feat: implement profile API

Backend API implementation with schema and endpoints.

Beads Tasks:
- beads-101: Created profile schema
- beads-102: Built GET/POST /api/profile endpoints"
git push

# Continue working...

# Milestone 2: Complete UI work (days later)
bd close beads-103 beads-104 --reason="UI milestone complete" --json
bd sync --flush-only
git add src/ui/ .beads/*.jsonl
git commit -m "feat: implement profile UI

Frontend UI implementation with form validation.

Beads Tasks:
- beads-103: Built ProfilePage component
- beads-104: Added E2E tests for profile workflows"
git push
```

**When to use two-commit pattern:**
- Epic spans 2+ days with natural breakpoints
- Each milestone is independently deployable
- Team prefers smaller, focused commits for easier review

**When NOT to use two-commit pattern:**
- Feature takes < 1 day (use single commit)
- Changes are tightly coupled (use single commit)
- You're unsure (default to single commit)

**What changed from old approach:**
- ❌ OLD: Commit code → sync beads → commit metadata separately (2 commits minimum)
- ✅ NEW: Close → sync → commit everything together (1 commit default)
```

**Why separate commits?**
- ✅ Feature commits = code changes (reviewable in PR)
- ✅ Beads commits = task tracking metadata (informational)
- ✅ Keeps PR diffs focused on actual code changes
- ✅ Makes it easy to see which tasks were completed in each feature

**Common mistake:** Forgetting to commit beads changes at all, leaving `.beads/issues.jsonl` modified but uncommitted.

### When to Sync
```bash
# CRITICAL: bd sync only writes to JSONL - it does NOT commit
# You must commit the JSONL changes manually

# Standard workflow: Close → Sync → Commit
# 1. Close all beads tasks for the feature
bd close beads-xxx beads-yyy beads-zzz --reason="Feature complete" --json

# 2. Sync to JSONL (DO NOT commit yet)
bd sync --flush-only

# 3. Commit code + beads metadata together
git add src/ tests/ .beads/*.jsonl
git commit -m "feat: implement feature X

Complete implementation with comprehensive testing.

Beads Tasks:
- beads-xxx: Implemented core functionality
- beads-yyy: Added error handling
- beads-zzz: Added unit and integration tests"
git push

# For large features with milestones (optional):
# You can sync and commit at each milestone:
# - Complete milestone 1 → close tasks → sync → commit → push
# - Complete milestone 2 → close tasks → sync → commit → push
# Each commit includes both code changes AND beads metadata together

# DO NOT sync after every beads task - that defeats the purpose
# Sync ONLY when you're ready to commit a feature milestone
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

## Common Mistakes to Avoid (Complete List - 15+ Items)

### 🚨 Critical Mistakes (Will Break Your Workflow)

❌ **#1: Starting work without git branch setup**
- **Impact**: Working on stale code, merge conflicts, lost work
- **Fix**: Always complete Git Branch Setup checklist FIRST (or run git-branch-setup.sh)
- **Detection**: Run `git status` - if on main/master, STOP and create feature branch

❌ **#2: Working directly on default branch**
- **Impact**: Cannot create clean pull requests, pollutes main history
- **Fix**: Always work on feature branches (feature/<description>)
- **Detection**: `git branch --show-current` should show feature/* not main/master

❌ **#3: Starting code before creating beads task**
- **Impact**: Lost context if session interrupted, no tracking
- **Fix**: Always `bd create` BEFORE first file edit
- **Detection**: Check `bd list --status=in_progress` before coding

❌ **#4: Forgetting bd sync before commit**
- **Impact**: Beads metadata not included in commit, leaves .beads/*.jsonl uncommitted
- **Fix**: Always sync BEFORE committing: `bd sync --flush-only`
- **Detection**: Run `git status .beads/` - should show modified files before commit

❌ **#5: Not committing .beads/*.jsonl changes**
- **Impact**: Task tracking history is lost, other developers can't see completed work
- **Fix**: After `bd sync`, run `git add .beads/*.jsonl` before committing
- **Detection**: `git status` should include .beads/issues.jsonl and .beads/interactions.jsonl
- **Note**: `.beads/issues.jsonl` IS tracked by git (see `.beads/.gitignore` comments)

### ⚠️ High-Impact Mistakes (Will Cause Pain)

❌ **#6: Committing after each beads task completion**
- **Impact**: Noisy git history (10+ commits per feature), harder PR reviews, less meaningful commits
- **Fix**: Close ALL related beads tasks FIRST, then make ONE meaningful commit
- **Example BAD**: 5 commits for "feat: add profile", "add tests", "fix lint", "update docs", "final fix"
- **Example GOOD**: 1 commit "feat: add user profile - Beads: beads-101, beads-102, beads-103"
- **Detection**: Before committing, ask: "Are there related tasks I should close together?"

❌ **#7: Not setting upstream tracking for new branches**
- **Impact**: `git push` fails with "no upstream branch", unclear branch status
- **Fix**: Always use `git push -u origin <branch>` for new branches
- **Detection**: `git status` shows "Your branch is based on 'origin/...' but..."

❌ **#8: Closing task without reason**
- **Impact**: No breadcrumbs for future debugging, lost context
- **Fix**: Always use `--reason="detailed explanation"`
- **Example**: `bd close beads-102 --reason="Fixed null check in AuthHandler.validate()"`

❌ **#9: Not checking bd ready at session start**
- **Impact**: Miss available work, duplicate effort, work on wrong tasks
- **Fix**: `bd ready --json` as FIRST command each session
- **Detection**: Run at session start, should become habitual

❌ **#10: Not handling squash merge conflicts properly**
- **Impact**: Spending hours resolving conflicts that can't be resolved
- **Fix**: Recognize squash merge pattern, start fresh branch from updated main
- **Detection**: Branch shows conflicts with main BUT PR was already merged → squash merge scenario

### 📋 Quality & Organization Mistakes

❌ **#11: Creating tasks too large**
- **Impact**: Tasks stay in_progress for days, blocking others, unclear progress
- **Fix**: Break into sub-tasks with dependencies (use epic pattern)
- **Example BAD**: "Implement user management" (too broad)
- **Example GOOD**: Epic: "User management" → Tasks: "User schema", "CRUD API", "UI forms", "Tests"
- **Detection**: If task takes > 1 day, consider splitting

❌ **#12: Forgetting to add task descriptions**
- **Impact**: Future sessions lack context, can't remember why task exists
- **Fix**: Always use `--description="Detailed context"` when creating tasks
- **Example GOOD**: `bd create --title="Fix null pointer" --description="UserService.validate() throws NPE when email is null - add null check before regex validation"`
- **Example BAD**: `bd create --title="Fix null pointer"` (no description)

❌ **#13: Using wrong priority values**
- **Impact**: `bd create --priority=high` FAILS (expects 0-4)
- **Fix**: 0=critical, 1=high, 2=medium, 3=low, 4=backlog
- **Detection**: Error message "invalid priority value"

❌ **#14: Batch-closing tasks at end of day (without intermediate closes)**
- **Impact**: While batching into one commit is GOOD, closing tasks late loses progress tracking
- **Fix**: Close each task immediately after completing it, THEN batch them into one commit
- **Example**: Close beads-101 (11am), close beads-102 (2pm), close beads-103 (4pm), THEN commit at 4pm with all three IDs

❌ **#15: Creating git setup beads tasks unnecessarily**
- **Impact**: Inflates task count with infrastructure work
- **Fix**: Only create beads task if git setup FAILS and requires debugging
- **Detection**: Normal git branch setup is infrastructure, not tracked work

### 🔧 Technical Mistakes

❌ **#16: Forgetting to set git remote HEAD**
- **Impact**: Automated scripts fail to detect default branch
- **Fix**: Run `git remote set-head origin --auto` once per repo
- **Detection**: `git rev-parse --abbrev-ref origin/HEAD` returns error

❌ **#17: Not validating beads state before pushing**
- **Impact**: Push incomplete work, leave tasks stuck in_progress
- **Fix**: Run `validate-beads-state.sh` before every push
- **Detection**: Manual check: `bd list --status=in_progress` should be empty

❌ **#18: Ignoring stale in_progress tasks at session start**
- **Impact**: Pollutes `bd ready` output, inaccurate project stats
- **Fix**: At session start: `bd list --status=in_progress` → close or continue each one
- **Detection**: Session start checklist item #3

### 💡 Pro Tips to Avoid Mistakes

1. **Use session checklists religiously** - Print them, memorize them
2. **Automate where possible** - Use `git-branch-setup.sh` script
3. **Validate before pushing** - Run `validate-beads-state.sh`
4. **Make atomic commits** - Close → Sync → Commit pattern
5. **Review before closing sessions** - Are all tasks closed? Is everything pushed?

---

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

❌ **Committing after each beads task completion**
- **Impact**: Noisy git history (10+ commits per feature), harder PR reviews, less meaningful commits
- **Fix**: Close ALL related beads tasks FIRST, then make ONE meaningful commit
- **Example BAD**: 5 commits for "feat: add profile", "add tests", "fix lint", "update docs", "final fix"
- **Example GOOD**: 1 commit "feat: add user profile with tests and docs - Closes: beads-101, beads-102, beads-103"

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

❌ **Not committing beads JSONL changes**
- **Impact**: Task tracking history is lost, other developers can't see completed work
- **Fix**: After feature commit + `bd sync`, run `git add .beads/*.jsonl && git commit -m "chore: sync beads tracking"`
- **Note**: `.beads/issues.jsonl` IS tracked by git (see `.beads/.gitignore` comments)

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
- **Impact**: While this is GOOD for commits, ensure you're closing tasks as you finish them (not waiting until end of day)
- **Fix**: Close each task immediately after completing it, THEN batch them into one commit
- **Example**: Close beads-101 (11am), close beads-102 (2pm), close beads-103 (4pm), THEN commit at 4pm with all three IDs

---

## Quick Tips

💡 **Use bd show for dependency debugging**
```bash
bd show <id> --json  # See full dependency graph
```

💡 **Standard workflow: Close → Sync → Commit**
```bash
# 1. Close all related tasks first
bd close beads-101 --reason="Schema implemented" --json
bd close beads-102 --reason="API implemented" --json  
bd close beads-103 --reason="Tests added" --json

# 2. Sync beads to JSONL
bd sync --flush-only

# 3. Commit everything together (code + beads)
git add src/ tests/ .beads/*.jsonl
git commit -m "feat: add user profile feature

Complete profile management with schema, API, and comprehensive tests.

Beads Tasks:
- beads-101: Implemented User schema with validation
- beads-102: Built GET/POST /api/profile endpoints
- beads-103: Added integration tests with 90% coverage"
git push
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

💡 **Commit at logical milestones, not per task**
```bash
# For large features spanning multiple days, you can commit at milestones:
# - Milestone 1: Backend API complete (3-4 beads tasks) → close → sync → commit
# - Milestone 2: Frontend UI complete (2-3 beads tasks) → close → sync → commit  
# - Milestone 3: E2E tests complete (1-2 beads tasks) → close → sync → commit
# Each commit includes both code AND beads metadata
```

---

## Quick Reference Cards

### Card 1: Universal Workflow (All Projects)

```
╔══════════════════════════════════════════════════════════════╗
║  BEADS QUICK REFERENCE - UNIVERSAL                           ║
╠══════════════════════════════════════════════════════════════╣
║  SESSION START CHECKLIST:                                    ║
║  1. Git branch setup:  git-branch-setup.sh                   ║
║  2. Check beads ready: bd ready --json                       ║
║  3. Check stale tasks: bd list --status=in_progress --json   ║
║  4. Create/find task:  bd create --title="..." -t task -p 2  ║
║  5. Claim work:        bd update <id> --status=in_progress   ║
╠══════════════════════════════════════════════════════════════╣
║  DURING WORK:                                                ║
║  Add progress notes:   bd update <id> --notes="..."          ║
║  Close task:           bd close <id> --reason="..."          ║
╠══════════════════════════════════════════════════════════════╣
║  COMMIT WORKFLOW (CRITICAL - prevents multiple commits):    ║
║  1. Close all tasks:   bd close <id1> <id2> --reason="..."  ║
║  2. Sync to JSONL:     bd sync --flush-only                  ║
║  3. Commit together:   git add <files> .beads/*.jsonl        ║
║                        git commit -m "feat: ..."             ║
║  4. Push:              git push                              ║
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

### Card 2: Command Cheat Sheet

```
╔══════════════════════════════════════════════════════════════╗
║  BEADS COMMAND CHEAT SHEET                                   ║
╠══════════════════════════════════════════════════════════════╣
║  FINDING WORK:                                               ║
║  bd ready --json                    # Show ready issues      ║
║  bd list --status=open --json       # All open issues        ║
║  bd show <id> --json                # Issue details          ║
║  bd blocked --json                  # Show blocked issues    ║
╠══════════════════════════════════════════════════════════════╣
║  CREATING & UPDATING:                                        ║
║  bd create --title="..." -t task -p 2 --json                 ║
║  bd update <id> --status=in_progress --json                  ║
║  bd update <id> --notes="..." --json                         ║
║  bd close <id> --reason="..." --json                         ║
║  bd close <id1> <id2> ... --reason="..." --json  # Batch    ║
╠══════════════════════════════════════════════════════════════╣
║  DEPENDENCIES:                                               ║
║  bd dep add <issue> <depends-on> --json                      ║
║    → Reads as: <issue> depends on <depends-on>              ║
║    → Or: <depends-on> blocks <issue>                        ║
╠══════════════════════════════════════════════════════════════╣
║  SYNC & HEALTH:                                              ║
║  bd sync --flush-only               # Export to JSONL        ║
║  bd stats                           # Project health         ║
║  bd doctor                          # Check for issues       ║
╚══════════════════════════════════════════════════════════════╝
```

### Card 3: Git Integration

```
╔══════════════════════════════════════════════════════════════╗
║  BEADS + GIT INTEGRATION                                     ║
╠══════════════════════════════════════════════════════════════╣
║  BRANCH WORKFLOW:                                            ║
║  git checkout -b feature/<description>                       ║
║  git push -u origin feature/<description>                    ║
║                                                              ║
║  Examples:                                                   ║
║    feature/user-profile-api                                  ║
║    feature/fix-auth-null-check                               ║
║    feature/extract-validation                                ║
╠══════════════════════════════════════════════════════════════╣
║  COMMIT MESSAGE FORMAT:                                      ║
║  <type>: <description (50 chars max)>                        ║
║                                                              ║
║  <optional body explaining why>                              ║
║                                                              ║
║  Beads Tasks:                                                ║
║  - beads-xxx: <what this task did>                           ║
║  - beads-yyy: <what this task did>                           ║
║                                                              ║
║  Types: feat, fix, refactor, test, docs, chore, style, perf  ║
╠══════════════════════════════════════════════════════════════╣
║  SYNC WORKFLOW:                                              ║
║  1. bd close <tasks> --reason="..."                          ║
║  2. bd sync --flush-only                                     ║
║  3. git add <code-files> .beads/*.jsonl                      ║
║  4. git commit -m "..."                                      ║
║  5. git push                                                 ║
╚══════════════════════════════════════════════════════════════╝
```

### Card 4: Decision Tree (Condensed)

```
╔══════════════════════════════════════════════════════════════╗
║  SHOULD I CREATE A BEADS TASK?                               ║
╠══════════════════════════════════════════════════════════════╣
║  ✅ YES - Create Task:                                       ║
║    • Creating/modifying/deleting files                       ║
║    • Multi-step work (2+ commands)                           ║
║    • Work that will be committed to git                      ║
║    • Features, bugs, refactoring, docs                       ║
╠══════════════════════════════════════════════════════════════╣
║  ❌ NO - Skip Task:                                          ║
║    • Reading files (no modification)                         ║
║    • Explaining how code works                               ║
║    • One-off commands (git status, npm test)                 ║
║    • Pure conversation/planning                              ║
╠══════════════════════════════════════════════════════════════╣
║  🎯 Key Principle:                                           ║
║     "If it will be committed to git, it needs a beads task"  ║
║                                                              ║
║  When unsure → Default to YES                                ║
╚══════════════════════════════════════════════════════════════╝
```

### Card 5: Troubleshooting

```
╔══════════════════════════════════════════════════════════════╗
║  COMMON ISSUES & FIXES                                       ║
╠══════════════════════════════════════════════════════════════╣
║  "Error: no beads database found"                            ║
║    → Run: bd init                                            ║
╠══════════════════════════════════════════════════════════════╣
║  "Tasks stuck in_progress from yesterday"                    ║
║    → bd list --status=in_progress --json                     ║
║    → Close or continue each one                              ║
╠══════════════════════════════════════════════════════════════╣
║  "Branch has merge conflicts but PR was merged"              ║
║    → Squash merge scenario                                   ║
║    → Start fresh: git checkout main && git pull              ║
║                   git checkout -b feature/new-name           ║
╠══════════════════════════════════════════════════════════════╣
║  ".beads/*.jsonl showing as modified"                        ║
║    → Expected! Commit these files with your code             ║
║    → git add .beads/*.jsonl                                  ║
╠══════════════════════════════════════════════════════════════╣
║  "Forgot to sync before committing"                          ║
║    → Run: bd sync --flush-only                               ║
║    → Make new commit with .beads/*.jsonl                     ║
╠══════════════════════════════════════════════════════════════╣
║  "Created task with priority=high (failed)"                  ║
║    → Use numbers: 0=critical, 1=high, 2=medium               ║
║                   3=low, 4=backlog                           ║
╚══════════════════════════════════════════════════════════════╝
```

### Card 6: Priority Guide

```
╔══════════════════════════════════════════════════════════════╗
║  BEADS PRIORITY SCALE                                        ║
╠══════════════════════════════════════════════════════════════╣
║  P0 (0) - CRITICAL                                           ║
║    • Production down                                         ║
║    • Data loss risk                                          ║
║    • Security breach                                         ║
║    Example: "PROD: Payment processing failing"               ║
╠══════════════════════════════════════════════════════════════╣
║  P1 (1) - HIGH                                               ║
║    • Major features                                          ║
║    • Blocking bugs                                           ║
║    • Sprint commitments                                      ║
║    Example: "Fix null pointer in login"                      ║
╠══════════════════════════════════════════════════════════════╣
║  P2 (2) - MEDIUM (Default)                                   ║
║    • Standard features                                       ║
║    • Minor bugs                                              ║
║    • Refactoring                                             ║
║    Example: "Extract validation to utility"                  ║
╠══════════════════════════════════════════════════════════════╣
║  P3 (3) - LOW                                                ║
║    • Nice-to-have                                            ║
║    • Tech debt                                               ║
║    • Documentation                                           ║
║    Example: "Update README with examples"                    ║
╠══════════════════════════════════════════════════════════════╣
║  P4 (4) - BACKLOG                                            ║
║    • Future ideas                                            ║
║    • Not currently planned                                   ║
║    • Wishlist items                                          ║
║    Example: "Consider adding GraphQL API"                    ║
╚══════════════════════════════════════════════════════════════╝
```

---

_For core policy and session checklists, see `~/.config/opencode/agents/beads-workflow.md`_
