---
Version: 2.0.0
Last Updated: 2026-02-09
Changelog:
- 2.0.0 (2026-02-09): Split into core policy (agents/) + detailed guide (skills/) for 69% token reduction
- 1.3.0 (2026-02-09): Added Session Start Checklist, beads commit conventions, stale task handling, and validation guidance
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

## 🏁 Session Start Checklist (MANDATORY)

**Run these commands at the START of every work session:**

```bash
# 1. Git Branch Setup (infrastructure - not tracked in beads)
~/.config/opencode/scripts/git-branch-setup.sh
# OR load beads-workflow skill for manual step-by-step guide

# 2. Check beads initialization
bd ready --json  # Should show available work OR empty list (not an error)

# 3. Check for stale tasks from previous sessions
bd list --status=in_progress --json  # Should be empty or tasks you're continuing

# 4. Plan your work
bd list --status=open --json  # Review existing open tasks
# OR
bd create --title="..." --type=task --priority=2 --description="Detailed context" --json

# 5. Claim a task (tracking begins)
bd update <id> --status=in_progress --json
```

**If `bd ready` shows "Error: no beads database found":**
```bash
bd init  # Initialize beads (one-time setup)
```

**Why this matters:**
- ✅ Ensures you're working on latest code (git branch setup)
- ✅ Finds existing work before creating duplicates
- ✅ Identifies abandoned tasks from interrupted sessions
- ✅ Creates proper tracking from the start (not retroactively)

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

## 📚 Beads + Git Integration (Essential)

### Commit Messages Include Beads ID
```bash
git commit -m "feat: add user profile endpoint [beads-102]"
git commit -m "fix: null pointer in auth [beads-87]"
```

### Beads Changes Committed Separately
```bash
# After feature work is committed:
bd sync --flush-only
git add .beads/issues.jsonl .beads/interactions.jsonl
git commit -m "chore: sync beads tracking for [feature-name]"
git push
```

**Why:** Keeps feature commits (code) separate from tracking metadata (beads)

---

## Common Mistakes to Avoid (Top 5)

❌ **Starting code before creating task**
- **Impact**: Lost context if session interrupted
- **Fix**: Always `bd create` BEFORE first file edit

❌ **Forgetting bd sync before session end**
- **Impact**: Task state not exported to JSONL
- **Fix**: Run `bd sync --flush-only` then commit `.beads/issues.jsonl`

❌ **Closing task without reason**
- **Impact**: No breadcrumbs for future debugging
- **Fix**: Always use `--reason="detailed explanation"`

❌ **Creating tasks retroactively (after work is done)**
- **Impact**: No real-time tracking, defeats session recovery
- **Fix**: Create tasks at session start, update status as you progress

❌ **Using wrong priority values**
- **Impact**: `bd create --priority=high` FAILS (expects 0-4)
- **Fix**: 0=critical, 1=high, 2=medium, 3=low, 4=backlog

**For complete list:** Load the beads-workflow skill

---

## Quick Reference Card

```
╔══════════════════════════════════════════════════════════════╗
║  BEADS QUICK REFERENCE                                       ║
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
║  SESSION END CHECKLIST:                                      ║
║  1. Sync to JSONL:     bd sync --flush-only                  ║
║  2. Commit beads:      git add .beads/issues.jsonl           ║
║                        git commit -m "chore: sync beads..."  ║
║  3. Push all:          git push                              ║
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

## 📚 For Detailed Workflows

**When you need comprehensive step-by-step guides**, load the beads-workflow skill:

```
Use skill tool with name: "beads-workflow"
```

**The skill provides:**
- Git branch setup procedures (3 scenarios with decision trees)
- Workflow patterns (simple bug fix, epic, refactoring, hotfix)
- Squash merge conflict resolution
- Stale task recovery procedures
- Complete list of common mistakes (15+ items)
- Technology-specific integration guidance

---

## Next Steps

- **Project-specific workflows:** See your project's `.agents/examples/` directory
- **Session completion protocol:** See [session-completion.md](session-completion.md)
- **Setting up new project:** See [project-onboarding.md](project-onboarding.md)

---

_This is a universal guide. For technology-specific integration, see your project's AGENTS.md._
