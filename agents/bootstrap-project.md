---
name: bootstrap-project
description: Execute bootstrap-project script to set up PRD workflow
version: 1.0.0
tags: [setup, bootstrap, prd, beads]
---

# Bootstrap Project Agent

Wrapper agent for the bootstrap-project script.

## 🎯 Purpose

When the user invokes `/bootstrap-project`, this agent executes the bootstrap script to:
1. Initialize beads with project name
2. Create `.agents/AGENTS.md` config
3. Set up git hooks
4. Configure PRD workflow

## 🔄 Workflow

### Step 1: Detect Context

```bash
# Check if in git repo
git rev-parse --git-dir

# Detect project name from directory
basename "$(pwd)"

# Detect tech stack (backend/frontend/fullstack)
```

### Step 2: Execute Bootstrap Script

```bash
# Interactive mode (recommended)
~/.config/opencode/scripts/bootstrap-project.sh

# With project name
~/.config/opencode/scripts/bootstrap-project.sh my-project

# With stack specification
~/.config/opencode/scripts/bootstrap-project.sh my-project --stack=fullstack
```

### Step 3: Verify Setup

```bash
# Check beads is working
bd stats

# Verify config was created
cat .agents/AGENTS.md

# Check git hooks
ls -la .git/hooks/post-commit .git/hooks/pre-push
```

### Step 4: Provide Next Steps

Guide the user on:
- Reviewing the generated `.agents/AGENTS.md`
- Creating their first PRD with `/prd`
- Understanding the workflow

## 📋 User Interaction

**Prompt for:**
1. Project name confirmation (if auto-detected)
2. Stack selection (if not auto-detected)
3. Confirmation before reinitializing beads (if already exists)

**Do NOT:**
- Skip user confirmation steps
- Overwrite existing configs without warning
- Proceed if prerequisites are missing

## ✅ Success Criteria

Bootstrap is successful when:
- ✅ `.beads/` directory exists and initialized
- ✅ `.agents/AGENTS.md` created with project config
- ✅ Git hooks installed and executable
- ✅ `bd stats` executes without errors
- ✅ User understands next steps

## 🆘 Error Handling

### Not in Git Repo
```bash
error "Not in a git repository. Run 'git init' first."
exit 1
```

### Beads Not Installed
```bash
error "beads (bd) command not found. Please install beads first."
exit 1
```

### Already Initialized
Ask user if they want to reinitialize (WARNING: resets all tasks)

## 📚 Related

- Command documentation: `~/.config/opencode/commands/bootstrap-project.md`
- Bootstrap script: `~/.config/opencode/scripts/bootstrap-project.sh`
- PRD workflow: `/prd` command
- Project onboarding: `agents/project-onboarding.md`
