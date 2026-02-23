# Documents Module for Frappe Orchestrator
# Manages file storage, versioning, metadata tagging, and audit trails

from frappe import _

app_name = "orchestrator_docs"
app_title = "Orchestrator Documents"
app_publisher = "Orchestrator Team"
app_description = "Document and file management with versioning, metadata tagging, full-text search, and audit logging"
app_icon = "octicon octicon-file"
app_color = "#8e44ad"
app_version = "0.1.0"
app_license = "Proprietary"

app_include_js = [
    "/assets/orchestrator_docs/js/docs.js",
]

app_include_css = [
    "/assets/orchestrator_docs/css/docs.css",
]

fixtures = [
    {
        "doctype": "Custom Role",
        "filters": {
            "name": ["in", ["Content Manager", "Document Manager", "Document Viewer"]]
        }
    }
]

doctype_list = [
    "Document",
    "Document Folder",
    "Document Template",
    "Document Audit",
]

# Full-text search configuration
# search_config = {
#     "indexing": {
#         "Document": {
#             "fields": ["title", "description", "file_name", "content"]
#         }
#     }
# }

# Scheduled jobs for cleanup and archival
# scheduler_events = {
#     "daily": [
#         "orchestrator_docs.tasks.archive_old_versions",
#         "orchestrator_docs.tasks.cleanup_orphaned_files"
#     ],
#     "weekly": [
#         "orchestrator_docs.tasks.generate_document_audit_report"
#     ]
# }

# Document hooks for audit trail
# doc_events = {
#     "Document": {
#         "after_insert": "orchestrator_docs.document.after_insert",
#         "on_update": "orchestrator_docs.document.on_update",
#         "before_delete": "orchestrator_docs.document.before_delete"
#     }
# }
