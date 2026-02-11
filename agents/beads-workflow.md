---
Version: 2.1.0
Last Updated: 2026-02-09
Changelog:
- 2.1.0 (2026-02-09): Added "Decision Tree: Should I Create a Beads Task?" section with visual flow and examples
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

## 🤔 Decision Tree: Should I Create a Beads Task?

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

### Commit Workflow: Close → Sync → Commit

**CRITICAL:** Follow this exact order to avoid multiple commits per feature.

```bash
# 1. Close all beads tasks for the feature (DO NOT commit yet)
bd close beads-xxx --reason="Implemented feature X" --json
bd close beads-yyy --reason="Added tests for X" --json

# 2. Sync beads to JSONL (DO NOT commit yet)
bd sync --flush-only

# 3. Commit EVERYTHING together (code + beads metadata)
git add <changed-files> .beads/issues.jsonl .beads/interactions.jsonl
git commit -m "feat: add user profile endpoint

- Implemented profile schema and API
- Added validation and tests

Closes: beads-xxx, beads-yyy"
git push
```

### Commit Message Format
```bash
# Include all beads IDs in commit footer
git commit -m "feat: description\n\nCloses: beads-xxx, beads-yyy, beads-zzz"
```

**Why this order matters:**
- ✅ Prevents multiple commits per feature (was causing 3+ commits for simple work)
- ✅ Keeps code and tracking metadata atomic
- ✅ Cleaner git history
- ✅ Easier code reviews

---

## Common Mistakes to Avoid (Top 5)

❌ **Starting code before creating task**
- **Impact**: Lost context if session interrupted
- **Fix**: Always `bd create` BEFORE first file edit

❌ **Committing after each beads task**
- **Impact**: Creates 3+ commits for simple features, noisy git history
- **Fix**: Follow close → sync → commit pattern (all together)

❌ **Forgetting bd sync before commit**
- **Impact**: Beads metadata not included in commit, leaves .beads/*.jsonl uncommitted
- **Fix**: Always sync BEFORE committing: `bd sync --flush-only`

❌ **Closing task without reason**
- **Impact**: No breadcrumbs for future debugging
- **Fix**: Always use `--reason="detailed explanation"`

❌ **Not committing .beads/*.jsonl changes**
- **Impact**: Task tracking history lost
- **Fix**: Always include .beads/*.jsonl in your commit: `git add .beads/*.jsonl`

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
