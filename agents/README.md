# Specialized Agents

This directory contains documentation for specialized OpenCode agents that provide specific workflows and capabilities.

## Overview

Agents are specialized AI workflows that handle specific tasks like code review, commit message generation, or complex problem analysis. Each agent is defined by a markdown file that provides instructions, patterns, and examples.

## Available Agents

### 🚨 Mandatory Agents

These agents define universal workflows that apply to all projects:

- **[beads-workflow.md](beads-workflow.md)** - Universal task tracking with beads
  - Core commands and patterns
  - Multi-step workflows (epics, dependencies)
  - Git integration
  - Common mistakes to avoid

- **[session-completion.md](session-completion.md)** - Session end protocol
  - Quality gate requirements
  - Git push requirements
  - Clean state verification
  - Handoff procedures

### 📋 Project Setup

- **[project-onboarding.md](project-onboarding.md)** - Setting up new projects
  - Documentation structure
  - Beads integration
  - Configuration templates

### 🛠️ Development Agents

- **[code-reviewer.md](code-reviewer.md)** - Comprehensive code review
  - Multi-dimensional analysis
  - Security and performance checks
  - Best practices verification

- **[code-simplifier.md](code-simplifier.md)** - Refactoring for clarity
  - Simplification patterns
  - Maintains functionality
  - Improves maintainability

- **[git-commit.md](git-commit.md)** - Conventional commit messages
  - Analyzes staged changes
  - Generates semantic commits
  - Follows commit conventions

- **[deep-thinker.md](deep-thinker.md)** - Complex problem analysis
  - Structured thinking process
  - Decision support
  - Problem decomposition

### 🎨 Creation Agents

- **[skill-creator.md](skill-creator.md)** - Creating custom skills
  - Skill structure and metadata
  - Packaging for distribution
  - Testing and validation

- **[talk.md](talk.md)** - Conversation agent
  - Interactive dialogue
  - Context-aware responses

## Usage

### Automatic Loading

OpenCode automatically loads all agent configurations from this directory. Agents are available system-wide and apply their specialized workflows when appropriate.

### Invoking Agents

Agents are typically invoked through the Task tool with specific subagent types:

```typescript
// In OpenCode
Task(
  description="Review the authentication code",
  prompt="Please review the auth implementation for security issues",
  subagent_type="code-reviewer"
)
```

### Agent Precedence

1. **Mandatory agents** (beads-workflow, session-completion) are non-overridable
2. **Project-local agents** can override development agents for tech-specific needs
3. **Global agents** provide defaults for all projects

## Creating Custom Agents

To create a new agent:

1. **Create a markdown file** in this directory (e.g., `my-agent.md`)

2. **Add YAML frontmatter** with metadata:
   ```yaml
   ---
   Version: 1.0.0
   Last Updated: 2026-02-09
   Changelog:
   - 1.0.0 (2026-02-09): Initial creation
   ---
   ```

3. **Document the workflow**:
   - Clear description of purpose
   - Step-by-step instructions
   - Examples and patterns
   - Common pitfalls

4. **Test the agent** by invoking it through OpenCode

5. **Consider using the skill-creator agent** for more complex agents

## Best Practices

- **Keep agents focused**: Each agent should have a single, clear purpose
- **Provide examples**: Show concrete usage patterns
- **Document assumptions**: State prerequisites and context requirements
- **Version your agents**: Track changes in the changelog
- **Link related agents**: Reference complementary workflows

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on improving agent documentation or creating new agents.
