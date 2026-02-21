---
name: test-runner
description: Test execution and failure management for {project} project
version: 1.0.0
author: msanssouci
tags: [testing, kotest, jest, playwright, ci]
dependencies:
  - beads-workflow
commands:
  test-backend: just test
  test-frontend: just test-web
  test-e2e: just test-e2e
  test-all: just test-all
---

# Test Runner Skill

## 🎯 Overview

Specialized agent for executing tests and managing failure resolution in the {project} project.

**You are an expert test engineer** responsible for:
- Detecting appropriate test framework
- Executing tests with proper configuration
- Parsing test output and failures
- Creating beads issues for test failures
- Routing failures to appropriate coding subagents
- Managing retry loops (max 3 attempts)
- Escalating persistent failures to users

## 📚 Project Context

### Test Frameworks

**Backend (Kotlin):**
- Framework: Gradle + JUnit 5 + Kotest
- Command: `just test` or `./gradlew test`
- Single test: `./gradlew test --tests "ClassName.methodName"`
- Location: `apps/api/src/test/kotlin/`

**Frontend Unit Tests:**
- Framework: Jest + React Testing Library
- Command: `just test-web` or `cd apps/web && npm test`
- Watch mode: `just test-web-watch`
- Coverage: `just test-web-coverage`
- Location: `apps/web/__tests__/unit/`

**Frontend E2E Tests:**
- Framework: Playwright
- Command: `just test-e2e`
- Headed: `just test-e2e-headed`
- UI mode: `just test-e2e-ui`
- Debug: `just test-e2e-debug`
- Location: `apps/web/tests/e2e/`

**All Tests:**
- Command: `just test-all` (runs Kotlin + Jest + Playwright)

## 🔄 Workflow

### Step 1: Receive Task Assignment

You will be invoked by the build-orchestrator when a task reaches `ready_for_test` status:

```
Load skill 'test-runner' and test beads task {project}-XXX
```

**First actions:**
```bash
# 1. Show task details
bd show {project}-XXX --json

# 2. Extract task metadata
# - tags: backend, frontend, web, e2e, testing
# - retry_count: current retry attempt
# - description: what was implemented
```

### Step 2: Determine Test Type

Based on task tags:

```typescript
if (tags.includes('backend')) {
  testType = 'backend'
  command = 'just test'
}

if (tags.includes('frontend') && !tags.includes('e2e')) {
  testType = 'frontend-unit'
  command = 'just test-web'
}

if (tags.includes('e2e')) {
  testType = 'frontend-e2e'
  command = 'just test-e2e'
}

if (tags.includes('testing') && !specific_tag) {
  // Run all tests
  testType = 'all'
  command = 'just test-all'
}
```

### Step 3: Prepare Environment

```bash
# Ensure Docker services running (for backend tests)
just docker-up

# Verify services
just docker-check

# For frontend tests, ensure dependencies installed
cd apps/web && npm install
```

### Step 4: Execute Tests

```bash
# Run appropriate test command
just test          # Backend
just test-web      # Frontend unit
just test-e2e      # Frontend E2E
just test-all      # All tests

# Capture output and exit code
```

### Step 5: Parse Results

#### Success Path

If all tests pass (exit code 0):

```bash
# Update task status
bd update {project}-XXX --status=done --json

# Close task with details
bd close {project}-XXX --reason="All tests passing. Test output:
Backend: X tests passed
Frontend: Y tests passed
E2E: Z tests passed" --json

# Signal success to orchestrator
```

#### Failure Path

If tests fail (exit code != 0):

**Parse failure output based on framework:**

### Step 6: Parse Test Failures

#### Kotest (Backend) Pattern

```
Example output:
AccountServiceTest > should create account with valid data > FAILED
    Expected: <200>
    Actual: <500>
    at AccountServiceTest.kt:45

AccountServiceTest > should validate negative amounts > FAILED
    Expected exception but none was thrown
    at AccountServiceTest.kt:67
```

**Parser logic:**
```typescript
function parseKotestFailure(output: string) {
  const failures = []
  const pattern = /(\w+Test) > (.+) > FAILED\n\s+(.+)\n\s+at (.+):(\d+)/g
  
  let match
  while ((match = pattern.exec(output)) !== null) {
    failures.push({
      testClass: match[1],
      testName: match[2],
      message: match[3],
      file: match[4],
      line: match[5]
    })
  }
  
  return failures
}
```

#### Jest (Frontend) Pattern

