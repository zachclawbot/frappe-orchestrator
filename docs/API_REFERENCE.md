# API Reference

## Overview

Frappe Orchestrator exposes a comprehensive REST API for programmatic access to all modules and features. All endpoints follow REST conventions and return JSON responses.

## Authentication

### Session-Based (Web Browser)
```http
POST /api/method/frappe.client.get_list
Cookie: sid=<session-id>
```

### API Token (Programmatic Access)
```http
GET /api/method/orchestrator.crm.get_leads
Authorization: token api-key:api-secret
```

Generate token in Frappe: User → API → Create API Key/Secret

### Bearer Token (OAuth2 - Future)
```http
GET /api/method/orchestrator.crm.get_leads
Authorization: Bearer <access-token>
```

## Common Response Formats

### Success Response (200 OK)
```json
{
  "message": "Data fetched successfully",
  "data": {
    "leads": [...],
    "total": 100
  },
  "exc": ""
}
```

### List Response with Pagination
```json
{
  "data": [
    {
      "name": "L001",
      "lead_name": "John Doe",
      "email": "john@example.com",
      "status": "Open"
    }
  ],
  "keys": ["name", "lead_name", "email", "status"],
  "message": null
}
```

### Error Response
```json
{
  "message": null,
  "data": null,
  "exc": "ValidationError: Email is required",
  "_server_messages": ["[\"ValidationError\", \"Email is required\"]"]
}
```

## CRM Module Endpoints

### Leads

#### Get List of Leads
```http
GET /api/method/frappe.client.get_list?doctype=Lead&fields=["name","lead_name","email","status"]&filters=[["status","=","Open"]]&limit_page_length=20
```

**Parameters:**
- `doctype` - Document type (e.g., "Lead")
- `fields` - Array of fields to return
- `filters` - Array of filter conditions [[field, operator, value]]
- `limit_page_length` - Records per page (default: 20, max: 500)
- `limit_start` - Pagination offset (default: 0)
- `order_by` - Sort order (e.g., "name asc")

**Response:**
```json
{
  "data": [
    {
      "name": "L001",
      "lead_name": "John Doe",
      "email": "john@example.com",
      "status": "Open"
    }
  ]
}
```

#### Get Single Lead
```http
GET /api/method/frappe.client.get?doctype=Lead&name=L001
```

**Response:**
```json
{
  "data": {
    "name": "L001",
    "lead_name": "John Doe",
    "email": "john@example.com",
    "phone": "123-456-7890",
    "source": "Website",
    "status": "Open",
    "probability": 50,
    "assigned_to": "user@example.com"
  }
}
```

#### Create Lead
```http
POST /api/method/frappe.client.insert
Content-Type: application/json

{
  "doctype": "Lead",
  "lead_name": "Jane Smith",
  "email": "jane@example.com",
  "phone": "098-765-4321",
  "source": "Referral",
  "topic": "Product Inquiry"
}
```

**Response:** Returns created Lead document with `name` field

#### Update Lead
```http
PUT /api/method/frappe.client.set_value?doctype=Lead&name=L001&fieldname=status&value=Qualified
```

Or via POST:
```http
POST /api/method/frappe.client.set_value
Content-Type: application/json

{
  "doctype": "Lead",
  "name": "L001",
  "status": "Qualified",
  "probability": 75
}
```

#### Delete Lead
```http
DELETE /api/method/frappe.client.delete?doctype=Lead&name=L001
```

### Opportunities

#### Get Pipeline Summary
```http
GET /api/method/orchestrator.crm.get_pipeline_summary?user=user@example.com
```

**Response:**
```json
{
  "data": {
    "open": 5,
    "qualified": 3,
    "in_progress": 2,
    "closed_won": 8,
    "closed_lost": 1,
    "total_value": 150000
  }
}
```

#### Advance Opportunity Status
```http
POST /api/method/orchestrator.crm.advance_opportunity
Content-Type: application/json

{
  "opportunity": "O001",
  "new_status": "In Progress",
  "notes": "Client approved budget"
}
```

## HR Module Endpoints

### Employees

