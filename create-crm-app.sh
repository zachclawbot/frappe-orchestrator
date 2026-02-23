#!/bin/bash
# Create a working Frappe CRM app from scratch

cd /home/frappe/frappe-bench

# Create the app directory structure manually
mkdir -p apps/orch_crm/orch_crm

# Create setup.py
cat > apps/orch_crm/setup.py <<'EOF'
from setuptools import setup, find_packages

setup(
    name='orch_crm',
    version='0.0.1',
    description='Orchestrator CRM',
    author='Orchestrator Team',
    author_email='team@orchestrator.local',
    packages=find_packages(),
    zip_safe=False,
    include_package_data=True,
    install_requires=open('requirements.txt').read().splitlines(),
)
EOF

# Create requirements.txt
cat > apps/orch_crm/requirements.txt <<'EOF'
frappe
EOF

# Create MANIFEST.in
cat > apps/orch_crm/MANIFEST.in <<'EOF'
include MANIFEST.in
include requirements.txt
include *.json
include *.md
include *.py
include *.txt
recursive-include orch_crm *.css
recursive-include orch_crm *.csv
recursive-include orch_crm *.html
recursive-include orch_crm *.ico
recursive-include orch_crm *.js
recursive-include orch_crm *.json
recursive-include orch_crm *.md
recursive-include orch_crm *.png
recursive-include orch_crm *.py
recursive-include orch_crm *.svg
recursive-include orch_crm *.txt
recursive-exclude orch_crm *.pyc
EOF

# Create __init__.py
cat > apps/orch_crm/orch_crm/__init__.py <<'EOF'
__version__ = '0.0.1'
EOF

# Create hooks.py
cat > apps/orch_crm/orch_crm/hooks.py <<'EOF'
app_name = "orch_crm"
app_title = "Orchestrator CRM"
app_publisher = "Orchestrator Team"
app_description = "Customer Relationship Management"
app_email = "team@orchestrator.local"
app_license = "MIT"

# Includes in <head>
# ------------------

# include js, css files in header of desk.html
# app_include_css = "/assets/orch_crm/css/orch_crm.css"
# app_include_js = "/assets/orch_crm/js/orch_crm.js"

# include js, css files in header of web template
# web_include_css = "/assets/orch_crm/css/orch_crm.css"
# web_include_js = "/assets/orch_crm/js/orch_crm.js"

# include custom scss in every website theme (without file extension ".scss")
# website_theme_scss = "orch_crm/public/scss/website"

# include js, css files in header of web form
# webform_include_js = {"doctype": "public/js/doctype.js"}
# webform_include_css = {"doctype": "public/css/doctype.css"}

# include js in page
# page_js = {"page" : "public/js/file.js"}

# include js in doctype views
# doctype_js = {"doctype" : "public/js/doctype.js"}
# doctype_list_js = {"doctype" : "public/js/doctype_list.js"}
# doctype_tree_js = {"doctype" : "public/js/doctype_tree.js"}
# doctype_calendar_js = {"doctype" : "public/js/doctype_calendar.js"}

# Svg Icons
# ------------------
# include app icons in desk
# app_include_icons = "orch_crm/public/icons.svg"

# Home Pages
# ----------

# application home page (will override Website Settings)
# home_page = "login"

# website user home page (by Role)
# role_home_page = {
#   "Role": "home_page"
# }

# Generators
# ----------

# automatically create page for each record of this doctype
# website_generators = ["Web Page"]

# Jinja
# ----------

# add methods and filters to jinja environment
# jinja = {
#   "methods": "orch_crm.utils.jinja_methods",
#   "filters": "orch_crm.utils.jinja_filters"
# }

# Installation
# ------------

# before_install = "orch_crm.install.before_install"
# after_install = "orch_crm.install.after_install"

# Uninstallation
# ------------

# before_uninstall = "orch_crm.uninstall.before_uninstall"
# after_uninstall = "orch_crm.uninstall.after_uninstall"

# Integration Setup
# ------------------
# To set up dependencies/integrations with other apps
# Name of the app being installed is passed as an argument