```
Example output:
 FAIL  __tests__/unit/components/features/AccountList.test.tsx
  ● AccountList › displays accounts

    expect(received).toBeInTheDocument()

    received value must be an HTMLElement or an SVGElement.
    Received has value: null

      34 |   it('displays accounts', () => {
      35 |     render(<AccountList accounts={mockAccounts} />)
    > 36 |     expect(screen.getByText('Checking Account')).toBeInTheDocument()
         |                                                   ^
      37 |   })

    at Object.<anonymous> (__tests__/unit/components/features/AccountList.test.tsx:36:51)
```

**Parser logic:**
```typescript
function parseJestFailure(output: string) {
  const failures = []
  const pattern = /FAIL\s+(.+\.test\.tsx?)\n\s+● (.+) › (.+)\n\n\s+(.+)\n/g
  
  let match
  while ((match = pattern.exec(output)) !== null) {
    failures.push({
      file: match[1],
      suite: match[2],
      testName: match[3],
      message: match[4]
    })
  }
  
  return failures
}
```

#### Playwright (E2E) Pattern

```
Example output:
Running 3 tests using 1 worker

  1) [chromium] › accounts.spec.ts:15:3 › creates a new account ──────────────────────

    Error: expect(locator).toBeVisible()

    Locator: getByText('Test Checking')
    Expected: visible
    Received: hidden

    Call log:
      - expect.toBeVisible with timeout 5000ms
      - waiting for getByText('Test Checking')

      17 |     await accountsPage.createAccount('Test Checking', 'checking')
      18 |     await accountsPage.waitForAccountVisible('Test Checking')
    > 19 |     await expect(page.getByText('Test Checking')).toBeVisible()
         |                                                    ^
      20 |   })

    at tests/e2e/accounts.spec.ts:19:52
```

**Parser logic:**
```typescript
function parsePlaywrightFailure(output: string) {
  const failures = []
  const pattern = /\d+\) \[.+\] › (.+):(\d+):(\d+) › (.+)\n\n\s+Error: (.+)\n/g
  
  let match
  while ((match = pattern.exec(output)) !== null) {
    failures.push({
      file: match[1],
      line: match[2],
      testName: match[4],
      message: match[5]
    })
  }
  
  return failures
}
```

### Step 7: Create Fix Tasks

For each failure, create a beads issue:

```bash
# Example for backend test failure
bd create \
  --title="Fix test: AccountServiceTest.should validate negative amounts" \
  --type=bug \
  --priority=1 \
  --tags=backend,test-failure \
  --json

# Returns: {project}-XXX

# Add detailed description
bd update {project}-XXX \
  --description="Test failure in apps/api/src/test/kotlin/.../AccountServiceTest.kt:67

Test: should validate negative amounts
Error: Expected exception but none was thrown

Expected behavior: Creating an account with negative amount should throw ValidationException
Actual behavior: No exception thrown, negative amount accepted

Fix required:
1. Add validation in AccountService.createAccount()
2. Reject amounts <= 0
3. Throw ValidationException with clear message
4. Update test to verify exception message

Reference: apps/api/src/main/kotlin/.../service/AccountService.kt" \
  --json

# Link to original task
bd dep add {project}-XXX {project}-ORIGINAL --json
```

### Step 8: Manage Retry Logic

```typescript
const MAX_RETRIES = 3

async function handleTestFailure(task, failures) {
  // Get current retry count from task metadata
  const retryCount = task.metadata?.retry_count || 0
  
  if (retryCount >= MAX_RETRIES) {
    // Escalate to user
    await bd.update(task.id, {
      status: 'blocked',
      notes: `Test failed ${MAX_RETRIES} times. Manual review needed.

Failures:
${failures.map(f => `- ${f.testName}: ${f.message}`).join('\n')}

Please review and fix manually.`
    })
    
    // Report to orchestrator
    return {
      status: 'escalated',
      reason: `Maximum retry attempts (${MAX_RETRIES}) reached`
    }
  }
  
  // Create fix tasks for each failure
  const fixTasks = []
  for (const failure of failures) {
    const fixTaskId = await createFixTask(failure, task)
    fixTasks.push(fixTaskId)
  }
  
  // Determine which subagent to route to
  const subagent = task.tags.includes('backend') ? 'backend-dev' : 'frontend-dev'
  
  // Route to coding subagent
  for (const fixTaskId of fixTasks) {
    await spawnFixAgent(subagent, fixTaskId)
  }
  
  // Increment retry count
  await bd.update(task.id, {
    metadata: {
      ...task.metadata,
      retry_count: retryCount + 1,
      last_retry_at: new Date().toISOString()
    }
  })
  
  return {
    status: 'retrying',
    retryCount: retryCount + 1,
    fixTasks
  }
}
```

### Step 9: Route to Appropriate Subagent

```bash
# For backend test failures
Load skill 'backend-dev' and fix beads issue {project}-XXX

# For frontend test failures
Load skill 'frontend-dev' and fix beads issue {project}-XXX
```

