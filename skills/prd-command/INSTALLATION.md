# /prd Command Installation Summary

## ✅ What Was Created

### 1. Main Command: `/prd`
**Location:** `~/.config/opencode/commands/prd.md`

**What it does:**
- Analyzes PRD requirements using `prd-planner` skill
- Creates epic + implementation tasks with dependencies
- **Shows task breakdown and asks for approval** (interactive checkpoint)
- Orchestrates parallel implementation using `build-orchestrator` skill
- Runs quality gates (build + tests) after each batch
- Stops on failures and asks for guidance
- Commits changes with conventional commit message
- Closes epic and syncs beads
- Reports final statistics

**Configuration:**
- `agent: general` - Uses general-purpose agent
- `subtask: false` - Runs in main conversation (full visibility)
- Interactive checkpoint before implementation
- Stop-and-report error handling

### 2. Resume Command: `/prd-continue`
**Location:** `~/.config/opencode/commands/prd-continue.md`

**What it does:**
- Resumes implementation after user modifies tasks
- Picks up where `/prd` left off (from checkpoint)
- Executes remaining tasks in parallel batches
- Same quality gates and commit workflow as `/prd`

### 3. Documentation Updates
**Updated files:**
- `~/.config/opencode/commands/README.md` - Added `/prd` and `/prd-continue` documentation
- `~/.config/opencode/skills/prd-command/README.md` - Added installation notes and command references

---

## 🚀 Usage

### Basic Usage

```bash
# In any OpenCode session
/prd "Your feature description here"
```

### Example: Simple Feature

```bash
/prd "Add GET /api/health endpoint that returns {status: 'ok', timestamp: <now>}"
```

**What happens:**
1. **Phase 1: Analysis**
   - Creates 1 epic
   - Creates 4 tasks (backend endpoint, tests, frontend types, API client)
   - Shows task breakdown
   
2. **🚨 CHECKPOINT**
   ```
   📋 Planning Complete!
   
   Created: 1 epic, 4 tasks
   Ready to start: 4 tasks
   Blocked: 0 tasks
   
   What would you like to do?
   1. ✅ Proceed with implementation
   2. ❌ Cancel (keep tasks for manual work)
   3. 📝 Modify tasks first
   
   Enter choice (1/2/3):
   ```

3. **Phase 2: Implementation** (if you choose option 1)
   - Executes 4 tasks in parallel
   - Runs `just build-all` and `just test-all`
   - Commits changes
   - Closes epic
   - Reports completion

4. **Result:**
   - ~10-15 minutes
   - 4 tasks completed
   - All tests passing
   - 1 commit

### Example: Complex Feature

```bash
/prd "Budget Tracking:
- Users can create budgets with name, category, amount, and period (monthly/yearly)
- Each budget belongs to an account
- System shows budget vs actual spending
- Users receive alerts when budget exceeded
- Monthly budget summary report"
```

**What happens:**
1. **Phase 1: Analysis**
   - Creates 1 epic
   - Creates 18-25 tasks (backend, frontend, testing)
   - Shows full breakdown with dependencies
   
2. **🚨 CHECKPOINT** - You review the plan

3. **Phase 2: Implementation** (if approved)
   - Executes tasks in batches of 4
   - ~5-7 batches total
   - Runs tests after each batch
   - Commits when complete

4. **Result:**
   - ~40-60 minutes
   - 18-25 tasks completed
   - 35+ files created/modified
   - 60+ tests added
   - 1 commit

### Example: Modify Tasks Before Implementation

```bash
/prd "Add user profile feature"
```

**At checkpoint, choose option 3:**
```
What would you like to do?
1. ✅ Proceed with implementation
2. ❌ Cancel (keep tasks for manual work)
3. 📝 Modify tasks first

Enter choice (1/2/3): 3
```

**Then modify tasks:**
```bash
# View tasks
bd list --status=open

# Update a task
bd update {project}-123 --title="New title" --priority=1

# Add dependencies
bd dep add {project}-124 {project}-123

# When ready, resume
/prd-continue
```

---

## 📋 Workflow Details

### Phase 1: Requirements Analysis & Task Planning

