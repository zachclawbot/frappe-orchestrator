# Data Schema Reference

## Overview

This document defines all DocTypes (data structures) for Frappe Orchestrator, organized by module. Each DocType is equivalent to a database table in traditional applications.

## Core DocTypes (Shared Across Modules)

### 1. Client

**Purpose:** Core entity representing a person receiving services (patient, customer, etc.)
**Storage:** Single source of truth synced from external sources (Kipu) or created internally

```
DocType: Client
├── Core Fields
│   ├── name (Unique ID, e.g., clientId = "C123")
│   ├── client_type (Patient, Customer, User, etc.) [Select]
│   ├── status (active, discharged, pending, archived) [Select]
│   ├── admission_date [Date]
│   ├── discharge_date [Date]
│   └── notes [Text]
│
├── Personal Information
│   ├── first_name [String, required]
│   ├── last_name [String, required]
│   ├── nickname [String]
│   ├── date_of_birth [Date]
│   ├── gender (M, F, Other) [Select]
│   ├── phone [String]
│   └── email [Email]
│
├── External System
│   ├── mr_number [String, indexed] (Medical Record Number)
│   ├── kipu_id [String, indexed] (Kipu system ID)
│   ├── synced_from_kipu [Boolean]
│   ├── kipu_last_synced_at [DateTime]
│   └── external_metadata [JSON] (store additional fields)
│
└── Relationships (Child Table rows)
    ├── medical_assignments (Medical Department assignments)
    │   ├── template_id [Link to Medical Template]
    │   ├── status (active, inactive) [Select]
    │   ├── activated_at [DateTime]
    │   └── activated_by [Link to User]
    │
    └── program_assignments (Program Department assignments)
        ├── program_id [Link to Program]
        ├── status [Select]
        ├── group_assignment [String]
        └── start_date [Date]
```

**Indices:**
- `status, updatedAt` (filter active clients)
- `mr_number` (lookup by medical record number)
- `kipu_id` (prevent duplicate syncs)

### 2. Department

**Purpose:** Organizational units (Medical, Program, Finance, HR, etc.)

```
DocType: Department
├── name [String, required, unique]
├── description [Text]
├── manager [Link to User]
├── color [String] (for UI)
├── is_active [Boolean, default=true]
├── roles [Table]
│   ├── role [Link to Role]
│   └── can_read [Boolean]
│       can_write [Boolean]
│
└── settings [JSON]
    ├── approval_required [Boolean]
    ├── auto_assign [Boolean]
    └── custom_fields [Array]
```

**Roles Mapped to Department:**
- Medical Department → Medical Staff, RN, Medical Admin
- Program Department → Program Coordinator, Program Staff, Program Admin
- HR Department → HR Manager, HR Staff
- Finance Department → Finance Manager, Accountant

### 3. Role (Frappe Native)

**Purpose:** User roles with permission sets

Examples:
- Super Admin (all access)
- Medical Staff (medical data only)
- Program Coordinator (program data only)
- Supervisor (read-only across departments)
- HR Manager (HR data only)
- Finance Manager (finance data only)

---

## CRM Module DocTypes

### 1. Lead

```
DocType: Lead
├── topic [String, e.g., "Admission Inquiry"]
├── lead_name [String, required]
├── email [Email]
├── phone [String]
├── company_name [String]
├── source (Website, Referral, Cold Call, Event) [Select]
├── status (Open, Contacted, Qualified, Converted, Lost) [Select]
├── probability (0-100) [Int]
├── assigned_to [Link to User]
├── address [Link to Address]
│
└── Notes & History
    ├── notes [Text]
    ├── created_date [DateTime]
    └── last_touch [DateTime]
```

### 2. Contact

```
DocType: Contact
├── first_name [String]
├── last_name [String]
├── email [Email]
├── phone [String]
├── mobile_no [String]
├── designation [String]
├── client_link [Link to Client] (associate with patient/customer)
├── company_link [Link to Company]
│
└── Address Information
    ├── address [Link to Address]
    └── is_primary_contact [Boolean]
```

### 3. Company

