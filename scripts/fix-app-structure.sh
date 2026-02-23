#!/bin/bash
# Creates missing Frappe app structure files for all orchestrator apps

WORKSPACE="/mnt/c/workspace/frappe-orchestrator/apps"

declare -A APPS
APPS["orchestrator-crm"]="orchestrator_crm|Orchestrator CRM|#1f8dd6|Customer Relationship Management module"
APPS["orchestrator-hr"]="orchestrator_hr|Orchestrator HR|#27ae60|Human Resources module with employee management"
APPS["orchestrator-helpdesk"]="orchestrator_helpdesk|Orchestrator Helpdesk|#e74c3c|Support ticket management with SLA tracking"
APPS["orchestrator-docs"]="orchestrator_docs|Orchestrator Documents|#8e44ad|Document and file management with versioning"
APPS["orchestrator-insights"]="orchestrator_insights|Orchestrator Insights|#3498db|Business intelligence and analytics"
APPS["orchestrator-gameplan"]="orchestrator_gameplan|Orchestrator Gameplan|#f39c12|Project management with task hierarchies"

for APP_DIR in "${!APPS[@]}"; do
  IFS='|' read -r PKG TITLE COLOR DESC <<< "${APPS[$APP_DIR]}"
  BASE="$WORKSPACE/$APP_DIR"
  PKG_DIR="$BASE/$PKG"

  echo "=== Processing $APP_DIR ($PKG) ==="

  # Create requirements.txt if missing
  if [ ! -f "$BASE/requirements.txt" ]; then
    printf "# %s dependencies\n# frappe is provided by the bench environment\n" "$TITLE" > "$BASE/requirements.txt"
    echo "  Created requirements.txt"
  fi

  # Create MANIFEST.in
  printf "include MANIFEST.in\nrecursive-include %s *.html *.css *.js *.csv *.png *.jpg *.svg *.json *.txt\n" "$PKG" > "$BASE/MANIFEST.in"
  echo "  Created MANIFEST.in"

  # Create modules.txt
  printf "%s\n" "$TITLE" > "$PKG_DIR/modules.txt"
  echo "  Created modules.txt"

  # Create hooks.py
  cat > "$PKG_DIR/hooks.py" << HOOKEOF
app_name = "$PKG"
app_title = "$TITLE"
app_publisher = "Orchestrator Team"
app_description = "$DESC"
app_email = "team@orchestrator.local"
app_license = "Proprietary"
app_version = "0.1.0"

# Uncomment to include js/css bundles
# app_include_js = ["/assets/$PKG/js/main.js"]
# app_include_css = ["/assets/$PKG/css/main.css"]

# Scheduled Tasks
# scheduler_events = {
#     "daily": ["$PKG.tasks.daily"],
# }

# Document Events
# doc_events = {}
HOOKEOF
  echo "  Created hooks.py"

  # Fix __init__.py - make frappe import safe (wrap in try/except)
  INIT_FILE="$PKG_DIR/__init__.py"
  if [ -f "$INIT_FILE" ] && grep -q "^from frappe import" "$INIT_FILE"; then
    sed -i 's/^from frappe import _$/try:\n    from frappe import _\nexcept ImportError:\n    _ = lambda x: x/' "$INIT_FILE"
    echo "  Fixed __init__.py (safe frappe import)"
  fi

  # Create config directory
  mkdir -p "$PKG_DIR/config"
  touch "$PKG_DIR/config/__init__.py"

  # Create public directories
  mkdir -p "$PKG_DIR/public/css" "$PKG_DIR/public/js"

  echo "  Done."
done

echo ""
echo "=== App structure fix complete ==="
find "$WORKSPACE" -name "hooks.py" | sort