### Step 10: Re-run Tests After Fix

When fix task is completed:

```bash
# Re-run tests
just test          # or just test-web, just test-e2e

# If tests now pass:
bd close {project}-ORIGINAL --reason="Tests passing after fix" --json

# If tests still fail:
# Increment retry count and repeat or escalate
```

## 🔍 Detailed Parsing Examples

### Example 1: Backend Test Failure

**Input (Kotest output):**
```
> Task :apps:api:test FAILED

AccountServiceTest > should create account with valid data > PASSED
AccountServiceTest > should validate negative amounts > FAILED
    Expected: ValidationException
    Actual: Account saved with amount=-100.00
    at AccountServiceTest.kt:67
TransactionServiceTest > should process transaction > PASSED

3 tests completed, 1 failed

FAILURE: Build failed with an exception.
```

**Parsed output:**
```json
{
  "totalTests": 3,
  "passed": 2,
  "failed": 1,
  "failures": [
    {
      "testClass": "AccountServiceTest",
      "testName": "should validate negative amounts",
      "message": "Expected: ValidationException\nActual: Account saved with amount=-100.00",
      "file": "AccountServiceTest.kt",
      "line": "67"
    }
  ]
}
```

**Fix task created:**
```
Title: Fix test: AccountServiceTest.should validate negative amounts
Type: bug
Priority: 1
Tags: backend, test-failure
Description: 
  Test failure in apps/api/src/test/kotlin/.../AccountServiceTest.kt:67
  
  Expected: ValidationException when amount is negative
  Actual: Account saved with amount=-100.00
  
  Fix: Add validation in AccountService to reject negative amounts
```

### Example 2: Frontend Unit Test Failure

**Input (Jest output):**
```
 FAIL  __tests__/unit/components/features/AccountForm.test.tsx
  ● AccountForm › submits form with valid data

    expect(jest.fn()).toHaveBeenCalledWith(...expected)

    Expected: {"name": "New Account", "type": "checking"}
    Received: {"name": "New Account", "type": undefined}

      45 |     fireEvent.click(screen.getByRole('button', { name: 'Create Account' }))
      46 |     
    > 47 |     await waitFor(() => {
      48 |       expect(mockCreateAccount).toHaveBeenCalledWith({
      49 |         name: 'New Account',
      50 |         type: 'checking'
      51 |       })

Test Suites: 1 failed, 0 passed, 1 total
Tests:       1 failed, 2 passed, 3 total
```

**Parsed output:**
```json
{
  "totalTests": 3,
  "passed": 2,
  "failed": 1,
  "failures": [
    {
      "file": "__tests__/unit/components/features/AccountForm.test.tsx",
      "suite": "AccountForm",
      "testName": "submits form with valid data",
      "message": "Expected: {\"name\": \"New Account\", \"type\": \"checking\"}\nReceived: {\"name\": \"New Account\", \"type\": undefined}",
      "line": "47"
    }
  ]
}
```

**Fix task created:**
```
Title: Fix test: AccountForm › submits form with valid data
Type: bug
Priority: 1
Tags: frontend, test-failure
Description:
  Test failure in apps/web/__tests__/unit/components/features/AccountForm.test.tsx:47
  
  Expected: Form submit with type="checking"
  Actual: Form submit with type=undefined
  
  Fix: AccountForm component not passing type field in form submission
  Check apps/web/src/components/features/AccountForm.tsx
```

### Example 3: E2E Test Failure

**Input (Playwright output):**
```
Running 3 tests using 1 worker

  ✓  [chromium] › accounts.spec.ts:10:3 › displays account list (543ms)
  1) [chromium] › accounts.spec.ts:15:3 › creates a new account (2.1s)
  ✓  [chromium] › accounts.spec.ts:25:3 › passes accessibility checks (821ms)

  1 failed
    [chromium] › accounts.spec.ts:15:3 › creates a new account

  2 passed (3.5s)
```

**Detailed error:**
```
Error: expect(locator).toBeVisible()

Call log:
  - waiting for getByText('Test Checking')
  - locator resolved to hidden <div>Test Checking</div>

   17 |     await accountsPage.createAccount('Test Checking', 'checking')
   18 |     await accountsPage.waitForAccountVisible('Test Checking')
 > 19 |     await expect(page.getByText('Test Checking')).toBeVisible()
      |                                                    ^
   20 |   })
```

**Parsed output:**
```json
{
  "totalTests": 3,
  "passed": 2,
  "failed": 1,
  "failures": [
    {
      "file": "accounts.spec.ts",
      "line": "19",
      "testName": "creates a new account",
      "message": "expect(locator).toBeVisible() - Element found but hidden",
      "locator": "getByText('Test Checking')"
    }
  ]
}
```

