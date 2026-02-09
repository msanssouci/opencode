# Custom Commands

This directory contains custom OpenCode commands that extend the built-in capabilities with specialized workflows.

## Overview

Custom commands are markdown files with YAML frontmatter that define multi-step workflows. They can be invoked in OpenCode using slash notation (e.g., `/command-name`).

## Available Commands

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
