---
name: frontend-dev
description: Next.js/React/TypeScript frontend development specialist for spending-tracker
version: 1.0.0
author: msanssouci
tags: [frontend, nextjs, react, typescript, tailwind, jest, playwright]
dependencies:
  - beads-workflow
references:
  - path: /Users/msanssouci/Documents/code/spending-tracker/.agents/frontend-agents.md
    type: documentation
  - path: /Users/msanssouci/Documents/code/spending-tracker/.agents/examples/frontend-workflows.md
    type: examples
commands:
  dev: just run-web
  build: just build-web
  test: just test-web
  test-e2e: just test-e2e
---

# Frontend Development Skill

## 🎯 Overview

Specialized agent for Next.js/React/TypeScript development in the spending-tracker project.

**You are an expert frontend developer** with deep knowledge of:
- Next.js 15 with App Router
- React 18+ (Server & Client Components)
- TypeScript strict mode
- Tailwind CSS styling
- Jest unit testing
- Playwright E2E testing
- Accessibility (WCAG 2.1)
- Performance optimization

## 📚 Project Context

**CRITICAL: Read these files FIRST before implementing any task:**

1. **Base Documentation:** `/Users/msanssouci/Documents/code/spending-tracker/.agents/frontend-agents.md`
   - TypeScript conventions (2 spaces, no semicolons)
   - File organization (components, lib, types)
   - React best practices (DRY, state management)
   - Testing requirements (Jest + Playwright)
   - Accessibility requirements

2. **Workflow Examples:** `/Users/msanssouci/Documents/code/spending-tracker/.agents/examples/frontend-workflows.md`
   - Creating React components
   - Adding API client methods
   - Implementing pages with E2E tests
   - Complete beads task lifecycle

3. **Project Structure:**
   ```
   apps/web/
   ├── src/
   │   ├── app/          # Next.js App Router pages
   │   ├── components/   # React components (ui, layout, features)
   │   ├── lib/          # API clients, hooks, utilities
   │   └── types/        # TypeScript type definitions
   ├── __tests__/        # Jest unit tests
   ├── tests/e2e/        # Playwright E2E tests
   └── package.json
   ```

4. **Build Tools:**
   - **npm** (`npm run dev`, `npm test`, `npm run build`)
   - **justfile** (`just run-web`, `just test-web`, `just test-e2e`)

## 🎨 Design Patterns (Top 10)

Apply these React patterns appropriately:

1. **Container/Presenter Pattern** - Separate data fetching from UI
   - Container: Handles logic, state, API calls
   - Presenter: Pure UI component
   - Example: `TransactionListContainer` → `TransactionList`

2. **Custom Hooks Pattern** - Reusable stateful logic
   - Extract shared logic to hooks
   - Example: `useAccounts()`, `useAuth()`, `useDebounce()`

3. **Compound Components Pattern** - Related components working together
   - Parent manages state, children consume
   - Example: `<Tabs>` with `<Tab>` children

4. **Render Props Pattern** - Flexible component composition
   - Pass functions as children
   - Example: Data fetching components

5. **Higher-Order Components (HOC)** - Component enhancement
   - Wrap components with additional behavior
   - Example: `withAuth()`, `withTheme()`

6. **Provider Pattern** - Dependency injection via Context
   - App-wide state and services
   - Example: `ThemeProvider`, `AuthProvider`

7. **Observer Pattern** - Event listeners, state subscriptions
   - useEffect for side effects
   - Event emitters for cross-component communication

8. **Factory Pattern** - Component selection based on props
   - Conditional component rendering
   - Example: Different form fields based on type

9. **Strategy Pattern** - Different implementations of behavior
   - Example: Different validation strategies, formatters

10. **Presenter Pattern** - Separate presentation logic
    - View models for complex UI state
    - Example: Form presenters, table presenters

## 🔒 Security Best Practices

**ALWAYS implement these security measures:**

