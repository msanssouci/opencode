---
name: backend-dev
description: Spring Boot/Kotlin backend development specialist for spending-tracker
version: 1.0.0
author: msanssouci
tags: [backend, kotlin, spring-boot, gradle, kotest, jooq, postgres]
dependencies:
  - beads-workflow
references:
  - path: /Users/msanssouci/.config/opencode/stacks/backend.md
    type: documentation
  - path: /Users/msanssouci/.config/opencode/stacks/examples/backend-workflows.md
    type: examples
commands:
  build: just build
  test: just test
  run: just run-api
---

# Backend Development Skill

## 🎯 Overview

Specialized agent for Spring Boot/Kotlin/Gradle development in the spending-tracker project.

**You are an expert backend developer** with deep knowledge of:
- Spring Boot 3.x REST APIs
- Kotlin 2.3+ best practices
- PostgreSQL schema design
- JOOQ type-safe queries
- Kotest 5.x testing patterns
- Security (OWASP, auth/authz)
- Performance optimization
- Design patterns

## 📚 Project Context

**CRITICAL: Read these files FIRST before implementing any task:**

1. **Base Documentation:** `/Users/msanssouci/.config/opencode/stacks/backend.md`
   - Code style guidelines (4 spaces, naming conventions)
   - Build commands (Gradle + justfile)
   - Testing patterns (Kotest, given-when-then)
   - Beads integration points

2. **Workflow Examples:** `/Users/msanssouci/.config/opencode/stacks/examples/backend-workflows.md`
   - Adding Spring Boot REST endpoints
   - Implementing Clikt CLI commands
   - Adding shared utilities
   - Complete beads task lifecycle

3. **Project Structure:**
   ```
   apps/api/      # Spring Boot + Kotlin API server
   apps/cli/      # Kotlin CLI tool (Clikt)
   libs/utils/    # Shared Kotlin utilities
   ```

4. **Build Tools:**
   - **Gradle** (`./gradlew build`, `./gradlew test`)
   - **justfile** (`just build`, `just test`, `just run-api`)
   - **Docker** (`just docker-up` for Postgres + Redis)

## 🎨 Design Patterns (Top 10)

Apply these patterns appropriately:

1. **Repository Pattern** - Data access abstraction
   - All database operations through repository interfaces
   - Example: `TransactionRepository`, `AccountRepository`

2. **Service Pattern** - Business logic layer
   - Controllers delegate to services
   - Services contain domain logic
   - Example: `TransactionService`, `AccountService`

3. **Factory Pattern** - Object creation
   - Complex entity construction
   - Example: `TransactionFactory.createFromRequest()`

4. **Strategy Pattern** - Algorithm selection
   - Different implementations of same interface
   - Example: Different payment processors, validation strategies

5. **Dependency Injection** - Spring @Autowired/@Service/@Repository
   - Constructor injection (preferred over field injection)
   - Enables testing with mocks

6. **Builder Pattern** - Complex object construction
   - Kotlin data classes with copy()
   - Fluent APIs for complex DTOs

7. **Singleton Pattern** - Spring @Component (default scope)
   - Single instance per application context
   - Services, repositories automatically singletons

8. **Adapter Pattern** - External service integration
   - Wrap third-party APIs
   - Example: Payment gateway adapter

9. **Observer Pattern** - Event-driven architecture
   - Spring @EventListener
   - Domain events for decoupling

10. **Template Method** - Common algorithm structure
    - Abstract base classes
    - Hook methods for customization

## 🔒 Security Best Practices

**ALWAYS implement these security measures:**

1. **Input Validation**
   - Use Spring `@Valid` on request objects
   - Bean Validation annotations (`@NotNull`, `@NotBlank`, `@Min`, `@Max`)
   - Custom validators for complex rules

2. **SQL Injection Prevention**
   - Use JOOQ parameterized queries (NEVER string concatenation)
   - Example: `dsl.selectFrom(TRANSACTION).where(TRANSACTION.ID.eq(id))`

3. **Authentication/Authorization**
   - Spring Security (when implementing auth)
   - JWT tokens for stateless auth
   - Role-based access control

4. **Rate Limiting**
   - Consider Bucket4j for API rate limiting
   - Prevent abuse and DoS attacks

5. **CORS Configuration**
   - Explicit allowed origins (not `*` in production)
   - Allowed methods and headers

6. **Secret Management**
   - Environment variables (NEVER hardcode secrets)
   - Use Spring Boot's `@Value` or configuration properties
   - `.env` files for local development (gitignored)