```
DocType: Company
├── company_name [String, required, unique]
├── legal_name [String]
├── company_type (Healthcare Facility, Corporate, Partner) [Select]
├── country [String]
├── website [String]
├── email [Email]
├── phone [String]
│
└── Details
    ├── registration_number [String]
    ├── tax_id [String]
    └── description [Text]
```

### 4. Opportunity

```
DocType: Opportunity
├── opportunity_name [String, required]
├── opportunity_type (New Business, Cross-sell, Upsell) [Select]
├── client_link [Link to Client] (if applicable)
├── company_link [Link to Company]
├── lead_link [Link to Lead]
├── amount [Currency]
├── currency [Link to Currency]
├── status (Open, Qualified, In Progress, Closed Won, Closed Lost) [Select]
├── probability (0-100) [Int]
├── expected_close_date [Date]
├── assigned_to [Link to User]
├── owner_user [Link to User] (sales person)
│
└── Details
    ├── description [Text]
    ├── requirements [Text]
    ├── next_step [Text]
    ├── notes [Text]
    └── history [Table]
        ├── status_change [String]
        ├── changed_date [DateTime]
        └── notes [Text]
```

### 5. Communication

```
DocType: Communication (Frappe Native)
├── communication_type (Email, Phone, SMS, Meeting, Comment) [Select]
├── communication_medium (Email, Phone, SMS, WhatsApp) [Select]
├── sent_or_received (Sent, Received) [Select]
├── status (Open, Closed, Linked) [Select]
├── subject [String]
├── content [Text Editor]
├── sender [Email]
├── recipients [Table]
│   └── email [Email]
│
├── Reference (what this communication is about)
│   ├── reference_doctype [String]
│   └── reference_name [String]
│
└── Metadata
    ├── date [DateTime]
    ├── sent_on [DateTime]
    ├── read_by_recipient [DateTime]
    └── attachments [Table]
```

---

## HR Module DocTypes

### 1. Employee

```
DocType: Employee
├── employee_name [String, required]
├── employee_id [String, unique, required]
├── status (Active, Left, Suspended) [Select]
├── date_of_joining [Date]
├── date_of_leaving [Date]
├── department [Link to Department]
├── designation [Link to Employee Designation]
├── reports_to [Link to Employee]
│
├── Contact
│   ├── personal_email [Email]
│   ├── company_email [Email]
│   ├── phone_no [String]
│   ├── mobile_no [String]
│   └── address [Link to Address]
│
├── Employment
│   ├── employment_type (Full-time, Part-time, Contract, Intern) [Select]
│   ├── contract_end_date [Date]
│   └── notice_period [String]
│
└── HR Details
    ├── salary_structure [Link to Salary Structure]
    ├── salary_grade [String]
    ├── performance_rating [Float]
    └── notes [Text]
```

### 2. Department HR

```
DocType: Department
├── department_name [String, required]
├── manager [Link to Employee]
├── parent_department [Link to Department]
├── company [Link to Company]
└── is_active [Boolean]
```

### 3. Shift

```
DocType: Shift
├── shift_name [String, required]
├── start_time [Time]
├── end_time [Time]
├── working_hours [Float]
├── description [Text]
└── is_active [Boolean]
```

### 4. Attendance

```
DocType: Attendance
├── employee [Link to Employee, required]
├── attendance_date [Date, required]
├── status (Present, Absent, Half Day, Work from Home) [Select]
├── shift [Link to Shift]
├── working_hours [Float]
├── notes [Text]
└── attachment [File] (proof of absence)
```

### 5. Leave

```
DocType: Leave
├── employee [Link to Employee, required]
├── leave_type [Link to Leave Type]
├── from_date [Date, required]
├── to_date [Date, required]
├── total_days [Float]
├── status (Submitted, Approved, Rejected, Cancelled) [Select]
├── approval_history [Table]
│   ├── approver [Link to User]
│   ├── approval_date [DateTime]
│   └── status [String]
│
└── Details
    ├── reason [Text]
    ├── address_during_leave [String]
    └── contact_during_leave [String]
```

### 6. Leave Type

