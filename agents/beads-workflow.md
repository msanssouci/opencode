---
Version: 1.1.0
Last Updated: 2026-02-09
Changelog:
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

## Universal Workflow Patterns

### Pattern 1: Simple Bug Fix
```bash
# 1. Find or create issue
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

### Commit Message Convention
```bash
# Include beads ID in commit message
git commit -m "feat: add user profile endpoint [beads-102]"
git commit -m "fix: null pointer in auth [beads-87]"
git commit -m "refactor: extract validation utils [beads-45]"
```

### Branch Naming (Optional)
```bash
git checkout -b beads-102-user-profile-api
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
║  Start Session:    bd ready --json                           ║
║  Create Task:      bd create --title="..." -t task -p 2      ║
║  Claim Work:       bd update <id> --status=in_progress       ║
║  Add Progress:     bd update <id> --notes="..."              ║
║  Close Task:       bd close <id> --reason="..."              ║
║  End Session:      bd sync --flush-only                      ║
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
