---
Version: 1.0.0
Last Updated: 2026-02-08
Changelog:
- 1.0.0 (2026-02-08): Initial creation - extracted from monolithic AGENTS.md
---

# Frontend Development Guide (Next.js/React/TypeScript)

## Build & Development Commands

- **Development:** `just run-web` (http://localhost:3000)
- **Build:** `just build-web` (static SPA output)
- **Test:** `just test-web` / `just test-web-watch` / `just test-web-coverage`
- **Lint:** `just lint-web`
- **E2E Tests:**
  - `just test-e2e` - Run all E2E tests (headless)
  - `just test-e2e-headed` - Run with browser visible
  - `just test-e2e-ui` - Open Playwright UI mode for debugging
  - `just test-e2e-debug` - Run with debugging enabled

---

## TypeScript Conventions

- **Indentation:** 2 spaces
- **Line length:** 100 characters maximum
- **Semicolons:** Omitted
- **Type annotations:** Always for function params & return types (public APIs)
- **Avoid `any`:** Use `unknown` with type guards

### Example
```typescript
// Good
function processUser(user: User): UserResponse {
  return { id: user.id, name: user.name }
}

// Bad - missing types
function processUser(user) {
  return { id: user.id, name: user.name }
}
```

---

## File Organization

### Naming Conventions
- **Components:** PascalCase (`UserForm.tsx`, `TransactionList.tsx`)
- **Utils/hooks:** camelCase (`useUser.ts`, `formatCurrency.ts`)
- **Tests:** `<File>.test.tsx` in `__tests__/` mirroring `src/` structure

### Directory Structure
```
apps/web/src/
├── app/                    # Next.js App Router pages
│   ├── layout.tsx         # Root layout
│   ├── page.tsx           # Home page
│   └── [feature]/         # Feature-specific pages
├── components/
│   ├── ui/                # Reusable UI components (buttons, inputs)
│   ├── layout/            # Layout components (header, footer, nav)
│   ├── features/          # Feature-specific components
│   └── shared/            # Shared cross-feature components
├── lib/
│   ├── api/               # API client code
│   ├── hooks/             # Custom React hooks
│   └── utils/             # Utility functions
└── types/                 # TypeScript type definitions
```

---

## React Best Practices

### DRY Principle
- Extract to custom hooks & utilities
- Single responsibility per component
- Reuse logic via composition

### State Management
- Keep local; lift only when sharing needed
- Use React Context for app-wide state
- Prefer server state libraries (TanStack Query) for API data

### Client/Server Components
- **Default:** Server Components (no `'use client'`)
- **Use `'use client'` only for:**
  - Hooks (useState, useEffect, custom hooks)
  - Event handlers (onClick, onChange)
  - Browser APIs (localStorage, window)
  - Third-party libraries requiring client-side rendering

---

## Testing (MANDATORY)

### Jest Unit Tests
- **ALL TypeScript code requires Jest tests**
- **Coverage targets:**
  - Utilities: 100%
  - Components: User interactions and edge cases
  - API clients: Mock responses
  - Hooks: Test with React Testing Library
- **Location:** `__tests__/unit/` mirroring source structure

### Example Component Test
```typescript
// __tests__/unit/components/features/UserProfile.test.tsx
import { render, screen } from '@testing-library/react'
import { UserProfile } from '@/components/features/UserProfile'

describe('UserProfile', () => {
  it('displays user name', () => {
    const user = { id: 1, name: 'John Doe', email: 'john@example.com' }
    render(<UserProfile user={user} />)
    expect(screen.getByText('John Doe')).toBeInTheDocument()
  })

  it('shows loading state', () => {
    render(<UserProfile user={null} isLoading />)
    expect(screen.getByText('Loading...')).toBeInTheDocument()
  })
})
```

---

## Next.js App Router

### Routing Conventions
- **Routes:** `page.tsx` in app directory
- **Layouts:** `layout.tsx` for shared UI
- **Dynamic routes:** `[param]/` folders
- **Params access:** `const { param } = await params` (Promise in Next.js 15+)

### Example Page
```typescript
// app/transactions/[id]/page.tsx
interface PageProps {
  params: Promise<{ id: string }>
}

export default async function TransactionPage({ params }: PageProps) {
  const { id } = await params
  // Fetch data server-side
  return <div>Transaction {id}</div>
}
```

---

## Dark Mode (next-themes)

### Setup
- **Provider:** `<ThemeProvider attribute="class" defaultTheme="system">`
- **Toggle:** Check `mounted` before rendering (avoid hydration mismatch)
- **Tailwind:** `dark:` prefix + `darkMode: 'selector'` config

### Example Toggle Component
```typescript
'use client'

import { useTheme } from 'next-themes'
import { useEffect, useState } from 'react'

export function ThemeToggle() {
  const [mounted, setMounted] = useState(false)
  const { theme, setTheme } = useTheme()

  useEffect(() => setMounted(true), [])
  if (!mounted) return null

  return (
    <button onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}>
      Toggle Theme
    </button>
  )
}
```

---

## API Client Pattern

### Structure
- **Base client:** `lib/api/client.ts` with `fetchApi()` function
- **Custom error:** `ApiError` class for typed error handling
- **Resource files:** Separate files per resource (`users.ts`, `transactions.ts`)
- **Always type:** Request/response payloads

### Example
```typescript
// lib/api/client.ts
export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message)
  }
}

export async function fetchApi<T>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}${endpoint}`, options)
  if (!response.ok) {
    throw new ApiError(response.status, await response.text())
  }
  return response.json()
}

// lib/api/transactions.ts
export interface Transaction {
  id: number
  amount: number
  category: string
  date: string
}

