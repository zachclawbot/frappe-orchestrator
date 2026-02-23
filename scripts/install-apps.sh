#!/bin/bash
# install-apps.sh - Installs orchestrator apps in bench and on site
export HOME=/home/frappe
export PATH=/home/frappe/.local/bin:/usr/local/bin:/usr/bin:/bin
export GIT_PYTHON_REFRESH=quiet

BENCH_DIR=/home/frappe/frappe-bench
SITE_NAME=frappe-orchestrator.local

cd "$BENCH_DIR"

# Set default site
bench use "$SITE_NAME" 2>/dev/null
echo "Default site: $SITE_NAME"

# Install each app
APPS=(
    "orchestrator-crm:orchestrator_crm"
    "orchestrator-hr:orchestrator_hr"
    "orchestrator-helpdesk:orchestrator_helpdesk"
    "orchestrator-docs:orchestrator_docs"
    "orchestrator-insights:orchestrator_insights"
    "orchestrator-gameplan:orchestrator_gameplan"
)

for APP_PAIR in "${APPS[@]}"; do
    APP_DIR="${APP_PAIR%%:*}"
    PKG="${APP_PAIR##*:}"
    
    echo ""
    echo "=== $APP_DIR ($PKG) ==="
    
    # Install in bench Python environment
    echo "  pip install..."
    env/bin/pip install --quiet -e "apps/$APP_DIR" 2>&1 && echo "  pip: OK" || echo "  pip: FAILED"
    
    # Register in apps.txt if not already there
    if ! grep -qx "$PKG" sites/apps.txt 2>/dev/null; then
        echo "$PKG" >> sites/apps.txt
        echo "  Added $PKG to apps.txt"
    fi

    # Install on site
    echo "  bench install-app $PKG..."
    bench --site "$SITE_NAME" install-app "$PKG" 2>&1 && echo "  site install: OK" || echo "  site install: FAILED (expected since no DocTypes defined yet)"
done

echo ""
echo "=== apps.txt ==="
cat sites/apps.txt

echo ""
echo "=== Installed Apps on Site ==="
bench --site "$SITE_NAME" list-apps 2>&1

echo ""
echo "=== Done ==="