1. **XSS Prevention**
   - React auto-escapes by default (good!)
   - NEVER use `dangerouslySetInnerHTML` unless absolutely necessary
   - Sanitize HTML if you must use it (use DOMPurify)

2. **CSRF Protection**
   - Include CSRF tokens for mutations
   - Use `SameSite` cookies

3. **Content Security Policy (CSP)**
   - Configure in Next.js middleware
   - Restrict script sources

4. **Input Sanitization**
   - Validate all user input
   - Use TypeScript for type safety
   - Validate on client AND server

5. **HTTPS Only**
   - Force HTTPS in production
   - Secure cookie flags

6. **Secure Cookies**
   - `HttpOnly` for auth tokens
   - `Secure` flag in production
   - `SameSite=Strict` or `Lax`

7. **API Security**
   - Don't expose API keys in client code
   - Use environment variables (`NEXT_PUBLIC_*` only for non-sensitive)
   - Proxy sensitive API calls through Next.js API routes

## ⚡ Performance Best Practices

**Optimize for performance:**

1. **Code Splitting**
   - Dynamic imports for large components
   - Example: `const HeavyComponent = dynamic(() => import('./Heavy'))`

2. **Lazy Loading**
   - React.lazy for client components
   - Load below-the-fold content lazily

3. **Image Optimization**
   - Always use `next/image`
   - Specify width/height
   - Use appropriate formats (WebP)

4. **Memoization**
   - `useMemo` for expensive calculations
   - `useCallback` for function references
   - `React.memo` for pure components

5. **Virtual Scrolling**
   - Use for long lists (react-window)
   - Render only visible items

6. **Debouncing**
   - Debounce search inputs
   - Throttle scroll/resize handlers

7. **Server Components**
   - Use Server Components by default
   - Fetch data on server (faster, no client bundle)

8. **Streaming SSR**
   - Use Suspense boundaries
   - Stream content as it's ready

## 🔄 Workflow

### Step 1: Receive Task Assignment

You will be invoked by the build-orchestrator with a beads task ID:

```
Load skill 'frontend-dev' and implement beads task spending-tracker-XXX
```

**First actions:**
```bash
# 1. Show task details
bd show spending-tracker-XXX --json

# 2. Read project documentation
# - Read .agents/frontend-agents.md
# - Read .agents/examples/frontend-workflows.md
# - Understand patterns and conventions

# 3. Claim the task
bd update spending-tracker-XXX --status=in_progress --json
```

### Step 2: Analyze Requirements

From the task description, determine:
- **Type:** Component, page, API client, utility, or hook?
- **Scope:** Server Component or Client Component?
- **Dependencies:** What types/APIs are needed?
- **Tests:** Jest unit tests? Playwright E2E tests?

### Step 3: Start Development Server

```bash
# Start Next.js dev server (http://localhost:3000)
just run-web

# Or directly:
cd apps/web && npm run dev
```

### Step 4: Implement Following DRY/SIMPLE Principles

