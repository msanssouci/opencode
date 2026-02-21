---
description: Resume PRD implementation after task modifications
agent: general
subtask: false
---

# PRD Continue - Resume Implementation

You are resuming a **PRD workflow** that was paused for task modifications.

## Context

The user previously ran `/prd` and chose to modify tasks before implementation. The tasks have been created in beads and are ready for execution.

## Execution Workflow

### 1. Verify Tasks Exist

Check for open tasks:
```bash
!`bd list --status=open --json`
```

If no tasks found:
```
🚨 No open tasks found!

Either:
- No /prd workflow was started
- All tasks are already complete
- Tasks were closed/cancelled

Run: bd list --status=all
To see all tasks.

Exit workflow.
```

### 2. Show Current State

Display task summary:
```bash
!`bd ready --json`
!`bd list --status=in_progress --json`
!`bd blocked --json`
```

Report:
```
📋 Current Task Status:

Ready to start: X tasks
In progress: Y tasks  
Blocked: Z tasks
Total open: W tasks

Ready tasks:
- <task-id>: <title>
- <task-id>: <title>
...
```

### 3. Ask for Confirmation

```
Ready to start parallel implementation?

This will:
- Execute ready tasks in parallel batches (max 4 at a time)
- Run build + tests after each batch
- Stop on failures for your guidance
- Commit when all tasks complete

Proceed? (yes/no):
```

**Handle responses:**
- **"yes" or "proceed"**: Continue to Phase 4
- **"no" or "cancel"**: 
  ```
  Tasks remain available in beads.
  
  To start manually:
  - View tasks: bd ready
  - Start a task: bd update <id> --status=in_progress
  - Complete a task: bd close <id>
  
  Exit workflow.
  ```

### 4. Load build-orchestrator skill

- Use the `skill` tool to load the `build-orchestrator` skill
- The build-orchestrator will:
  - Query `bd ready --json` for available tasks
  - Group tasks by type (backend, frontend)
  - Execute up to 4 tasks in parallel per batch
  - Use `backend-dev` and `frontend-dev` subagents
  - Monitor task completion and update beads status

### 5. Quality Gates After Each Batch

**After each batch completes:**
- Run `just build-all` to verify compilation
- Run `just test-all` to verify tests pass

**If build fails:**
```
🚨 Build Failed!

Error details:
[Show build error output]

What would you like to do?
1. Fix the error and retry
2. Skip this batch and continue
3. Stop execution

Enter choice (1/2/3):
```

**If tests fail:**
```
🚨 Tests Failed!

Failing tests:
[Show test failures]

What would you like to do?
1. Fix the tests and retry
2. Continue with other tasks (mark these as blocked)
3. Stop execution

Enter choice (1/2/3):
```

### 6. Batch Progress Reporting

After each successful batch:
```
✅ Batch N Complete (X/Y tasks done)

Completed in this batch:
- Task ID: Task title
- Task ID: Task title

Remaining: Z tasks
Next batch: W tasks ready
```

### 7. Continue Until All Tasks Complete

- Repeat batches until `bd ready --json` returns no tasks
- Track total tasks completed vs. remaining
- Update user after each batch

### 8. Final Quality Check

- Run `just build-all` one final time
- Run `just test-all` one final time
- If failures, report and ask user to fix before committing

### 9. Commit Changes

- Review all changes: `git status` and `git diff`
- Find the epic ID from the first task's metadata
- Generate conventional commit message:
  ```
  feat: <epic title>
  
  <Summary of changes - entities, services, components, tests>
  
  Implemented via multi-agent workflow (/prd command)
  - X backend tasks completed
  - Y frontend tasks completed
  - Z tests added (all passing)
  
  Closes <epic-id>
  ```
- Commit: `git add . && git commit -m "..."`
- Sync beads: `bd sync`

### 10. Close Epic & Report

- Find and close the epic: `bd close <epic-id> --reason="Feature complete via /prd-continue"`
- Sync beads to JSONL: `bd sync`
- Generate final report:
  ```
  🎉 Feature Complete!
  
  📊 Statistics:
     Epic: <epic-id> (<epic-title>)
     Tasks: X completed (100%)
     Files: Y created, Z modified
     Tests: W added (all passing ✅)
  
  📦 What Was Built:
     Backend:
     - A entities, B repositories, C services, D controllers
     - E database migrations
     - F unit tests (Kotest)
     
     Frontend:
     - G type files, H API clients
     - I components, J pages
     - K unit tests (Jest)
  
  ✅ Build: SUCCESS
  ✅ Tests: W/W passing
  ✅ Commit: <commit-hash>
  ✅ Beads: Synced
  ```

## Error Handling

### Docker Not Running
```bash
!`docker ps`
```
If fails:
```
🚨 Docker not running!

Please start Docker:
   just docker-up

Then retry: /prd-continue
```

### Beads Not Initialized
```bash
!`bd ready --json`
```
If fails:
```
🚨 Beads not initialized!

Please initialize:
   bd init {project}

Then retry: /prd-continue
```

### Git Working Directory Dirty (excluding expected /prd changes)
```bash
!`git status --porcelain`
```
If dirty with unexpected changes:
```
⚠️ Warning: Working directory has uncommitted changes!

These may interfere with the /prd workflow.
Consider committing or stashing unrelated changes.

Proceed anyway? (yes/no):
```

## Success Criteria

A `/prd-continue` execution is successful when:

1. ✅ All remaining tasks completed
2. ✅ All builds passing (`just build-all`)
3. ✅ All tests passing (`just test-all`)
4. ✅ Changes committed with conventional commit message
5. ✅ Epic closed with completion reason
6. ✅ Beads synced to JSONL
7. ✅ Final report provided to user

---

**Resuming your feature implementation! 🚀**