```
DocType: Leave Type
├── leave_type_name [String, required]
├── description [Text]
├── allocation_days [Float]
├── is_active [Boolean]
├── allow_negative_balance [Boolean]
├── is_carry_forward [Boolean]
├── carry_forward_days [Float]
└── applicable_year [String]
```

### 7. Salary Structure

```
DocType: Salary Structure
├── name [String, required]
├── designation [Link to Employee Designation]
├── company [Link to Company]
├── docstatus [Int] (0=Draft, 1=Submitted, 2=Cancelled)
│
├── Earnings [Table]
│   ├── salary_component [Link to Salary Component]
│   ├── amount [Currency]
│   └── depends_on_payment_days [Boolean]
│
├── Deductions [Table]
│   ├── salary_component [Link to Salary Component]
│   └── amount [Currency]
│
└── Details
    ├── total_earning [Currency]
    ├── total_deduction [Currency]
    └── net_pay [Currency]
```

---

## Helpdesk Module DocTypes

### 1. Issue (Ticket)

```
DocType: Issue
├── issue_title [String, required]
├── status (Open, In Progress, On Hold, Resolved, Closed, Reopened) [Select]
├── priority (Low, Medium, High, Urgent) [Select]
├── severity (Low, Medium, High, Critical) [Select]
│
├── Assignment
│   ├── assigned_to [Link to User]
│   ├── assigned_date [DateTime]
│   └── assignment_history [Table]
│       ├── assigned_to [User]
│       ├── assigned_date [DateTime]
│       └── reason [String]
│
├── Requester Information
│   ├── customer [Link to Customer/Client]
│   ├── customer_email [Email]
│   ├── customer_name [String]
│   ├── customer_phone [String]
│   └── department [Link to Department]
│
├── Issue Details
│   ├── description [Text Editor]
│   ├── issue_category [String]
│   ├── tags [Array]
│   ├── resolution_time [Duration]
│   ├── resolution_notes [Text]
│   └── root_cause [Text]
│
├── SLA & Response
│   ├── service_level_agreement [Link to SLA]
│   ├── first_response_time [DateTime]
│   ├── response_time_sla_status (Unmet, Met, Met But Breached) [Select]
│   ├── resolution_time_sla_status [Select]
│   └── sla_breach_date [DateTime]
│
└── Metadata
    ├── created_by [Link to User]
    ├── created_date [DateTime]
    ├── modified_date [DateTime]
    ├── attachments [Table]
    └── linked_issues [Table]
        └── link_issue [Link to Issue]
```

### 2. Service Level Agreement (SLA)

```
DocType: Service Level Agreement
├── name [String, required]
├── description [Text]
├── is_active [Boolean]
│
├── Response Time
│   ├── response_time [Duration, e.g., "2 hours"]
│   ├── response_time_business_hours [Boolean]
│   └── response_escalation_step [Table]
│       ├── escalation_level [Int]
│       ├── escalation_after [Duration]
│       ├── assign_to [Link to User/Team]
│       └── notify [Array of Users]
│
├── Resolution Time
│   ├── resolution_time [Duration, e.g., "24 hours"]
│   ├── resolution_time_business_hours [Boolean]
│   └── resolution_escalation_step [Table]
│
└── Applicable To
    ├── priority_levels [Array] (High, Critical, etc.)
    ├── customer_groups [Table]
    │   └── customer [Link to Customer]
    └── issue_types [Array]
```

### 3. Issue Communication

```
DocType: Issue Communication
├── issue [Link to Issue, required]
├── communication_date [DateTime]
├── from_user [Link to User]
├── message [Text Editor]
├── message_type (Internal Note, External Comment) [Select]
├── attachments [Table]
└── public [Boolean]
```

### 4. Issue Template

```
DocType: Issue Template
├── title [String, required]
├── description [Text Editor]
├── resolution_template [Text Editor]
├── issue_category [String]
├── priority [Select]
├── sla [Link to SLA]
├── tags [Array]
└── is_active [Boolean]
```

---

## Documents Module DocTypes

### 1. Document