#### Get Employee by ID
```http
GET /api/method/frappe.client.get?doctype=Employee&name=EMP001
```

#### Check In / Check Out
```http
POST /api/method/orchestrator.hr.check_in
Content-Type: application/json

{
  "employee": "EMP001",
  "timestamp": "2025-02-19T09:00:00",
  "location": "office"
}
```

### Leave Management

#### Apply for Leave
```http
POST /api/method/orchestrator.hr.apply_leave
Content-Type: application/json

{
  "employee": "EMP001",
  "leave_type": "Annual Leave",
  "from_date": "2025-03-01",
  "to_date": "2025-03-05",
  "reason": "Family vacation"
}
```

#### Get Leave Balance
```http
GET /api/method/orchestrator.hr.get_leave_balance?employee=EMP001&leave_type=Annual%20Leave
```

**Response:**
```json
{
  "data": {
    "leave_type": "Annual Leave",
    "allocated": 20,
    "used": 5,
    "balance": 15,
    "pending": 2
  }
}
```

## Helpdesk Module Endpoints

### Tickets (Issues)

#### Create Support Ticket
```http
POST /api/method/frappe.client.insert
Content-Type: application/json

{
  "doctype": "Issue",
  "issue_title": "Cannot login to system",
  "description": "I'm getting an authorization error when trying to log in",
  "priority": "High",
  "customer": "C001",
  "customer_email": "user@example.com"
}
```

#### Get My Tickets
```http
GET /api/method/frappe.client.get_list?doctype=Issue&filters=[["customer_email","=","user@example.com"]]&order_by=modified%20desc
```

#### Update Ticket Status
```http
POST /api/method/frappe.client.set_value
Content-Type: application/json

{
  "doctype": "Issue",
  "name": "ISS001",
  "status": "In Progress",
  "assigned_to": "support@example.com"
}
```

#### Add Reply to Ticket
```http
POST /api/method/orchestrator.helpdesk.add_issue_comment
Content-Type: application/json

{
  "issue": "ISS001",
  "message": "We've identified the issue in your account. Resetting your password now.",
  "is_internal": false
}
```

#### Check SLA Status
```http
GET /api/method/orchestrator.helpdesk.get_sla_status?issue=ISS001
```

**Response:**
```json
{
  "data": {
    "issue": "ISS001",
    "sla": "Premium Support",
    "first_response_due": "2025-02-19T11:00:00",
    "resolution_due": "2025-02-20T11:00:00",
    "first_response_met": true,
    "resolution_status": "on_track"
  }
}
```

## Documents Module Endpoints

### File Management

#### Upload Document
```http
POST /api/method/upload_file
Content-Type: multipart/form-data

file: <binary-file>
folder: /Documents/Contracts
is_private: 0
```

#### Get Document Metadata
```http
GET /api/method/frappe.client.get?doctype=Document&name=DOC001
```

#### List Documents in Folder
```http
GET /api/method/frappe.client.get_list?doctype=Document&filters=[["document_folder","=","Contracts"]]
```

#### Create Document Version
```http
POST /api/method/orchestrator.docs.create_version
Content-Type: application/json

{
  "document": "DOC001",
  "version_notes": "Updated contract terms",
  "file": "file-content-or-url"
}
```

## Insights Module Endpoints

### Dashboard Data

#### Get Dashboard
```http
GET /api/method/orchestrator.insights.get_dashboard?dashboard=sales_dashboard
```

#### Refresh Metrics
```http
POST /api/method/orchestrator.insights.refresh_metrics
Content-Type: application/json

{
  "dashboard": "sales_dashboard",
  "items": ["metric_1", "metric_2"]
}
```

### Reports

#### Get Report Data
```http
GET /api/method/frappe.desk.report.run?report_name=Lead%20Analysis&filters={"status":"Open","source":"Website"}
```

#### Generate Report
```http
POST /api/method/orchestrator.insights.generate_report
Content-Type: application/json

{
  "report_name": "Monthly Sales Report",
  "format": "pdf",
  "send_mail": false
}
```

## Gameplan Module Endpoints

