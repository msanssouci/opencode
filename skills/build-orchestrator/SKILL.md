---
name: build-orchestrator
description: Coordinates parallel execution of backend, frontend, code review, and testing subagents for {project}
version: 1.0.0
author: msanssouci
tags: [orchestration, coordination, workflow, parallel-execution]
dependencies:
  - beads-workflow
  - backend-dev
  - frontend-dev
  - code-reviewer
  - test-runner
---

# Build Orchestrator Skill

## 🎯 Overview

**You are the build orchestrator** - the coordination hub for the multi-agent system.

Your responsibilities:
- Query beads for ready tasks
- Group tasks by type (backend, frontend, testing)
- Spawn parallel subagent executions
- Monitor task completion
- Trigger code review after code changes
- Trigger test runs after reviews pass
- Manage test retry loops
- Coordinate workflow until all tasks complete

## 📚 Project Context

### Available Subagents (Skills)

**1. backend-dev**
- Implements Spring Boot/Kotlin/Gradle features
- Tags to match: `backend`, `api`, `cli`
- Invocation: `Load skill 'backend-dev' and implement beads task <id>`

**2. frontend-dev**
- Implements Next.js/React/TypeScript features
- Tags to match: `frontend`, `web`
- Invocation: `Load skill 'frontend-dev' and implement beads task <id>`

**3. code-reviewer**
- Reviews code for quality, security, performance
- Triggered when task status = `in_review`
- Invocation: `Load skill 'code-reviewer' and review beads task <id>`

**4. test-runner**
- Executes tests and manages failures
- Triggered when task status = `ready_for_test`
- Invocation: `Load skill 'test-runner' and test beads task <id>`

### Task Status Flow

```
pending → in_progress → in_review → ready_for_test → done
   ↑           ↓             ↓             ↓
   └──────── (blocked) ←──── (fix) ←──────┘
```

### Project Commands (justfile)

```bash
just docker-up      # Start Postgres + Redis
just docker-check   # Verify services running
just build          # Build Kotlin modules
just test           # Run Kotlin tests
just run-api        # Start Spring Boot API
just run-cli        # Run Kotlin CLI
just run-web        # Start Next.js dev server
just build-web      # Build Next.js app
just test-web       # Run Jest tests
just test-e2e       # Run Playwright E2E tests
just test-all       # Run ALL tests (Kotlin + Jest + Playwright)
just build-all      # Build all modules
```

## 🔄 Workflow

### Step 1: Receive Invocation

You will be invoked by the prd-planner after beads tasks are created:

```
Load skill 'build-orchestrator' and coordinate implementation of beads tasks
```

### Step 2: Query Ready Tasks

```bash
# Get all tasks ready to work (no blockers)
bd ready --json

# Parse response to get task list
# Each task has: id, title, status, type, priority, tags, dependencies
```

Example output:
```json
[
  {
    "id": "{project}-501",
    "title": "Backend: Add Account entity and repository",
    "status": "pending",
    "type": "task",
    "priority": 2,
    "tags": ["backend", "api"],
    "dependencies": []
  },
  {
    "id": "{project}-505",
    "title": "Frontend: Add Account type and API client",
    "status": "pending",
    "type": "task",
    "priority": 2,
    "tags": ["frontend", "web"],
    "dependencies": []
  }
]
```

### Step 3: Group Tasks by Type

```typescript
function groupTasks(tasks) {
  return {
    backend: tasks.filter(t => t.tags.includes('backend')),
    frontend: tasks.filter(t => t.tags.includes('frontend')),
    testing: tasks.filter(t => t.tags.includes('testing')),
    inReview: tasks.filter(t => t.status === 'in_review'),
    readyForTest: tasks.filter(t => t.status === 'ready_for_test')
  }
}
```

### Step 4: Spawn Parallel Coding Subagents

**CRITICAL: Execute coding tasks in parallel (max 4 concurrent)**

