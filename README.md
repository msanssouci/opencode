# OpenCode Configuration

A production-ready OpenCode configuration featuring specialized agents, custom commands, helper scripts, and integrated beads task tracking.

## Features

- **Specialized Agents**: Code review, git commits, deep thinking, code simplification, and more
- **Custom Commands**: GitHub issue management, i18n translations, and project scaffolding examples
- **Helper Scripts**: Automated git workflows and pre-commit checks
- **Beads Integration**: Universal task tracking across all projects
- **MCP Servers**: Brave Search integration (configurable)

## Prerequisites

- [OpenCode](https://opencode.ai) installed
- [Bun](https://bun.sh) or Node.js for dependencies
- [Beads](https://github.com/opencode-ai/beads) for task tracking (optional but recommended)
- [GitHub CLI](https://cli.github.com/) for `ghi-upsert` command (optional)

## Installation

1. **Clone this repository** to your OpenCode config directory:
   ```bash
   git clone https://github.com/yourusername/opencode ~/.config/opencode
   cd ~/.config/opencode
   ```

2. **Install dependencies**:
   ```bash
   bun install
   # or: npm install
   ```

3. **Configure MCP servers** (optional):
   ```bash
   cp opencode.example.json opencode.json
   # Edit opencode.json and add your API keys
   ```

4. **Set up environment variables** (optional):
   ```bash
   cp .env.example .env
   # Edit .env and add your API keys
   ```

5. **Initialize beads** (if using task tracking):
   ```bash
   bd init
   ```

## Configuration

### MCP Servers (opencode.json)

The `opencode.json` file configures MCP (Model Context Protocol) servers that provide additional capabilities to OpenCode. Copy `opencode.example.json` to `opencode.json` and add your API keys.

Example configuration:
```json
{
  "mcp": {
    "brave-search": {
      "type": "local",
      "command": [ "npx", "-y", "@brave/brave-search-mcp-server", "--transport", "http" ],
      "enabled": true,
      "environment": {
        "BRAVE_API_KEY": "your_api_key_here"
      }
    }
  },
  "plugin": ["opencode-beads"]
}
```

### Provider Settings (config.json)

The `config.json` file configures OpenCode's AI provider settings. The default configuration uses Ollama with the qwen3 model running locally.

## Repository Structure

```
opencode/
├── agents/          # Specialized agent documentation
│   ├── beads-workflow.md      # Mandatory task tracking workflow
│   ├── session-completion.md  # Session end protocol
│   ├── code-reviewer.md       # Code review agent
│   └── ...
├── commands/        # Custom slash commands
│   ├── ghi-upsert.md          # GitHub issue management
│   └── update-translations.md # i18n management
├── examples/        # Example commands and workflows
│   └── create-spring-boot-kotlin-project.prompt.md
├── scripts/         # Helper scripts for git workflows
│   ├── create-commit.sh       # Automated commit creation
│   ├── get-git-context.sh     # Git context extraction
│   └── run-precommit.sh       # Pre-commit checks
├── skills/          # Custom skills
├── AGENTS.md        # Agent configuration and preferences
├── config.json      # OpenCode provider settings
└── opencode.json    # MCP servers & plugins (not versioned)
```

## Usage

### Using Agents

OpenCode automatically loads agent configurations. Specialized agents include:

- `beads-workflow` - Universal task tracking (mandatory)
- `session-completion` - Session end protocol (mandatory)
- `project-onboarding` - Setting up new projects
- `code-reviewer` - Comprehensive code reviews
- `git-commit` - Conventional commit messages
- `deep-thinker` - Complex problem analysis
- `code-simplifier` - Refactoring for clarity
- `skill-creator` - Creating custom skills

See `agents/README.md` for complete documentation.

### Using Custom Commands

Custom commands are invoked with a slash prefix:

- `/ghi-upsert <issue-number>` - Create, update, or comment on GitHub issues
- `/update-translations` - Manage i18n translation files

See `commands/README.md` for detailed documentation.

See `examples/` directory for complex command examples like Spring Boot project scaffolding.

### Using Helper Scripts

The `scripts/` directory contains bash scripts for common git workflows:

```bash
./scripts/create-commit.sh "commit message"  # Create a git commit
./scripts/get-git-context.sh                 # Extract git context for AI
./scripts/run-precommit.sh                   # Run pre-commit checks
```

See `scripts/README.md` for usage details.

## Beads Task Tracking

This configuration uses [beads](https://github.com/opencode-ai/beads) for task tracking across projects. The beads workflow is documented in `agents/beads-workflow.md` and is mandatory for all agents.

Quick start:
```bash
bd init                          # Initialize beads in a project
bd ready --json                  # Show available tasks
bd create --title="..." -t task  # Create new task
bd update <id> --status=in_progress
bd close <id> --reason="..."     # Close task with context
bd sync --flush-only             # Export to JSONL
```

## Contributing

Contributions welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.
