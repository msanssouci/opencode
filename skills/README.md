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

*This directory is currently empty. Add your custom skills here.*

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