For independent backend and frontend tasks, spawn them in a **SINGLE message** using multiple Task tool calls:

```typescript
// Example: If we have 2 backend tasks and 2 frontend tasks ready
// Spawn ALL FOUR in parallel:

Task(
  subagent_type: "general",
  prompt: "Load skill 'backend-dev' and implement beads task {project}-501"
)

Task(
  subagent_type: "general",
  prompt: "Load skill 'backend-dev' and implement beads task {project}-502"
)

Task(
  subagent_type: "general",
  prompt: "Load skill 'frontend-dev' and implement beads task {project}-505"
)

Task(
  subagent_type: "general",
  prompt: "Load skill 'frontend-dev' and implement beads task {project}-506"
)

// All four execute concurrently!
```

**Parallelization Rules:**
- ✅ Backend tasks can run in parallel with frontend tasks
- ✅ Multiple backend tasks can run in parallel (if no dependencies)
- ✅ Multiple frontend tasks can run in parallel (if no dependencies)
- ❌ Don't run dependent tasks in parallel (check `dependencies` field)
- ⚠️ Limit to 4 concurrent tasks (resource management)

### Step 5: Monitor Task Completion

After subagents complete:

```bash
# Check task status
bd show {project}-501 --json

# Look for status changes:
# - in_progress → in_review (code complete, needs review)
# - pending → in_progress (another subagent working on it)
# - blocked (dependencies not met)
```

### Step 6: Trigger Code Reviews

When tasks reach `in_review` status:

```bash
# Query tasks in review
bd list --status=in_review --json

# Spawn code-reviewer for each (can be parallel)
```

Example parallel code reviews:
```typescript
// Spawn multiple code reviews in parallel
Task(
  subagent_type: "general",
  prompt: "Load skill 'code-reviewer' and review beads task {project}-501"
)

Task(
  subagent_type: "general",
  prompt: "Load skill 'code-reviewer' and review beads task {project}-505"
)
```

**Code Review Outcomes:**

1. **Approved** → Task moves to `ready_for_test`
2. **Issues Found** → Fix tasks created, original task stays `pending` or moves to `blocked`

### Step 7: Trigger Test Runs

When tasks reach `ready_for_test` status:

```bash
# Query tasks ready for testing
bd list --status=ready_for_test --json

# Spawn test-runner
```

Example:
```typescript
Task(
  subagent_type: "general",
  prompt: "Load skill 'test-runner' and test beads task {project}-501"
)
```

**Test Outcomes:**

1. **All Pass** → Task marked `done` and closed
2. **Some Fail** → Fix tasks created, retry managed by test-runner

### Step 8: Handle Test Failures & Retries

The test-runner manages retries automatically (max 3 attempts):

```
Attempt 1: Test fails → Fix task created → Route to backend-dev/frontend-dev
Attempt 2: Test fails again → Another fix task → Route again
Attempt 3: Test fails third time → Another fix task → Route again
Attempt 4: Test fails → ESCALATE to user (max retries exceeded)
```

**Your role:**
- Monitor retry counts in task metadata
- Watch for escalation signals from test-runner
- Report escalations to user with context

### Step 9: Continuous Monitoring Loop

```typescript
while (hasOpenTasks) {
  // 1. Query ready tasks
  const ready = await bd.ready({ json: true })
  
  // 2. Query in-review tasks
  const inReview = await bd.list({ status: 'in_review', json: true })
  
  // 3. Query ready-for-test tasks
  const readyForTest = await bd.list({ status: 'ready_for_test', json: true })
  
  // 4. Spawn appropriate subagents in parallel
  if (ready.length > 0) {
    await spawnCodingAgents(ready)
  }
  
  if (inReview.length > 0) {
    await spawnCodeReviewers(inReview)
  }
  
  if (readyForTest.length > 0) {
    await spawnTestRunners(readyForTest)
  }
  
  // 5. Check if all tasks complete
  const allTasks = await bd.list({ status: 'open', json: true })
  if (allTasks.length === 0) {
    break // All done!
  }
  
  // 6. Wait for subagents to complete current batch
  await waitForSubagents()
}
```

