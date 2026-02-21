# Sample PRD: Full-Stack Feature

## Feature: Account Management

### Overview
Users can create and manage accounts for tracking expenses. Each user can have multiple accounts (checking, savings, credit cards).

### Domain Model

**Account Entity:**
- id: Long (primary key, auto-generated)
- userId: Long (foreign key to User)
- name: String (max 100 characters, required)
- type: Enum (checking, savings, credit)
- createdAt: Instant
- updatedAt: Instant

**Relationships:**
- User has many Accounts
- Account has many Expenses (future feature)

### Backend Requirements

**REST API Endpoints:**
1. POST /api/accounts - Create new account
2. GET /api/accounts/:id - Get account by ID
3. GET /api/accounts - Get all accounts for current user
4. PUT /api/accounts/:id - Update account
5. DELETE /api/accounts/:id - Delete account

**Validation Rules:**
- Account name required, max 100 characters
- Account type must be: checking, savings, or credit
- User cannot create duplicate account names
- Cannot delete account with existing expenses

**Business Logic:**
- Set createdAt/updatedAt timestamps automatically
- Associate account with authenticated user
- Return 404 if account not found
- Return 403 if user tries to access another user's account

### Frontend Requirements

**UI Components:**
1. AccountList - Display all user accounts in a grid
2. AccountForm - Form for creating/editing accounts
3. AccountCard - Individual account display with actions

**Pages:**
- /accounts - List all accounts with create button
- /accounts/[id] - Account detail view (future)

**User Flows:**
1. User navigates to /accounts
2. User sees list of existing accounts
3. User clicks "Create Account" button
4. Form appears with name input and type dropdown
5. User fills form and submits
6. New account appears in list
7. User can edit or delete existing accounts

### Testing Requirements

**Backend Tests (Kotest):**
- AccountService CRUD operations
- Validation rules (empty name, invalid type)
- Edge cases (null values, duplicate names)
- Error handling (account not found)

**Frontend Tests (Jest):**
- AccountList renders correctly
- AccountList shows empty state
- AccountForm validates input
- AccountForm submits correctly
- AccountForm handles errors

**E2E Tests (Playwright):**
- Complete account CRUD flow
- Account creation with all types
- Account deletion confirmation
- Accessibility validation

### Acceptance Criteria

**Backend:**
- [ ] All REST endpoints implemented
- [ ] Input validation working
- [ ] Kotest tests passing (>80% coverage)
- [ ] API documented

**Frontend:**
- [ ] All components implemented
- [ ] Tailwind CSS styling
- [ ] Dark mode support
- [ ] Accessible (WCAG 2.1 AA)
- [ ] Jest tests passing
- [ ] E2E test passing

**Overall:**
- [ ] User can create accounts
- [ ] User can view their accounts
- [ ] User can edit accounts
- [ ] User can delete accounts
- [ ] Changes persist in database
- [ ] All tests passing
