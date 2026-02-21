# Custom Commands

This directory contains custom OpenCode commands that extend the built-in capabilities with specialized workflows.

## Overview

Custom commands are markdown files with YAML frontmatter that define multi-step workflows. They can be invoked in OpenCode using slash notation (e.g., `/command-name`).

## Available Commands

### Project Setup

**[bootstrap-project.md](bootstrap-project.md)** - Bootstrap Project for PRD Workflow
- Initializes beads task tracking system
- Creates project-specific `.agents/AGENTS.md` configuration
- Sets up git hooks for automatic beads sync
- Configures PRD workflow and agent orchestration
- Auto-detects tech stack (backend/frontend/fullstack)

**Usage:**
```
/bootstrap-project
/bootstrap-project my-awesome-app
/bootstrap-project my-app --stack=fullstack
```

**Requirements:**
- Git repository initialized (`git init`)
- In project root directory
- Beads CLI (`bd`) installed

### Product Development Workflow

**[prd.md](prd.md)** - End-to-End PRD Implementation
- Analyzes product requirements documents
- Creates structured beads task breakdown with dependencies
- Orchestrates parallel multi-agent implementation
- Runs quality gates (build + tests) after each batch
- Interactive checkpoint for approval before implementation
- Commits changes with conventional commit messages

**Usage:**
```
/prd "Add health check endpoint at GET /api/health"
/prd "Budget tracking: users set monthly limits per category, system alerts when exceeded"
```

**Requirements:**
- Beads initialized (`bd ready` works)
- Docker running (`just docker-up`)
- Clean git working directory
- Project bootstrapped (use `/bootstrap-project` if not already done)

**[prd-continue.md](prd-continue.md)** - Resume PRD Implementation
- Resumes implementation after task modifications
- Picks up where `/prd` left off
- Executes remaining tasks in parallel batches
- Same quality gates and commit workflow

**Usage:**
```
/prd-continue
```

**Requirements:** Same as `/prd`, plus open tasks from a previous `/prd` run

### GitHub Integration

**[ghi-upsert.md](ghi-upsert.md)** - GitHub Issue Management
- Create, update, or comment on GitHub issues via gh CLI
- Intelligent upsert logic (create if missing, update if exists)
- Interactive prompts for confirmation
- Preserves issue context and history

**Usage:**
```
/ghi-upsert #123
/ghi-upsert 456
```

**Requirements:** GitHub CLI (`gh`) installed and authenticated

### Internationalization

**[update-translations.md](update-translations.md)** - Translation File Management
- Update `cs.json` and `en.json` message files
- Auto-detect namespaces from context
- Extract text from Figma designs (optional)
- Update component files with translation keys

**Usage:**
```
/update-translations Add sign-in form translations
/update-translations Get text from Figma node 123:456
/update-translations Update src/components/auth/SignUp.tsx with translations
```

**Requirements:** 
- Project with `src/i18n/messages/` directory
- Figma MCP server (optional, for Figma integration)

## Complex Examples

For more complex or specialized commands, see the `examples/` directory:

- **Spring Boot Kotlin Project Scaffolding** - See `../examples/create-spring-boot-kotlin-project.prompt.md`

## Command Structure

Custom commands follow this structure:

```markdown
---
description: Brief description of what the command does
---

Full description and usage instructions

## Arguments

$ARGUMENTS — Description of expected arguments

## Steps

1. **Step name**
   - Detailed instructions
   - Tool calls: !`command to run`
   - Conditional logic

2. **Next step**
   - Continue workflow...

## Examples

### Example 1: Description
- User: `/command example`
- Result: What happens
```

## Creating Custom Commands

To create a new command:

1. **Create a markdown file** in this directory (e.g., `my-command.md`)

2. **Add YAML frontmatter**:
   ```yaml
   ---
   description: What this command does
   ---
   ```

3. **Document the workflow**:
   - Arguments expected
   - Step-by-step process
   - Tool/CLI invocations
   - Error handling
   - Examples

4. **Test the command** by invoking `/my-command` in OpenCode

## Best Practices

- **Use descriptive names**: Command names should clearly indicate purpose
- **Handle errors gracefully**: Check for prerequisites and provide helpful error messages
- **Provide examples**: Show common usage patterns
- **Document requirements**: List required tools, file structure, or configuration
- **Use interactive prompts**: Ask for confirmation on destructive operations
- **Preserve context**: Show relevant information before and after operations

## Integration Points

Commands can integrate with:

- **Shell commands**: Use `!` prefix for bash/shell execution
- **MCP servers**: Access external services (Figma, GitHub, etc.)
- **Git operations**: Leverage git CLI for version control
- **File operations**: Read, write, and manipulate files
- **Agent workflows**: Combine with specialized agents for complex tasks

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on creating new commands or improving existing ones.
