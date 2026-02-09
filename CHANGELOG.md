# Changelog

All notable changes to this OpenCode configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-09

### Added

- **Specialized Agents**
  - `beads-workflow` - Universal task tracking workflow (mandatory)
  - `session-completion` - Session end protocol with quality gates
  - `project-onboarding` - New project setup guide
  - `code-reviewer` - Comprehensive code review agent
  - `git-commit` - Conventional commit message generation
  - `code-simplifier` - Code refactoring for clarity
  - `deep-thinker` - Complex problem analysis
  - `skill-creator` - Custom skill creation
  - `talk` - Conversation agent

- **Custom Commands**
  - `/ghi-upsert` - GitHub issue management via gh CLI
  - `/update-translations` - i18n translation file management

- **Helper Scripts**
  - `create-commit.sh` - Automated git commit creation
  - `get-git-context.sh` - Git context extraction for AI
  - `run-precommit.sh` - Pre-commit validation checks

- **Examples**
  - Spring Boot Kotlin project scaffolding command

- **Configuration**
  - Ollama provider configuration with qwen3 model
  - MCP server support (Brave Search)
  - Beads plugin integration
  - Environment-based API key management

- **Documentation**
  - Comprehensive README with installation and usage
  - MIT License
  - Contributing guidelines
  - Directory-specific documentation

### Configuration

- OpenCode provider: Ollama (local)
- Default model: qwen3:latest
- Task tracking: Beads
- MCP servers: Brave Search (optional)

[1.0.0]: https://github.com/yourusername/opencode/releases/tag/v1.0.0