**Automated:**
1. Loads `prd-planner` skill
2. Parses PRD description
3. Identifies entities, backend needs, frontend needs
4. Creates epic with task breakdown
5. Sets up dependencies
6. Shows task summary

**Example output:**
```
✅ Created epic: {project}-abc (Budget Tracking Feature)

📋 Task Breakdown:

Backend (8 tasks):
- {project}-101: Create Budget entity
- {project}-102: Add Budget migration
- {project}-103: Create BudgetRepository
- {project}-104: Create BudgetService
- {project}-105: Create BudgetController
- {project}-106: Write Budget unit tests
- {project}-107: Create alert service
- {project}-108: Create report service

Frontend (6 tasks):
- {project}-201: Create Budget types
- {project}-202: Create Budget API client
- {project}-203: Create BudgetList component
- {project}-204: Create BudgetForm component
- {project}-205: Create budget dashboard
- {project}-206: Create alert notifications

Testing (4 tasks):
- {project}-301: Budget integration tests
- {project}-302: Budget E2E scenarios
- {project}-303: Alert system tests
- {project}-304: Report generation tests

Dependencies configured:
- Frontend depends on backend
- Tests depend on implementation
- Alert/report services depend on base CRUD

Ready to start: 5 tasks (no blockers)
Blocked: 13 tasks (waiting on dependencies)
```

### 🚨 Interactive Checkpoint

**You have 3 options:**

**Option 1: Proceed (Recommended for well-defined PRDs)**
- Continues immediately to parallel implementation
- Best when you trust the task breakdown
- Fastest path to completion

**Option 2: Cancel (Manual control)**
- Keeps all created tasks in beads
- You implement manually or delegate specific tasks
- Good when you want fine-grained control

**Option 3: Modify (Review and adjust)**
- Pauses workflow for task modifications
- You can update titles, descriptions, priorities, dependencies
- Resume with `/prd-continue` when ready
- Good for complex features that need refinement

### Phase 2: Parallel Implementation

**Automated (only if approved):**
1. Loads `build-orchestrator` skill
2. Queries `bd ready --json` for available tasks
3. Executes up to 4 tasks in parallel per batch
4. Uses `backend-dev` and `frontend-dev` subagents
5. Monitors task completion
6. Updates beads status

**Example batch execution:**
```
🚀 Batch 1 (4 parallel agents):
   - backend-dev → {project}-101 (Budget entity)
   - backend-dev → {project}-102 (Migration)
   - frontend-dev → {project}-201 (Types)
   - frontend-dev → {project}-202 (API client)

⏳ Executing... (est. 5-7 minutes)

✅ Batch 1 complete (4/18 tasks done)

Running quality gates...
✅ just build-all: SUCCESS
✅ just test-all: SUCCESS

🚀 Batch 2 (4 parallel agents):
   - backend-dev → {project}-103 (Repository)
   - backend-dev → {project}-104 (Service)
   - frontend-dev → {project}-203 (BudgetList)
   - frontend-dev → {project}-204 (BudgetForm)

...
```

### Quality Gates

**After each batch:**
1. Runs `just build-all` to verify code compiles
2. Runs `just test-all` to verify tests pass

**If build fails:**
```
🚨 Build Failed!

Error: Compilation error in BudgetService.kt:45
Type mismatch: required Budget, found Budget?

Stack trace:
[detailed error output]

What would you like to do?
1. Fix the error and retry
2. Skip this batch and continue
3. Stop execution

Enter choice (1/2/3):
```

**If tests fail:**
```
🚨 Tests Failed!

Failing tests (3):
✗ BudgetServiceTest > createBudget should validate amount
✗ BudgetRepositoryTest > findByAccountId should return budgets
✗ BudgetControllerTest > POST /budgets should create budget

What would you like to do?
1. Fix the tests and retry
2. Continue with other tasks (mark these as blocked)
3. Stop execution

Enter choice (1/2/3):
```

### Phase 3: Commit & Report

**Automated (when all tasks complete):**
1. Runs final `just build-all` and `just test-all`
2. Reviews all changes: `git status` and `git diff`
3. Generates conventional commit message
4. Commits: `git add . && git commit -m "..."`
5. Closes epic: `bd close <epic-id> --reason="..."`
6. Syncs beads: `bd sync`
7. Shows final report