export async function getTransactions(): Promise<Transaction[]> {
  return fetchApi<Transaction[]>('/api/transactions')
}

export async function createTransaction(data: Omit<Transaction, 'id'>): Promise<Transaction> {
  return fetchApi<Transaction>('/api/transactions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  })
}
```

---

## Accessibility

### Requirements
- Semantic HTML elements (`<nav>`, `<main>`, `<button>`)
- ARIA labels for icon-only buttons
- Form label associations (`<label htmlFor="...">`)
- `aria-invalid` for error states
- Keyboard support (tab navigation, Enter/Space activation)
- Focus indicators (visible focus rings)

### Example Accessible Form
```typescript
<form>
  <label htmlFor="amount">Amount</label>
  <input
    id="amount"
    type="number"
    aria-invalid={!!errors.amount}
    aria-describedby={errors.amount ? 'amount-error' : undefined}
  />
  {errors.amount && (
    <span id="amount-error" role="alert">
      {errors.amount}
    </span>
  )}
</form>
```

---

## E2E Testing (Playwright)

### Test Location
- **Directory:** `tests/e2e/`
- **Configuration:** `playwright.config.ts` (base URL, timeouts, screenshots, traces)

### Page Object Model Pattern
- **All page objects in:** `tests/e2e/pages/`
- **Extend `BasePage`** for common functionality
- **Include:** Locators, actions, and assertions
- **Export from:** `pages/index.ts` for easy imports

### Example Page Object
```typescript
// tests/e2e/pages/TransactionsPage.ts
import { Page } from '@playwright/test'
import { BasePage } from './BasePage'

export class TransactionsPage extends BasePage {
  constructor(page: Page) {
    super(page)
  }

  async goto() {
    await this.page.goto('/transactions')
  }

  async clickAddButton() {
    await this.page.getByRole('button', { name: 'Add Transaction' }).click()
  }

  async getTransactionRows() {
    return this.page.locator('tbody tr')
  }
}
```

### Test Structure
- **Test files:** `*.spec.ts` in `tests/e2e/`
- **Group tests:** Use `test.describe()`
- **Setup:** Use `test.beforeEach()` for common setup
- **Selectors:** Prefer semantic selectors (role, label) over CSS selectors

### Best Practices
- Use `getByRole()`, `getByLabel()`, `getByText()` for resilient selectors
- Wait for elements with `toBeVisible()` instead of arbitrary timeouts
- Test user flows, not implementation details
- Include both positive and negative test cases
- Use `@axe-core/playwright` for accessibility testing

### Example E2E Test
```typescript
// tests/e2e/transactions.spec.ts
import { test, expect } from '@playwright/test'
import { TransactionsPage } from './pages/TransactionsPage'
import AxeBuilder from '@axe-core/playwright'

test.describe('Transactions Page', () => {
  test('should display transaction list', async ({ page }) => {
    const transactionsPage = new TransactionsPage(page)
    await transactionsPage.goto()

    const rows = await transactionsPage.getTransactionRows()
    expect(await rows.count()).toBeGreaterThan(0)
  })

  test('should pass accessibility checks', async ({ page }) => {
    const transactionsPage = new TransactionsPage(page)
    await transactionsPage.goto()

    const results = await new AxeBuilder({ page }).analyze()
    expect(results.violations).toEqual([])
  })
})
```

---

## Beads Integration Points

### When to Create Tasks

**Component Development:**
```bash
# Before creating component
bd create --title="Create TransactionList component" --type=task --priority=2 --json

# Before writing tests
bd create --title="Write Jest tests for TransactionList" --type=task --priority=2 --json

# Before E2E tests
bd create --title="Add E2E test for transaction list page" --type=task --priority=2 --json

# Set dependencies
bd dep add beads-yyy beads-xxx --json  # Tests depend on component
bd dep add beads-zzz beads-yyy --json  # E2E depends on unit tests
```

**API Client:**
```bash
# Before adding API method
bd create --title="Add transactions.create() API method" --type=task --priority=2 --json

# Before mocking
bd create --title="Mock transactions API in tests" --type=task --priority=2 --json
```

**Page/Route:**
```bash
# Before implementing page
bd create --title="Implement /transactions page" --type=feature --priority=2 --json

# Before loading states
bd create --title="Add loading/error states to transactions page" --type=task --priority=2 --json
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
   - Write component/page/utility code
   - Write Jest tests
   - Write E2E tests (if applicable)
   - Verify tests pass: `just test-web` and `just test-e2e`

4. **Close task with details**
   ```bash
   bd close beads-xxx --reason="Created TransactionList component with loading/empty states, full test coverage" --json
   ```

### Example Workflows

See [.agents/examples/frontend-workflows.md](.agents/examples/frontend-workflows.md) for complete examples:
- Creating a React component
- Adding an API client method
- Implementing a new page with E2E tests

---

## Agent Behavior

- Always prefer existing justfile commands for build/test/run tasks.
- If automation fails, attempt to restore a consistent state (via `just clean` or `rm -rf node_modules && npm install`).
- Code changes MUST follow the above style guidelines for naming, structure, and TypeScript conventions.
- When adding or refactoring tests, use React Testing Library patterns.
- **ALWAYS create beads task BEFORE writing code** - see [beads-workflow.md](~/.config/opencode/agents/beads-workflow.md)

---

_For universal beads workflow, see [~/.config/opencode/agents/beads-workflow.md](~/.config/opencode/agents/beads-workflow.md)_
_For session completion protocol, see [~/.config/opencode/agents/session-completion.md](~/.config/opencode/agents/session-completion.md)_
