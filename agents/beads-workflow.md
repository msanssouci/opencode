---
Version: 3.0.0
Last Updated: 2026-02-21
Changelog:
- 3.0.0 (2026-02-21): Optimized token usage - reduced from 466 lines (~5,300 tokens) to ~236 lines (~2,500 tokens) by moving detailed content to skill. 53% reduction.
- 2.3.0 (2026-02-11): Updated commit message format to use succinct subject line with Beads Tasks section
- 2.2.0 (2026-02-11): Added auto-load triggers for agents to recognize when to load beads-workflow skill
- 2.1.0 (2026-02-09): Added "Decision Tree: Should I Create a Beads Task?" section with visual flow and examples
- 2.0.0 (2026-02-09): Split into core policy (agents/) + detailed guide (skills/) for 69% token reduction
- 1.3.0 (2026-02-09): Added Session Start Checklist, beads commit conventions, stale task handling, and validation guidance
- 1.2.0 (2026-02-09): Added Git Branch Setup checklist with upstream tracking and automation script
- 1.1.0 (2026-02-09): Added "Before You Start" section with bd init instructions
- 1.0.0 (2026-02-08): Initial creation - extracted from project AGENTS.md
---

# Beads Workflow - Universal Task Tracking

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

## 🚨 Session Start Checklist (MANDATORY)

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


## 🎯 When to Create Beads Tasks (Simplified)

**Key Principle**: "If it will be committed to git, it needs a beads task."

### ✅ ALWAYS Create a Beads Task For:

1. **File Operations** - Creating, modifying, or deleting files
2. **Multi-Step Work** - Anything requiring 2+ tool invocations
3. **Work That Will Be Committed** - ANY changes resulting in `git commit`

### ❌ Do NOT Create Beads Tasks For:

1. **Read-Only Requests** - Explaining code, answering questions
2. **One-Off Commands** - Running `git status`, `npm test`, etc.
3. **Pure Conversation** - Discussing design, planning (before implementation)

### 💡 When Unsure

**Default to creating a beads task.** The overhead is minimal, and the benefits (traceability, session recovery) are substantial.

**For comprehensive decision tree with flowchart and examples:** Load skill `beads-workflow`

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

Implemented profile management with validation and comprehensive testing.

Beads Tasks:
- beads-xxx: Created profile schema and API
- beads-yyy: Added validation and integration tests"
git push
```

### Commit Message Format (Abbreviated)

```bash
# Standard format (50 chars max for subject line):
# <type>: <succinct description>
# 
# <detailed body - optional>
# 
# Beads Tasks:
# - beads-xxx: <brief description>
# - beads-yyy: <brief description>

# Example:
git commit -m "feat: add user profile endpoint

Implemented user profile management with schema, API, and tests.

Beads Tasks:
- beads-101: Created User schema with validation
- beads-102: Built GET/POST /api/profile endpoints
- beads-103: Added integration tests with 90% coverage"

# Commit types: feat, fix, refactor, test, docs, chore, style, perf
```

**Rules:**
- ✅ First line: 50 characters max, imperative mood ("add" not "added")
- ✅ Beads section: Lists each task with what it accomplished
- ❌ Don't put beads IDs in subject line (keeps it clean)

**For detailed examples and patterns:** Load skill `beads-workflow`

**Why this order matters:**
- ✅ Prevents multiple commits per feature
- ✅ Keeps code and tracking metadata atomic
- ✅ Cleaner git history

---

## Common Mistakes to Avoid (Top 3)

❌ **Starting code before creating task**
- **Impact**: Lost context if session interrupted
- **Fix**: Always `bd create` BEFORE first file edit

❌ **Committing after each beads task**
- **Impact**: Creates 3+ commits for simple features, noisy git history
- **Fix**: Follow close → sync → commit pattern (all together)

❌ **Forgetting bd sync before commit**
- **Impact**: Beads metadata not included in commit, leaves .beads/*.jsonl uncommitted
- **Fix**: Always sync BEFORE committing: `bd sync --flush-only`

**For complete list (15+ mistakes with detailed fixes):** Load skill `beads-workflow`

---

## 🤖 Auto-Load Triggers for Agents

**AUTOMATICALLY load the beads-workflow skill when you encounter:**

1. **Git Issues:**
   - Branch conflicts or merge failures
   - Squash merge problems ("already merged but shows conflicts")
   - Diverged branch needing resolution
   - Need for manual git branch setup steps
   - User mentions "git conflicts", "squash merge", or "branch issues"

2. **Session Recovery:**
   - Stale tasks stuck in `in_progress` status
   - Interrupted session recovery needed
   - User asks "what happened to my tasks?" or "recover from yesterday"

3. **Workflow Guidance:**
   - User asks "how do I..." with any workflow pattern
   - Need for step-by-step pattern examples (bug fix, epic, refactor, hotfix)
   - User requests "show me the workflow" or "what's the process for..."

4. **Troubleshooting:**
   - User encounters errors with bd commands
   - Need for complete mistakes list
   - User asks "what am I doing wrong?" or "why isn't this working?"

5. **First-Time Setup:**
   - User is new to beads workflow
   - User asks for detailed examples or walkthroughs
   - User needs technology-specific integration guidance

**Trigger phrases to watch for:**
- "How do I set up my git branch?"
- "I have merge conflicts"
- "My tasks are stuck in progress"
- "Show me a workflow example"
- "What's the pattern for X?"
- "Squash merge issue"
- "Step-by-step guide"
- "Detailed workflow"

**When to skip auto-loading:**
- User just needs quick command reference (already in this file)
- Simple one-off bd command execution
- Question answered by decision tree or quick reference above

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
- Quick reference cards
- Detailed commit message examples

---

## Next Steps

- **Project-specific workflows:** See your project's `.agents/examples/` directory
- **Session completion protocol:** See [session-completion.md](session-completion.md)
- **Setting up new project:** See [project-onboarding.md](project-onboarding.md)

---

_This is a universal guide. For technology-specific integration, see your project's AGENTS.md._
