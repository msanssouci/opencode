---
name: bootstrap-project
description: Bootstrap a project to use PRD workflow and agent orchestration
tags: [setup, initialization, prd, beads, project-setup]
---

# Bootstrap Project Command

Automatically sets up a project for PRD-driven development with multi-agent orchestration.

## 🎯 What This Does

This command initializes your project with:
1. ✅ Beads task tracking system
2. ✅ Project-specific `.agents/AGENTS.md` configuration
3. ✅ Git hooks for automatic beads sync
4. ✅ PRD workflow setup (ready to use `/prd` command)
5. ✅ Agent orchestration configuration

## 📋 Prerequisites

- Git repository initialized (`git init` already run)
- Project directory exists
- You're in the project root directory

## 🚀 Usage

### Interactive Mode (Recommended)

```bash
/bootstrap-project
```

The command will:
1. Detect your current directory name as the project name
2. Ask you to confirm or customize the project name
3. Detect your tech stack (backend/frontend/monorepo)
4. Set up all configurations automatically

### Non-Interactive Mode

```bash
# Specify project name directly
/bootstrap-project my-awesome-app

# With tech stack detection
/bootstrap-project my-awesome-app --stack=fullstack
```

## 📁 What Gets Created

```
your-project/
├── .agents/
│   └── AGENTS.md           # Project-specific agent config
├── .beads/
│   ├── config.toml         # Beads configuration
│   ├── issues/             # Issue storage
│   └── index.json          # Issue index
└── .git/hooks/
    ├── post-commit         # Auto-sync beads after commits
    └── pre-push            # Verify beads sync before push
```

## 🎨 Tech Stack Detection

The command auto-detects your stack by checking for:

**Backend (Kotlin/Spring Boot):**
- `build.gradle.kts` or `settings.gradle.kts`
- `apps/api/` directory

**Frontend (Next.js/React):**
- `package.json` with "next" dependency
- `apps/web/` directory

**Monorepo:**
- Both backend and frontend detected
- Multiple `apps/` subdirectories

**Custom:**
- Manual selection if auto-detection fails

## 📝 Generated `.agents/AGENTS.md`

Example for a full-stack monorepo:

```markdown
# Project Configuration

## Project Context
- **Name:** my-awesome-app
- **Beads Prefix:** my-awesome-app
- **Stack:** Backend (Kotlin/Spring Boot) + Frontend (Next.js/React)

## Build Commands

### Backend
- Build: `./gradlew build` or `just build`
- Test: `./gradlew test` or `just test`
- Run: `./gradlew bootRun` or `just run-api`

### Frontend
- Build: `npm run build` or `just build-web`
- Test: `npm test` or `just test-web`
- Run: `npm run dev` or `just run-web`

## Directory Structure
- `apps/api/` - Spring Boot backend
- `apps/web/` - Next.js frontend
- `apps/cli/` - CLI tools (if applicable)

## Stack References
- Backend: See `~/.config/opencode/stacks/backend.md`
- Frontend: See `~/.config/opencode/stacks/frontend.md`
```

## ✅ Verification

After running the command, verify setup:

```bash
# Check beads is initialized
bd stats

# Verify project configuration
cat .agents/AGENTS.md

# Test PRD workflow
/prd
```

## 🔧 What You Can Do Next

### 1. Create Your First PRD

```bash
/prd
```

This will:
- Guide you through creating a Product Requirements Document
- Auto-generate beads tasks from the PRD
- Orchestrate backend-dev, frontend-dev, and test-runner agents in parallel
- Execute the full implementation

### 2. Manual Task Creation

```bash
# Create a task manually
bd create --title="Add user authentication" --type=feature --priority=2

# List ready tasks
bd ready

# Start working on a task
bd update <task-id> --status=in_progress
```

### 3. Use Agent Orchestration

The `/prd` command automatically uses the build-orchestrator to:
- Run backend-dev and frontend-dev agents in parallel
- Execute test-runner for quality verification
- Invoke code-reviewer for all changes
- Ensure all tasks pass quality gates

## 🎯 Success Criteria

Bootstrap is successful when:
- ✅ `bd stats` shows project statistics
- ✅ `.agents/AGENTS.md` exists with project config
- ✅ Git hooks are installed and executable
- ✅ `/prd` command is ready to use
- ✅ `bd ready` works without errors

## 🆘 Troubleshooting

### "Beads already initialized"

If beads is already initialized:
```bash
# Check existing config
bd stats

# Reinitialize if needed (WARNING: This resets all tasks)
rm -rf .beads
bd init <project-name>
```

### "Git hooks not executable"

Fix permissions:
```bash
chmod +x .git/hooks/post-commit
chmod +x .git/hooks/pre-push
```

### "Cannot detect project structure"

Manually specify in `.agents/AGENTS.md`:
```bash
mkdir -p .agents
$EDITOR .agents/AGENTS.md  # Add your config manually
```

## 📚 Related Commands

- `/prd` - Create and implement a PRD with agent orchestration
- `/prd-continue` - Resume a PRD after modifications
- Load skill `prd-planner` - Advanced PRD planning
- Load skill `build-orchestrator` - Multi-agent coordination

---

**Ready to bootstrap your project? Run `/bootstrap-project` now!** 🚀
