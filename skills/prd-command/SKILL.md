---
name: prd-command
description: End-to-end PRD processing command - analyzes requirements, creates tasks, and orchestrates parallel implementation
version: 1.0.0
author: msanssouci
tags: [command, workflow, automation, orchestration]
command: prd
dependencies:
  - beads-workflow
  - prd-planner
  - build-orchestrator
---

# PRD Command Skill

## 🎯 Overview

**You are the PRD command handler** - the single-command entry point for the entire multi-agent workflow.

This skill provides a `/prd` slash command that automates the complete workflow:
1. Analyze PRD requirements
2. Create beads task breakdown
3. Coordinate parallel implementation
4. Run tests and reviews
5. Commit changes
6. Report completion status

## 📝 Command Usage

### Basic Usage

```bash
/prd "Feature description here"
```

### Examples

```bash
# Simple feature
/prd "Add a health check endpoint at GET /api/health"

# Complex feature
/prd "Users can create budgets with monthly limits. Each budget belongs to an account and has a name, amount, and period (monthly/yearly)."

# Full PRD
/prd "Budget Tracking Feature:
- Users can set budget limits for categories
- System alerts when budget is exceeded
- Monthly budget reports via email
- Admin dashboard for all budgets"
```

### Command Flags (Future Enhancement)

```bash
/prd --dry-run "Feature..."     # Analyze only, don't implement
/prd --skip-tests "Feature..."  # Skip test execution
/prd --manual "Feature..."      # Create tasks only, manual execution
```

## 🔄 Execution Workflow

### Phase 1: PRD Analysis (prd-planner)

**What happens:**
1. Load prd-planner skill
2. Parse the PRD text
3. Identify entities, backend needs, frontend needs
4. Create epic + implementation tasks
5. Set up dependencies
6. Tag tasks appropriately

**Output:**
- Epic created (e.g., `spending-tracker-XXX`)
- 5-30 implementation tasks created
- Dependencies configured
- Tasks marked as ready/blocked

**Example output:**
```
✅ Created epic: spending-tracker-abc (Budget Tracking Feature)
✅ Created 18 tasks:
   - 8 backend tasks (entities, repos, services, controllers, tests)
   - 6 frontend tasks (types, API clients, components, pages, tests)
   - 4 testing tasks (integration + E2E)
✅ 5 tasks ready to start (no blockers)
✅ 13 tasks blocked (waiting on dependencies)
```

### Phase 2: Parallel Implementation (build-orchestrator)

**What happens:**
1. Query `bd ready --json` for available tasks
2. Group tasks by type (backend, frontend, testing)
3. Launch up to 4 parallel agents per batch
4. Monitor task completion
5. Repeat until all tasks done

**Agents used:**
- `backend-dev` - Implements backend tasks
- `frontend-dev` - Implements frontend tasks
- `code-reviewer` - Reviews code quality (unused currently due to constraints)
- `test-runner` - Executes tests (unused currently due to constraints)

**Example execution:**
```
🚀 Batch 1 (4 parallel agents):
   - backend-dev → Budget entity + migration
   - backend-dev → Budget DTOs
   - frontend-dev → Budget types
   - frontend-dev → Budget API client

✅ Batch 1 complete (4/18 tasks done)

🚀 Batch 2 (3 parallel agents):
   - backend-dev → BudgetRepository
   - backend-dev → BudgetService
   - frontend-dev → BudgetForm component

✅ Batch 2 complete (7/18 tasks done)
...
```

### Phase 3: Quality Gates

**After each batch:**
1. Run `just build` to verify code compiles
2. Run `just test` to verify tests pass
3. Fix any failures before continuing
4. Update beads task status

**Final verification:**
```bash
just build-all   # Build backend + frontend
just test-all    # Run all tests (Kotest + Jest + Playwright)
just lint-web    # Lint frontend code
```

### Phase 4: Commit & Report

**What happens:**
1. Commit all changes with conventional commit message
2. Close the epic with completion summary
3. Sync beads to JSONL
4. Report final statistics

