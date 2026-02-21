---
Version: 1.0.0
Last Updated: 2026-02-08
Changelog:
- 1.0.0 (2026-02-08): Initial examples
---

# Frontend Workflow Examples

Concrete examples combining beads task tracking with Next.js/React/TypeScript development.

---

## Example 1: Creating a React Component

### Scenario
Build `TransactionList` component to display spending transactions in a table.

### Beads Setup
```bash
# Create component task
bd create --title="Create TransactionList component" --type=task --priority=2 --json
# Returns: {project}-300

# Create test task
bd create --title="Write Jest tests for TransactionList" --type=task --priority=2 --json
# Returns: {project}-301

# Create E2E task
bd create --title="Add E2E test for transactions page" --type=task --priority=2 --json
# Returns: {project}-302

# Set dependencies
bd dep add {project}-301 {project}-300 --json  # Unit tests depend on component
bd dep add {project}-302 {project}-301 --json  # E2E depends on unit tests

# Start work
bd update {project}-300 --status=in_progress --json
```

### Implementation Steps

**1. Define TypeScript types**
```typescript
// File: apps/web/src/types/transaction.ts
export interface Transaction {
  id: number
  amount: number
  category: string
  description?: string
  date: string
  createdAt: string
}
```

**2. Create component**
```tsx
// File: apps/web/src/components/features/TransactionList.tsx
import { Transaction } from '@/types/transaction'

interface TransactionListProps {
  transactions: Transaction[]
  isLoading?: boolean
}

export function TransactionList({ transactions, isLoading }: TransactionListProps) {
  if (isLoading) {
    return <div role="status">Loading transactions...</div>
  }

  if (transactions.length === 0) {
    return <div>No transactions found</div>
  }

  return (
    <table className="w-full">
      <thead>
        <tr>
          <th>Date</th>
          <th>Category</th>
          <th>Description</th>
          <th>Amount</th>
        </tr>
      </thead>
      <tbody>
        {transactions.map((tx) => (
          <tr key={tx.id}>
            <td>{new Date(tx.date).toLocaleDateString()}</td>
            <td>{tx.category}</td>
            <td>{tx.description || '-'}</td>
            <td>${tx.amount.toFixed(2)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}
```

**3. Run dev server to verify**
```bash
just run-web
# Visit http://localhost:3000 and test component
```

### Close Component Task
```bash
bd close {project}-300 --reason="Created TransactionList component with loading/empty states in apps/web/src/components/features/TransactionList.tsx" --json
```

### Write Jest Tests
```bash
bd ready --json  # Shows {project}-301
bd update {project}-301 --status=in_progress --json
```

**4. Add unit tests**
```tsx
// File: apps/web/__tests__/unit/components/features/TransactionList.test.tsx
import { render, screen } from '@testing-library/react'
import { TransactionList } from '@/components/features/TransactionList'

describe('TransactionList', () => {
  const mockTransactions = [
    { 
      id: 1, 
      amount: 42.50, 
      category: 'food', 
      description: 'Lunch',
      date: '2026-02-08', 
      createdAt: '2026-02-08T12:00:00Z' 
    },
    { 
      id: 2, 
      amount: 15.00, 
      category: 'transport', 
      date: '2026-02-07', 
      createdAt: '2026-02-07T10:00:00Z' 
    }
  ]

  it('renders transactions table', () => {
    render(<TransactionList transactions={mockTransactions} />)
    expect(screen.getByText('food')).toBeInTheDocument()
    expect(screen.getByText('$42.50')).toBeInTheDocument()
    expect(screen.getByText('Lunch')).toBeInTheDocument()
  })

  it('shows loading state', () => {
    render(<TransactionList transactions={[]} isLoading />)
    expect(screen.getByRole('status')).toHaveTextContent('Loading transactions...')
  })

  it('shows empty state', () => {
    render(<TransactionList transactions={[]} />)
    expect(screen.getByText('No transactions found')).toBeInTheDocument()
  })

  it('handles missing descriptions', () => {
    const txWithoutDesc = [{ ...mockTransactions[0], description: undefined }]
    render(<TransactionList transactions={txWithoutDesc} />)
    expect(screen.getByText('-')).toBeInTheDocument()
  })
})
```

**5. Run tests**
```bash
just test-web
```

### Close Test Task
```bash
bd close {project}-301 --reason="Added Jest tests for TransactionList with 100% coverage in apps/web/__tests__/unit/components/features/TransactionList.test.tsx" --json
```

