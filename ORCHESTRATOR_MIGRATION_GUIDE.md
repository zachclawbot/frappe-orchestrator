# Migrating Chateau Orchestrator to Frappe - Complete Migration Guide

## Executive Summary

**Current State:** Next.js + Firebase healthcare operations platform  
**Target State:** Frappe-based ERP with same functionality + enterprise features  
**Migration Strategy:** Phased approach with parallel running during transition

---

## Why Frappe Makes Sense for Your Project

### **Perfect Feature Alignment:**

| Orchestrator Feature | Frappe Equivalent | Improvement |
|---------------------|-------------------|-------------|
| Task Management | Frappe Task/ToDo + Custom DocTypes | ✅ Built-in workflows, dependencies, subtasks |
| Knowledge Base | Frappe Web Pages + Custom KB DocTypes | ✅ Versioning, approval workflows, search |
| User/Team Management | Frappe User + Employee DocTypes | ✅ RBAC, departments, org chart |
| Workspaces (Medical/Program) | Frappe Workspaces + Custom Modules | ✅ Department-specific views, permissions |
| Dashboard | Frappe Dashboard + Chart builder | ✅ Real-time charts, customizable widgets |
| Patient Management (Kipu) | Custom Client DocType + API integration | ✅ Structured data, audit trails, workflows |
| Scheduler/Calendar | Frappe Calendar + Event DocTypes | ✅ Resource scheduling, conflicts |
| Announcements | Custom Announcement DocType | ✅ Approval, targeting, scheduling |

### **What You Gain:**

✅ **Built-in Features:**
- Document workflows (draft → approved → published)
- Version control for knowledge base articles
- Advanced permissions (field-level, role-based)
- Audit trails (who changed what, when)
- Report builder (no code needed)
- REST API (auto-generated for all data)
- Mobile-responsive UI

✅ **Enterprise Capabilities:**
- Multi-tenancy (separate data per facility if needed)
- Scheduled jobs (data sync, backups, cleanup)
- Email integration (notifications, document emails)
- File attachments (PDFs, images, linked to records)
- Print templates (reports, forms, certificates)

✅ **Developer Experience:**
- Single codebase (no separate frontend/backend)
- Less code to maintain (Frappe handles CRUD, UI, API)
- Hot reload (instant updates during development)
- Built-in testing framework

---

## Migration Architecture

### **Phase 1: Foundation (Week 1-2)**

**Goal:** Set up Frappe, create core DocTypes for foundational data

#### **Step 1.1: Install Frappe (Already Done! ✅)**
- ✅ Frappe v15 running at http://localhost:8000
- ✅ MariaDB configured
- ✅ Site: `orchestrator.local`

#### **Step 1.2: Create Core Modules**

```bash
# In WSL
cd ~/frappe-bench
bench new-app orchestrator_crm
bench new-app orchestrator_hr
bench new-app orchestrator_clinical
bench new-app orchestrator_knowledge

bench --site orchestrator.local install-app orchestrator_crm
bench --site orchestrator.local install-app orchestrator_hr
bench --site orchestrator.local install-app orchestrator_clinical
bench --site orchestrator.local install-app orchestrator_knowledge
```

#### **Step 1.3: Create User/Employee DocTypes**