**Example commit:**
```
feat: implement Budget Tracking feature

- Backend: Budget entity, repository, service, controller
- Database migration for budgets table
- Frontend: Budget types, API client, components, pages
- Tests: 45 unit tests + 3 E2E scenarios

Implemented via multi-agent workflow (/prd command)
All tests passing. All builds successful.

Closes spending-tracker-abc
```

**Final report:**
```
🎉 Feature Complete!

📊 Statistics:
   - Tasks: 18 completed (100%)
   - Files: 28 created, 5 modified
   - Tests: 45 added (all passing ✅)
   - Time: ~35 minutes (would be 2-3 hours sequential)
   - Speedup: 4x faster with parallel execution

📦 What Was Built:
   Backend:
   - 3 entities, 3 repositories, 3 services, 3 controllers
   - 2 database migrations
   - 38 unit tests (Kotest)
   
   Frontend:
   - 3 type files, 3 API clients
   - 6 components, 2 pages
   - 7 unit tests (Jest)

✅ Build: SUCCESS
✅ Tests: 45/45 passing
✅ Commit: d5f3281
✅ Beads: Synced
```

## 🛠️ Implementation Details

### How I Process the Command

When invoked with `/prd "Feature description..."`, I:

1. **Extract PRD text** from command argument
2. **Load prd-planner skill** and pass the PRD
3. **Wait for task creation** (epic + implementation tasks)
4. **Count ready tasks** using `bd ready --json`
5. **Execute parallel batches** until all tasks complete
6. **Run quality gates** after each batch
7. **Commit and report** when done

### Parallel Execution Strategy

**Current approach:**
- Use `task` tool to invoke multiple subagents in a single message
- Max 4 parallel agents per batch (system limit)
- Each agent works independently on a separate beads task
- I coordinate batches sequentially

**Example batch invocation:**
```typescript
<invoke task backend-dev for spending-tracker-123>
<invoke task backend-dev for spending-tracker-124>
<invoke task frontend-dev for spending-tracker-125>
<invoke task frontend-dev for spending-tracker-126>
// All 4 execute simultaneously
```

**Performance:**
- Sequential: ~5 minutes per task = 90 minutes for 18 tasks
- Parallel (4 agents): ~5 batches × 5 minutes = ~25-30 minutes
- **Speedup: 3-4x faster**

### Error Handling

**Build failures:**
- Stop execution
- Report error details
- Mark task as blocked
- Ask user for guidance

**Test failures:**
- Retry up to 3 times (test-runner skill)
- If still failing, escalate to user
- Continue with other tasks in parallel

**Task dependencies:**
- Only run tasks with no blockers
- Auto-unblock when dependencies complete
- Report blocked count in each batch

## 📚 Project Context

### spending-tracker Architecture

**Backend (Kotlin/Spring Boot):**
- Location: `apps/api/`
- Testing: Kotest
- Database: PostgreSQL (via JOOQ)
- Build: Gradle
- Patterns: Repository → Service → Controller

**Frontend (Next.js/React):**
- Location: `apps/web/`
- Testing: Jest (unit) + Playwright (E2E)
- Build: Next.js 15 with Turbopack
- Patterns: API client → Component → Page

### Available Commands (justfile)

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

**All tasks use beads:**
- Prefix: `spending-tracker-XXX`
- Create epic first: `bd create --title="Feature Name" --type=feature --priority=2`
- Create tasks: `bd create --title="Task" --type=task --priority=2`
- Set dependencies: `bd dep add <task> <depends-on>`
- Mark progress: `bd update <id> --status=in_progress`
- Close when done: `bd close <id> --reason="..."`

**Task statuses:**
```
pending → in_progress → in_review → ready_for_test → done
```

## 🎯 Success Criteria

A `/prd` command execution is successful when:

1. ✅ All beads tasks created with proper dependencies
2. ✅ All tasks completed (status = closed)
3. ✅ All builds passing (`just build-all`)
4. ✅ All tests passing (`just test-all`)
5. ✅ Changes committed with conventional commit message
6. ✅ Epic closed with completion reason
7. ✅ Beads synced to JSONL
8. ✅ Final report provided to user

## 🚨 Important Notes

### System Constraints

**Nested task limitation:**
- Subagents cannot invoke more subagents
- I must coordinate all parallel invocations
- build-orchestrator skill cannot self-orchestrate
- Max 4 parallel agents per batch

