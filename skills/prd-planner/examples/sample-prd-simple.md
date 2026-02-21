# Sample PRD: Simple Feature

## Feature: Health Check Endpoint

### Overview
Add a simple health check endpoint to verify API is running.

### Requirements
- Endpoint: GET /api/health
- Response: `{"status": "ok", "timestamp": "2026-02-20T12:00:00Z"}`
- No authentication required
- Include in API documentation

### Acceptance Criteria
- [ ] Endpoint returns 200 status code
- [ ] Response includes current timestamp
- [ ] Endpoint accessible without auth
- [ ] Integration test validates response format
