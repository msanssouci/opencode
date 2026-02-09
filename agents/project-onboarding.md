---
Version: 1.0.0
Last Updated: 2026-02-08
Changelog:
- 1.0.0 (2026-02-08): Initial creation
---

# Project Onboarding Guide

This guide explains how to structure agent documentation for new projects.

---

## Documentation Architecture

Every project should have:

1. **AGENTS.md** (root) - Orchestration document
2. **.agents/** directory - Technology-specific guidelines
3. **.agents/examples/** directory - Concrete workflow examples

---

## Template Structure

### Root AGENTS.md Template

```markdown
# [PROJECT-NAME] Agent Guide

## Overview
[Brief description: tech stack, architecture, purpose]

## 📚 Documentation Structure

### Universal Workflows (Global OpenCode Config)
- **Task Tracking:** [~/.config/opencode/agents/beads-workflow.md](~/.config/opencode/agents/beads-workflow.md)
- **Session Completion:** [~/.config/opencode/agents/session-completion.md](~/.config/opencode/agents/session-completion.md)

### Project-Specific Guidelines (This Repo)
- **[Technology 1]:** [.agents/backend-agents.md](.agents/backend-agents.md)
- **[Technology 2]:** [.agents/frontend-agents.md](.agents/frontend-agents.md)

## Quick Reference

### Start Session
\`\`\`bash
bd ready --json
bd show <id> --json
bd update <id> --status=in_progress --json
\`\`\`

### Quality Gates (Session Close)
\`\`\`bash
[Your project's test command]
[Your project's lint command]
[Your project's build command]
\`\`\`

### Project Commands
[Build/test/run/deploy commands specific to this project]

## Directory Structure
[ASCII tree of project layout]

_For complete workflows, see .agents/ subdirectory_
```

### .agents/ Directory Template

**Create specialized files per technology:**

**.agents/backend-agents.md** - For server-side code
- Build commands
- Code style conventions
- Framework-specific patterns
- Testing requirements
- Beads integration points

**.agents/frontend-agents.md** - For client-side code
- Development commands
- UI framework patterns
- Testing strategies (unit + E2E)
- Accessibility requirements
- Beads integration points

**.agents/mobile-agents.md** - For mobile apps (if applicable)
**.agents/data-agents.md** - For ML/data pipelines (if applicable)

### .agents/examples/ Directory Template

**Concrete workflow walkthroughs:**

**.agents/examples/[domain]-workflows.md**
```markdown
# [Domain] Workflow Examples

## Example 1: [Common Task Title]

### Beads Setup
\`\`\`bash
bd create --title="..." --type=task --priority=2 --json
bd update beads-xxx --status=in_progress --json
\`\`\`

### Implementation Steps
1. [Step 1 with code snippet]
2. [Step 2 with code snippet]
3. [Step 3 with code snippet]

### Completion
\`\`\`bash
bd close beads-xxx --reason="..." --json
\`\`\`

[Repeat for 3-5 common scenarios]
```

---

## Scaffolding Command (Future)

**Proposed:** Add to beads CLI or create standalone script

```bash
bd agents-init [--backend=kotlin|python|go] [--frontend=react|vue|angular]
```

**What it would generate:**
- Root AGENTS.md with placeholders
- .agents/ directory with template files
- .agents/examples/ directory with TODO placeholders
- justfile command for `just agents-check`

**Manual alternative (for now):**
```bash
# In your project root
mkdir -p .agents/examples
touch AGENTS.md
touch .agents/backend-agents.md
touch .agents/frontend-agents.md
touch .agents/examples/backend-workflows.md
touch .agents/examples/frontend-workflows.md

# Copy templates from this guide, replace placeholders
```

---

## Integration Points

### Where to Create Beads Tasks

**Backend patterns:**
- Before implementing endpoint/route/handler
- Before adding service/business logic method
- Before database migration
- Before infrastructure change

**Frontend patterns:**
- Before creating new component
- Before adding page/route
- Before API client method
- Before E2E test scenario

**General rules:**
- One task per logical unit of work
- Create test task as dependency
- Break large features into epic + sub-tasks

---

## Version Control

**Add to each file:**
```markdown
---
Version: 1.0.0
Last Updated: YYYY-MM-DD
Changelog:
- 1.0.0 (YYYY-MM-DD): Initial creation
---
```

**Update changelog when modifying:**
```markdown
- 1.1.0 (YYYY-MM-DD): Added Playwright E2E guidelines
- 1.0.1 (YYYY-MM-DD): Fixed typo in build command
```

---

## CI Integration

**Add to project's build tool (justfile example):**

```makefile
# Validate agent documentation structure
agents-check:
    @echo "Checking agent documentation..."
    @test -f AGENTS.md || (echo "❌ Missing AGENTS.md" && exit 1)
    @test -d .agents || (echo "❌ Missing .agents/ directory" && exit 1)
    @echo "✅ Agent documentation structure valid"

# Lint markdown files
agents-lint:
    @command -v markdownlint >/dev/null 2>&1 || (echo "⚠️  markdownlint not installed" && exit 0)
    markdownlint AGENTS.md .agents/**/*.md
    @echo "✅ Markdown lint passed"
```

---

## Maintenance

**Keep documentation current:**
- Update when adding new automation commands
- Update when changing tech stack
- Update when discovering new patterns
- Update version/changelog on every change

**Review quarterly:**
- Are examples still accurate?
- Are commands still correct?
- Are best practices still relevant?

---

_For universal workflows, see [beads-workflow.md](beads-workflow.md) and [session-completion.md](session-completion.md)_
