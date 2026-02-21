# PRD Command Examples

## Simple Features

### Health Check Endpoint
```bash
/prd "Add GET /api/health endpoint that returns {status: 'ok', timestamp: ISO8601}"
```

**Expected tasks:**
- Backend: Create HealthController
- Backend: Write tests
- (2 tasks, ~5 minutes)

### Version Endpoint
```bash
/prd "Add GET /api/version endpoint returning version from build.gradle.kts"
```

**Expected tasks:**
- Backend: Create VersionController
- Backend: Extract version from Gradle
- Backend: Write tests
- (3 tasks, ~8 minutes)

---

## Medium Features

### Tags for Expenses
```bash
/prd "Users can add tags to expenses. An expense can have multiple tags. Tags have a name and color. Add CRUD endpoints for tags and update expense endpoints to support tags."
```

**Expected tasks:**
- Backend: Tag entity + migration
- Backend: Many-to-many relationship with expenses
- Backend: TagRepository, TagService, TagController
- Backend: Update ExpenseService/Controller for tags
- Backend: Tests for tags
- Frontend: Tag types
- Frontend: Tag API client
- Frontend: TagPicker component
- Frontend: Update ExpenseForm to include tags
- Frontend: Display tags in ExpenseList
- Frontend: Tests
- (15+ tasks, ~30 minutes)

### Budget Alerts
```bash
/prd "Add budget alerts: when an account's expenses exceed 80% of budget, send an email alert. Check daily via scheduled job."
```

**Expected tasks:**
- Backend: BudgetAlertService
- Backend: Scheduled job (Spring @Scheduled)
- Backend: Email service integration
- Backend: Alert threshold configuration
- Backend: Tests for alert logic
- Frontend: Alert settings UI
- Frontend: Alert history page
- (10+ tasks, ~25 minutes)

---

## Complex Features

### Budget Tracking (Full Feature)
```bash
/prd "Budget Tracking Feature:

Users can create budgets with:
- Name (required, max 100 chars)
- Category (required, one of: groceries, dining, transportation, utilities, entertainment, other)
- Amount (required, positive decimal)
- Period (required, monthly or yearly)
- Account (required, foreign key to accounts table)

Business logic:
- A user can have multiple budgets per account
- Budget names must be unique per account
- System calculates actual spending by summing expenses in the category for the current period
- Users can view budget vs actual on a dashboard

REST API:
- POST /api/accounts/:accountId/budgets - Create budget
- GET /api/accounts/:accountId/budgets - List budgets for account
- GET /api/budgets/:id - Get budget details with spending summary
- PUT /api/budgets/:id - Update budget
- DELETE /api/budgets/:id - Delete budget

Frontend:
- Budget list component (shows name, category, amount, period, progress bar)
- Budget form component (create/edit)
- Budget dashboard page at /accounts/:id/budgets
- Budget vs actual chart (bar chart)
- Color-coded progress (green < 50%, yellow 50-80%, red > 80%)

Testing:
- Unit tests for all backend services
- Integration tests for budget calculations
- E2E test: create budget → add expenses → verify dashboard shows correct amounts
"
```

**Expected tasks:**
- Backend: Budget entity + migration (~5 tasks)
- Backend: BudgetRepository, BudgetService, BudgetController (~6 tasks)
- Backend: Spending calculation logic (~2 tasks)
- Backend: Tests (~4 tasks)
- Frontend: Types, API client (~2 tasks)
- Frontend: Components (BudgetList, BudgetForm, BudgetDashboard, Chart) (~6 tasks)
- Frontend: Page (/accounts/:id/budgets) (~1 task)
- Frontend: Tests (~3 tasks)
- Testing: E2E scenarios (~2 tasks)
- **Total: ~30 tasks, ~60-90 minutes**

---

## Bug Fixes

### Cascade Delete
```bash
/prd "Fix: When an account is deleted, all associated expenses should be deleted automatically (cascade delete)"
```

**Expected tasks:**
- Backend: Add ON DELETE CASCADE to expenses FK constraint
- Backend: Create migration
- Backend: Add test to verify cascade
- (3 tasks, ~10 minutes)

### Validation Fix
```bash
/prd "Fix: Expense amount validation is inconsistent. Backend allows 0 but frontend requires > 0. Both should require amount > 0."
```