**Workaround:**
- I act as the orchestrator
- I invoke multiple task tools in parallel
- Each subagent completes one beads task
- I manage batching and sequencing

### When to Use vs. Manual Workflow

**Use `/prd` command when:**
- ✅ Feature is well-defined in a single PRD
- ✅ You want full automation (analysis → implementation → commit)
- ✅ You trust the multi-agent system
- ✅ Feature fits the spending-tracker architecture

**Use manual workflow when:**
- ❌ PRD is vague or needs refinement
- ❌ You want to review tasks before implementation
- ❌ You want fine-grained control over execution
- ❌ Feature requires architectural changes

## 📖 Examples

### Example 1: Simple Endpoint

**Command:**
```bash
/prd "Add GET /api/version endpoint that returns {version: '1.0.0', build: 'timestamp'}"
```

**Generated tasks:**
1. Backend: Create VersionController with endpoint
2. Backend: Write Kotest tests for VersionController
3. Frontend: Add version type definition
4. Frontend: Create version API client method

**Result:**
- 4 tasks completed in ~10 minutes
- 1 commit
- All tests passing

### Example 2: Full Feature

**Command:**
```bash
/prd "Budget Tracking:
- Users can create budgets with name, category, amount, and period (monthly/yearly)
- Each budget belongs to an account
- System shows budget vs actual spending
- Users receive alerts when budget exceeded
- Monthly budget summary report"
```

**Generated tasks:**
- 1 epic (Budget Tracking Feature)
- 8 backend tasks (entity, repo, service, controller, tests, alert service, report service)
- 6 frontend tasks (types, API client, BudgetList, BudgetForm, dashboard, alerts)
- 3 testing tasks (integration tests, E2E scenarios, alert tests)

**Result:**
- 18 tasks completed in ~40 minutes
- 35 files created/modified
- 60+ tests added
- 1 commit
- Feature ready for deployment

### Example 3: Bug Fix

**Command:**
```bash
/prd "Fix: Account deletion should also delete associated expenses (cascade delete)"
```

**Generated tasks:**
1. Backend: Add ON DELETE CASCADE to expenses foreign key
2. Backend: Create migration for constraint change
3. Backend: Update AccountService delete method
4. Backend: Add Kotest tests for cascade delete
5. Frontend: Update delete confirmation message

**Result:**
- 5 tasks completed in ~15 minutes
- Database migration applied
- Tests verify cascade behavior
- 1 commit

## 🎓 Tips for Good PRDs

### ✅ Good PRDs

**Specific entities:**
```
"Add Task entity with title, description, status, priority, assignee, dueDate"
```

**Clear relationships:**
```
"A project can have many tasks. A task belongs to one project."
```

**Explicit validation:**
```
"Title is required (max 100 chars). Status must be: todo, in_progress, or done."
```

**Defined endpoints:**
```
"REST endpoints: POST /api/tasks, GET /api/tasks/:id, PUT /api/tasks/:id, DELETE /api/tasks/:id"
```

### ❌ Vague PRDs

**Too generic:**
```
"Make the app better"
"Add some features"
```

**Unclear scope:**
```
"Improve performance"
"Refactor code"
```

**Missing details:**
```
"Add user management" (what operations? what fields? what validations?)
```

## 🔧 Future Enhancements

**Planned features:**
- `--dry-run` flag: Analyze and plan without executing
- `--skip-tests` flag: Skip test execution for rapid prototyping
- `--manual` flag: Create tasks only, let user implement manually
- `--checkpoint` flag: Pause after each batch for review
- PRD file support: `/prd --file=/path/to/prd.md`
- Interactive mode: Ask clarifying questions before planning
- Progress dashboard: Real-time visualization of agent activity
- Cost estimation: Predict time/tasks before execution
- Rollback support: Undo feature if tests fail

---

## 🚀 Invocation

When the user types:
```bash
/prd "Feature description..."
```

You will:
1. Extract the PRD text from the command
2. Load prd-planner skill and create tasks
3. Execute parallel implementation batches
4. Run quality gates after each batch
5. Commit changes when complete
6. Report final statistics

**Let's build amazing features together! 🎉**