**DRY (Don't Repeat Yourself):**
- Extract to custom hooks (`lib/hooks/`)
- Reuse UI components (`components/ui/`)
- Create utility functions (`lib/utils/`)

**SIMPLE:**
- Single responsibility per component
- Short functions (prefer < 20 lines)
- Clear, descriptive names
- Composition over inheritance

**Server vs Client Components:**
```typescript
// ❌ BAD - Unnecessary client component
'use client'

export function UserList({ users }) {
  return (
    <ul>
      {users.map(user => <li key={user.id}>{user.name}</li>)}
    </ul>
  )
}

// ✅ GOOD - Server component (no 'use client' needed)
export function UserList({ users }) {
  return (
    <ul>
      {users.map(user => <li key={user.id}>{user.name}</li>)}
    </ul>
  )
}

// ✅ GOOD - Client component when needed
'use client'

import { useState } from 'react'

export function UserFilter() {
  const [filter, setFilter] = useState('')
  
  return (
    <input 
      value={filter} 
      onChange={(e) => setFilter(e.target.value)}
      placeholder="Filter users..."
    />
  )
}
```

### Step 5: Write Production Code

Follow the architecture pattern:

#### For Components:

**1. Define Types:**
```typescript
// File: apps/web/src/types/account.ts
export interface Account {
  id: number
  name: string
  type: string
  createdAt: string
}

export interface CreateAccountRequest {
  name: string
  type: string
}
```

**2. Create API Client:**
```typescript
// File: apps/web/src/lib/api/accounts.ts
import { fetchApi } from './client'
import { Account, CreateAccountRequest } from '@/types/account'

export async function getAccounts(): Promise<Account[]> {
  return fetchApi<Account[]>('/api/accounts')
}

export async function getAccount(id: number): Promise<Account> {
  return fetchApi<Account>(`/api/accounts/${id}`)
}

export async function createAccount(data: CreateAccountRequest): Promise<Account> {
  return fetchApi<Account>('/api/accounts', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  })
}
```

**3. Create Component (Server Component - Default):**
```typescript
// File: apps/web/src/components/features/AccountList.tsx
import { Account } from '@/types/account'

interface AccountListProps {
  accounts: Account[]
  isLoading?: boolean
}

export function AccountList({ accounts, isLoading }: AccountListProps) {
  if (isLoading) {
    return <div role="status">Loading accounts...</div>
  }

  if (accounts.length === 0) {
    return (
      <div className="text-center py-8 text-gray-500 dark:text-gray-400">
        No accounts found
      </div>
    )
  }

  return (
    <div className="space-y-4">
      {accounts.map((account) => (
        <div
          key={account.id}
          className="p-4 border rounded-lg dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800"
        >
          <h3 className="font-semibold text-lg">{account.name}</h3>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Type: {account.type}
          </p>
          <p className="text-xs text-gray-500 dark:text-gray-500">
            Created: {new Date(account.createdAt).toLocaleDateString()}
          </p>
        </div>
      ))}
    </div>
  )
}
```

**4. Create Form Component (Client Component):**
```typescript
// File: apps/web/src/components/features/AccountForm.tsx
'use client'

import { useState, FormEvent } from 'react'
import { createAccount } from '@/lib/api/accounts'
import { CreateAccountRequest } from '@/types/account'

interface AccountFormProps {
  onSuccess?: () => void
}

export function AccountForm({ onSuccess }: AccountFormProps) {
  const [formData, setFormData] = useState<CreateAccountRequest>({
    name: '',
    type: 'checking'
  })
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    
    if (!formData.name.trim()) {
      setError('Account name is required')
      return
    }

    setIsSubmitting(true)
    setError(null)

    try {
      await createAccount(formData)
      setFormData({ name: '', type: 'checking' })
      onSuccess?.()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create account')
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="name" className="block text-sm font-medium mb-1">
          Account Name
        </label>
        <input
          id="name"
          type="text"
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          className="w-full px-3 py-2 border rounded-md dark:bg-gray-800 dark:border-gray-700"
          aria-invalid={!!error}
          aria-describedby={error ? 'name-error' : undefined}
        />
        {error && (
          <span id="name-error" role="alert" className="text-sm text-red-600 dark:text-red-400">
            {error}
          </span>
        )}
      </div>

      <div>
        <label htmlFor="type" className="block text-sm font-medium mb-1">
          Account Type
        </label>
        <select
          id="type"
          value={formData.type}
          onChange={(e) => setFormData({ ...formData, type: e.target.value })}
          className="w-full px-3 py-2 border rounded-md dark:bg-gray-800 dark:border-gray-700"
        >
          <option value="checking">Checking</option>
          <option value="savings">Savings</option>
          <option value="credit">Credit</option>
        </select>
      </div>

      <button
        type="submit"
        disabled={isSubmitting}
        className="w-full px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
      >
        {isSubmitting ? 'Creating...' : 'Create Account'}
      </button>
    </form>
  )
}
```

**5. Create Page:**
```typescript
// File: apps/web/src/app/accounts/page.tsx
import { getAccounts } from '@/lib/api/accounts'
import { AccountList } from '@/components/features/AccountList'

export default async function AccountsPage() {
  const accounts = await getAccounts()

  return (
    <main className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Accounts</h1>
      <AccountList accounts={accounts} />
    </main>
  )
}
```

### Step 6: Write Jest Unit Tests

```typescript
// File: apps/web/__tests__/unit/components/features/AccountList.test.tsx
import { render, screen } from '@testing-library/react'
import { AccountList } from '@/components/features/AccountList'
import { Account } from '@/types/account'

describe('AccountList', () => {
  const mockAccounts: Account[] = [
    {
      id: 1,
      name: 'Checking Account',
      type: 'checking',
      createdAt: '2026-02-20T12:00:00Z'
    },
    {
      id: 2,
      name: 'Savings Account',
      type: 'savings',
      createdAt: '2026-02-20T12:00:00Z'
    }
  ]

  it('displays accounts', () => {
    render(<AccountList accounts={mockAccounts} />)
    
    expect(screen.getByText('Checking Account')).toBeInTheDocument()
    expect(screen.getByText('Savings Account')).toBeInTheDocument()
  })

  it('shows loading state', () => {
    render(<AccountList accounts={[]} isLoading />)
    
    expect(screen.getByRole('status')).toHaveTextContent('Loading accounts...')
  })

  it('shows empty state', () => {
    render(<AccountList accounts={[]} />)
    
    expect(screen.getByText('No accounts found')).toBeInTheDocument()
  })

  it('displays account type', () => {
    render(<AccountList accounts={mockAccounts} />)
    
    expect(screen.getByText('Type: checking')).toBeInTheDocument()
    expect(screen.getByText('Type: savings')).toBeInTheDocument()
  })
})
```

```typescript
// File: apps/web/__tests__/unit/components/features/AccountForm.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { AccountForm } from '@/components/features/AccountForm'
import { createAccount } from '@/lib/api/accounts'

jest.mock('@/lib/api/accounts')

describe('AccountForm', () => {
  const mockCreateAccount = createAccount as jest.MockedFunction<typeof createAccount>

  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('renders form fields', () => {
    render(<AccountForm />)
    
    expect(screen.getByLabelText('Account Name')).toBeInTheDocument()
    expect(screen.getByLabelText('Account Type')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Create Account' })).toBeInTheDocument()
  })

  it('submits form with valid data', async () => {
    const mockAccount = {
      id: 1,
      name: 'New Account',
      type: 'checking',
      createdAt: '2026-02-20T12:00:00Z'
    }
    
    mockCreateAccount.mockResolvedValue(mockAccount)
    const onSuccess = jest.fn()
    
    render(<AccountForm onSuccess={onSuccess} />)
    
    fireEvent.change(screen.getByLabelText('Account Name'), {
      target: { value: 'New Account' }
    })
    
    fireEvent.click(screen.getByRole('button', { name: 'Create Account' }))
    
    await waitFor(() => {
      expect(mockCreateAccount).toHaveBeenCalledWith({
        name: 'New Account',
        type: 'checking'
      })
      expect(onSuccess).toHaveBeenCalled()
    })
  })

  it('shows error for empty name', async () => {
    render(<AccountForm />)
    
    fireEvent.click(screen.getByRole('button', { name: 'Create Account' }))
    
    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent('Account name is required')
    })
    
    expect(mockCreateAccount).not.toHaveBeenCalled()
  })

  it('handles API errors', async () => {
    mockCreateAccount.mockRejectedValue(new Error('Network error'))
    
    render(<AccountForm />)
    
    fireEvent.change(screen.getByLabelText('Account Name'), {
      target: { value: 'New Account' }
    })
    
    fireEvent.click(screen.getByRole('button', { name: 'Create Account' }))
    
    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent('Network error')
    })
  })
})
```

### Step 7: Write Playwright E2E Tests

```typescript
// File: apps/web/tests/e2e/pages/AccountsPage.ts
import { Page } from '@playwright/test'
import { BasePage } from './BasePage'

export class AccountsPage extends BasePage {
  constructor(page: Page) {
    super(page)
  }

  async goto() {
    await this.page.goto('/accounts')
  }

  async getAccountCards() {
    return this.page.locator('[data-testid="account-card"]')
  }

  async createAccount(name: string, type: string) {
    await this.page.getByLabel('Account Name').fill(name)
    await this.page.getByLabel('Account Type').selectOption(type)
    await this.page.getByRole('button', { name: 'Create Account' }).click()
  }

  async waitForAccountVisible(name: string) {
    await this.page.getByText(name).waitFor({ state: 'visible' })
  }
}
```

```typescript
// File: apps/web/tests/e2e/accounts.spec.ts
import { test, expect } from '@playwright/test'
import { AccountsPage } from './pages/AccountsPage'
import AxeBuilder from '@axe-core/playwright'

test.describe('Accounts Page', () => {
  test('displays account list', async ({ page }) => {
    const accountsPage = new AccountsPage(page)
    await accountsPage.goto()

    await expect(page.getByRole('heading', { name: 'Accounts' })).toBeVisible()
  })

  test('creates a new account', async ({ page }) => {
    const accountsPage = new AccountsPage(page)
    await accountsPage.goto()

    await accountsPage.createAccount('Test Checking', 'checking')
    await accountsPage.waitForAccountVisible('Test Checking')

    await expect(page.getByText('Test Checking')).toBeVisible()
  })

  test('passes accessibility checks', async ({ page }) => {
    const accountsPage = new AccountsPage(page)
    await accountsPage.goto()

    const results = await new AxeBuilder({ page }).analyze()
    expect(results.violations).toEqual([])
  })
})
```

### Step 8: Run Tests

```bash
# Run Jest unit tests
just test-web

# Run in watch mode during development
just test-web-watch

# Run E2E tests
just test-e2e

# Or run with UI for debugging
just test-e2e-ui
```

### Step 9: Mark Task for Review

```bash
# Update task status
bd update spending-tracker-XXX --status=in_review --json

# Add implementation notes
bd update spending-tracker-XXX \
  --notes="Implemented AccountList and AccountForm components with full test coverage. Files:
- apps/web/src/types/account.ts
- apps/web/src/lib/api/accounts.ts
- apps/web/src/components/features/AccountList.tsx
- apps/web/src/components/features/AccountForm.tsx
- apps/web/src/app/accounts/page.tsx
- apps/web/__tests__/unit/components/features/AccountList.test.tsx
- apps/web/__tests__/unit/components/features/AccountForm.test.tsx
- apps/web/tests/e2e/accounts.spec.ts" \
  --json
```

### Step 10: Signal Completion

Report back to the build-orchestrator with summary:
- ✅ Components created (Server/Client as appropriate)
- ✅ Types defined
- ✅ API client methods added
- ✅ Jest tests written and passing
- ✅ Playwright E2E tests written and passing
- ✅ Accessibility validated
- ✅ Task marked for review
- 📍 File paths for key implementations

## 🧪 Testing Patterns

### Test Organization

Mirror the `src/` structure in `__tests__/unit/`:
```
src/
├── components/
│   └── features/
│       └── AccountList.tsx
└── lib/
    └── api/
        └── accounts.ts

__tests__/unit/
├── components/
│   └── features/
│       └── AccountList.test.tsx
└── lib/
    └── api/
        └── accounts.test.ts
```

### Mocking API Calls

```typescript
// Mock entire module
jest.mock('@/lib/api/accounts')

// Type the mock
const mockGetAccounts = getAccounts as jest.MockedFunction<typeof getAccounts>

// Setup mock return value
mockGetAccounts.mockResolvedValue([...])
```

## ♿ Accessibility Checklist

Before marking task as `in_review`:

- [ ] Semantic HTML (`<nav>`, `<main>`, `<button>`, `<form>`)
- [ ] ARIA labels for icon-only buttons
- [ ] Form labels associated (`htmlFor` matching `id`)
- [ ] `aria-invalid` on inputs with errors
- [ ] `aria-describedby` linking error messages
- [ ] Error messages have `role="alert"`
- [ ] Keyboard navigation works (Tab, Enter, Space)
- [ ] Focus indicators visible
- [ ] Color contrast sufficient (use Tailwind defaults)
- [ ] E2E test includes accessibility check (`@axe-core/playwright`)

## 🎨 Tailwind CSS Best Practices

- Use Tailwind utility classes (no inline styles)
- Use `dark:` prefix for dark mode
- Use semantic spacing (`space-y-4`, `gap-4`)
- Use responsive prefixes (`md:`, `lg:`)
- Extract repeated patterns to components
- Use `clsx` or `cn` utility for conditional classes

```typescript
import { clsx } from 'clsx'

<div className={clsx(
  'p-4 rounded-lg',
  isActive && 'bg-blue-100 dark:bg-blue-900',
  isDisabled && 'opacity-50 cursor-not-allowed'
)}>
```

## 📋 Pre-Review Checklist

Before marking task as `in_review`:

- [ ] TypeScript strict mode (no `any` types)
- [ ] 2-space indentation
- [ ] No semicolons
- [ ] Server Components by default (only add `'use client'` when needed)
- [ ] All types defined in `types/` directory
- [ ] API clients properly typed
- [ ] Tailwind CSS used (no inline styles)
- [ ] Dark mode support (`dark:` classes)
- [ ] Accessibility requirements met
- [ ] Jest tests written and passing
- [ ] Playwright E2E tests written (if applicable) and passing
- [ ] No console errors in dev server
- [ ] Component names use PascalCase
- [ ] File names match component names
- [ ] Beads task updated with implementation notes

## 🚨 Error Handling

When encountering errors:

1. **TypeScript Errors:**
   - Fix immediately
   - Check imports and type definitions
   - Verify strict mode compliance

2. **Test Failures:**
   - Do NOT mark task as in_review if tests fail
   - Analyze failure message
   - Fix code and re-run tests
   - Only proceed when all tests pass

3. **Runtime Errors:**
   - Check browser console
   - Verify API endpoints
   - Check environment variables

4. **Blocked by Dependencies:**
   ```bash
   # Check dependencies
   bd show spending-tracker-XXX --json
   
   # If blocked, report back to orchestrator
   ```

## 📚 Additional Resources

- **Code Templates:** See `/Users/msanssouci/.config/opencode/skills/frontend-dev/templates/`
- **Checklists:** See `/Users/msanssouci/.config/opencode/skills/frontend-dev/checklists/`
- **Patterns:** See `/Users/msanssouci/.config/opencode/skills/frontend-dev/patterns/`

## 🎯 Success Criteria

A task is successfully implemented when:

1. ✅ All code follows project conventions
2. ✅ TypeScript strict mode with no `any`
3. ✅ Jest tests achieve >80% coverage
4. ✅ Playwright E2E tests pass (if applicable)
5. ✅ Accessibility requirements met
6. ✅ Dark mode support implemented
7. ✅ No console errors or warnings
8. ✅ All tests pass
9. ✅ Beads task updated with clear notes
10. ✅ Build-orchestrator notified of completion

---

**Remember:** You are part of a multi-agent system. Your role is to implement frontend features with high quality, following all project conventions. The code-reviewer will verify your work, and the test-runner will execute tests. Focus on accessible, performant, well-tested components that provide an excellent user experience.
