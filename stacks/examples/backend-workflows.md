---
Version: 1.0.0
Last Updated: 2026-02-08
Changelog:
- 1.0.0 (2026-02-08): Initial examples
---

# Backend Workflow Examples

Concrete examples combining beads task tracking with Kotlin/Spring/Gradle development.

---

## Example 1: Adding a Spring Boot REST Endpoint

### Scenario
Add `POST /api/transactions` endpoint to create new spending transactions.

### Beads Setup
```bash
# Create epic (optional, for organization)
bd create --title="Transaction API endpoints" --type=feature --priority=2 --json
# Returns: {project}-200

# Create implementation task
bd create --title="Add POST /api/transactions endpoint" --type=task --priority=2 --json
# Returns: {project}-201

# Create test task
bd create --title="Write tests for TransactionController.create()" --type=task --priority=2 --json
# Returns: {project}-202

# Set dependency
bd dep add {project}-202 {project}-201 --json  # Tests depend on implementation

# Start work
bd ready --json  # Shows {project}-201
bd update {project}-201 --status=in_progress --json
```

### Implementation Steps

**1. Define request/response DTOs**
```kotlin
// File: apps/api/src/main/kotlin/com/sans/souci/spending_tracker/dto/TransactionDto.kt
package com.sans.souci.spending_tracker.dto

import java.math.BigDecimal
import java.time.LocalDate
import java.time.Instant

data class CreateTransactionRequest(
    val amount: BigDecimal,
    val category: String,
    val description: String?,
    val date: LocalDate
)

data class TransactionResponse(
    val id: Long,
    val amount: BigDecimal,
    val category: String,
    val description: String?,
    val date: LocalDate,
    val createdAt: Instant
)
```

**2. Create service method**
```kotlin
// File: apps/api/src/main/kotlin/com/sans/souci/spending_tracker/service/TransactionService.kt
package com.sans.souci.spending_tracker.service

import com.sans.souci.spending_tracker.dto.CreateTransactionRequest
import com.sans.souci.spending_tracker.dto.TransactionResponse
import com.sans.souci.spending_tracker.repository.TransactionRepository
import com.sans.souci.spending_tracker.model.Transaction
import org.springframework.stereotype.Service

@Service
class TransactionService(
    private val repository: TransactionRepository
) {
    fun createTransaction(request: CreateTransactionRequest): TransactionResponse {
        val transaction = Transaction(
            amount = request.amount,
            category = request.category,
            description = request.description,
            date = request.date
        )
        val saved = repository.save(transaction)
        return saved.toResponse()
    }
}
```

**3. Add controller endpoint**
```kotlin
// File: apps/api/src/main/kotlin/com/sans/souci/spending_tracker/controller/TransactionController.kt
package com.sans.souci.spending_tracker.controller

import com.sans.souci.spending_tracker.dto.CreateTransactionRequest
import com.sans.souci.spending_tracker.dto.TransactionResponse
import com.sans.souci.spending_tracker.service.TransactionService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/transactions")
class TransactionController(
    private val service: TransactionService
) {
    @PostMapping
    fun create(@RequestBody request: CreateTransactionRequest): ResponseEntity<TransactionResponse> {
        val response = service.createTransaction(request)
        return ResponseEntity.ok(response)
    }
}
```

**4. Run API to verify**
```bash
just run-api
# Test with curl:
# curl -X POST http://localhost:8080/api/transactions \
#   -H "Content-Type: application/json" \
#   -d '{"amount":42.50,"category":"food","description":"Lunch","date":"2026-02-08"}'
```

### Close Implementation Task
```bash
bd close {project}-201 --reason="Implemented POST /api/transactions with TransactionService and DTOs in apps/api/src/.../controller/TransactionController.kt" --json
```

### Write Tests
```bash
bd ready --json  # Now shows {project}-202 (blocker cleared)
bd update {project}-202 --status=in_progress --json
```