### Projects

#### Get Project Details
```http
GET /api/method/frappe.client.get?doctype=Project&name=PROJ001
```

#### Get Project Tasks
```http
GET /api/method/frappe.client.get_list?doctype=Task&filters=[["project","=","PROJ001"]]&order_by=start_date
```

### Tasks

#### Create Task
```http
POST /api/method/frappe.client.insert
Content-Type: application/json

{
  "doctype": "Task",
  "task_name": "Implement authentication",
  "project": "PROJ001",
  "status": "Open",
  "priority": "High",
  "assigned_to": "user@example.com",
  "due_date": "2025-03-15",
  "estimated_effort_hours": 8
}
```

#### Update Task Progress
```http
POST /api/method/frappe.client.set_value
Content-Type: application/json

{
  "doctype": "Task",
  "name": "TASK001",
  "progress_percentage": 50,
  "progress_notes": "Unit tests completed, integration testing in progress"
}
```

#### Get Sprint Burndown
```http
GET /api/method/orchestrator.gameplan.get_sprint_burndown?sprint=SPRINT001
```

**Response:**
```json
{
  "data": {
    "sprint": "SPRINT001",
    "days": ["Day 1", "Day 2", ...],
    "ideal_hours": [40, 36, 32, ...],
    "actual_hours": [40, 38, 35, ...]
  }
}
```

## Data Synchronization Endpoints

### Kipu Integration

#### Sync Clients
```http
POST /api/method/orchestrator.sync.sync_kipu_clients
Content-Type: application/json

{
  "sync_type": "incremental",
  "dry_run": false,
  "since_date": "2025-02-18"
}
```

**Response:**
```json
{
  "data": {
    "imported": 45,
    "updated": 12,
    "skipped": 3,
    "errors": [],
    "sync_duration_seconds": 45
  }
}
```

#### Get Sync History
```http
GET /api/method/orchestrator.sync.get_sync_history?limit=10
```

## Batch Operations

### Bulk Update
```http
POST /api/method/frappe.desk.bulk_assignment.set_assignment_for_many
Content-Type: application/json

{
  "doctype": "Lead",
  "name": ["L001", "L002", "L003"],
  "assigned_to": "sales@example.com"
}
```

### Bulk Delete
```http
POST /api/method/frappe.desk.delete.delete_many
Content-Type: application/json

{
  "doctype": "Lead",
  "name": ["L001", "L002", "L003"]
}
```

## Error Handling

### Common HTTP Status Codes
- `200 OK` - Success
- `201 Created` - Resource created
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - State conflict (e.g., duplicate)
- `422 Unprocessable Entity` - Validation error
- `429 Too Many Requests` - Rate limited
- `500 Internal Server Error` - Server error

### Error Response Example
```json
{
  "exc": "[\"ValidationError\", \"Lead title is required\"]",
  "_server_messages": ["[\"ValidationError\", \"Lead title is required\"]"]
}
```

## Rate Limiting

- **Default**: 100 requests per minute per user
- **Burst**: Up to 1000 requests per minute with Authentication
- **Rate limit info** in response headers:
  ```
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 95
  X-RateLimit-Reset: 1645270800
  ```

## Pagination

All list endpoints support pagination:

```http
GET /api/method/frappe.client.get_list?doctype=Lead&limit_page_length=20&limit_start=40
```

**Parameters:**
- `limit_page_length` - Records per page (default: 20, max: 500)
- `limit_start` - Starting offset (0-based)

**Response includes:**
- `data` - Array of records
- `keys` - Field names in each record

## Webhooks (Future)

Subscribe to events:

```http
POST /api/method/frappe.desk.doctype.webhook.create
Content-Type: application/json

{
  "doctype": "Lead",
  "webhook_name": "lead_created",
  "events": ["after_insert"],
  "request_url": "https://your-server.com/webhook",
  "request_method": "POST",
  "webhook_headers": [
    {"header_key": "Authorization", "header_value": "Bearer token123"}
  ]
}
```

---

**Last Updated:** February 2026  
**Frappe Version:** 14.x  
**API Version:** v1