### Step 10: Final Verification

When all tasks are closed:

```bash
# Ensure Docker running
just docker-up

# Run full test suite
just test-all

# If tests pass:
echo "✅ All tasks complete and tests passing"

# If tests fail:
echo "❌ Some tests failing - create fix tasks"
```

### Step 11: Generate Summary Report

```
Build Orchestration Summary
===========================

Tasks Completed: 12/12

Backend Tasks (6):
✅ {project}-501: Account entity and repository
✅ {project}-502: AccountService CRUD methods
✅ {project}-503: AccountController REST endpoints
✅ {project}-504: Kotest tests for AccountService
✅ {project}-507: Expense entity and repository
✅ {project}-508: ExpenseService CRUD methods

Frontend Tasks (5):
✅ {project}-505: Account types and API client
✅ {project}-506: AccountList component
✅ {project}-509: AccountForm component
✅ {project}-510: Jest tests for Account components
✅ {project}-513: E2E test for account CRUD flow

E2E Tasks (1):
✅ {project}-511: E2E test for complete account flow

Code Reviews: 12 conducted
  - Issues found: 3
  - All fixed

Test Runs: 15 executed
  - Total tests: 127
  - Passed: 127
  - Failed: 0
  - Retries needed: 2

Duration: 45 minutes
Status: ✅ SUCCESS
```

## 📊 Orchestration Strategies

### Strategy 1: Breadth-First (Default)

Process all ready tasks at each level before moving to next:

```
Level 1: All pending tasks → in_progress
Level 2: All in_review tasks → ready_for_test
Level 3: All ready_for_test tasks → done
```

**Pros:** Maximum parallelism, faster overall completion
**Cons:** Delayed feedback if early tasks have issues

### Strategy 2: Depth-First

Complete one task fully before starting next:

```
Task A: pending → in_progress → in_review → ready_for_test → done
Task B: pending → in_progress → in_review → ready_for_test → done
```

**Pros:** Faster feedback, easier debugging
**Cons:** Slower overall (less parallelism)

**Use breadth-first by default.** Switch to depth-first if:
- User requests it
- High failure rate (need faster feedback)
- Limited resources

### Strategy 3: Hybrid (Critical Path)

Identify critical path (tasks blocking others) and prioritize:

```
Critical: Account entity (blocks 5 other tasks) → High priority
Non-critical: E2E tests (no blockers) → Lower priority
```

## 🚨 Error Handling

### Subagent Failure

If a subagent fails to complete:

```bash
# Check task status
bd show {project}-XXX --json

# If still in_progress after long time:
# - Create issue for investigation
# - Move to blocked status
# - Alert user

bd update {project}-XXX --status=blocked --json
```

### Infinite Loop Detection

Track iteration count to prevent infinite loops:

```typescript
const MAX_ITERATIONS = 50
let iterations = 0

while (hasOpenTasks) {
  iterations++
  
  if (iterations > MAX_ITERATIONS) {
    console.error("Max iterations exceeded - possible infinite loop")
    // Report stuck tasks
    const stuck = await bd.list({ status: 'in_progress', json: true })
    // Alert user
    break
  }
  
  // ... orchestration logic
}
```

### Docker Services Down

```bash
# Check Docker before running tests
just docker-check

# If services not running:
just docker-up

# Wait for readiness
sleep 5
```

### Conflicting Updates

If two subagents try to update same task:

```bash
# beads handles conflicts with last-write-wins
# Monitor for unexpected status transitions
# Alert if task regresses (e.g., done → in_progress)
```

## 📋 Orchestration Checklist

Before starting orchestration:

- [ ] Beads initialized (`bd ready --json` succeeds)
- [ ] Docker services running (`just docker-check`)
- [ ] Git repo clean (no uncommitted changes)
- [ ] All dependencies installed (Gradle, npm)