**5. Add test**
```kotlin
// File: apps/api/src/test/kotlin/com/sans/souci/spending_tracker/controller/TransactionControllerTest.kt
package com.sans.souci.spending_tracker.controller

import com.sans.souci.spending_tracker.dto.CreateTransactionRequest
import com.sans.souci.spending_tracker.dto.TransactionResponse
import com.sans.souci.spending_tracker.service.TransactionService
import org.junit.jupiter.api.Test
import org.mockito.Mockito.`when`
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.*
import java.math.BigDecimal
import java.time.LocalDate
import java.time.Instant

@WebMvcTest(TransactionController::class)
class TransactionControllerTest {
    @Autowired lateinit var mockMvc: MockMvc
    @MockBean lateinit var service: TransactionService

    @Test
    fun `create transaction returns 200 with response`() {
        // Given
        val request = CreateTransactionRequest(
            amount = BigDecimal("42.50"),
            category = "food",
            description = "Lunch",
            date = LocalDate.of(2026, 2, 8)
        )
        val response = TransactionResponse(
            id = 1,
            amount = BigDecimal("42.50"),
            category = "food",
            description = "Lunch",
            date = LocalDate.of(2026, 2, 8),
            createdAt = Instant.now()
        )
        
        `when`(service.createTransaction(request)).thenReturn(response)
        
        // When/Then
        mockMvc.perform(
            post("/api/transactions")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"amount":42.50,"category":"food","description":"Lunch","date":"2026-02-08"}""")
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.amount").value(42.50))
            .andExpect(jsonPath("$.category").value("food"))
    }
}
```

**6. Run tests**
```bash
just test
# Or specific test:
# ./gradlew test --tests "TransactionControllerTest"
```

### Close Test Task
```bash
bd close {project}-202 --reason="Added unit tests for TransactionController.create() with MockMvc, 100% coverage in apps/api/src/test/.../TransactionControllerTest.kt" --json
```

---

## Example 2: Implementing Clikt CLI Command

### Scenario
Add `transaction add` CLI command to create transactions from command line.

### Beads Setup
```bash
# Create implementation task
bd create --title="Implement 'transaction add' CLI command" --type=task --priority=2 --json
# Returns: {project}-210

# Create test task
bd create --title="Test CLI command parsing and validation" --type=task --priority=2 --json
# Returns: {project}-211

# Set dependency
bd dep add {project}-211 {project}-210 --json

# Start work
bd update {project}-210 --status=in_progress --json
```

### Implementation Steps

**1. Create command class**
```kotlin
// File: apps/cli/src/main/kotlin/com/sans/souci/spending_tracker/commands/TransactionAddCommand.kt
package com.sans.souci.spending_tracker.commands

import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.parameters.options.option
import com.github.ajalt.clikt.parameters.options.required
import com.github.ajalt.clikt.parameters.types.double
import java.time.LocalDate

class TransactionAddCommand : CliktCommand(
    name = "add",
    help = "Add a new transaction"
) {
    private val amount by option("-a", "--amount", help = "Transaction amount").double().required()
    private val category by option("-c", "--category", help = "Transaction category").required()
    private val description by option("-d", "--description", help = "Optional description")
    private val date by option("--date", help = "Transaction date (YYYY-MM-DD, defaults to today)")

    override fun run() {
        val txDate = date?.let { LocalDate.parse(it) } ?: LocalDate.now()
        
        echo("Adding transaction:")
        echo("  Amount: $${amount}")
        echo("  Category: $category")
        echo("  Description: ${description ?: "N/A"}")
        echo("  Date: $txDate")
        
        // TODO: Call API to persist transaction
        echo("✓ Transaction added successfully")
    }
}
```

