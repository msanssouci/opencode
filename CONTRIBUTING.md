# Contributing to OpenCode Configuration

Thank you for your interest in improving this OpenCode configuration! This document provides guidelines for contributing.

## How to Contribute

### Reporting Issues

If you encounter problems or have suggestions:

1. **Check existing issues** to avoid duplicates
2. **Open a new issue** with:
   - Clear, descriptive title
   - Detailed description of the problem or suggestion
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment (OS, OpenCode version, etc.)

### Suggesting Enhancements

We welcome ideas for new features:

- **New agents**: Propose specialized agent workflows
- **Custom commands**: Share useful command patterns
- **Helper scripts**: Contribute automation scripts
- **Documentation improvements**: Better examples, clarity, etc.

### Submitting Pull Requests

1. **Fork the repository** and create a new branch
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the guidelines below

3. **Test your changes**:
   - Verify agents load correctly
   - Test custom commands work as expected
   - Ensure scripts execute without errors
   - Check documentation renders properly

4. **Commit with clear messages**:
   ```bash
   git commit -m "feat: add new agent for X"
   git commit -m "docs: improve command documentation"
   git commit -m "fix: correct script exit codes"
   ```

5. **Push and create a pull request**:
   - Describe what changed and why
   - Reference any related issues
   - Include examples if applicable

## Code Style Guidelines

### Agent Documentation

- Use markdown format with YAML frontmatter
- Include clear descriptions and examples
- Follow the structure of existing agents
- Add version and changelog information

### Custom Commands

- Use `.md` format for command documentation
- Include `description` in YAML frontmatter
- Provide usage examples
- Document all arguments and options

### Helper Scripts

- Use bash with proper error handling
- Include usage comments at the top
- Follow guard clause pattern
- Return meaningful exit codes
- Add error messages for common issues

### Documentation

- Keep language clear and concise
- Use code examples where helpful
- Update README.md if adding major features
- Update CHANGELOG.md following Keep a Changelog format

## Development Workflow

This configuration uses **beads** for task tracking:

```bash
# Create a task for your work
bd create --title="Add new agent for X" --type=feature --priority=2

# Work on the task
bd update <task-id> --status=in_progress

# Close when complete
bd close <task-id> --reason="Implemented agent with examples and tests"
```

## Testing

Before submitting:

1. **Verify file structure**: Ensure files are in correct directories
2. **Check markdown**: Validate markdown syntax
3. **Test scripts**: Run scripts to verify they work
4. **Review documentation**: Ensure docs are accurate

## Questions?

If you have questions:

- Open an issue for discussion
- Check existing documentation in `agents/`, `commands/`, and `scripts/` directories
- Review similar implementations for patterns

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