```
DocType: Document
├── name [String, required]
├── document_type (Contract, Policy, Procedure, Report, Other) [Select]
├── status (Draft, Published, Archived) [Select]
├── document_category [String]
├── tags [Array]
│
├── Content
│   ├── description [Text]
│   ├── file [File, required]
│   ├── file_size [Int]
│   ├── file_name [String]
│   ├── mime_type [String]
│   └── file_version [String]
│
├── Metadata
│   ├── author [Link to User]
│   ├── document_owner [Link to User]
│   ├── created_date [DateTime]
│   ├── modified_date [DateTime]
│   ├── last_accessed_date [DateTime]
│   └── expiry_date [Date]
│
├── Access Control
│   ├── department [Link to Department]
│   ├── is_public [Boolean]
│   └── access_list [Table]
│       ├── user_or_role [String]
│       ├── permission (Read, Write, Delete) [Array]
│       └── granted_date [DateTime]
│
└── Versioning
    ├── parent_document [Link to Document] (if version)
    └── version_number [Int]
```

### 2. Document Folder

```
DocType: Document Folder
├── folder_name [String, required, unique]
├── description [Text]
├── parent_folder [Link to Document Folder]
├── is_active [Boolean]
└── department [Link to Department]
```

### 3. Document Template

```
DocType: Document Template
├── template_name [String, required]
├── description [Text]
├── template_category [String]
├── content [Text Editor] (HTML/markdown)
├── variables [Table]
│   ├── variable_name [String]
│   ├── description [String]
│   └── required [Boolean]
│
└── Metadata
    ├── author [Link to User]
    └── is_active [Boolean]
```

### 4. Document Audit

```
DocType: Document Audit
├── document [Link to Document]
├── action (Created, Modified, Accessed, Downloaded, Deleted) [Select]
├── performed_by [Link to User]
├── performed_date [DateTime]
├── changes [JSON]
├── ip_address [String]
└── notes [Text]
```

---

## Insights Module DocTypes

### 1. Dashboard

```
DocType: Dashboard
├── dashboard_name [String, required]
├── description [Text]
├── dashboard_type (Personal, Department, Executive, Public) [Select]
├── is_active [Boolean]
│
├── Owner & Permissions
│   ├── owner [Link to User]
│   ├── dashboard_access [Table]
│   │   ├── user_or_role [String]
│   │   └── permission (View, Edit, Delete) [Array]
│   └── is_public [Boolean]
│
├── Dashboard Items
│   ├── dashboard_item [Table]
│   │   ├── item_name [String]
│   │   ├── item_type (Metric Card, Chart, Table, KPI) [Select]
│   │   ├── data_source [Link to Report/Query]
│   │   ├── position [JSON] (x, y, width, height)
│   │   ├── refresh_interval [Int] (seconds)
│   │   └── configuration [JSON]
│   │
│   └── Filters
│       ├── filter_field [String]
│       ├── filter_operator (=, !=, <, >, in, between) [Select]
│       └── filter_value [String]
│
└── Metadata
    ├── created_date [DateTime]
    ├── modified_date [DateTime]
    └── last_viewed_date [DateTime]
```

### 2. Report

```
DocType: Report
├── report_name [String, required]
├── report_type (Report Builder, Query Report, Script Report) [Select]
├── doctype [Link to DocType] (for Report Builder)
├── description [Text]
│
├── Configuration
│   ├── columns [Table]
│   │   ├── fieldname [String]
│   │   ├── label [String]
│   │   └── fieldtype [String]
│   │
│   ├── filters [Table]
│   │   ├── fieldname [String]
│   │   ├── fieldtype [String]
│   │   └── default [String]
│   │
│   └── query [Text] (SQL for Query Report)
│
└── Metadata
    ├── created_by [Link to User]
    ├── is_public [Boolean]
    └── is_standard [Boolean]
```

### 3. Chart

```
DocType: Chart
├── chart_name [String, required]
├── chart_type (Line, Bar, Pie, Doughnut, Area, Scatter) [Select]
├── doctype [Link to DocType]
├── x_field [String]
├── y_field [String]
├── color_field [String]
├── description [Text]
│
├── Configuration
│   ├── title [String]
│   ├── format_y_values_as (Number, Currency, Percentage) [Select]
│   ├── show_legend [Boolean]
│   ├── show_labels [Boolean]
│   └── stacked [Boolean]
│
└── Metadata
    ├── created_by [Link to User]
    └── is_public [Boolean]
```

