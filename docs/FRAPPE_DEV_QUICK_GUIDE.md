# Frappe Development Quick Guide

## Creating a DocType

### Via UI (Easiest for Beginners)
1. Go to Frappe UI → Setup → Customize Form
2. Click "New" → Select "DocType"
3. Fill in details:
   - Name: `Lead`
   - Module: `orchestrator_crm`
   - Add fields
4. Save and Submit

### Via JSON (For Version Control)
Create file: `apps/orchestrator-crm/orchestrator_crm/doctype/lead/lead.json`

```json
{
  "doctype": "DocType",
  "module": "Orchestrator CRM",
  "name": "Lead",
  "label": "Lead",
  "document_type": "Document",
  "fields": [
    {
      "fieldname": "lead_name",
      "fieldtype": "Data",
      "label": "Lead Name",
      "reqd": 1
    },
    {
      "fieldname": "email",
      "fieldtype": "Email",
      "label": "Email",
      "reqd": 1
    },
    {
      "fieldname": "status",
      "fieldtype": "Select",
      "label": "Status",
      "options": "Open\nQualified\nConverted\nLost",
      "default": "Open"
    }
  ],
  "permissions": [
    {
      "role": "CRM Manager",
      "read": 1,
      "write": 1,
      "create": 1,
      "delete": 1
    }
  ]
}
```

## Adding Business Logic

### Server-Side (Python)

Create file: `apps/orchestrator-crm/orchestrator_crm/doctype/lead/lead.py`

```python
import frappe
from frappe.model.document import Document

class Lead(Document):
    def validate(self):
        """Run validation before save"""
        if not self.lead_name or not self.email:
            frappe.throw("Lead name and email are required")
    
    def before_insert(self):
        """Run before first insert"""
        self.status = "Open"
    
    def after_insert(self):
        """Run after insert"""
        frappe.msgprint(f"Lead {self.lead_name} created successfully")
    
    def on_update(self):
        """Run on any update"""
        # Send notification if status changed
        if self.has_value_changed("status"):
            frappe.sendmail(
                recipients=self.assigned_to,
                subject=f"Lead status changed to {self.status}",
                message=f"Lead {self.lead_name} status changed to {self.status}"
            )

@frappe.whitelist()
def get_leads_for_user(user):
    """Custom API endpoint"""
    return frappe.get_list('Lead', filters={'assigned_to': user})

@frappe.whitelist()
def advance_lead(lead_id, new_status):
    """Custom action"""
    lead = frappe.get_doc('Lead', lead_id)
    lead.status = new_status
    lead.save()
    return {'message': f'Lead {lead_id} updated to {new_status}'}
```

### Client-Side (JavaScript)

Create file: `apps/orchestrator-crm/orchestrator_crm/doctype/lead/lead.js`

```javascript
frappe.ui.form.on('Lead', {
    onload: function(frm) {
        // Load data when form opens
        console.log("Lead form loaded", frm.doc);
    },
    
    refresh: function(frm) {
        // Refresh form layout/buttons
        if (frm.doc.status === "Open") {
            frm.add_custom_button('Qualify', function() {
                frm.set_value('status', 'Qualified');
                frm.save();
            });
        }
        
        if (frm.doc.status === "Qualified") {
            frm.add_custom_button('Convert to Opportunity', function() {
                frappe.call({
                    method: 'orchestrator_crm.lead.convert_to_opportunity',
                    args: { lead_id: frm.doc.name },
                    callback: (r) => {
                        frappe.msgprint('Opportunity created!');
                        frappe.set_route('Form', 'Opportunity', r.message);
                    }
                });
            });
        }
    },
    
    lead_name: function(frm) {
        // Field change handler
        console.log("Lead name changed to:", frm.doc.lead_name);
    }
});
```

## Working with Child Tables

### DocType Definition
```json
{
  "fieldname": "tasks",
  "fieldtype": "Table",
  "label": "Tasks",
  "options": "Task"
}
```