**Example commit:**
```
feat: implement Budget Tracking feature

Backend:
- Budget entity with validation
- Database migration for budgets table
- BudgetRepository, BudgetService, BudgetController
- Alert service for budget exceeded notifications
- Report service for monthly summaries

Frontend:
- Budget types and API client
- BudgetList, BudgetForm components
- Budget dashboard with spending visualization
- Alert notification system

Testing:
- 45 unit tests (Kotest + Jest)
- 8 integration tests
- 3 E2E scenarios

Implemented via multi-agent workflow (/prd command)
All tests passing. All builds successful.

Closes {project}-abc
```

**Example report:**
```
🎉 Feature Complete!

📊 Statistics:
   Epic: {project}-abc (Budget Tracking Feature)
   Tasks: 18 completed (100%)
   Files: 28 created, 5 modified
   Tests: 45 added (all passing ✅)
   Time: ~42 minutes
   Speedup: 3.5x faster than sequential

📦 What Was Built:
   Backend:
   - 3 entities, 3 repositories, 3 services, 3 controllers
   - 2 database migrations
   - 38 unit tests (Kotest)
   
   Frontend:
   - 3 type files, 3 API clients
   - 6 components, 2 pages
   - 7 unit tests (Jest)
   
   Testing:
   - 8 integration tests
   - 3 E2E scenarios (Playwright)

✅ Build: SUCCESS
✅ Tests: 45/45 passing
✅ Commit: a3f5c7d
✅ Beads: Synced

📝 Next Steps:
   - Review commit: git show a3f5c7d
   - Test manually: just dev
   - Deploy: (your deployment process)
```

---

## 🔧 Requirements

### System Requirements
- ✅ Docker running (`just docker-up`)
- ✅ Beads initialized (`bd ready`)
- ✅ Clean git working directory (no uncommitted changes)
- ✅ Dependencies installed (`npm install` in apps/web)

### Project Requirements
- ✅ {project} project structure
- ✅ Backend: Kotlin/Spring Boot (apps/api/)
- ✅ Frontend: Next.js/React (apps/web/)
- ✅ Build system: Gradle + Just
- ✅ Testing: Kotest + Jest + Playwright

### Pre-flight Checks

The command automatically checks:
1. Docker is running (`docker ps`)
2. Beads is initialized (`bd ready --json`)
3. Git working directory is clean (`git status --porcelain`)
4. PRD description is provided (`$ARGUMENTS`)

**If any check fails, you'll get clear instructions:**
```
🚨 Docker not running!

Please start Docker:
   just docker-up

Then retry: /prd "your feature description"
```

---

## 💡 Tips for Success

### Writing Good PRDs

**✅ Be specific about entities:**
```
"Add Task entity with:
- title: string, required, max 100 chars
- description: string, optional, max 500 chars
- status: enum (todo, in_progress, done)
- priority: integer 0-4
- assignee: UUID reference to User
- dueDate: timestamp, optional"
```

**✅ Define relationships clearly:**
```
"A project has many tasks (one-to-many)
A task belongs to one project
A task can have one assignee (many-to-one with User)"
```

**✅ List all endpoints:**
```
"REST API:
- POST /api/tasks - Create task
- GET /api/tasks - List all tasks
- GET /api/tasks/:id - Get task by ID
- PUT /api/tasks/:id - Update task
- DELETE /api/tasks/:id - Delete task
- GET /api/projects/:id/tasks - List tasks for project"
```

**✅ Specify validation rules:**
```
"Validation:
- Title is required
- Status must be one of: todo, in_progress, done
- Priority must be 0-4
- Due date must be in the future
- Cannot delete task with status in_progress"
```

**❌ Avoid vague descriptions:**
```
"Make the app better"
"Add some features"
"Improve performance"
"Refactor code"
```

### When to Use /prd vs Manual

**✅ Use `/prd` when:**
- Feature is well-defined and clear
- You want semi-automated workflow (plan → approve → implement)
- Feature fits {project} architecture
- You trust the multi-agent system
- You want 3-4x speedup via parallel execution

