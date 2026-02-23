# Gameplan Module for Frappe Orchestrator
# Project and task management with Gantt charts, sprints, resource allocation

from frappe import _

app_name = "orchestrator_gameplan"
app_title = "Orchestrator Gameplan"
app_publisher = "Orchestrator Team"
app_description = "Project management with task hierarchies, sprint planning, resource allocation, and Gantt charts"
app_icon = "octicon octicon-checklist"
app_color = "#f39c12"
app_version = "0.1.0"
app_license = "Proprietary"

app_include_js = [
    "/assets/orchestrator_gameplan/js/gameplan.js",
    "/assets/orchestrator_gameplan/js/gantt.js",
    "/assets/orchestrator_gameplan/js/kanban.js",
]

app_include_css = [
    "/assets/orchestrator_gameplan/css/gameplan.css",
]

fixtures = [
    {
        "doctype": "Custom Role",
        "filters": {
            "name": ["in", ["Project Manager", "Team Lead", "Team Member", "Resource Manager"]]
        }
    }
]

doctype_list = [
    "Project",
    "Task",
    "Sprint",
    "Milestone",
    "Task Template",
    "Resource Allocation",
    "Project Settings",
]

# Scheduled jobs for sprint automation and deadline tracking
# scheduler_events = {
#     "daily": [
#         "orchestrator_gameplan.tasks.check_task_deadlines",
#         "orchestrator_gameplan.tasks.update_sprint_burndown",
#         "orchestrator_gameplan.tasks.send_task_reminders",
#         "orchestrator_gameplan.tasks.check_blocked_dependencies"
#     ],
#     "weekly": [
#         "orchestrator_gameplan.tasks.generate_sprint_report"
#     ]
# }

# Document lifecycle hooks
# doc_events = {
#     "Task": {
#         "after_insert": "orchestrator_gameplan.task.after_insert",
#         "on_update": "orchestrator_gameplan.task.on_update",
#         "before_submit": "orchestrator_gameplan.task.before_submit"
#     },
#     "Sprint": {
#         "on_update": "orchestrator_gameplan.sprint.on_update",
#         "before_submit": "orchestrator_gameplan.sprint.before_submit"
#     }
# }

# Real-time collaboration hooks
# websocket_events = {
#     "task_updated": "orchestrator_gameplan.ws.on_task_update",
#     "comment_added": "orchestrator_gameplan.ws.on_comment_add"
# }
