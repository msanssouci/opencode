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

See `agents/beads-workflow.md` for complete reference.

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
│  │ • Mandatory beads usage policy                         │    │
│  │ • Core bd commands & patterns                          │    │
│  │ • Technology-agnostic examples                         │    │
│  └────────────────────────────────────────────────────────┘    │
│                             │                                    │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ agents/session-completion.md      [UNIVERSAL]          │    │
│  │ • Quality gate protocol                                │    │
│  │ • Git push requirements                                │    │
│  │ • Clean state verification                             │    │
│  └────────────────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Applied to ALL projects
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Project Config (e.g., spending-tracker/)                       │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ AGENTS.md                                               │    │
│  │ • Links to global workflows                            │    │
│  │ • Quick reference commands                             │    │
│  │ • Directory structure                                  │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌──────────────────────┐  ┌──────────────────────┐           │
│  │ .agents/             │  │ .agents/             │           │
│  │ backend-agents.md    │  │ frontend-agents.md   │           │
│  │                      │  │                      │           │
│  │ • Language/framework │  │ • UI framework       │           │
│  │ • Build system       │  │ • Testing strategy   │           │
│  │ • Code conventions   │  │ • Accessibility      │           │
│  │ • Testing patterns   │  │ • State management   │           │
│  └──────────────────────┘  └──────────────────────┘           │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ .agents/examples/                                       │    │
│  │ • backend-workflows.md  (Concrete examples)            │    │
│  │ • frontend-workflows.md (Step-by-step guides)          │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘

Key:
• Global docs = Universal across ALL projects (non-overridable)
• Project docs = Technology/stack-specific (inherits from global)
• Examples = Concrete workflows combining beads + tech patterns
```

---

## How This Works

### Global Configuration (This Location)
- **Personal Preferences**: Pyramid method, emoji usage, language settings
- **Universal Workflows**: Task tracking (beads), session completion protocol
- **Agent Specializations**: code-reviewer, git-commit, deep-thinker, etc.
- **Project Onboarding**: How to structure new projects

### Project-Local Configuration
- **Technology Stack**: Language, frameworks, libraries
- **Build System**: Commands for test/lint/build/run
- **Code Style**: Project-specific conventions
- **Integration Points**: Where to create beads tasks in your workflow

### Precedence Rules
1. Project-local AGENTS.md overrides global for tech-specific matters
2. Global beads-workflow.md is **MANDATORY** and non-overridable
3. Global session-completion.md is **MANDATORY** protocol
4. Personal preferences (pyramid method, emojis) always apply

---

## Quick Links

### Universal Workflows (MANDATORY)
- [Beads Workflow](agents/beads-workflow.md) - Task tracking for ALL projects
- [Session Completion](agents/session-completion.md) - Protocol for ending work sessions
- [Project Onboarding](agents/project-onboarding.md) - Setting up new projects

### Specialized Agents
- [Code Reviewer](agents/code-reviewer.md) - Comprehensive code review
- [Git Commit](agents/git-commit.md) - Conventional commit messages
- [Code Simplifier](agents/code-simplifier.md) - Refactoring for clarity
- [Deep Thinker](agents/deep-thinker.md) - Complex problem analysis
- [Skill Creator](agents/skill-creator.md) - Creating custom skills

---

_Last updated: 2026-02-08 (Added documentation architecture and universal workflow links)_

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
