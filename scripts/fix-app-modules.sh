#!/bin/bash
# fix-app-modules.sh
# Creates the required module subdirectory structure for each Frappe app
# Frappe requires: apps/orchestrator-crm/orchestrator_crm/orchestrator_crm/
# to match the module name in modules.txt

export HOME=/home/frappe
export PATH=/home/frappe/.local/bin:/usr/local/bin:/usr/bin:/bin

BENCH_DIR=/home/frappe/frappe-bench
SRC_APPS=/mnt/c/workspace/frappe-orchestrator/apps

declare -A APP_MODULES
APP_MODULES["orchestrator-crm"]="orchestrator_crm:Orchestrator CRM"
APP_MODULES["orchestrator-hr"]="orchestrator_hr:Orchestrator HR"
APP_MODULES["orchestrator-helpdesk"]="orchestrator_helpdesk:Orchestrator Helpdesk"
APP_MODULES["orchestrator-docs"]="orchestrator_docs:Orchestrator Documents"
APP_MODULES["orchestrator-insights"]="orchestrator_insights:Orchestrator Insights"
APP_MODULES["orchestrator-gameplan"]="orchestrator_gameplan:Orchestrator Gameplan"

for APP_DIR in "${!APP_MODULES[@]}"; do
    IFS=':' read -r PKG TITLE <<< "${APP_MODULES[$APP_DIR]}"
    
    # Fix in both source and bench locations
    for BASE in "$SRC_APPS/$APP_DIR" "$BENCH_DIR/apps/$APP_DIR"; do
        if [ ! -d "$BASE" ]; then
            continue
        fi
        
        PKG_DIR="$BASE/$PKG"
        MODULE_DIR="$PKG_DIR/$PKG"   # e.g. orchestrator_crm/orchestrator_crm/
        
        echo "=== $APP_DIR: Creating module dir $MODULE_DIR ==="
        
        mkdir -p "$MODULE_DIR"
        
        # Create module __init__.py
        cat > "$MODULE_DIR/__init__.py" << 'MODEOF'
# Module package
MODEOF
        
        # Create desktop shortcut icon for this module
        cat > "$MODULE_DIR/desktop_icon.py" << DESKEOF
from __future__ import unicode_literals

def get_data():
    return {
        "label": "$TITLE",
        "color": "blue",
        "icon": "octicon octicon-briefcase",
        "type": "module",
    }
DESKEOF

        # Update modules.txt to use the module-level folder name (matching subdir)
        printf "%s\n" "$PKG" > "$PKG_DIR/modules.txt"
        
        echo "  Created $MODULE_DIR/__init__.py"
    done
done

echo ""
echo "=== Module directories created ==="
find "$SRC_APPS" -name "desktop_icon.py" | sort
find "$BENCH_DIR/apps" -name "desktop_icon.py" | sort 2>/dev/null