**Expected tasks:**
- Backend: Update Expense entity validation
- Backend: Update tests
- Frontend: Update validation message
- Frontend: Update tests
- (4 tasks, ~12 minutes)

---

## Refactoring

### Extract Utility
```bash
/prd "Refactor: Extract date formatting logic into a shared utility module used by both API and Web"
```

**Expected tasks:**
- Shared: Create DateUtils in libs/utils
- Backend: Replace inline formatting with DateUtils
- Frontend: Replace inline formatting with DateUtils
- Backend: Add tests for DateUtils
- Frontend: Add tests for DateUtils
- (5 tasks, ~15 minutes)

---

## Tips for Writing Good PRDs

### ✅ Do This

**Be specific about entities:**
```
"Add Task entity with: title (string, required, max 100), description (string, optional, max 500), status (enum: todo, in_progress, done), priority (int, 0-4), dueDate (LocalDate, optional)"
```

**Define relationships clearly:**
```
"A project has many tasks (one-to-many). A task belongs to one project (required foreign key)."
```

**Specify validation rules:**
```
"Title is required and must be 1-100 characters. Status defaults to 'todo'. Priority defaults to 2 (medium)."
```

**List endpoints explicitly:**
```
"REST API:
- POST /api/projects - Create project
- GET /api/projects - List all projects for current user
- GET /api/projects/:id - Get project details
- PUT /api/projects/:id - Update project
- DELETE /api/projects/:id - Delete project and all tasks"
```

**Describe UI components:**
```
"ProjectList component shows projects in a grid with name, task count, and creation date. Each card has a delete button and links to /projects/:id"
```

### ❌ Don't Do This

**Too vague:**
```
"Add project management"
"Improve the UI"
"Make it faster"
```

**Missing key details:**
```
"Add tasks" (what fields? what relationships? what endpoints?)
```

**Conflicting requirements:**
```
"Tasks should be sortable by priority and date" (which is primary? both? user choice?)
```

---

## Advanced Usage

### Incremental Features

Instead of one giant PRD, break into phases:

**Phase 1:**
```bash
/prd "Add basic Task entity with title, description, status. CRUD endpoints only."
```

**Phase 2 (after Phase 1 complete):**
```bash
/prd "Add priority and dueDate to Task entity. Update API and UI to support these fields."
```

**Phase 3:**
```bash
/prd "Add Project entity. A project has many tasks. Update task endpoints to support project filtering."
```

This approach:
- ✅ Smaller, faster iterations
- ✅ Test core functionality first
- ✅ Easier to review and adjust
- ✅ Less risk of large failures

### Combining Multiple PRDs

You can combine related features:

```bash
/prd "Multi-feature PRD:

Feature 1: Tags for expenses
- Tag entity with name and color
- Many-to-many with expenses
- CRUD endpoints
- TagPicker component

Feature 2: Expense categories
- Predefined categories (groceries, dining, etc.)
- Category icons and colors
- Update ExpenseForm with category dropdown

Feature 3: Expense filtering
- Filter expenses by tag, category, date range
- Add filter UI to ExpenseList
- Backend support for query parameters"
```

The planner will create separate task groups for each feature with proper dependencies.

---

## Troubleshooting

### "Too many tasks created"

**Problem:** PRD is too broad, creates 50+ tasks

**Solution:** Break into smaller PRDs, focus on MVP first

### "Tasks have circular dependencies"

**Problem:** Poor task breakdown with circular deps

**Solution:** Rewrite PRD to clarify order of implementation

### "Build fails after batch"

**Problem:** Code doesn't compile

**Solution:** Review the error, fix manually, then continue with `/prd resume`

### "Tests fail repeatedly"

**Problem:** Test logic is incorrect

**Solution:** Fix tests manually, mark task complete, continue

---

## Performance Expectations

| Feature Complexity | Tasks | Time (Parallel) | Time (Sequential) | Speedup |
|--------------------|-------|-----------------|-------------------|---------|
| Simple endpoint    | 2-4   | ~5-10 min       | ~10-20 min        | 2x      |
| Medium feature     | 8-15  | ~20-30 min      | ~60-90 min        | 3-4x    |
| Complex feature    | 20-30 | ~40-60 min      | ~2-3 hours        | 3-4x    |
| Bug fix            | 2-5   | ~5-15 min       | ~10-30 min        | 2x      |

**Note:** Times assume:
- Docker is running
- Dependencies are installed
- No major blockers
- 4 parallel agents per batch