---

## Gameplan Module DocTypes

### 1. Project

```
DocType: Project
├── project_name [String, required]
├── status (Open, Completed, Cancelled, On Hold) [Select]
├── priority (Low, Medium, High, Critical) [Select]
├── description [Text Editor]
│
├── Dates
│   ├── start_date [Date]
│   ├── end_date [Date]
│   └── expected_completion_date [Date]
│
├── Assignment
│   ├── department [Link to Department]
│   ├── project_manager [Link to User]
│   ├── team_members [Table]
│   │   ├── user [Link to User]
│   │   ├── role (Team Lead, Developer, QA, Designer) [Select]
│   │   └── allocation_percentage [Int]
│   │
│   └── stakeholders [Table]
│       ├── user [Link to User]
│       └── role [String]
│
├── Resources
│   ├── budget [Currency]
│   ├── currency [Link to Currency]
│   └── estimated_effort_hours [Float]
│
└── Metadata
    ├── created_date [DateTime]
    └── created_by [Link to User]
```

### 2. Task

```
DocType: Task
├── task_name [String, required]
├── status (Open, In Progress, Completed, Cancelled, On Hold) [Select]
├── priority (Low, Medium, High, Critical) [Select]
├── task_type (Epic, User Story, Task, Bug, Feature) [Select]
│
├── Project & Hierarchy
│   ├── project [Link to Project, required]
│   ├── parent_task [Link to Task] (for task hierarchy)
│   ├── depends_on [Link to Task] (dependency for sequencing)
│   └── blocks_task [Link to Task]
│
├── Assignment
│   ├── assigned_to [Link to User]
│   ├── assigned_date [DateTime]
│   └── reviewers [Table]
│       ├── user [Link to User]
│       └── review_status (Pending, Approved, Rejected) [Select]
│
├── Dates & Duration
│   ├── start_date [Date]
│   ├── due_date [Date, required]
│   ├── actual_start_date [Date]
│   ├── actual_completion_date [Date]
│   └── estimated_effort_hours [Float]
│
├── Details
│   ├── description [Text Editor]
│   ├── acceptance_criteria [Text Editor]
│   ├── implementation_notes [Text]
│   ├── progress_percentage [Int] (0-100)
│   └── progress_notes [Text]
│
├── Tracking
│   ├── attachments [Table]
│   ├── comments [Table]
│   │   ├── comment_by [User]
│   │   ├── comment_date [DateTime]
│   │   ├── comment [Text]
│   │   └── mentions [Array] (@user mentions)
│   │
│   └── activity_log [Table]
│       ├── action [String]
│       ├── changed_by [User]
│       ├── changed_date [DateTime]
│       └── details [JSON]
│
└── Metadata
    ├── created_by [Link to User]
    ├── created_date [DateTime]
    └── modified_date [DateTime]
```

### 3. Sprint

```
DocType: Sprint
├── sprint_name [String, required]
├── status (Planning, Active, Completed, Cancelled) [Select]
├── project [Link to Project]
│
├── Dates
│   ├── start_date [Date]
│   ├── end_date [Date]
│   └── duration_days [Int]
│
├── Capacity Planning
│   ├── planned_capacity_hours [Float]
│   ├── actual_capacity_hours [Float]
│   ├── team_members [Table]
│   │   ├── user [Link to User]
│   │   ├── availability_percentage [Int]
│   │   └── capacity_hours [Float]
│   │
│   └── sprint_tasks [Table]
│       └── task [Link to Task]
│
├── Goals
│   ├── sprint_goals [Text Editor]
│   └── retrospective_notes [Text]
│
└── Metrics
    ├── total_story_points [Int]
    ├── completed_story_points [Int]
    ├── velocity [Float]
    └── burn_down_chart [JSON]
```

### 4. Milestone

