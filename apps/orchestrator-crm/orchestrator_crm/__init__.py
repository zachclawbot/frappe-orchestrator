# CRM Module for Frappe Orchestrator
# Manages leads, contacts, companies, opportunities, and communications

from frappe import _

app_name = "orchestrator_crm"
app_title = "Orchestrator CRM"
app_publisher = "Orchestrator Team"
app_description = "Customer Relationship Management module with lead tracking, opportunity pipeline, and communication history"
app_icon = "octicon octicon-organization"
app_color = "#1f8dd6"
app_version = "0.1.0"
app_license = "Proprietary"

# Includes in <head>
# ----------------------
# include_js = "crm.bundle.js"
# include_css = "crm.bundle.css"

# include_js in page
# ----------------------
# Page -> override_docstatus_for_submit = ["naming_series"]

app_include_js = [
    "/assets/orchestrator_crm/js/crm.js",
]

app_include_css = [
    "/assets/orchestrator_crm/css/crm.css",
]

# Fixtures (default data)
# ----------------------
fixtures = [
    {
        "doctype": "Custom Role",
        "filters": {
            "name": ["in", ["CRM Manager", "CRM User", "Sales Representative"]]
        }
    }
]

# Desk Notifications
# ----------------------
# desk_notifications = "orchestrator_crm.notifications.get_notifications"

# Permissions
# ----------------------
permission = [
    {
        "doctype": "Lead",
        "roles": ["CRM Manager", "CRM User", "Sales Representative"],
        "perm_level": 0,
        "apply_user_permissions": 1,
        "match_filters": [
            {"key": "assigned_to", "value": "user"},
        ],
        "read": 1,
        "write": 1,
        "create": 1,
        "delete": 0,
        "submit": 0,
        "amend": 0,
        "cancel": 0,
        "export": 1,
        "print": 1,
        "email": 1,
        "report": 1,
    }
]

# DocTypes
# --------
# Document types defined in this app
doctype_list = [
    "Lead",
    "Contact",
    "Company",
    "Opportunity",
    # "Communication" - Frappe native
]

# Hooks for background jobs and scheduled tasks
# -------
# scheduler_events = {
#     "daily": [
#         "orchestrator_crm.tasks.daily_cleanup"
#     ],
#     "hourly": [
#         "orchestrator_crm.tasks.hourly_sync"
#     ]
# }

# Hooks for document lifecycle
# -----
# doc_events = {
#     "Lead": {
#         "after_insert": "orchestrator_crm.lead.after_insert",
#         "on_update": "orchestrator_crm.lead.on_update"
#     }
# }

# Hooks for form customization
# ----
# customize_forms = {
#     "Lead": "orchestrator_crm.customizations.customize_lead"
# }

# API routes
# ----------
# api_routes = {
#     "/api/crm/leads": "orchestrator_crm.api.get_leads",
#     "/api/crm/pipeline": "orchestrator_crm.api.get_pipeline"
# }

# Portal (client-facing) pages
# ---
# portal_menu_items = [
#     {
#         "title": "My Tickets",
#         "route": "/app/issue",
#         "icon": "octicon octicon-inbox",
#         "roles": ["Customer"]
#     }
# ]

# Dashboard overrides
# ---
# dashboard_overrides = {
#     "CRM": "orchestrator_crm.dashboard.crm_dashboard"
# }
