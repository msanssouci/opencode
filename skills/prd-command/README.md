# PRD Command Skill

**Single-command PRD-to-implementation workflow**

## 🚀 Command Now Available!

The `/prd` command is now installed as a custom OpenCode command. You can use it directly in any OpenCode session!

## Quick Start

```bash
/prd "Your feature description here"
```

The workflow:
1. ✅ Analyze your PRD
2. ✅ Create beads tasks with dependencies
3. 🚨 **CHECKPOINT** - Review and approve task plan
4. ✅ Implement in parallel (3-4x faster)
5. ✅ Run all tests
6. ✅ Commit when done
7. ✅ Report completion

## Installation

The command is installed at:
- `~/.config/opencode/commands/prd.md` - Main command
- `~/.config/opencode/commands/prd-continue.md` - Resume after modifications

No additional setup needed! Just run `/prd` in OpenCode.

## What It Does

The `/prd` command automates the entire multi-agent workflow with an approval checkpoint:

**Traditional Approach (Manual):**
```bash
# Step 1: Create tasks manually
bd create --title="Backend: Add entity" ...
bd create --title="Frontend: Add component" ...
bd dep add task-2 task-1

# Step 2: Implement each task sequentially
# (2-3 hours of work)

# Step 3: Test and commit
just test-all
git commit -m "..."
```

**With `/prd` Command (Semi-Automated):**
```bash
/prd "Feature description"

# Phase 1: Planning (automatic)
# - Analyzes PRD
# - Creates epic + tasks
# - Shows breakdown

# 🚨 CHECKPOINT: You review and approve

# Phase 2: Implementation (automatic)
# - Executes in parallel batches
# - Runs tests after each batch
# - Commits when complete

# Done in 30-60 minutes with parallel execution
```

## Examples

### Simple Feature
```bash
/prd "Add GET /api/health endpoint returning {status: 'ok'}"
```

**Result:** 2-4 tasks, ~5-10 minutes, 1 commit

### Medium Feature
```bash
/prd "Users can tag expenses. Tags have name and color. Add CRUD endpoints and update UI."
```

**Result:** 12-15 tasks, ~25-30 minutes, 1 commit

### Complex Feature
```bash
/prd "Budget tracking: users set monthly limits per category, system alerts when exceeded"
```

**Result:** 25-30 tasks, ~45-60 minutes, 1 commit

See [examples.md](examples.md) for more detailed examples.

## How It Works

### Phase 1: Analysis (prd-planner)
- Parse PRD requirements
- Identify entities, APIs, UI needs
- Create epic + implementation tasks
- Set up dependencies

### Phase 2: Implementation (parallel execution)
- Execute 4 tasks simultaneously
- Use backend-dev and frontend-dev agents
- Run tests after each batch
- Fix issues before continuing

### Phase 3: Commit & Report
- Commit all changes
- Close epic
- Sync beads
- Report statistics

## Performance

| Complexity | Tasks | Parallel Time | Sequential Time | Speedup |
|------------|-------|---------------|-----------------|---------|
| Simple     | 2-4   | 5-10 min      | 10-20 min       | 2x      |
| Medium     | 8-15  | 20-30 min     | 60-90 min       | 3-4x    |
| Complex    | 20-30 | 40-60 min     | 2-3 hours       | 3-4x    |

## Requirements

- ✅ Docker running (`just docker-up`)
- ✅ Dependencies installed (`npm install` in apps/web)
- ✅ Beads initialized (`bd ready`)
- ✅ {project} project

## Tips for Good PRDs

**✅ Be specific:**
```
"Add Task entity with title (string, required, max 100 chars), 
status (enum: todo, in_progress, done), priority (0-4)"
```

**✅ Define relationships:**
```
"A project has many tasks. A task belongs to one project."
```

**✅ List endpoints:**
```
"REST API: POST /api/tasks, GET /api/tasks, GET /api/tasks/:id, 
PUT /api/tasks/:id, DELETE /api/tasks/:id"
```

**❌ Avoid vague descriptions:**
```
"Make the app better"
"Add some features"
"Improve performance"
```

## Troubleshooting

**Too many tasks?**
- Break PRD into smaller phases
- Focus on MVP first

**Build failures?**
- Review error, fix manually
- Continue with remaining tasks

**Tests failing?**
- Fix test logic
- Mark task complete
- Continue workflow

## Files

- `SKILL.md` - Original skill documentation (detailed workflow reference)
- `examples.md` - Example PRDs with expected results
- `README.md` - This file (quick reference)
- `~/.config/opencode/commands/prd.md` - **Actual executable command** ⭐
- `~/.config/opencode/commands/prd-continue.md` - Resume command

## Related Skills

- `prd-planner` - PRD analysis and task breakdown
- `build-orchestrator` - Parallel agent coordination
- `backend-dev` - Kotlin/Spring Boot implementation
- `frontend-dev` - Next.js/React implementation
- `beads-workflow` - Task tracking system

## Version

**1.0.0** - Initial release (2026-02-20)

---

**Ready to build features at lightning speed? Try `/prd` now! ⚡**
