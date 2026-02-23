# Helpdesk Module for Frappe Orchestrator
# Manages support tickets, service levels, escalations, and knowledge base

from frappe import _

app_name = "orchestrator_helpdesk"
app_title = "Orchestrator Helpdesk"
app_publisher = "Orchestrator Team"
app_description = "Support ticket management with SLA tracking, escalation policies, and knowledge base integration"
app_icon = "octicon octicon-comment"
app_color = "#e74c3c"
app_version = "0.1.0"
app_license = "Proprietary"

app_include_js = [
    "/assets/orchestrator_helpdesk/js/helpdesk.js",
]

app_include_css = [
    "/assets/orchestrator_helpdesk/css/helpdesk.css",
]

fixtures = [
    {
        "doctype": "Custom Role",
        "filters": {
            "name": ["in", ["Support Manager", "Support Agent", "Support Lead"]]
        }
    }
]

doctype_list = [
    "Issue",
    "Service Level Agreement",
    "Service Level Agreement Term",
    "Issue Communication",
    "Issue Template",
    "Knowledge Category",
    "Knowledge Article",
]

# Scheduled jobs for SLA monitoring and escalations
# scheduler_events = {
#     "all": [
#         "orchestrator_helpdesk.tasks.check_sla_breaches",
#         "orchestrator_helpdesk.tasks.escalate_issues",
#         "orchestrator_helpdesk.tasks.send_sla_alerts"
#     ]
# }

# Document lifecycle hooks
# doc_events = {
#     "Issue": {
#         "after_insert": "orchestrator_helpdesk.issue.after_insert",
#         "on_update": "orchestrator_helpdesk.issue.on_update",
#         "before_submit": "orchestrator_helpdesk.issue.before_submit"
#     }
# }

# Email integration for ticket creation
# periodic_emails = [
#     {
#         "cron": "0 * * * *",
#         "method": "orchestrator_helpdesk.tasks.fetch_emails"
#     }
# ]
