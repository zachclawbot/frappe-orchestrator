# Insights Module for Frappe Orchestrator
# Provides dashboards, KPIs, custom reports, and real-time metrics

from frappe import _

app_name = "orchestrator_insights"
app_title = "Orchestrator Insights"
app_publisher = "Orchestrator Team"
app_description = "Business intelligence and analytics with dashboards, KPIs, custom reports, and real-time metrics"
app_icon = "octicon octicon-graph"
app_color = "#3498db"
app_version = "0.1.0"
app_license = "Proprietary"

app_include_js = [
    "/assets/orchestrator_insights/js/insights.js",
    "/assets/orchestrator_insights/js/charts.js",
]

app_include_css = [
    "/assets/orchestrator_insights/css/insights.css",
]

fixtures = [
    {
        "doctype": "Custom Role",
        "filters": {
            "name": ["in", ["Analytics Manager", "Analyst", "Dashboard Viewer"]]
        }
    }
]

doctype_list = [
    "Dashboard",
    "Dashboard Item",
    "Report",
    "Chart",
    "KPI",
]

# Scheduled jobs for report generation and metric calculation
# scheduler_events = {
#     "hourly": [
#         "orchestrator_insights.tasks.refresh_dashboard_metrics"
#     ],
#     "daily": [
#         "orchestrator_insights.tasks.generate_daily_report",
#         "orchestrator_insights.tasks.calculate_kpis",
#         "orchestrator_insights.tasks.send_report_emails"
#     ],
#     "monthly": [
#         "orchestrator_insights.tasks.generate_executive_summary"
#     ]
# }

# Caching for performance
# redis_cache = {
#     "metrics": 3600,  # Cache metrics for 1 hour
#     "reports": 86400,  # Cache reports for 1 day
#     "dashboards": 1800  # Cache dashboards for 30 minutes
# }

# Background job hooks for heavy computations
# background_tasks = {
#     "long_running": [
#         "orchestrator_insights.tasks.overnight_batch_report_generation"
#     ]
# }