### Python Operations
```python
# Create with child table data
doc = frappe.new_doc('Project')
doc.project_name = "Website Redesign"
doc.append('tasks', {
    'title': 'Design mockups',
    'status': 'Open',
    'priority': 'High'
})
doc.append('tasks', {
    'title': 'Develop frontend',
    'status': 'Open',
    'priority': 'High'
})
doc.save()

# Update child table
project = frappe.get_doc('Project', 'PROJ001')
project.tasks[0].status = 'In Progress'
project.save()

# Remove from child table
del project.tasks[0]
project.save()

# Filter child table
active_tasks = [row for row in project.tasks if row.status != 'Done']
```

## Permissions & Roles

### Define Role
Go to Setup → Role → Create new role "CRM Manager"

### Assign Permission to DocType

```python
# Via code
frappe.db.set_value('DocType', 'Lead', 'permissions', [
    {
        'role': 'CRM Manager',
        'read': 1,
        'write': 1,
        'create': 1,
        'delete': 1,
        'submit': 0,
        'amend': 0,
        'cancel': 0
    },
    {
        'role': 'CRM User',
        'read': 1,
        'write': 1,
        'create': 1,
        'delete': 0,
        'submit': 0,
        'amend': 0,
        'cancel': 0
    }
])
```

### Field-Level Permissions
```python
@frappe.whitelist()
def sensitive_data(lead_id):
    """Only CRM Manager can access"""
    if not frappe.has_role('CRM Manager'):
        frappe.throw("Access denied", frappe.PermissionError)
    
    lead = frappe.get_doc('Lead', lead_id)
    return lead.salary_info  # Sensitive field
```

## Queries & Filtering

### Get List
```python
# Simple
leads = frappe.get_list('Lead')

# With filters
leads = frappe.get_list('Lead', filters={
    'status': 'Open',
    'assigned_to': frappe.session.user
})

# With specific fields
leads = frappe.get_list('Lead', fields=['name', 'lead_name', 'email'], 
                       filters={'status': 'Open'})

# With order and limit
leads = frappe.get_list('Lead', 
                       fields=['*'],
                       filters={'status': 'Open'},
                       order_by='modified desc',
                       limit_page_length=50)
```

### Get Single Doc
```python
lead = frappe.get_doc('Lead', 'L001')
print(lead.lead_name)
print(lead.status)

# With child table data
print(lead.tasks)  # List of Task rows
for task in lead.tasks:
    print(task.title)
```

### Database Query
```python
# Raw SQL
results = frappe.db.sql(
    "SELECT name, lead_name, status FROM `tabLead` WHERE status = %s",
    ('Open',), as_dict=1
)

# More readable
leads = frappe.db.get_list('Lead', 
                          filters=[['status', '=', 'Open']],
                          fields=['name', 'lead_name', 'email'])
```

## Workflows

### Define Workflow States

Go to Setup → Workflow → Create new:

```
Workflow: Lead Conversion
DocType: Lead
Document States:
  - Open (Initial)
  - Qualified
  - Converted (Final)
  - Lost (Final)

Transitions:
  - Open → Qualified (CRM User, condition: email is not empty)
  - Qualified → Converted (CRM Manager, no condition)
  - Qualified → Lost (CRM User, no condition)
  - Open → Lost (CRM User, no condition)
```

### Check Workflow State in Code
```python
def get_current_state(doc):
    """Get current workflow state"""
    workflow = frappe.get_doc('Workflow', 'Lead Conversion')
    state = frappe.get_value('Workflow State', 
                            filters={'doctype_name': 'Lead', 
                                    'doc_id': doc.name})
    return state

def can_transition(doc, target_state):
    """Check if transition is allowed"""
    workflow_state = frappe.db.get_value('Workflow', 
                                        {'document_type': 'Lead'},
                                        'name')
    transitions = frappe.get_list('Workflow Transition',
                                 filters=[
                                    ['workflow', '=', workflow_state],
                                    ['state', '=', doc.workflow_state],
                                    ['next_state', '=', target_state]
                                 ])
    return len(transitions) > 0
```

## Email Templates