```
DocType: Milestone
├── milestone_name [String, required]
├── status (Open, Achieved, Failed, Cancelled) [Select]
├── project [Link to Project]
├── description [Text]
│
├── Dates
│   ├── target_date [Date]
│   └── achieved_date [Date]
│
├── Associated Tasks
│   └── tasks [Table]
│       └── task [Link to Task]
│
└── Impact
    ├── deliverables [Text]
    └── success_criteria [Text]
```

---

## Query Patterns & Indexes

### Frequently Queried Patterns

```sql
-- Get active clients with their medical assignments
SELECT c.name, c.mr_number, ma.template_id, ma.status
FROM clients c
LEFT JOIN client_medical_assignments ma ON c.name = ma.parent
WHERE c.status = 'active' AND ma.status = 'active'
INDEX: (status, updated_at)

-- Get issues by assigned user and status
SELECT * FROM issue
WHERE assigned_to = 'user@example.com' AND status IN ('Open', 'In Progress')
INDEX: (assigned_to, status, modified_at DESC)

-- Get tasks by project and sprint
SELECT * FROM task
WHERE project = 'proj-123' AND sprint = 'sprint-456'
ORDER BY start_date ASC
INDEX: (project, sprint, start_date)

-- Get recent communications
SELECT * FROM communication
WHERE reference_doctype = 'Lead' AND reference_name = 'L123'
ORDER BY date DESC LIMIT 50
INDEX: (reference_doctype, reference_name, date DESC)
```

### Index Strategy

```javascript
// firestore.indexes.json equivalent for Frappe
[
  {
    "doctype": "Client",
    "fields": ["status", "updated_at"]
  },
  {
    "doctype": "Issue",
    "fields": ["assigned_to", "status", "modified_at"]
  },
  {
    "doctype": "Task",
    "fields": ["project", "sprint", "start_date"]
  },
  {
    "doctype": "Communication",
    "fields": ["reference_doctype", "reference_name", "date"]
  },
  {
    "doctype": "Leave",
    "fields": ["employee", "from_date", "to_date"]
  }
]
```

---

## Relationships & Referential Integrity

```
Client
├── → Medical Templates (Child Table)
├── → Program Assignments (Child Table)
├── → Tasks (1:N via task references)
├── → Documents (1:N via folder/access)
├── → Communications (1:N via reference_doctype)
└── → Leads/Opportunities (1:1 conversion path)

Project
├── → Tasks (1:N)
├── → Team Members (1:N via child table)
├── → Sprints (1:N)
├── → Milestones (1:N)
└── → Documents (1:N via tags/folder)

Issue
├── → Communications (1:N)
├── → Linked Issues (N:N)
├── → SLA (N:1)
├── → Assigned User (N:1)
└── → Documents (1:N via attachments)

Employee
├── → Department (N:1)
├── → Leaves (1:N)
├── → Attendance (1:N)
├── → Salary Structure (1:1)
└── → Tasks (1:N via assigned_to)
```

---

## Data Validation Rules

### Client DocType

```python
# Ensure admission date <= discharge date
def validate(self):
    if self.discharge_date and self.admission_date > self.discharge_date:
        frappe.throw("Discharge date must be after admission date")

# Prevent duplicate MR numbers
def before_insert(self):
    if frappe.get_value('Client', {'mr_number': self.mr_number}):
        frappe.throw(f"Client with MR# {self.mr_number} already exists")

# Mark as synced from Kipu
def after_insert(self):
    if self.synced_from_kipu:
        self.kipu_last_synced_at = frappe.utils.now()
        self.save()
```

### Issue DocType

```python
def validate(self):
    # Validate SLA compatibility
    if self.service_level_agreement:
        sla = frappe.get_doc('Service Level Agreement', self.service_level_agreement)
        if self.priority not in sla.priority_levels:
            frappe.throw(f"Selected SLA doesn't apply to {self.priority} priority")
    
    # Ensure resolution_time >= first_response_time
    if self.resolution_time and self.first_response_time:
        if self.resolution_time < self.first_response_time:
            frappe.throw("Resolution time cannot be before first response time")
```

---

**Last Updated:** February 2026
**Status:** Phase 1 - Core DocTypes Defined
**Next Phase:** Implement type validation, custom fields, and computed fields