### Write E2E Test
```bash
bd ready --json  # Shows {project}-302
bd update {project}-302 --status=in_progress --json
```

**6. Create page object**
```typescript
// File: apps/web/tests/e2e/pages/TransactionsPage.ts
import { Page } from '@playwright/test'
import { BasePage } from './BasePage'

export class TransactionsPage extends BasePage {
  constructor(page: Page) {
    super(page)
  }

  async goto() {
    await this.page.goto('/transactions')
  }

  async getTransactionRows() {
    return this.page.locator('tbody tr')
  }

  async getTransactionByCategory(category: string) {
    return this.page.locator(`tr:has-text("${category}")`)
  }

  async waitForLoaded() {
    await this.page.waitForSelector('tbody tr', { state: 'visible' })
  }
}
```

**7. Write E2E spec**
```typescript
// File: apps/web/tests/e2e/transactions.spec.ts
import { test, expect } from '@playwright/test'
import { TransactionsPage } from './pages/TransactionsPage'
import AxeBuilder from '@axe-core/playwright'

test.describe('Transactions Page', () => {
  test('displays transaction list', async ({ page }) => {
    const transactionsPage = new TransactionsPage(page)
    await transactionsPage.goto()
    await transactionsPage.waitForLoaded()

    const rows = await transactionsPage.getTransactionRows()
    expect(await rows.count()).toBeGreaterThan(0)
  })

  test('shows transaction details', async ({ page }) => {
    const transactionsPage = new TransactionsPage(page)
    await transactionsPage.goto()

    const foodTransaction = await transactionsPage.getTransactionByCategory('food')
    await expect(foodTransaction).toBeVisible()
  })

  test('passes accessibility checks', async ({ page }) => {
    const transactionsPage = new TransactionsPage(page)
    await transactionsPage.goto()

    const results = await new AxeBuilder({ page }).analyze()
    expect(results.violations).toEqual([])
  })
})
```

**8. Run E2E tests**
```bash
just test-e2e
```

### Close E2E Task
```bash
bd close {project}-302 --reason="Added Playwright E2E tests for transactions page with page object model and accessibility checks in apps/web/tests/e2e/transactions.spec.ts" --json
```

---

## Example 2: Adding API Client Method

### Scenario
Add `transactions.create()` method to API client for creating new transactions.

### Beads Setup
```bash
# Create implementation task
bd create --title="Add transactions.create() API method" --type=task --priority=2 --json
# Returns: {project}-310

# Create test task
bd create --title="Mock transactions API in tests" --type=task --priority=2 --json
# Returns: {project}-311

# Set dependency
bd dep add {project}-311 {project}-310 --json

# Start work
bd update {project}-310 --status=in_progress --json
```

### Implementation Steps

**1. Define types**
```typescript
// File: apps/web/src/types/transaction.ts
export interface Transaction {
  id: number
  amount: number
  category: string
  description?: string
  date: string
  createdAt: string
}

export interface CreateTransactionRequest {
  amount: number
  category: string
  description?: string
  date: string
}
```

**2. Create API client method**
```typescript
// File: apps/web/src/lib/api/transactions.ts
import { fetchApi } from './client'
import { Transaction, CreateTransactionRequest } from '@/types/transaction'

export async function getTransactions(): Promise<Transaction[]> {
  return fetchApi<Transaction[]>('/api/transactions')
}

export async function createTransaction(
  data: CreateTransactionRequest
): Promise<Transaction> {
  return fetchApi<Transaction>('/api/transactions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  })
}

export async function getTransaction(id: number): Promise<Transaction> {
  return fetchApi<Transaction>(`/api/transactions/${id}`)
}
```

**3. Test manually (optional)**
```typescript
// In a test page or console
import { createTransaction } from '@/lib/api/transactions'

const newTx = await createTransaction({
  amount: 42.50,
  category: 'food',
  description: 'Lunch',
  date: '2026-02-08'
})
console.log(newTx)
```

### Close Implementation Task
```bash
bd close {project}-310 --reason="Added transactions.create() API method with typed request/response in apps/web/src/lib/api/transactions.ts" --json
```

### Write Tests
```bash
bd update {project}-311 --status=in_progress --json
```

