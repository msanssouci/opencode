## 🚨 CRITICAL: Task Tracking Policy

**ALWAYS use `bd` (beads) for task tracking. NEVER use TodoWrite.**

### Mandatory Beads Usage
- ✅ **MUST USE**: `bd create`, `bd update`, `bd close`, `bd list` for ALL tasks
- ❌ **PROHIBITED**: TodoWrite tool, TaskCreate, TODO comments, markdown TODO files
- 🔧 **Before starting work**: Run `bd ready --json` to check initialization
- 📋 **Every task starts with**: `bd create --title="..." --type=task --priority=2 --json`

### Why Beads is Mandatory
1. **Session continuity**: Tasks persist across agent sessions
2. **Git integration**: Task IDs in commits enable full traceability
3. **Project health**: `bd stats` shows real progress metrics
4. **Collaboration**: All agents/developers see unified task state

### Beads Documentation
- **Core policy** (always loaded): `agents/beads-workflow.md` - Mandatory usage, session checklists, essential commands
- **Detailed guide** (on-demand): Load skill `beads-workflow` for git branch setup, workflow patterns, troubleshooting

---

### Response Style

Use the **pyramid method**:
1. **Main message first** - Lead with the core answer or conclusion
2. **Key details second** - Provide supporting information and context
3. **Smart follow-up questions** - Suggest 2-3 relevant next steps with estimated relevance:
   - [High probability] Question about immediate next action
   - [Medium probability] Question about alternative approaches
   - [Low probability] Question about edge cases or optimization

### Emojis

Use emojis for better visual recognition:

- 🤔 **Thinking** — questions, considerations, suggestions to explore, decision points
- ⚠️ **Alert** — warnings, critical messages, important notes, potential issues
- ✅ **Success** — completed tasks, confirmations, approved items
- ❌ **Error** — failures, rejected options, blockers
- 💡 **Idea** — tips, recommendations, insights
- 📝 **Note** — summaries, documentation, additional context

## Development General Guidelines

- Avoid nested if statements.
- Follow the single responsibility principle.
- Follow the guard clause pattern.
- Keep things smart and simple.
- Refer to available skills when possible.

---

## Documentation Architecture

This global configuration works in tandem with project-local documentation to provide comprehensive agent guidance.

```
┌─────────────────────────────────────────────────────────────────┐
│  Global Config (~/.config/opencode/)                            │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ AGENTS.md                                               │    │
│  │ • Personal preferences (pyramid method, emojis)        │    │
│  │ • General development philosophy                       │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ agents/beads-workflow.md          [UNIVERSAL]          │    │
│  │ • Mandatory beads usage policy (core - 234 lines)     │    │
│  │ • Core bd commands & session checklists               │    │
│  └────────────────────────────────────────────────────────┘    │
│                             │                                    │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ skills/beads-workflow/     [ON-DEMAND]                 │    │
│  │ • Detailed git branch setup procedures                 │    │
│  │ • Workflow patterns & troubleshooting (664 lines)      │    │
│  │ • 69% token reduction via on-demand loading            │    │
│  └────────────────────────────────────────────────────────┘    │
│                             │                                    │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ agents/session-completion.md      [UNIVERSAL]          │    │
│  │ • Quality gate protocol                                │    │
│  │ • Git push requirements                                │    │
│  │ • Clean state verification                             │    │
│  └────────────────────────────────────────────────────────┘    │
│                             │                                    │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ stacks/                   [REUSABLE TECH STACKS]       │    │
│  │ • backend.md       - Kotlin/Spring Boot/Gradle         │    │
│  │ • frontend.md      - Next.js/React/TypeScript          │    │
│  │ • examples/        - Workflow walkthroughs             │    │
│  │   ├── backend-workflows.md                             │    │
│  │   └── frontend-workflows.md                            │    │
│  └────────────────────────────────────────────────────────┘    │
│                             │                                    │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ skills/                   [SPECIALIZED AGENTS]         │    │
│  │ • backend-dev/    - References stacks/backend.md       │    │
│  │ • frontend-dev/   - References stacks/frontend.md      │    │
│  │ • build-orchestrator/ - Coordinates both stacks        │    │
│  │ • code-reviewer/  - Reviews using stack conventions    │    │
│  │ • prd-planner/    - Plans tasks using stack patterns   │    │
│  └────────────────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Applied to ALL projects
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Project Config (e.g., spending-tracker/)                       │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ .agents/AGENTS.md                                       │    │
│  │ • References global stacks (stacks/backend.md, etc.)   │    │
│  │ • Project-specific overrides (build commands)          │    │
│  │ • Quick reference commands                             │    │
│  │ • Directory structure                                  │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ Optional: Project-Specific Overrides                    │    │
│  │ .agents/backend-overrides.md  (if needed)              │    │
│  │ .agents/frontend-overrides.md (if needed)              │    │
│  │ • Only for deviations from global stacks               │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘

Key:
• Global docs = Universal across ALL projects (non-overridable)
• Global stacks = Reusable tech stack configurations (backend, frontend)
• Project docs = Minimal reference + project-specific overrides
• Skills = Specialized agents that combine stacks + workflows
```

---

## How This Works

### Global Configuration (This Location)
- **Personal Preferences**: Pyramid method, emoji usage, language settings
- **Universal Workflows**: Task tracking (beads), session completion protocol
- **Reusable Tech Stacks**: Backend (Kotlin/Spring Boot), Frontend (Next.js/React)
- **Specialized Skills**: backend-dev, frontend-dev, code-reviewer, etc.
- **Project Onboarding**: How to structure new projects

### Project-Local Configuration
- **Minimal AGENTS.md**: References global stacks + project-specific overrides
- **Build Commands**: Project-specific test/lint/build/run commands
- **Environment Setup**: Docker, databases, ports, etc.
- **Optional Overrides**: Only when deviating from global stack conventions

### Precedence Rules
1. Global workflows (beads, session completion) are **MANDATORY** and non-overridable
2. Global stacks (backend.md, frontend.md) are **DEFAULT** conventions
3. Project-local overrides supersede global stacks when specified
4. Personal preferences (pyramid method, emojis) always apply

---

## Quick Links

### Universal Workflows (MANDATORY)
- [Beads Workflow](agents/beads-workflow.md) - Task tracking for ALL projects (core policy)
  - For detailed workflows: Load skill `beads-workflow`
- [Session Completion](agents/session-completion.md) - Protocol for ending work sessions
- [Project Onboarding](agents/project-onboarding.md) - Setting up new projects

### Reusable Tech Stacks
- [Backend Stack](stacks/backend.md) - Kotlin/Spring Boot/Gradle conventions
- [Frontend Stack](stacks/frontend.md) - Next.js/React/TypeScript conventions
- [Stack Examples](stacks/examples/) - Workflow walkthroughs for each stack

### Specialized Agents
- [Code Reviewer](agents/code-reviewer.md) - Comprehensive code review
- [Git Commit](agents/git-commit.md) - Conventional commit messages
- [Code Simplifier](agents/code-simplifier.md) - Refactoring for clarity
- [Deep Thinker](agents/deep-thinker.md) - Complex problem analysis
- [Skill Creator](agents/skill-creator.md) - Creating custom skills

---

_Last updated: 2026-02-21 (Moved tech stacks to global /stacks/ directory for reusability across projects)_

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
