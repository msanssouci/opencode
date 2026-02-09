---
Version: 1.0.0
Last Updated: 2026-02-08
Changelog:
- 1.0.0 (2026-02-08): Initial creation - extracted from project AGENTS.md
---

# Session Completion Protocol

**CRITICAL:** Work is NOT complete until ALL steps succeed. "Landing the plane" means ensuring nothing is stranded locally.

---

## 🚨 Mandatory Checklist

### Step 1: Review Active Work
```bash
bd list --status=in_progress --json
```

**Actions:**
- ✅ **Completed tasks**: Close with `--reason`
- 🔄 **Partially done**: Add `--notes` with progress update, keep in_progress
- ❌ **Blocked**: Update status if blocker discovered

**Example:**
```bash
# Task completed
bd close beads-123 --reason="Implemented UserService with full test coverage" --json

# Task partial
bd update beads-124 --notes="API endpoint done, tests 60% complete, UI pending" --json
```

---

### Step 2: Create Follow-Up Issues

**Capture ALL remaining work:**
- TODOs found in code
- Incomplete features
- Discovered bugs
- Technical debt
- Documentation needs

**Example:**
```bash
bd create --title="Fix TODO in AuthController line 45" --type=task --priority=3 --json
bd create --title="Document API authentication flow" --type=task --priority=4 --json
bd create --title="Investigate slow database query in UserService" --type=bug --priority=2 --json
```

**Add dependencies if needed:**
```bash
bd dep add beads-125 beads-124 --json  # New task depends on in-progress work
```

---

### Step 3: Run Quality Gates

**CRITICAL:** ALL must pass before closing session.

#### Project-Specific Commands
> **See project's AGENTS.md for exact commands.** Examples:

**Option A: Monorepo with justfile**
```bash
just test-all      # Run all tests (backend + frontend)
just lint-web      # Lint frontend code
just build-all     # Build all modules for production
```

**Option B: Backend-only project**
```bash
./gradlew test     # OR: npm test, pytest, cargo test
./gradlew build    # OR: npm run build, make build
```

**Option C: Frontend-only project**
```bash
npm test           # Run Jest/Vitest tests
npm run lint       # ESLint check
npm run build      # Production build
```

#### Universal Rules
- ❌ **NEVER ignore test failures** - Fix OR create bug issue
- ❌ **NEVER ignore lint errors** - Fix OR create tech-debt task
- ❌ **NEVER skip build check** - Ensures code compiles/bundles
- ⚠️  **If checks fail**: Create high-priority issue, mark as blocker

---

### Step 4: Close Completed Work

**Batch close for efficiency:**
```bash
bd close beads-120 beads-121 beads-122 --reason="User profile feature complete with tests" --json
```

**Individual close with specific context:**
```bash
bd close beads-123 --reason="Fixed null pointer in AuthHandler.validate(), added guard clause" --json
```

**Tips:**
- Be specific in `--reason` (helps future debugging)
- Reference file paths if relevant
- Mention test coverage if applicable

---

### Step 5: Export Beads State

```bash
bd sync --flush-only
```

**What this does:**
- Exports all task changes to `.beads/*.jsonl`
- Does NOT interact with git (that's next step)
- Ensures task state persists if session crashes

---

### Step 6: Git Workflow

```bash
# 1. Pull latest changes
git pull --rebase

# 2. Push your work
git push

# 3. VERIFY success
git status
```

**Expected output:**
```
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

**If push fails:**
- Resolve conflicts/errors
- Retry until success
- NEVER leave work unpushed

---

### Step 7: Verify Clean State

**Check beads:**
```bash
bd ready --json           # Should show available work (NOT your in_progress tasks)
bd list --status=in_progress --json  # Should be EMPTY or only tasks with progress notes
```

**Check git:**
```bash
git status                # No uncommitted changes
git log -1                # Verify last commit is yours (if you committed)
```

**Check project health:**
```bash
bd stats --json           # Review open/closed/blocked counts
```

---

## 🚨 Failure Scenarios & Recovery

### Scenario 1: Tests Fail
```bash
just test-all
# ❌ 3 tests failing in UserService
```

**Recovery:**
```bash
# Create bug issue
bd create --title="Fix 3 failing UserService tests" --type=bug --priority=1 --json
# Returns: beads-150

# Mark as blocker if critical
bd update beads-150 --notes="Blocks deployment, affects user registration flow" --json

# Option A: Fix now (if quick)
bd update beads-150 --status=in_progress --json
# [Fix tests...]
bd close beads-150 --reason="Fixed assertions in testCreateUser, testUpdateUser, testDeleteUser" --json

# Option B: Defer (if complex)
# Leave in pending state, continue session close
# Another agent/session will pick up via `bd ready`
```

### Scenario 2: Push Fails (Merge Conflict)
```bash
git push
# ❌ rejected: non-fast-forward
```

**Recovery:**
```bash
git pull --rebase
# ❌ CONFLICT in src/UserService.kt

# 1. Resolve conflict
# [Edit file, resolve markers]
git add src/UserService.kt
git rebase --continue

# 2. Retry push
git push

# 3. Verify
git status  # Must show "up to date with origin"
```

### Scenario 3: Lint Errors
```bash
just lint-web
# ❌ 12 ESLint errors
```

**Recovery:**
```bash
# Option A: Auto-fix (if available)
npm run lint:fix
# OR
just lint-web-fix  # (if project has this command)

# Verify
just lint-web

# Option B: Create task (if complex)
bd create --title="Fix 12 ESLint errors in components/" --type=task --priority=2 --json
```

---

## Project-Specific Hooks

> Your project may have additional requirements. Check project AGENTS.md for:

**Examples:**
- Docker containers running (database, cache)
- Database migrations applied
- Environment variables configured
- Test coverage thresholds met
- Security scans passed

**How to add:**
In your project's AGENTS.md, extend this protocol:
```markdown
## Extended Session Completion

Before Step 6 (Git Workflow), also run:
- `just docker-check` - Verify containers healthy
- `just db-migrate-check` - Ensure migrations applied
- `just security-scan` - Run SAST/dependency checks
```

---

## Quick Checklist (Print-Friendly)

```
┌─────────────────────────────────────────────────────────┐
│  SESSION COMPLETION CHECKLIST                           │
├─────────────────────────────────────────────────────────┤
│  ☐ 1. Review active work (bd list --status=in_progress) │
│  ☐ 2. Create follow-up issues (bd create)              │
│  ☐ 3. Run quality gates (just test-all / lint / build) │
│  ☐ 4. Close completed work (bd close)                  │
│  ☐ 5. Export beads (bd sync --flush-only)              │
│  ☐ 6. Git push (git pull --rebase && git push)         │
│  ☐ 7. Verify clean (bd ready, git status)              │
├─────────────────────────────────────────────────────────┤
│  CRITICAL: Work NOT complete until git status shows     │
│            "up to date with origin"                     │
└─────────────────────────────────────────────────────────┘
```

---

## Philosophy

**Why this protocol matters:**
1. **Prevents lost work**: Context persists in beads + git
2. **Enables collaboration**: Others can pick up where you left off
3. **Maintains quality**: Tests/lint/build gates prevent regressions
4. **Builds trust**: Consistent hygiene = predictable outcomes

**Anti-patterns:**
- ❌ "I'll push later" - Never push later, push NOW
- ❌ "Tests can wait" - Tests are not optional
- ❌ "Too tired to close tasks" - 30 seconds now saves 30 minutes later

---

_For beads task tracking details, see [beads-workflow.md](beads-workflow.md)_
_For project setup, see [project-onboarding.md](project-onboarding.md)_
