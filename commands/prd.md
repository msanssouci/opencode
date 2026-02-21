---
description: End-to-end PRD processing - analyzes requirements, creates tasks, orchestrates parallel implementation
agent: general
subtask: false
---

# PRD Command - Product Requirements to Implementation

You are the **PRD Command Handler** - orchestrating the complete workflow from requirements analysis to deployed feature.

## Input

**PRD Description:** $ARGUMENTS

## Execution Workflow

### Phase 1: Requirements Analysis & Task Planning

1. **Load prd-planner skill**
   - Use the `skill` tool to load the `prd-planner` skill
   - Pass the PRD description from $ARGUMENTS
   - The prd-planner will:
     - Parse the requirements
     - Identify entities, backend needs, frontend needs
     - Create an epic with proper beads task breakdown
     - Set up dependencies between tasks
     - Tag tasks appropriately (backend, frontend, testing)

2. **Show Planning Results**
   - Display the created epic ID and title
   - List all created tasks grouped by type:
     - Backend tasks (entities, repos, services, controllers, tests)
     - Frontend tasks (types, API clients, components, pages, tests)
     - Testing tasks (integration, E2E)
   - Show dependency graph (which tasks are ready, which are blocked)
   - Report task counts: `X tasks ready, Y tasks blocked`

3. **🚨 CHECKPOINT: Get User Approval**
   
   Ask the user:
   ```
   📋 Planning Complete!
   
   Created: 1 epic, X tasks
   Ready to start: Y tasks
   Blocked (waiting on dependencies): Z tasks
   
   What would you like to do?
   1. ✅ Proceed with implementation
   2. ❌ Cancel (keep tasks for manual work)
   3. 📝 Modify tasks first
   
   Enter choice (1/2/3):
   ```

   **Handle responses:**
   - **Choice 1 or "yes" or "proceed"**: Continue to Phase 2
   - **Choice 2 or "no" or "cancel"**: 
     ```
     Tasks have been created in beads. You can:
     - View tasks: bd list --status=open
     - Start manually: bd ready
     - Modify tasks: bd update <id> --title/--description
     
     Exit workflow.
     ```
   - **Choice 3 or "modify"**:
     ```
     Tasks are ready for modification. You can:
     - Update task details: bd update <id> --title="..." --description="..."
     - Adjust dependencies: bd dep add <task> <depends-on>
     - Change priorities: bd update <id> --priority=0-4
     
     When ready, run: /prd-continue
     
     Exit workflow (will create /prd-continue command to resume).
     ```

### Phase 2: Parallel Implementation (Only if approved in Phase 1)

4. **Load build-orchestrator skill**
   - Use the `skill` tool to load the `build-orchestrator` skill
   - The build-orchestrator will:
     - Query `bd ready --json` for available tasks
     - Group tasks by type (backend, frontend)
     - Execute up to 4 tasks in parallel per batch
     - Use `backend-dev` and `frontend-dev` subagents
     - Monitor task completion and update beads status

5. **Quality Gates After Each Batch**
   
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

6. **Batch Progress Reporting**
   
   After each successful batch:
   ```
   ✅ Batch N Complete (X/Y tasks done)
   
   Completed in this batch:
   - Task ID: Task title
   - Task ID: Task title
   
   Remaining: Z tasks
   Next batch: W tasks ready
   ```

7. **Continue Until All Tasks Complete**
   - Repeat batches until `bd ready --json` returns no tasks
   - Track total tasks completed vs. remaining
   - Update user after each batch

### Phase 3: Commit & Report (Only if all tasks complete)

8. **Final Quality Check**
   - Run `just build-all` one final time
   - Run `just test-all` one final time
   - If failures, report and ask user to fix before committing

9. **Commit Changes**
   - Review all changes: `git status` and `git diff`
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

10. **Close Epic & Report**
    - Close epic: `bd close <epic-id> --reason="Feature complete via /prd command"`
    - Sync beads to JSONL: `bd sync`
    - Generate final report:
      ```
      🎉 Feature Complete!
      
      📊 Statistics:
         Epic: <epic-id> (<epic-title>)
         Tasks: X completed (100%)
         Files: Y created, Z modified
         Tests: W added (all passing ✅)
         Time: ~N minutes
      
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
      
      🔗 Git commit: <commit-hash>
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

Then retry: /prd "$ARGUMENTS"
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

Then retry: /prd "$ARGUMENTS"
```

