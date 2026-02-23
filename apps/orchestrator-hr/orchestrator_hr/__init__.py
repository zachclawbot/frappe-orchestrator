# HR Module for Frappe Orchestrator
# Manages employees, departments, leaves, attendance, and payroll

from frappe import _

app_name = "orchestrator_hr"
app_title = "Orchestrator HR"
app_publisher = "Orchestrator Team"
app_description = "Human Resources module with employee management, payroll, leave management, and attendance tracking"
app_icon = "octicon octicon-people"
app_color = "#27ae60"
app_version = "0.1.0"
app_license = "Proprietary"

app_include_js = [
    "/assets/orchestrator_hr/js/hr.js",
]

app_include_css = [
    "/assets/orchestrator_hr/css/hr.css",
]

fixtures = [
    {
        "doctype": "Custom Role",
        "filters": {
            "name": ["in", ["HR Manager", "HR Staff", "Employee"]]
        }
    }
]

doctype_list = [
    "Employee",
    "Department",
    "Shift",
    "Attendance",
    "Leave",
    "Leave Type",
    "Salary Structure",
    "Employee Designation",
]

# Scheduled jobs
# scheduler_events = {
#     "daily": [
#         "orchestrator_hr.tasks.process_leave_accrual",
#         "orchestrator_hr.tasks.update_employee_anniversaries"
#     ],
#     "monthly": [
#         "orchestrator_hr.tasks.generate_payroll",
#         "orchestrator_hr.tasks.generate_leave_allocation"
#     ]
# }

# Customization hooks
# doc_events = {
#     "Leave": {
#         "after_insert": "orchestrator_hr.leave.after_insert",
#         "on_update": "orchestrator_hr.leave.on_update",
#         "before_submit": "orchestrator_hr.leave.before_submit"
#     },
#     "Attendance": {
#         "on_update": "orchestrator_hr.attendance.on_update"
#     }
# }