**❌ Use manual workflow when:**
- PRD is vague or exploratory
- You want to implement tasks yourself
- Feature requires architectural changes
- You need fine-grained control over every step
- You want to learn by doing

### Checkpoint Decision Guide

**Choose "Proceed" when:**
- ✅ Task breakdown looks correct
- ✅ Dependencies make sense
- ✅ All required tasks are present
- ✅ No missing or duplicate tasks

**Choose "Cancel" when:**
- ❌ PRD was misunderstood
- ❌ Too many or too few tasks
- ❌ You want to implement manually
- ❌ Need to refine requirements first

**Choose "Modify" when:**
- 🔄 Breakdown is mostly correct but needs tweaks
- 🔄 Want to adjust priorities
- 🔄 Need to add/remove dependencies
- 🔄 Want to split or merge tasks

---

## 🐛 Troubleshooting

### Command not recognized

**Symptom:** `/prd` command doesn't work

**Solution:**
1. Verify file exists: `ls ~/.config/opencode/commands/prd.md`
2. Check frontmatter syntax: `head -10 ~/.config/opencode/commands/prd.md`
3. Restart OpenCode session

### Tasks not created

**Symptom:** `/prd` runs but no tasks appear in beads

**Solution:**
1. Check beads is initialized: `bd ready`
2. Verify beads prefix: Should be `{project}`
3. Check for errors in prd-planner execution
4. Try simpler PRD first

### Build failures during execution

**Symptom:** Batch completes but build fails

**Solution:**
1. Choose option 1 to review error details
2. The command will show compilation errors
3. Fix errors manually
4. Retry the batch

### Tests failing unexpectedly

**Symptom:** Tests pass individually but fail in `/prd`

**Solution:**
1. Check for test isolation issues
2. Verify database state is clean
3. Review test dependencies
4. Run `just test-all` manually to reproduce

### Git conflicts

**Symptom:** Cannot commit due to conflicts

**Solution:**
1. The command checks for clean working directory
2. Commit or stash changes before running `/prd`
3. If conflicts occur mid-workflow, resolve manually

---

## 📚 Related Resources

### Skills
- `prd-planner` - PRD analysis and task breakdown
- `build-orchestrator` - Parallel agent coordination
- `backend-dev` - Kotlin/Spring Boot implementation
- `frontend-dev` - Next.js/React implementation
- `beads-workflow` - Task tracking system

### Documentation
- `~/.config/opencode/skills/prd-command/SKILL.md` - Detailed workflow reference
- `~/.config/opencode/skills/prd-command/examples.md` - Example PRDs
- `~/.config/opencode/agents/beads-workflow.md` - Beads usage guide

### Commands
- `/prd` - Main command (this document)
- `/prd-continue` - Resume after modifications
- `/bd ready` - Show available beads tasks
- `/bd list` - List all beads issues

---

## 🎯 Success Metrics

A successful `/prd` execution achieves:

1. ✅ All beads tasks created with proper dependencies
2. ✅ User approved task plan at checkpoint
3. ✅ All tasks completed (status = closed)
4. ✅ All builds passing (`just build-all`)
5. ✅ All tests passing (`just test-all`)
6. ✅ Changes committed with conventional commit message
7. ✅ Epic closed with completion reason
8. ✅ Beads synced to JSONL
9. ✅ Final report provided to user
10. ✅ 3-4x faster than sequential implementation

---

## 🚀 Next Steps

**Try it now:**
```bash
# Simple test
/prd "Add GET /api/version endpoint that returns {version: '1.0.0'}"

# Medium complexity
/prd "Users can tag expenses. Tags have name and color. Add CRUD endpoints and update UI."

# Full feature
/prd "Budget tracking: users set monthly limits per category, system alerts when exceeded, monthly reports"
```

**Customize the workflow:**
- Edit `~/.config/opencode/commands/prd.md` to adjust the workflow
- Modify checkpoint prompts
- Add additional quality gates
- Customize commit message format

**Extend the system:**
- Add `--dry-run` flag support
- Create project-specific PRD commands
- Integrate with issue trackers
- Add cost estimation

---

**Happy building! 🎉**