### No PRD Provided
If $ARGUMENTS is empty:
```
🚨 No PRD provided!

Usage:
   /prd "Feature description here"

Example:
   /prd "Add health check endpoint at GET /api/health"
```

### Git Working Directory Dirty
```bash
!`git status --porcelain`
```
If dirty:
```
🚨 Working directory has uncommitted changes!

Please commit or stash changes:
   git status
   git add .
   git commit -m "..."
   
Or stash:
   git stash

Then retry: /prd "$ARGUMENTS"
```

## Examples

### Example 1: Simple Endpoint
```
/prd "Add GET /api/version endpoint that returns {version: '1.0.0', build: 'timestamp'}"
```

**Expected outcome:**
- 1 epic created
- 4 tasks created (backend endpoint, tests, frontend types, API client)
- User approves at checkpoint
- 10-15 minutes execution
- All tests passing
- 1 commit

### Example 2: Full Feature
```
/prd "Budget Tracking:
- Users can create budgets with name, category, amount, and period (monthly/yearly)
- Each budget belongs to an account
- System shows budget vs actual spending
- Users receive alerts when budget exceeded"
```

**Expected outcome:**
- 1 epic created
- 18-25 tasks created (backend, frontend, testing)
- User reviews task breakdown
- User approves at checkpoint
- 40-60 minutes execution (parallel)
- 35+ files created/modified
- 60+ tests added
- 1 commit

### Example 3: User Cancels
```
/prd "Add complex reporting feature"
```

User sees tasks and chooses "Cancel" at checkpoint.

**Outcome:**
- Tasks remain in beads for manual implementation
- User can review: `bd list --status=open`
- User can start manually: `bd ready`
- No code changes made

## Project Context

### Architecture
- **Backend**: Kotlin/Spring Boot (apps/api/)
- **Frontend**: Next.js/React (apps/web/)
- **Database**: PostgreSQL via JOOQ
- **Testing**: Kotest (backend), Jest + Playwright (frontend)

### Available Commands
```bash
just docker-up      # Start Postgres + Redis
just build          # Build Kotlin backend
just test           # Run Kotest tests
just run-api        # Start Spring Boot API
just build-web      # Build Next.js app
just test-web       # Run Jest tests
just test-e2e       # Run Playwright E2E tests
just test-all       # Run ALL tests
just build-all      # Build everything
just dev            # Run API + Web concurrently
```

### Beads Integration
- Prefix: `{project}-XXX`
- Epic created first with type=feature
- Implementation tasks with type=task
- Dependencies configured via `bd dep add`
- Status flow: pending → in_progress → done

## Success Criteria

A `/prd` execution is successful when:

1. ✅ All beads tasks created with proper dependencies
2. ✅ User approved task plan at checkpoint
3. ✅ All tasks completed (status = closed)
4. ✅ All builds passing (`just build-all`)
5. ✅ All tests passing (`just test-all`)
6. ✅ Changes committed with conventional commit message
7. ✅ Epic closed with completion reason
8. ✅ Beads synced to JSONL
9. ✅ Final report provided to user

## Important Notes

### System Constraints
- Max 4 parallel subagents per batch
- Subagents cannot invoke other subagents
- You (prd command) must coordinate all parallelization
- Use `task` tool to invoke backend-dev and frontend-dev agents

### When to Use /prd vs Manual
**Use /prd when:**
- ✅ Feature is well-defined
- ✅ You want semi-automated workflow (plan → approve → implement)
- ✅ Feature fits {project} architecture
- ✅ You trust the multi-agent system

**Use manual workflow when:**
- ❌ PRD is vague or exploratory
- ❌ You want to implement tasks yourself
- ❌ Feature requires architectural changes
- ❌ You want fine-grained control

## Tips for Good PRDs

### ✅ Good PRDs
- **Specific entities**: "Add Task entity with title, description, status, priority, assignee, dueDate"
- **Clear relationships**: "A project can have many tasks. A task belongs to one project."
- **Explicit validation**: "Title is required (max 100 chars). Status must be: todo, in_progress, or done."
- **Defined endpoints**: "REST endpoints: POST /api/tasks, GET /api/tasks/:id, PUT /api/tasks/:id, DELETE /api/tasks/:id"

### ❌ Vague PRDs
- "Make the app better"
- "Add some features"
- "Improve performance"
- "Refactor code"

---

**Let's build amazing features together! 🎉**
