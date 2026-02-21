---
Version: 1.0.0
Last Updated: 2026-02-08
Changelog:
- 1.0.0 (2026-02-08): Initial creation - extracted from monolithic AGENTS.md
---

# Backend Development Guide (Kotlin/Gradle/Spring Boot/Clikt)

## Build Commands

### Gradle Commands
- **Build (all modules):**
  - `./gradlew build`
- **Clean:**
  - `./gradlew clean`
- **Run API server:**
  - `./gradlew :apps:api:bootRun`
- **Run CLI:**
  - `./gradlew :apps:cli:run --args="<args>"`
- **Run tests:**
  - `./gradlew test`
  - `./gradlew :apps:api:test`  # API tests only
  - `./gradlew :apps:cli:test`  # CLI tests only
  - `./gradlew :libs:utils:test`# Utils tests only

### Running a Single Test
- **By test class:**
  - `./gradlew test --tests "com.sans.souci.spending_tracker.<ClassName>"`
- **By method:**
  - `./gradlew test --tests "com.sans.souci.spending_tracker.<ClassName>.<methodName>"`

### Linting & Formatting
- **No explicit lint command found.**
  - _If adding lint tools (e.g., ktlint, detekt), document the command here._
  - Recommended: Use `ktlint` for formatting and `detekt` for static analysis on Kotlin code.

---

## Code Style Guidelines

### General Formatting
- **Indentation:** 4 spaces per level.
- **Line length:** 120 characters maximum, unless readability requires extension.
- **Braces:** On same line for function/class declarations.
- **Package declaration:** Always first line, followed by imports.

### Imports
- Grouped by origin: standard library, third-party, internal (in that order).
- No unused imports. Remove any automated/additional imports not in use.

### Types
- Leverage Kotlin's type inference, but:
  - Explicit types for public API, class fields, and mutable variables.
- Prefer immutable `val` over mutable `var`.
- Use sealed classes / enums for error and domain cases where appropriate.

### Naming Conventions
- **Packages:** Snake_case, e.g., `com.sans.souci.spending_tracker`
- **Classes & Types:** UpperCamelCase, e.g., `DemoApplication`, `SampleCli`
- **Functions & Variables:** lowerCamelCase, e.g., `main`, `capitalizeFirst`
- **Constants:** UPPER_SNAKE_CASE (if used)
- **Files:** Same as primary class/type, e.g., `DemoApplication.kt`

### Error Handling
- Use idiomatic exception patterns:
  - Prefer standard Kotlin/Java exceptions.
  - When possible, leverage Result wrappers or sealed classes.
  - Avoid exposing internal stack traces unless necessary.
  - Log errors with meaningful context, not raw exception.

---

## API Development (Spring Boot)

### Conventions
- Annotate application classes (e.g., `@SpringBootApplication`).
- Application entry point must be `fun main(args: Array<String>)`.
- Use standard Spring Boot dependency injection and REST conventions.

### Structure
```
apps/api/src/main/kotlin/com/sans/souci/spending_tracker/
├── controller/     # REST endpoints (@RestController)
├── service/        # Business logic (@Service)
├── repository/     # Data access (@Repository)
├── model/          # Domain entities
├── dto/            # Data transfer objects
└── config/         # Configuration classes
```

---

## CLI Development (Clikt)

### Conventions
- Entry point: `fun main(args: Array<String>)`.
- Commands inherit from CliktCommand.
- Each command class: Override `run()` for logic. Add argument parsing as fields/properties.
- Use clear, actionable help text in CLI commands.

### Structure
```
apps/cli/src/main/kotlin/com/sans/souci/spending_tracker/
├── commands/       # CLI command implementations
├── options/        # Reusable option/argument definitions
└── Main.kt         # Entry point with subcommands
```

---

## Shared Utilities

### Conventions
- Place extension functions (e.g., `String.capitalizeFirst`) in utils library.
- Make utils pure and stateless; avoid side-effects.

### Structure
```
libs/utils/src/main/kotlin/com/sans/souci/spending_tracker/utils/
├── StringExtensions.kt
├── DateUtils.kt
└── ValidationUtils.kt
```

---

## Testing Patterns

### Test Structure
- Use JUnit 5 for all tests
- Follow given-when-then pattern
- One test class per production class
- Test file naming: `<ClassName>Test.kt`

### Example
```kotlin
@Test
fun `createUser should return user with generated ID`() {
    // Given
    val request = CreateUserRequest("test@example.com")
    
    // When
    val result = userService.createUser(request)
    
    // Then
    assertNotNull(result.id)
    assertEquals("test@example.com", result.email)
}
```

### Mocking
- Use MockK for Kotlin-friendly mocking
- Prefer behavior verification over state verification
- Mock external dependencies, not domain logic

---

## Beads Integration Points

### When to Create Tasks

**API Development:**
```bash
# Before implementing endpoint
bd create --title="Add POST /api/transactions endpoint" --type=task --priority=2 --json

# Before writing tests
bd create --title="Write tests for TransactionController" --type=task --priority=2 --json

# Set dependency
bd dep add beads-yyy beads-xxx --json  # Tests depend on implementation
```

**CLI Development:**
```bash
# Before implementing command
bd create --title="Implement 'transaction add' CLI command" --type=task --priority=2 --json

# Before writing tests
bd create --title="Test CLI command parsing and validation" --type=task --priority=2 --json
```

**Shared Utilities:**
```bash
# Before adding utility function
bd create --title="Add CurrencyUtils.format() extension" --type=task --priority=3 --json
```

### Task Lifecycle Pattern

1. **Create task BEFORE writing code**
   ```bash
   bd create --title="..." --type=task --priority=2 --json
   # Returns: beads-xxx
   ```

2. **Claim task when starting**
   ```bash
   bd update beads-xxx --status=in_progress --json
   ```

3. **Implement feature**
   - Write production code
   - Write tests
   - Verify tests pass: `just test` or `./gradlew test`

4. **Close task with details**
   ```bash
   bd close beads-xxx --reason="Implemented TransactionController.create() with service layer and tests" --json
   ```

### Example Workflows

See [.agents/examples/backend-workflows.md](.agents/examples/backend-workflows.md) for complete examples:
- Adding a Spring Boot REST endpoint
- Implementing a Clikt CLI command
- Adding a shared utility function

---

## Agent Behavior

- Always prefer existing justfile or Gradle commands for build/test/run tasks.
- If automation fails, attempt to restore a consistent state (via `just clean` or `./gradlew clean`).
- Code changes MUST follow the above style guidelines for naming, imports, and structure.
- When adding or refactoring tests, use idiomatic Kotlin test/JUnit5 patterns.
- **ALWAYS create beads task BEFORE writing code** - see [beads-workflow.md](~/.config/opencode/agents/beads-workflow.md)

---

_For universal beads workflow, see [~/.config/opencode/agents/beads-workflow.md](~/.config/opencode/agents/beads-workflow.md)_
_For session completion protocol, see [~/.config/opencode/agents/session-completion.md](~/.config/opencode/agents/session-completion.md)_