### Create Template
Go to Setup → Email Template

```
Name: Lead Follow-up
DocType: Lead
Subject: Follow-up on {{lead_name}}

Dear {{contact_name or 'Customer'}},

Thank you for inquiring about our services. We would like to follow up on 
your interest.

Status: {{status}}

Best regards,
Sales Team
```

### Send Email
```python
frappe.sendmail(
    recipients=['customer@example.com'],
    subject=f"Follow-up on {lead.lead_name}",
    template='Lead Follow-up',
    args={
        'lead_name': lead.lead_name,
        'contact_name': lead.contact_name,
        'status': lead.status
    },
    reference_doctype='Lead',
    reference_name=lead.name
)
```

## Scheduled Jobs

Add to module `__init__.py`:

```python
scheduler_events = {
    "daily": [
        "orchestrator_crm.tasks.send_lead_follow_ups",
        "orchestrator_crm.tasks.close_stale_leads"
    ],
    "hourly": [
        "orchestrator_crm.tasks.sync_from_external_api"
    ],
    "weekly": [
        "orchestrator_crm.tasks.generate_sales_report"
    ]
}
```

Create `orchestrator_crm/tasks.py`:

```python
def send_lead_follow_ups():
    """Send daily follow-ups to qualified leads"""
    leads = frappe.get_list('Lead', filters={
        'status': 'Qualified',
        'assigned_to': ['!=', '']
    })
    
    for lead in leads:
        lead_doc = frappe.get_doc('Lead', lead.name)
        frappe.sendmail(
            recipients=[lead_doc.email],
            subject=f"Follow-up: {lead_doc.lead_name}",
            message=f"Hi {lead_doc.lead_name}, ..."
        )

def close_stale_leads():
    """Close leads with no activity in 90 days"""
    leads = frappe.get_list('Lead', filters=[
        ['status', 'in', ['Open', 'Qualified']],
        ['modified', '<', frappe.utils.add_days(frappe.utils.today(), -90)]
    ])
    
    for lead in leads:
        lead_doc = frappe.get_doc('Lead', lead.name)
        lead_doc.status = 'Lost'
        lead_doc.save()
```

## Testing

### Unit Test Example

Create file: `apps/orchestrator-crm/orchestrator_crm/doctype/lead/test_lead.py`

```python
import frappe
from frappe.test_runner import make_test_records
import unittest

class TestLead(unittest.TestCase):
    def setUp(self):
        # Create test data
        frappe.get_doc({
            'doctype': 'CRM Settings' if frappe.db.exists('DocType', 'CRM Settings') else 'Lead',
            'lead_name': 'Test Lead',
            'email': 'test@example.com'
        }).insert()

    def tearDown(self):
        # Cleanup
        frappe.db.delete('Lead', {'lead_name': 'Test Lead'})

    def test_lead_creation(self):
        lead = frappe.new_doc('Lead')
        lead.lead_name = 'John Doe'
        lead.email = 'john@example.com'
        lead.save()
        
        self.assertTrue(frappe.db.exists('Lead', lead.name))
        self.assertEqual(lead.status, 'Open')

    def test_lead_validation(self):
        lead = frappe.new_doc('Lead')
        # Missing required fields
        with self.assertRaises(frappe.ValidationError):
            lead.save()
```

Run tests:
```bash
docker-compose exec frappe \
  bench --site frappe-orchestrator.local run-tests --module orchestrator_crm
```

---

## Useful Commands

```bash
# Create DocType
bench make-doctype Lead

# Create Web Form
bench make-web-form

# Run migrations
bench migrate

# Clear cache
bench clear-cache

# Install app
bench --site frappe-orchestrator.local install-app orchestrator_crm

# Console
bench --site frappe-orchestrator.local console

# Execute custom function
bench --site frappe-orchestrator.local execute orchestrator_crm.tasks.my_function

# Database query
bench --site frappe-orchestrator.local sql "SELECT COUNT(*) FROM \`tabLead\`;"
```

---

**For more:** https://frappeframework.com/docs/v14/user/
