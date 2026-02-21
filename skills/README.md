# Custom Skills

This directory is for custom OpenCode skills that extend the platform's capabilities with domain-specific functionality.

## Overview

Skills are reusable, packaged capabilities that can be loaded into OpenCode to provide specialized workflows, domain knowledge, or integrations. Unlike agents (which are workflows) or commands (which are interactive), skills are code-based extensions.

## What Are Skills?

Skills are TypeScript/JavaScript modules that:
- Provide specialized functions or capabilities
- Can be distributed and shared across projects
- Have proper structure and metadata for OpenCode
- May include dependencies, configuration, and documentation

## Current Skills

### Multi-Agent Workflow System

**Spending-tracker specialized skills for coordinated feature development:**

#### `/prd` - PRD Command ⚡ (NEW!)
**Location:** `prd-command/`  
**Command:** `/prd "feature description"`  
**Description:** Single-command PRD-to-implementation workflow. Analyzes requirements, creates tasks, orchestrates parallel execution, and commits.

**Usage:**
```bash
/prd "Add budget tracking with monthly limits and alerts"
```

**What it does:**
1. Analyzes PRD → creates beads tasks
2. Executes 4 tasks in parallel (3-4x faster)
3. Runs tests after each batch
4. Commits when complete
5. Reports statistics

**Performance:** 20-30 task feature in ~40-60 minutes (vs 2-3 hours sequential)

---

#### `prd-planner` - PRD Analysis & Task Breakdown
**Location:** `prd-planner/`  
**Description:** Analyzes Product Requirement Documents and creates structured beads task breakdowns with dependencies.

**Usage:** `Load skill 'prd-planner' and process PRD: "feature description"`

---

#### `build-orchestrator` - Multi-Agent Coordinator
**Location:** `build-orchestrator/`  
**Description:** Coordinates parallel execution of backend, frontend, code review, and testing subagents.

**Usage:** `Load skill 'build-orchestrator' and coordinate implementation`

---

#### `backend-dev` - Spring Boot/Kotlin Specialist
**Location:** `backend-dev/`  
**Description:** Implements Spring Boot/Kotlin features following project conventions (Repository → Service → Controller).

**Usage:** `Load skill 'backend-dev' and implement beads task <id>`

---

#### `frontend-dev` - Next.js/React Specialist
**Location:** `frontend-dev/`  
**Description:** Implements Next.js/React/TypeScript features following project conventions.

**Usage:** `Load skill 'frontend-dev' and implement beads task <id>`

---

#### `code-reviewer` - Code Quality Enforcement
**Location:** `code-reviewer/`  
**Description:** Reviews code for DRY, SIMPLE principles, security, and performance.

**Usage:** `Load skill 'code-reviewer' and review beads task <id>`

---

#### `test-runner` - Test Execution & Failure Management
**Location:** `test-runner/`  
**Description:** Executes tests with retry logic (max 3 attempts) and escalates persistent failures.

**Usage:** `Load skill 'test-runner' and test beads task <id>`

---

#### `beads-workflow` - Task Tracking System
**Location:** `beads-workflow/`  
**Description:** Extended beads workflow documentation including git branch setup and troubleshooting.

**Usage:** `Load skill 'beads-workflow'` (loads on-demand detailed workflows)

## Creating Custom Skills

To create a new skill, use the **skill-creator agent**:

```
Task(
  description="Create a new skill",
  prompt="Create a skill for [your use case]",
  subagent_type="skill-creator"
)
```

The skill-creator agent will help you:
1. Set up the proper skill structure
2. Add required metadata and configuration
3. Implement core functionality
4. Package for distribution
5. Test and validate

## Skill Structure

A typical skill follows this structure:

```
my-skill/
├── src/
│   └── index.ts          # Main skill implementation
├── package.json          # Skill metadata and dependencies
├── skill.json            # OpenCode skill configuration
├── README.md             # Skill documentation
└── test/                 # Tests (optional)
    └── index.test.ts
```

## Skill Configuration

Skills use `skill.json` for OpenCode integration:

```json
{
  "name": "my-skill",
  "version": "1.0.0",
  "description": "What this skill does",
  "main": "src/index.ts",
  "capabilities": [
    "capability-1",
    "capability-2"
  ]
}
```

## Installing Skills

To use a skill:

1. **Copy to skills directory**: Place the skill folder in `~/.config/opencode/skills/`
2. **Install dependencies** (if any): `cd skills/my-skill && npm install`
3. **Load in OpenCode**: Skills are auto-loaded on startup

## Skill Development Best Practices

- **Single responsibility**: Each skill should have one clear purpose
- **Clear documentation**: Explain what the skill does and how to use it
- **Type safety**: Use TypeScript for better developer experience
- **Error handling**: Gracefully handle failures and edge cases
- **Testing**: Include tests to verify functionality
- **Versioning**: Follow semantic versioning

## Example Use Cases

Skills are useful for:

- **Domain-specific knowledge**: Medical, legal, financial terminology and workflows
- **API integrations**: Third-party service connectors
- **Code generation**: Framework-specific scaffolding
- **Data processing**: Specialized parsers or transformers
- **Validation**: Custom linting or checking rules

## Resources

- **Skill Creator Agent**: See `../agents/skill-creator.md`
- **OpenCode Documentation**: [https://opencode.ai/docs/skills](https://opencode.ai/docs/skills)
- **Contributing**: See `../CONTRIBUTING.md`

## Contributing

Have a useful skill to share? Consider:
1. Creating a separate repository for the skill
2. Publishing to npm for easier distribution
3. Submitting a PR to add it to a community skills list
4. Documenting usage examples and best practices

See [CONTRIBUTING.md](../CONTRIBUTING.md) for more details.