**User Management (extends Frappe's built-in User):**

Create custom fields via "Customize Form":
- Job Title (Data)
- Department (Link → Department)
- Status (Select: Active, On Leave, Terminated)
- Hire Date (Date)
- Emergency Contact (Data)
- Phone (Data)

**Employee DocType:**
- Extends Frappe's Employee
- Add custom fields:
  - Kipu User ID (Data) - for sync
  - Primary Department (Link → Department)
  - Backup Department (Link → Department)
  - Certifications (Table: certification_name, expiry_date, file_attachment)

#### **Step 1.4: Department Structure**

Create DocType: **Orchestrator Department**

Fields:
- Department Name (Data)
- Department Type (Select: Medical, Program, Clinical, Administrative)
- Template Type (Select: Medical Board, Program Table, etc.)
- Manager (Link → User)
- Members (Table: user, role, primary_dept checkbox)
- Workspace Config (JSON) - store widget/layout preferences

---

### **Phase 2: Task Management (Week 2-3)**

Your current 3-tier task system maps perfectly to Frappe:

#### **2.1: Quick Checklist DocType**

```
Fields:
- Title (Data, required)
- Description (Text Editor)
- Checklist Items (Table):
  - item_text (Data)
  - completed (Check)
  - completed_by (Link → User)
  - completed_at (Datetime)
- Recurrence (Select: Daily, Weekly, None)
- Assigned To (Link → User)
- Department (Link → Orchestrator Department)
- Due Date (Date)
- Status (Select: Open, Completed)
```

**Server Script (Auto-recreate daily tasks):**

```python
# Scheduled job: runs daily at midnight
def create_daily_checklists():
    from datetime import datetime, timedelta
    
    # Get all recurring checklists
    recurring = frappe.get_all('Quick Checklist',
        filters={'recurrence': 'Daily', 'status': 'Completed'},
        fields=['name', 'title', 'description', 'assigned_to', 'department', 'checklist_items']
    )
    
    for template in recurring:
        # Create new checklist for today
        new_checklist = frappe.get_doc({
            'doctype': 'Quick Checklist',
            'title': template.title,
            'description': template.description,
            'assigned_to': template.assigned_to,
            'department': template.department,
            'due_date': datetime.now().date(),
            'status': 'Open',
            'checklist_items': [{'item_text': item.item_text} for item in template.checklist_items]
        })
        new_checklist.insert()
```

#### **2.2: Detailed Task DocType**

```
Fields:
- Title (Data, required)
- Description (Text Editor)
- Task Type (Select: Ad-hoc, Workflow Step, Detailed)
- Assigned To (Link → User)
- Department (Link → Orchestrator Department)
- Priority (Select: Low, Medium, High, Critical)
- Status (Select: Open, Assigned, In Progress, On Hold, Completed)
- Due Date (Date)
- Estimated Hours (Float)
- Actual Hours (Float)

Child Tables:
- Subtasks (Table):
  - title (Data)
  - completed (Check)
  - assigned_to (Link → User)
  - due_date (Date)

- Comments (Table):
  - comment_text (Text Editor)
  - user (Link → User)
  - timestamp (Datetime)
  - edited (Check)

- Attachments (Link to File DocType)

- Dependencies (Table):
  - depends_on_task (Link → Detailed Task)
  - dependency_type (Select: Finish-to-Start, Start-to-Start)
```

**Server Script (Validation):**

```python
def validate(doc, method):
    # Check circular dependencies
    if has_circular_dependency(doc):
        frappe.throw("Circular dependency detected!")
    
    # Auto-set status to "In Progress" when subtask completed
    if any(subtask.completed for subtask in doc.subtasks):
        doc.status = "In Progress"
```

#### **2.3: Workflow Template DocType**

```
Fields:
- Template Name (Data)
- Description (Text Editor)
- Department (Link → Orchestrator Department)
- Trigger Event (Select: Client Admission, Employee Onboarding, etc.)
- Active (Check)

Steps (Table):
- step_order (Int)
- title (Data)
- description (Text)
- assigned_role (Link → Role)
- due_days_offset (Int) - days from trigger
- task_type (Link → Detailed Task)
- conditional_logic (Code) - Python expression
```

**Server Script (Trigger workflow on event):**

```python
# When a client is admitted, create workflow tasks
def on_client_admission(client_doc):
    workflows = frappe.get_all('Workflow Template',
        filters={'trigger_event': 'Client Admission', 'active': 1}
    )
    
    for workflow in workflows:
        template = frappe.get_doc('Workflow Template', workflow.name)
        
        for step in template.steps:
            # Evaluate conditional logic
            if step.conditional_logic:
                context = {'client': client_doc}
                if not eval(step.conditional_logic, context):
                    continue
            
            # Create task
            task = frappe.get_doc({
                'doctype': 'Detailed Task',
                'title': step.title,
                'description': step.description,
                'assigned_to': get_user_by_role(step.assigned_role),
                'due_date': add_days(today(), step.due_days_offset),
                'task_type': 'Workflow Step'
            })
            task.insert()
```

---

### **Phase 3: Client/Patient Management (Week 3-4)**

#### **3.1: Client DocType (Unified Schema)**

This replaces your proposed Firebase unified schema:

```
Fields:
- Client Name (Data, required)
- Nickname (Data)
- MR Number (Data, unique) - Medical Record #
- Kipu ID (Data) - for sync
- Date of Birth (Date)
- Admission Date (Date)
- Discharge Date (Date)
- Status (Select: Active, Discharged, On Leave)
- Primary Department (Link → Orchestrator Department)
- Assigned Care Team (Table):
  - team_member (Link → User)
  - role (Select: Therapist, Case Manager, etc.)
  - primary (Check)

-- Medical Department Fields --
- Medical Templates (Table):
  - template_name (Data)
  - active (Check)
  - assigned_by (Link → User)
  - activated_date (Date)

-- Program Department Fields --
- Program Status (Select: Orientation, Active, Alumni)
- Program Start Date (Date)

-- Contact Info --
- Emergency Contact (Data)
- Emergency Phone (Data)
- Next of Kin (Data)
```

**Subcollections (using Child DocTypes):**

**Medical Notes (Child DocType):**
```
Parent: Client
Fields:
- note_date (Date)
- note_text (Text Editor)
- author (Link → User)
- note_type (Select: Progress Note, Incident Report, etc.)
```

**Program Notes (Child DocType):**
```
Parent: Client
Fields:
- note_date (Date)
- note_text (Text Editor)
- author (Link → User)
- category (Select: Onboarding, Milestone, etc.)
```

#### **3.2: Kipu Integration (Server Script)**

Create a scheduled job to sync from Kipu:

```python
# Scheduled: Every 30 minutes
def sync_kipu_clients():
    from orchestrator_clinical.kipu_client import KipuClient
    
    kipu = KipuClient()
    census = kipu.get_patient_census()
    
    for patient in census:
        # Check if client exists
        existing = frappe.db.exists('Client', {'kipu_id': patient['id']})
        
        if existing:
            # Update existing
            client = frappe.get_doc('Client', existing)
            client.update({
                'client_name': f"{patient['first_name']} {patient['last_name']}",
                'status': 'Active' if patient['admission_date'] else 'Discharged',
                'admission_date': patient['admission_date'],
                'discharge_date': patient['discharge_date']
            })
            client.save()
        else:
            # Create new
            client = frappe.get_doc({
                'doctype': 'Client',
                'client_name': f"{patient['first_name']} {patient['last_name']}",
                'kipu_id': patient['id'],
                'mr_number': patient['mr_number'],
                'admission_date': patient['admission_date'],
                'status': 'Active'
            })
            client.insert()
```

---

### **Phase 4: Knowledge Base (Week 4-5)**

#### **4.1: Knowledge Category DocType**

```
Fields:
- Category Name (Data, required)
- Description (Text Editor)
- Icon (Attach Image)
- Position (Int) - for ordering
- Parent Category (Link → Knowledge Category) - for hierarchy
- Restricted Access (Check)
- Allowed Roles (Table): role (Link → Role)
```

#### **4.2: Knowledge Article DocType**

```
Fields:
- Title (Data, required)
- Category (Link → Knowledge Category)
- Content (Text Editor)
- Status (Select: Draft, Under Review, Published, Archived)
- Author (Link → User)
- Reviewer (Link → User)
- Keywords (Table): keyword (Data)
- Attachments (File attachments)
- Version (Int) - auto-incremented
- Published Date (Date)
- Last Updated (Datetime)
- View Count (Int)
```

**Version Control:**

```python
# Server Script: Before save
def before_save(doc, method):
    if doc.is_new():
        doc.version = 1
    else:
        # Check if content changed
        old_doc = frappe.get_doc('Knowledge Article', doc.name)
        if old_doc.content != doc.content:
            # Create version snapshot
            version_doc = frappe.get_doc({
                'doctype': 'Knowledge Article Version',
                'article': doc.name,
                'version_number': doc.version,
                'content': old_doc.content,
                'modified_by': frappe.session.user,
                'modified_date': now()
            })
            version_doc.insert()
            
            # Increment version
            doc.version += 1
```

**AI Integration (GenKit → Frappe):**

```python
# Server-side API endpoint
@frappe.whitelist()
def process_document_with_ai(file_url, doc_type):
    """Process PDF/DOCX and extract structured data"""
    import requests
    from orchestrator_knowledge.ai import process_document
    
    # Download file
    response = requests.get(file_url)
    file_content = response.content
    
    # Call AI processing (integrate your GenKit flow)
    result = process_document(file_content, doc_type)
    
    # Create knowledge article
    article = frappe.get_doc({
        'doctype': 'Knowledge Article',
        'title': result['title'],
        'content': result['content'],
        'category': result['category'],
        'keywords': [{'keyword': kw} for kw in result['keywords']],
        'status': 'Draft',
        'author': frappe.session.user
    })
    article.insert()
    
    return article.name
```

---

### **Phase 5: Workspace & Dashboard (Week 5-6)**

#### **5.1: Create Custom Workspaces**

**Medical Workspace:**

```python
# Create via UI: Workspace → New
{
    "title": "Medical Department",
    "module": "Orchestrator Clinical",
    "cards": [
        {
            "type": "Quick List",
            "label": "Active Clients",
            "document_type": "Client",
            "filters": [["status", "=", "Active"], ["primary_department", "=", "Medical"]]
        },
        {
            "type": "Chart",
            "label": "Tasks by Status",
            "chart_name": "medical_tasks_chart"
        },
        {
            "type": "Shortcuts",
            "shortcuts": [
                {"label": "New Client", "type": "DocType", "link_to": "Client"},
                {"label": "Daily Checklist", "type": "DocType", "link_to": "Quick Checklist"}
            ]
        }
    ]
}
```

**Program Workspace:**

Similar structure with Program-specific filters and shortcuts.

#### **5.2: Custom Dashboard**

Create: **Medical Dashboard**

Charts:
1. **Client Census** (Number Card)
   - Count of active clients
   - Real-time update

2. **Tasks by Status** (Donut Chart)
   - Open, In Progress, Completed

3. **Template Compliance** (Bar Chart)
   - % of clients with each template active

4. **Overdue Tasks** (Number Card with alert)
   - Count of tasks past due

---

### **Phase 6: Advanced Features (Week 6-8)**

#### **6.1: Announcements**

```
DocType: Announcement
Fields:
- Title (Data)
- Content (Text Editor)
- Priority (Select: Low, Normal, High, Critical)
- Status (Select: Draft, Published, Archived)
- Published Date (Datetime)
- Expires Date (Datetime)
- Target Departments (Table): department (Link → Orchestrator Department)
- Target Roles (Table): role (Link → Role)
- Author (Link → User)
- Pin to Top (Check)
```

**Display Logic:**

```python
# Server-side query
@frappe.whitelist()
def get_user_announcements():
    user_depts = frappe.get_all('Orchestrator Department Member',
        filters={'user': frappe.session.user},
        pluck='parent'
    )
    
    user_roles = frappe.get_roles()
    
    announcements = frappe.get_all('Announcement',
        filters=[
            ['status', '=', 'Published'],
            ['expires_date', '>=', today()],
            # Filter by dept or role
        ],
        fields=['name', 'title', 'content', 'priority', 'pin_to_top'],
        order_by='pin_to_top desc, published_date desc'
    )
    
    return announcements
```

#### **6.2: Supervisor Tools**

```
DocType: Supervisor Resource
Fields:
- Title (Data)
- Description (Text Editor)
- Resource Type (Select: Link, Document, Video, Tool)
- URL (Data)
- Department (Link → Orchestrator Department)
- Position (Int)
- Restricted (Check)
- Allowed Roles (Table): role
```

#### **6.3: Employee Scheduler**

```
DocType: Shift Template
Fields:
- Shift Name (Data)
- Start Time (Time)
- End Time (Time)
- Department (Link → Orchestrator Department)
- Required Staff Count (Int)

DocType: Shift Assignment
Fields:
- Shift Template (Link → Shift Template)
- Employee (Link → Employee)
- Date (Date)
- Status (Select: Scheduled, Confirmed, Completed, Cancelled)
- Notes (Text)
```

---

## Data Migration Strategy

### **Option A: Direct Migration (Recommended)**

**Step 1: Export from Firebase**

Create script: `export-firebase-data.ts`

```typescript
// Export all collections to JSON
const collections = [
  'users',
  'departments',
  'tasks',
  'clients',
  'knowledge_articles',
  'announcements'
];

for (const collection of collections) {
  const snapshot = await db.collection(collection).get();
  const data = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
  
  fs.writeFileSync(`./exports/${collection}.json`, JSON.stringify(data, null, 2));
}
```

**Step 2: Import into Frappe**

Create Frappe import script: `import_orchestrator_data.py`

```python
import frappe
import json

def import_users():
    with open('exports/users.json') as f:
        users = json.load(f)
    
    for user_data in users:
        # Create Frappe user
        if not frappe.db.exists('User', user_data['email']):
            user = frappe.get_doc({
                'doctype': 'User',
                'email': user_data['email'],
                'first_name': user_data.get('firstName'),
                'last_name': user_data.get('lastName'),
                # Map custom fields
            })
            user.insert()

def import_tasks():
    with open('exports/tasks.json') as f:
        tasks = json.load(f)
    
    for task_data in tasks:
        task = frappe.get_doc({
            'doctype': 'Detailed Task',
            'title': task_data['title'],
            'description': task_data.get('description'),
            'status': map_status(task_data['status']),
            'assigned_to': task_data.get('assignedTo'),
            # Map other fields
        })
        task.insert()

# Run migration
frappe.db.begin()
try:
    import_users()
    import_tasks()
    import_clients()
    import_knowledge_articles()
    frappe.db.commit()
except Exception as e:
    frappe.db.rollback()
    print(f"Migration failed: {e}")
```

**Step 3: Run Migration**

```bash
# In Frappe bench
bench --site orchestrator.local execute orchestrator_clinical.migrations.import_orchestrator_data.run_migration
```

### **Option B: Parallel Running (Low-Risk)**

Run both systems simultaneously:

1. **Keep Firebase app running** at current domain
2. **Run Frappe app** at subdomain (e.g., `beta.yourcompany.com`)
3. **Sync data bi-directionally** during transition:
   - Firebase writes sync to Frappe (via webhooks)
   - Frappe writes sync back to Firebase (via Frappe server scripts)
4. **Gradual user migration:**
   - Start with one department (e.g., Medical)
   - Train users
   - Migrate next department
5. **Full cutover** once all departments validated

---

## White-Labeling & Branding

Apply your existing design system to Frappe:

### **Step 1: Upload Assets**

1. Upload logo to `public/files/`
2. Set in Website Settings

### **Step 2: Custom CSS**

Create: `orchestrator_clinical/public/css/orchestrator.css`

```css
:root {
    /* Your brand colors from tailwind.config.ts */
    --primary-color: #f26522;  /* brand-orange */
    --secondary-color: #0c4b5e; /* brand-teal */
    --success-color: #03c95a;
    --danger-color: #e70d0d;
    --sidebar-bg: #212529;
}

/* Typography - Archivo font */
body {
    font-family: 'Archivo', -apple-system, sans-serif;
}

/* Apply brand colors */
.navbar {
    background: var(--secondary-color) !important;
}

.btn-primary {
    background: var(--primary-color) !important;
}

.sidebar {
    background: var(--sidebar-bg) !important;
}
```

### **Step 3: Include CSS**

In `orchestrator_clinical/hooks.py`:

```python
app_include_css = "/assets/orchestrator_clinical/css/orchestrator.css"

# Load Archivo font
web_include_css = [
    "https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600;700&display=swap"
]
```

---

## Timeline & Milestones

### **Week 1-2: Foundation**
- ✅ Frappe installed (DONE!)
- Create core modules
- Set up User/Department structure
- Test permissions

### **Week 3-4: Task System**
- Build 3 task DocTypes
- Implement workflows
- Test with sample data
- Train one department

### **Week 5-6: Client Management**
- Create Client DocType
- Integrate Kipu sync
- Migrate existing client data
- Test medical/program workflows

### **Week 7-8: Knowledge Base**
- Build KB DocTypes
- Integrate AI processing
- Migrate existing articles
- Set up approval workflows

### **Week 9-10: Workspaces & Polish**
- Create department workspaces
- Build custom dashboards
- White-label UI
- Final testing

### **Week 11-12: Training & Cutover**
- User training sessions
- Parallel running with Firebase
- Address feedback
- Full cutover

---

## Cost/Benefit Analysis

### **Firebase (Current)**

**Monthly Costs:**
- Firebase Hosting: ~$25
- Firestore reads/writes: ~$50-100
- Cloud Functions: ~$20
- Total: **~$95-145/month**

**Maintenance:**
- 2-3 developers
- Custom code for every feature
- Ongoing security updates

### **Frappe (Proposed)**

**Monthly Costs:**
- VPS hosting (4GB RAM): ~$20-40
- Backups: ~$10
- Total: **~$30-50/month**

**Maintenance:**
- 1-2 developers
- Most features built-in
- Framework updates handled by Frappe

**ROI:** ~$60-100/month savings + 30-50% reduction in development time

---

## Next Steps

### **Immediate (This Week):**

1. **Review this guide** - Does this align with your vision?
2. **Prioritize features** - Which modules are most critical?
3. **Create first DocType** - Let's build the Client DocType together to validate the approach

### **Short-term (Next 2 Weeks):**

1. Build Task Management system
2. Create Kipu integration
3. Migrate sample data

### **Medium-term (Month 2):**

1. Complete all core modules
2. White-label the UI
3. User training

---

## Questions for You:

1. **Timeline:** Do you want to go all-in on Frappe migration, or run parallel during transition?
2. **Priority:** Which module should we build first? (I recommend Task Management or Client Management)
3. **Data:** How much historical data needs to migrate from Firebase?
4. **Users:** How many concurrent users? (affects hosting specs)
5. **Kipu Integration:** Can you share the Kipu API endpoints you're currently using?

---

**Ready to start building?** Let me know which DocType you want to create first, and I'll walk you through building it in Frappe right now!