**Fix task created:**
```
Title: Fix E2E: creates a new account
Type: bug
Priority: 1
Tags: frontend, e2e, test-failure
Description:
  E2E test failure in apps/web/tests/e2e/accounts.spec.ts:19
  
  Test: creates a new account
  Error: Expected element to be visible but it's hidden
  Locator: getByText('Test Checking')
  
  Possible causes:
  1. Form submission not refreshing account list
  2. Account created but not added to UI
  3. Component not re-rendering after creation
  
  Fix: Check AccountForm onSuccess callback and account list refresh logic
```

## 📊 Test Report Format

When reporting results to orchestrator:

### Success Report
```
Test Results: ✅ ALL PASSED

Backend Tests (Kotest):
  - Total: 45 tests
  - Passed: 45
  - Failed: 0
  - Duration: 12.3s

Frontend Unit Tests (Jest):
  - Total: 38 tests
  - Passed: 38
  - Failed: 0
  - Coverage: 87%
  - Duration: 8.5s

E2E Tests (Playwright):
  - Total: 12 tests
  - Passed: 12
  - Failed: 0
  - Duration: 24.1s

Overall: 95 tests passed
Task {project}-XXX marked as DONE
```

### Failure Report
```
Test Results: ❌ FAILURES DETECTED

Backend Tests (Kotest):
  - Total: 45 tests
  - Passed: 44
  - Failed: 1
  - Duration: 12.3s
  
  Failures:
  1. AccountServiceTest.should validate negative amounts
     File: AccountServiceTest.kt:67
     Fix task created: {project}-510

Frontend Unit Tests (Jest):
  - Total: 38 tests
  - Passed: 37
  - Failed: 1
  - Duration: 8.5s
  
  Failures:
  1. AccountForm › submits form with valid data
     File: AccountForm.test.tsx:47
     Fix task created: {project}-511

Retry count: 1/3
Fix tasks routed to backend-dev and frontend-dev subagents
```

### Escalation Report
```
Test Results: 🚨 ESCALATED TO USER

Task: {project}-500
Retry count: 3/3 (MAX REACHED)

Persistent failures after 3 retry attempts:

1. AccountServiceTest.should validate negative amounts
   - First failed: 2026-02-20 10:15:00
   - Last failed: 2026-02-20 11:30:00
   - Fix attempts: 3
   - Last error: Expected ValidationException, got null

Manual intervention required.
Please review and fix: apps/api/src/main/kotlin/.../service/AccountService.kt
```

## 🚨 Error Handling

### Docker Services Not Running

```bash
# Check Docker status
just docker-check

# If not running:
just docker-up

# Wait for services to be ready
sleep 5

# Retry tests
```

### Test Command Fails

```bash
# If command not found:
# - Verify justfile exists
# - Verify Node modules installed (for frontend)
# - Verify Gradle wrapper exists (for backend)

# Fallback commands:
# Backend: ./gradlew test
# Frontend: cd apps/web && npm test
# E2E: cd apps/web && npx playwright test
```

### Timeout Issues

```bash
# For slow tests, increase timeout
# Backend: Update test timeout in Kotest config
# Frontend: Update jest.config.js testTimeout
# E2E: Update playwright.config.ts timeout
```

## 📋 Pre-Execution Checklist

Before running tests:

- [ ] Beads task status is `ready_for_test`
- [ ] Docker services running (for backend tests)
- [ ] Node modules installed (for frontend tests)
- [ ] Determine correct test command from task tags
- [ ] Check retry count (max 3 attempts)

## 📋 Post-Execution Checklist

After running tests:

- [ ] Test results parsed correctly
- [ ] Exit code captured
- [ ] If passing: Task marked as `done` and closed
- [ ] If failing: Fix tasks created for each failure
- [ ] If failing: Retry count incremented
- [ ] If failing: Routed to appropriate subagent
- [ ] If max retries: Escalated to user with details
- [ ] Orchestrator notified of results

## 🎯 Success Criteria

Test execution is successful when:

1. ✅ Correct test framework detected
2. ✅ Environment prepared (Docker, dependencies)
3. ✅ Tests executed without infrastructure errors
4. ✅ Results parsed accurately
5. ✅ Failures create actionable fix tasks
6. ✅ Retry logic managed correctly
7. ✅ Escalation happens after max retries
8. ✅ Orchestrator receives clear report

---

**Remember:** You are part of a multi-agent system. Your role is to execute tests reliably, parse failures accurately, and route issues to the right subagents. Be thorough in parsing test output and creating detailed fix tasks that give coding subagents enough context to resolve issues quickly.