# before_app_install = "orch_crm.utils.before_app_install"
# after_app_install = "orch_crm.utils.after_app_install"

# Integration Cleanup
# -------------------

# before_app_uninstall = "orch_crm.utils.before_app_uninstall"
# after_app_uninstall = "orch_crm.utils.after_app_uninstall"

# Desk Notifications
# -------------------
# See frappe.core.notifications.get_notification_config

# notification_config = "orch_crm.notifications.get_notification_config"

# Permissions
# -----------
# Permissions evaluated in scripted ways

# permission_query_conditions = {
#   "Event": "frappe.desk.doctype.event.event.get_permission_query_conditions",
# }
#
# has_permission = {
#   "Event": "frappe.desk.doctype.event.event.has_permission",
# }

# DocType Class
# ---------------
# Override standard doctype classes

# override_doctype_class = {
#   "ToDo": "custom_app.overrides.CustomToDo"
# }

# Document Events
# ---------------
# Hook on document methods and events

# doc_events = {
#   "*": {
#       "on_update": "method",
#       "on_cancel": "method",
#       "on_trash": "method"
#   }
# }

# Scheduled Tasks
# ---------------

# scheduler_events = {
#   "all": [
#       "orch_crm.tasks.all"
#   ],
#   "daily": [
#       "orch_crm.tasks.daily"
#   ],
#   "hourly": [
#       "orch_crm.tasks.hourly"
#   ],
#   "weekly": [
#       "orch_crm.tasks.weekly"
#   ],
#   "monthly": [
#       "orch_crm.tasks.monthly"
#   ],
# }

# Testing
# -------

# before_tests = "orch_crm.install.before_tests"

# Overriding Methods
# ------------------------------
#
# override_whitelisted_methods = {
#   "frappe.desk.doctype.event.event.get_events": "orch_crm.event.get_events"
# }
#
# each overriding function accepts a `data` argument;
# generated from the base implementation of the doctype dashboard,
# along with any modifications made in other Frappe apps
# override_doctype_dashboards = {
#   "Task": "orch_crm.task.get_dashboard_data"
# }

# exempt linked doctypes from being automatically cancelled
#
# auto_cancel_exempted_doctypes = ["Auto Repeat"]

# Ignore links to specified DocTypes when deleting documents
# -----------------------------------------------------------

# ignore_links_on_delete = ["Communication", "ToDo"]

# Request Events
# ----------------
# before_request = ["orch_crm.utils.before_request"]
# after_request = ["orch_crm.utils.after_request"]

# Job Events
# ----------
# before_job = ["orch_crm.utils.before_job"]
# after_job = ["orch_crm.utils.after_job"]

# User Data Protection
# --------------------

# user_data_fields = [
#   {
#       "doctype": "{doctype_1}",
#       "filter_by": "{filter_by}",
#       "redact_fields": ["{field_1}", "{field_2}"],
#       "partial": 1,
#   },
#   {
#       "doctype": "{doctype_2}",
#       "filter_by": "{filter_by}",
#       "partial": 1,
#   },
#   {
#       "doctype": "{doctype_3}",
#       "strict": False,
#   },
#   {
#       "doctype": "{doctype_4}"
#   }
# ]

# Authentication and authorization
# --------------------------------

# auth_hooks = [
#   "orch_crm.auth.validate"
# ]

# Automatically update python controller files with type annotations for this app.
# export_python_type_annotations = True

# default_log_clearing_doctypes = {
#   "Logging DocType Name": 30  # days to retain logs
# }

EOF

# Create modules.txt
cat > apps/orch_crm/orch_crm/modules.txt <<'EOF'
CRM
EOF

# Create CRM module directory
mkdir -p apps/orch_crm/orch_crm/crm
cat > apps/orch_crm/orch_crm/crm/__init__.py <<'EOF'
EOF

# Install the app
cd /home/frappe/frappe-bench
bench --site orchestrator.local install-app orch_crm

echo ""
echo "✅ orch_crm app created and installed!"
EOF
chmod +x /mnt/c/workspace/frappe-orchestrator/create-crm-app.sh
