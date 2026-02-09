# Command Examples

This directory contains complex or specialized command examples that demonstrate advanced OpenCode workflows.

## Overview

Examples are fully-documented command templates that you can use as-is or adapt for your specific needs. They typically involve multiple steps, external tools, or complex integrations.

## Available Examples

### Spring Boot Kotlin Project Scaffolding

**[create-spring-boot-kotlin-project.prompt.md](create-spring-boot-kotlin-project.prompt.md)**

A comprehensive command for scaffolding a production-ready Spring Boot project with Kotlin.

**Features:**
- Downloads Spring Boot template from start.spring.io
- Configures Gradle with version catalog
- Sets up Flyway database migrations
- Configures jOOQ code generation
- Adds Docker Compose for PostgreSQL and Redis
- Includes Just task runner for automation
- Full project structure with dependencies

**Technologies:**
- Spring Boot 3.5.9
- Kotlin with Gradle
- PostgreSQL + Flyway + jOOQ
- Redis for caching
- Docker Compose
- Just task runner

**Prerequisites:**
- Java 21 installed
- Docker and Docker Compose
- Just task runner (optional but recommended)

**Usage:**
This command is designed for project initialization and includes interactive prompts for:
- Project name
- Package name
- Database configuration

See the full command file for detailed step-by-step instructions.

---

## Using Examples

Examples in this directory are meant to be:

1. **Customized for your needs** - Replace placeholders and adjust configurations
2. **Learned from** - Understand patterns for building complex commands
3. **Extended** - Add or remove steps based on your workflow

## Adapting Examples

To adapt an example for your use:

1. **Copy the example** as a starting point
2. **Update variables**: Project names, versions, package names
3. **Modify dependencies**: Add/remove libraries as needed
4. **Adjust configurations**: Change database settings, ports, etc.
5. **Test thoroughly**: Run through all steps to verify it works

## Creating Your Own Examples

If you create a complex command workflow that might be useful to others:

1. **Document thoroughly**: Include all prerequisites and steps
2. **Use clear variable names**: Make it obvious what needs customization
3. **Add examples**: Show expected inputs and outputs
4. **Test from scratch**: Verify someone else could follow your instructions
5. **Submit a PR**: Share with the community

## Why Examples Live Here

Complex, specialized commands live in `examples/` rather than `commands/` because:

- They're not general-purpose workflows
- They may be technology or framework specific
- They serve as templates rather than ready-to-use commands
- They require significant customization

General-purpose commands that work across projects live in the `commands/` directory.

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding new examples or improving existing ones.