**4. Add test with mocks**
```typescript
// File: apps/web/__tests__/unit/lib/api/transactions.test.ts
import { createTransaction, getTransactions } from '@/lib/api/transactions'
import { fetchApi } from '@/lib/api/client'

// Mock fetchApi
jest.mock('@/lib/api/client', () => ({
  fetchApi: jest.fn()
}))

const mockFetchApi = fetchApi as jest.MockedFunction<typeof fetchApi>

describe('transactions API', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  describe('getTransactions', () => {
    it('fetches all transactions', async () => {
      const mockTransactions = [
        { id: 1, amount: 42.50, category: 'food', date: '2026-02-08', createdAt: '...' }
      ]
      mockFetchApi.mockResolvedValue(mockTransactions)

      const result = await getTransactions()

      expect(mockFetchApi).toHaveBeenCalledWith('/api/transactions')
      expect(result).toEqual(mockTransactions)
    })
  })

  describe('createTransaction', () => {
    it('creates a new transaction', async () => {
      const request = {
        amount: 42.50,
        category: 'food',
        description: 'Lunch',
        date: '2026-02-08'
      }
      const mockResponse = { id: 1, ...request, createdAt: '2026-02-08T12:00:00Z' }
      mockFetchApi.mockResolvedValue(mockResponse)

      const result = await createTransaction(request)

      expect(mockFetchApi).toHaveBeenCalledWith('/api/transactions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(request)
      })
      expect(result).toEqual(mockResponse)
    })
  })
})
```

**5. Run tests**
```bash
just test-web
```

### Close Test Task
```bash
bd close {project}-311 --reason="Added Jest tests with API mocks for transactions client, 100% coverage in apps/web/__tests__/unit/lib/api/transactions.test.ts" --json
```

---

## Example 3: Implementing New Page/Route

### Scenario
Create `/transactions` page that displays the transaction list with loading/error states.

### Beads Setup
```bash
# Create page implementation task
bd create --title="Implement /transactions page" --type=feature --priority=2 --json
# Returns: {project}-320

# Create loading/error states task
bd create --title="Add loading/error states to transactions page" --type=task --priority=2 --json
# Returns: {project}-321

# Set dependency
bd dep add {project}-321 {project}-320 --json

# Start work
bd update {project}-320 --status=in_progress --json
```

### Implementation Steps

**1. Create page component**
```tsx
// File: apps/web/src/app/transactions/page.tsx
import { Suspense } from 'react'
import { TransactionList } from '@/components/features/TransactionList'
import { getTransactions } from '@/lib/api/transactions'

async function TransactionsContent() {
  const transactions = await getTransactions()
  return <TransactionList transactions={transactions} />
}

export default function TransactionsPage() {
  return (
    <main className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Transactions</h1>
      <Suspense fallback={<TransactionList transactions={[]} isLoading />}>
        <TransactionsContent />
      </Suspense>
    </main>
  )
}
```

**2. Test page manually**
```bash
just run-web
# Visit http://localhost:3000/transactions
```

### Close Page Task
```bash
bd close {project}-320 --reason="Implemented /transactions page with Suspense loading in apps/web/src/app/transactions/page.tsx" --json
```

### Add Error Handling
```bash
bd update {project}-321 --status=in_progress --json
```

**3. Create error boundary**
```tsx
// File: apps/web/src/app/transactions/error.tsx
'use client'

import { useEffect } from 'react'

export default function TransactionsError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error('Transactions page error:', error)
  }, [error])

  return (
    <div className="container mx-auto p-4">
      <h2 className="text-xl font-bold text-red-600 mb-2">
        Failed to load transactions
      </h2>
      <p className="mb-4">{error.message}</p>
      <button
        onClick={reset}
        className="px-4 py-2 bg-blue-500 text-white rounded"
      >
        Try again
      </button>
    </div>
  )
}
```

**4. Add loading component**
```tsx
// File: apps/web/src/app/transactions/loading.tsx
import { TransactionList } from '@/components/features/TransactionList'

export default function TransactionsLoading() {
  return (
    <main className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Transactions</h1>
      <TransactionList transactions={[]} isLoading />
    </main>
  )
}
```

**5. Test error state**
```typescript
// Temporarily modify getTransactions to throw error
// Verify error.tsx displays correctly
```

### Close Error Handling Task
```bash
bd close {project}-321 --reason="Added error boundary and loading state for transactions page in apps/web/src/app/transactions/error.tsx and loading.tsx" --json
```

---

_For universal beads patterns, see [~/.config/opencode/agents/beads-workflow.md](~/.config/opencode/agents/beads-workflow.md)_
_For frontend guidelines, see [.agents/frontend-agents.md](.agents/frontend-agents.md)_
