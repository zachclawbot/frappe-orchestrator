#!/bin/bash
# Fix Frappe Orchestrator modules and install them properly

set -e

echo "🔧 Fixing Frappe Orchestrator Modules"
echo "======================================"
echo ""

cd /home/frappe/frappe-bench/apps

MODULES="orchestrator-crm orchestrator-hr orchestrator-helpdesk orchestrator-docs orchestrator-insights orchestrator-gameplan"

echo "📦 Cleaning up incorrectly named folders..."
for module in $MODULES; do
    if [ -d "$module" ]; then
        # Remove the hyphenated subfolder if it exists
        if [ -d "$module/$module" ]; then
            rm -rf "$module/$module"
            echo "  ✓ Removed $module/$module"
        fi
        
        # Fix setup.py to use underscores
        module_underscore=$(echo "$module" | tr '-' '_')
        
        if [ -f "$module/setup.py" ]; then
            sed -i "s/name=\"$module\"/name=\"$module_underscore\"/g" "$module/setup.py"
            echo "  ✓ Fixed setup.py for $module"
        fi
    fi
done

echo ""
echo "📦 Installing modules on site..."
cd /home/frappe/frappe-bench

for module in $MODULES; do
    module_underscore=$(echo "$module" | tr '-' '_')
    echo "  Installing $module_underscore..."
    
    # Add app to apps.txt if not already there
    if ! grep -q "^$module$" sites/apps.txt 2>/dev/null; then
        echo "$module" >> sites/apps.txt
    fi
    
    # Install the app
    bench --site orchestrator.local install-app "$module" || echo "    ⚠ $module install failed (may need to restart bench)"
done

echo ""
echo "🔨 Running migrations and building..."
bench migrate
bench build --app frappe
bench clear-cache

echo ""
echo "✅ Modules fixed and installed!"
echo ""
echo "🔄 Restart bench to see changes:"
echo "   Ctrl+C to stop bench"
echo "   bench start"