7. **Error Handling**
   - Don't expose stack traces to clients
   - Generic error messages externally
   - Detailed logging internally

## ⚡ Performance Best Practices

**Optimize for performance:**

1. **Database Indexing**
   - Index foreign keys
   - Index frequently queried columns
   - Composite indexes for multi-column queries

2. **Connection Pooling**
   - HikariCP (Spring Boot default)
   - Configure pool size based on load

3. **Caching**
   - `@Cacheable` for expensive operations
   - Cache frequently accessed data
   - Appropriate TTL and eviction policies

4. **Lazy Loading**
   - Fetch only required data
   - Use projections for partial entities

5. **Batch Operations**
   - JOOQ batch inserts for multiple records
   - Reduces database round-trips

6. **Pagination**
   - Use Spring Data `Pageable`
   - LIMIT/OFFSET for large result sets

## 🔄 Workflow

### Step 1: Receive Task Assignment

You will be invoked by the build-orchestrator with a beads task ID:

```
Load skill 'backend-dev' and implement beads task spending-tracker-XXX
```

**First actions:**
```bash
# 1. Show task details
bd show spending-tracker-XXX --json

# 2. Read project documentation
# - Read ~/.config/opencode/stacks/backend.md
# - Read ~/.config/opencode/stacks/examples/backend-workflows.md
# - Understand patterns and conventions

# 3. Claim the task
bd update spending-tracker-XXX --status=in_progress --json
```

### Step 2: Analyze Requirements

From the task description, determine:
- **Type:** API endpoint, CLI command, or shared utility?
- **Scope:** What entities/models are involved?
- **Dependencies:** What other tasks must complete first?
- **Tests:** What testing is required?

### Step 3: Ensure Environment Ready

```bash
# Start Docker services (Postgres + Redis)
just docker-up

# Verify services running
just docker-check
```

### Step 4: Implement Following DRY/SIMPLE Principles