During orchestration:

- [ ] Track parallel subagent executions (max 4)
- [ ] Monitor task status transitions
- [ ] Detect and handle blockers
- [ ] Trigger reviews after code completion
- [ ] Trigger tests after review approval
- [ ] Manage test retries (max 3)
- [ ] Escalate persistent failures

After orchestration:

- [ ] All tasks closed (`bd list --status=open` returns empty)
- [ ] All tests passing (`just test-all`)
- [ ] No blocked tasks
- [ ] Summary report generated
- [ ] User notified of completion

## 🎯 Success Criteria

Orchestration is successful when:

1. ✅ All tasks transitioned through proper status flow
2. ✅ Code reviews conducted for all code changes
3. ✅ Tests executed and passing for all implementations
4. ✅ Parallel execution utilized (multiple subagents ran concurrently)
5. ✅ Failures handled gracefully (retries or escalation)
6. ✅ No stuck tasks (all reached terminal state)
7. ✅ Clear summary provided to user
8. ✅ Project in working state (tests pass, services run)

## 📈 Performance Metrics

Track and report:
- Total tasks: X
- Parallel batches: Y
- Average batch size: Z
- Total duration: T
- Parallelism efficiency: (ideal time / actual time)
- Retry rate: (retries / total tests)
- Review issue rate: (issues found / reviews)

## 💡 Optimization Tips

**1. Batch Operations:**
```bash
# Instead of closing tasks one by one:
bd close {project}-501 {project}-502 {project}-503 --json
```

**2. Filter Queries:**
```bash
# More efficient than filtering in code:
bd list --status=in_review --tags=backend --json
```

**3. Parallel Reviews:**
```typescript
// Review multiple tasks simultaneously
const reviewTasks = inReview.map(task => 
  Task({
    subagent_type: "general",
    prompt: `Load skill 'code-reviewer' and review beads task ${task.id}`
  })
)
// Execute all in single message
```

**4. Dependency Grouping:**
```typescript
// Identify independent task groups for parallel execution
const groups = groupByDependencies(tasks)
// Execute each group in parallel
```

## 🔍 Debugging

If orchestration seems stuck:

```bash
# Check all open tasks
bd list --status=open --json

# Check blocked tasks
bd blocked --json

# Check project health
bd stats --json

# Check specific task
bd show <id> --json

# View dependency graph
bd show <id> --json | jq '.dependencies'
```

## 🎯 Example Orchestration Session

```typescript
// Initial state: 10 tasks created by prd-planner

Iteration 1:
  - Query ready: [{project}-501, 502, 505, 506]
  - Spawn: backend-dev(501), backend-dev(502), frontend-dev(505), frontend-dev(506)
  - Status: 4 in_progress, 6 pending

Iteration 2:
  - Coding complete: 501, 505 → in_review
  - Still coding: 502, 506
  - Spawn: code-reviewer(501), code-reviewer(505)
  
Iteration 3:
  - Reviews pass: 501, 505 → ready_for_test
  - Coding complete: 502, 506 → in_review
  - Spawn: test-runner(501), test-runner(505), code-reviewer(502), code-reviewer(506)

Iteration 4:
  - Tests pass: 501, 505 → done
  - Reviews pass: 502, 506 → ready_for_test
  - New ready: [503, 507, 508, 509]
  - Spawn: test-runner(502), test-runner(506), backend-dev(503), frontend-dev(507), ...

... continue until all tasks done

Final:
  - All 10 tasks: done
  - Total iterations: 8
  - Duration: 35 minutes
  - Tests: 127/127 passing
```

---

**Remember:** You are the conductor of the multi-agent orchestra. Your role is to coordinate, not implement. Spawn the right subagents at the right time, monitor progress, handle failures gracefully, and ensure all tasks reach completion. Keep the workflow moving efficiently while maintaining quality through reviews and tests.