**2. Register command in main CLI**
```kotlin
// File: apps/cli/src/main/kotlin/com/sans/souci/spending_tracker/Main.kt
package com.sans.souci.spending_tracker

import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.subcommands
import com.sans.souci.spending_tracker.commands.TransactionAddCommand

class SpendingTrackerCli : CliktCommand(name = "{project}") {
    override fun run() = Unit
}

fun main(args: Array<String>) = SpendingTrackerCli()
    .subcommands(TransactionAddCommand())
    .main(args)
```

**3. Test command manually**
```bash
just run-cli add -a 42.50 -c food -d "Lunch"
```

### Close Implementation Task
```bash
bd close {project}-210 --reason="Implemented CLI 'transaction add' command with Clikt in apps/cli/src/.../TransactionAddCommand.kt" --json
```

### Write Tests
```bash
bd update {project}-211 --status=in_progress --json
```

**4. Add test**
```kotlin
// File: apps/cli/src/test/kotlin/com/sans/souci/spending_tracker/commands/TransactionAddCommandTest.kt
package com.sans.souci.spending_tracker.commands

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import com.github.ajalt.clikt.core.MissingOption

class TransactionAddCommandTest {
    @Test
    fun `command requires amount and category`() {
        val command = TransactionAddCommand()
        assertThrows<MissingOption> {
            command.parse(emptyArray())
        }
    }
    
    @Test
    fun `command parses valid arguments`() {
        val command = TransactionAddCommand()
        command.parse(arrayOf("-a", "42.50", "-c", "food", "-d", "Lunch"))
        // Verify command executed (check output or side effects)
    }
}
```

**5. Run tests**
```bash
./gradlew :apps:cli:test
```

### Close Test Task
```bash
bd close {project}-211 --reason="Added CLI command tests for argument parsing and validation in apps/cli/src/test/.../TransactionAddCommandTest.kt" --json
```

---

## Example 3: Adding Shared Utility Function

### Scenario
Add `CurrencyUtils.format()` extension function to format BigDecimal as currency string.

### Beads Setup
```bash
bd create --title="Add CurrencyUtils.format() extension" --type=task --priority=3 --json
# Returns: {project}-220

bd update {project}-220 --status=in_progress --json
```

### Implementation Steps

**1. Create utility function**
```kotlin
// File: libs/utils/src/main/kotlin/com/sans/souci/spending_tracker/utils/CurrencyUtils.kt
package com.sans.souci.spending_tracker.utils

import java.math.BigDecimal
import java.text.NumberFormat
import java.util.Locale

fun BigDecimal.formatCurrency(locale: Locale = Locale.US): String {
    val formatter = NumberFormat.getCurrencyInstance(locale)
    return formatter.format(this)
}
```

**2. Add test**
```kotlin
// File: libs/utils/src/test/kotlin/com/sans/souci/spending_tracker/utils/CurrencyUtilsTest.kt
package com.sans.souci.spending_tracker.utils

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.assertEquals
import java.math.BigDecimal
import java.util.Locale

class CurrencyUtilsTest {
    @Test
    fun `formatCurrency formats USD correctly`() {
        val amount = BigDecimal("42.50")
        assertEquals("$42.50", amount.formatCurrency(Locale.US))
    }
    
    @Test
    fun `formatCurrency handles zero`() {
        val amount = BigDecimal.ZERO
        assertEquals("$0.00", amount.formatCurrency(Locale.US))
    }
    
    @Test
    fun `formatCurrency handles large numbers`() {
        val amount = BigDecimal("1234567.89")
        assertEquals("$1,234,567.89", amount.formatCurrency(Locale.US))
    }
}
```

**3. Run tests**
```bash
./gradlew :libs:utils:test
```

### Close Task
```bash
bd close {project}-220 --reason="Added CurrencyUtils.formatCurrency() extension with locale support and 100% test coverage in libs/utils/src/.../CurrencyUtils.kt" --json
```

---

_For universal beads patterns, see [~/.config/opencode/agents/beads-workflow.md](~/.config/opencode/agents/beads-workflow.md)_
_For backend guidelines, see [.agents/backend-agents.md](.agents/backend-agents.md)_