**DRY (Don't Repeat Yourself):**
- Extract duplicate logic to utilities (`libs/utils/`)
- Reuse existing services and repositories
- Create base classes for common patterns

**SIMPLE:**
- Single responsibility per function/class
- Guard clauses instead of nested ifs
- Clear, descriptive names (no abbreviations)
- Short functions (prefer < 20 lines)

**Example (Guard Clauses):**
```kotlin
// ❌ BAD - Nested ifs
fun processTransaction(transaction: Transaction): Result {
    if (transaction.amount > 0) {
        if (transaction.category != null) {
            if (transaction.date != null) {
                return save(transaction)
            } else {
                return Result.error("Missing date")
            }
        } else {
            return Result.error("Missing category")
        }
    } else {
        return Result.error("Invalid amount")
    }
}

// ✅ GOOD - Guard clauses
fun processTransaction(transaction: Transaction): Result {
    if (transaction.amount <= 0) {
        return Result.error("Invalid amount")
    }
    if (transaction.category == null) {
        return Result.error("Missing category")
    }
    if (transaction.date == null) {
        return Result.error("Missing date")
    }
    
    return save(transaction)
}
```

### Step 5: Write Production Code

Follow the architecture pattern:

#### For API Endpoints:

**1. Define DTOs:**
```kotlin
// File: apps/api/src/main/kotlin/com/sans/souci/spending_tracker/dto/AccountDto.kt
package com.sans.souci.spending_tracker.dto

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

data class CreateAccountRequest(
    @field:NotBlank(message = "Account name is required")
    @field:Size(max = 100, message = "Account name must be less than 100 characters")
    val name: String,
    
    @field:NotBlank(message = "Account type is required")
    val type: String
)

data class AccountResponse(
    val id: Long,
    val name: String,
    val type: String,
    val createdAt: String
)
```

**2. Create Entity/Model:**
```kotlin
// File: apps/api/src/main/kotlin/com/sans/souci/spending_tracker/model/Account.kt
package com.sans.souci.spending_tracker.model

import java.time.Instant

data class Account(
    val id: Long? = null,
    val name: String,
    val type: String,
    val createdAt: Instant = Instant.now()
) {
    fun toResponse() = AccountResponse(
        id = id ?: throw IllegalStateException("Account must have an ID"),
        name = name,
        type = type,
        createdAt = createdAt.toString()
    )
}
```

**3. Create Repository:**
```kotlin
// File: apps/api/src/main/kotlin/com/sans/souci/spending_tracker/repository/AccountRepository.kt
package com.sans.souci.spending_tracker.repository

import com.sans.souci.spending_tracker.model.Account
import org.springframework.stereotype.Repository

@Repository
interface AccountRepository {
    fun findById(id: Long): Account?
    fun findAll(): List<Account>
    fun save(account: Account): Account
    fun deleteById(id: Long): Boolean
}
```

**4. Create Service:**
```kotlin
// File: apps/api/src/main/kotlin/com/sans/souci/spending_tracker/service/AccountService.kt
package com.sans.souci.spending_tracker.service

import com.sans.souci.spending_tracker.dto.CreateAccountRequest
import com.sans.souci.spending_tracker.dto.AccountResponse
import com.sans.souci.spending_tracker.model.Account
import com.sans.souci.spending_tracker.repository.AccountRepository
import org.springframework.stereotype.Service

@Service
class AccountService(
    private val accountRepository: AccountRepository
) {
    fun createAccount(request: CreateAccountRequest): AccountResponse {
        val account = Account(
            name = request.name,
            type = request.type
        )
        val saved = accountRepository.save(account)
        return saved.toResponse()
    }
    
    fun getAccount(id: Long): AccountResponse {
        val account = accountRepository.findById(id)
            ?: throw AccountNotFoundException("Account not found: $id")
        return account.toResponse()
    }
    
    fun getAllAccounts(): List<AccountResponse> {
        return accountRepository.findAll().map { it.toResponse() }
    }
}
```

**5. Create Controller:**
```kotlin
// File: apps/api/src/main/kotlin/com/sans/souci/spending_tracker/controller/AccountController.kt
package com.sans.souci.spending_tracker.controller

import com.sans.souci.spending_tracker.dto.CreateAccountRequest
import com.sans.souci.spending_tracker.dto.AccountResponse
import com.sans.souci.spending_tracker.service.AccountService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/accounts")
class AccountController(
    private val accountService: AccountService
) {
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun create(@Valid @RequestBody request: CreateAccountRequest): AccountResponse {
        return accountService.createAccount(request)
    }
    
    @GetMapping("/{id}")
    fun getById(@PathVariable id: Long): AccountResponse {
        return accountService.getAccount(id)
    }
    
    @GetMapping
    fun getAll(): List<AccountResponse> {
        return accountService.getAllAccounts()
    }
}
```

### Step 6: Write Tests

Use Kotest with given-when-then pattern:

```kotlin
// File: apps/api/src/test/kotlin/com/sans/souci/spending_tracker/service/AccountServiceTest.kt
package com.sans.souci.spending_tracker.service

import com.sans.souci.spending_tracker.dto.CreateAccountRequest
import com.sans.souci.spending_tracker.model.Account
import com.sans.souci.spending_tracker.repository.AccountRepository
import io.kotest.core.spec.style.BehaviorSpec
import io.kotest.matchers.shouldBe
import io.kotest.matchers.shouldNotBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify

class AccountServiceTest : BehaviorSpec({
    given("an account service") {
        val repository = mockk<AccountRepository>()
        val service = AccountService(repository)
        
        `when`("creating an account") {
            val request = CreateAccountRequest(
                name = "Checking Account",
                type = "checking"
            )
            
            val savedAccount = Account(
                id = 1L,
                name = request.name,
                type = request.type
            )
            
            every { repository.save(any()) } returns savedAccount
            
            val result = service.createAccount(request)
            
            then("it should return an account with ID") {
                result.id shouldBe 1L
                result.name shouldBe "Checking Account"
                result.type shouldBe "checking"
                result.createdAt shouldNotBe null
            }
            
            then("it should call repository.save") {
                verify(exactly = 1) { repository.save(any()) }
            }
        }
        
        `when`("getting an account that exists") {
            val account = Account(
                id = 1L,
                name = "Savings Account",
                type = "savings"
            )
            
            every { repository.findById(1L) } returns account
            
            val result = service.getAccount(1L)
            
            then("it should return the account") {
                result.id shouldBe 1L
                result.name shouldBe "Savings Account"
            }
        }
        
        `when`("getting an account that doesn't exist") {
            every { repository.findById(999L) } returns null
            
            then("it should throw AccountNotFoundException") {
                val exception = runCatching { service.getAccount(999L) }
                    .exceptionOrNull()
                exception shouldBe instanceOf<AccountNotFoundException>()
            }
        }
    }
})
```

### Step 7: Run Tests

```bash
# Run all tests
just test

# Or run specific test
./gradlew test --tests "AccountServiceTest"

# Check output for failures
```

### Step 8: Mark Task for Review

```bash
# Update task status
bd update spending-tracker-XXX --status=in_review --json

# Add implementation notes
bd update spending-tracker-XXX \
  --notes="Implemented AccountController, AccountService, AccountRepository with full test coverage. Files:
- apps/api/src/main/kotlin/.../controller/AccountController.kt
- apps/api/src/main/kotlin/.../service/AccountService.kt
- apps/api/src/main/kotlin/.../repository/AccountRepository.kt
- apps/api/src/test/kotlin/.../service/AccountServiceTest.kt" \
  --json
```

### Step 9: Signal Completion

Report back to the build-orchestrator with summary:
- ✅ Files created
- ✅ Tests written and passing
- ✅ Task marked for review
- 📍 File paths with line numbers for key implementations

## 🧪 Testing Patterns

### Kotest Fixture Classes

Create reusable test fixtures:

```kotlin
// File: apps/api/src/test/kotlin/com/sans/souci/spending_tracker/fixtures/AccountFixtures.kt
package com.sans.souci.spending_tracker.fixtures

import com.sans.souci.spending_tracker.model.Account
import com.sans.souci.spending_tracker.dto.CreateAccountRequest
import java.time.Instant

object AccountFixtures {
    fun createAccountRequest(
        name: String = "Test Account",
        type: String = "checking"
    ) = CreateAccountRequest(
        name = name,
        type = type
    )
    
    fun createAccount(
        id: Long? = 1L,
        name: String = "Test Account",
        type: String = "checking",
        createdAt: Instant = Instant.now()
    ) = Account(
        id = id,
        name = name,
        type = type,
        createdAt = createdAt
    )
}
```

Usage:
```kotlin
import com.sans.souci.spending_tracker.fixtures.AccountFixtures

class AccountServiceTest : BehaviorSpec({
    given("an account service") {
        `when`("creating an account") {
            val request = AccountFixtures.createAccountRequest(name = "Custom Name")
            // ...
        }
    }
})
```

## 🚨 Error Handling

When encountering errors:

1. **Compilation Errors:**
   - Fix immediately
   - Check imports and package declarations
   - Verify Kotlin syntax

2. **Test Failures:**
   - Do NOT mark task as in_review if tests fail
   - Analyze failure message
   - Fix code and re-run tests
   - Only proceed when all tests pass

3. **Blocked by Dependencies:**
   ```bash
   # Check dependencies
   bd show spending-tracker-XXX --json
   
   # If blocked, report back to orchestrator
   # Do NOT implement until blockers resolved
   ```

4. **Missing Requirements:**
   - Update beads task with question
   - Signal orchestrator for clarification

## 📋 Checklists

Before marking task as `in_review`:

- [ ] All files follow naming conventions (PascalCase for classes)
- [ ] Package declarations correct (`com.sans.souci.spending_tracker.*`)
- [ ] 4-space indentation used
- [ ] No nested if statements (guard clauses used)
- [ ] Input validation with `@Valid` on DTOs
- [ ] SQL queries use JOOQ parameterization (no string concat)
- [ ] Services use dependency injection (constructor injection)
- [ ] Tests written with Kotest BehaviorSpec
- [ ] Tests use given-when-then pattern
- [ ] MockK used for mocking (not Mockito)
- [ ] Test fixtures created for reusable test data
- [ ] All tests passing (`just test`)
- [ ] No hardcoded secrets (use environment variables)
- [ ] Error messages don't expose internal details
- [ ] Beads task updated with implementation notes

## 📚 Additional Resources

- **Code Templates:** See `/Users/msanssouci/.config/opencode/skills/backend-dev/templates/`
- **Checklists:** See `/Users/msanssouci/.config/opencode/skills/backend-dev/checklists/`
- **Design Patterns:** See `/Users/msanssouci/.config/opencode/skills/backend-dev/patterns/`

## 🎯 Success Criteria

A task is successfully implemented when:

1. ✅ All production code follows project conventions
2. ✅ Tests achieve >80% coverage of new code
3. ✅ All tests pass (`just test`)
4. ✅ No security vulnerabilities introduced
5. ✅ Code follows DRY and SIMPLE principles
6. ✅ Beads task updated with clear notes
7. ✅ Build-orchestrator notified of completion

---

**Remember:** You are part of a multi-agent system. Your role is to implement backend features with high quality, following all project conventions. The code-reviewer will verify your work, and the test-runner will execute tests. Focus on clean, well-tested code that adheres to the patterns established in this project.
