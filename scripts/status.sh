#!/bin/bash
# status.sh - Check status of all services
# Run from Windows: wsl -d Ubuntu-22.04 -u root -- bash /mnt/c/workspace/frappe-orchestrator/scripts/status.sh

BENCH_DIR="/home/frappe/frappe-bench"
SITE_NAME="frappe-orchestrator.local"

echo "============================================================"
echo "  Frappe Orchestrator - Environment Status"
echo "============================================================"

# Check services
echo ""
echo "[Services]"
MYSQL_STATUS=$(service mariadb status 2>/dev/null | grep -oE "running|stopped|Active: active" | head -1 || echo "unknown")
REDIS_STATUS=$(redis-cli ping 2>/dev/null || echo "stopped")
echo "  MariaDB:      $MYSQL_STATUS"
echo "  Redis:        $REDIS_STATUS"

# Check bench
echo ""
echo "[Bench]"
if [ -d "$BENCH_DIR" ]; then
    echo "  Location:     $BENCH_DIR"
    BENCH_VER=$(cd "$BENCH_DIR" && sudo -u frappe .git/../env/bin/pip show frappe 2>/dev/null | grep Version | awk '{print $2}')
    echo "  Frappe:       ${BENCH_VER:-not found}"
else
    echo "  Status:       NOT INSTALLED"
fi

# Check site
echo ""
echo "[Site]"
if [ -d "$BENCH_DIR/sites/$SITE_NAME" ]; then
    echo "  Site:         $SITE_NAME"
    echo "  URL:          http://localhost:8000"
    echo "  Login:        Administrator / admin123"
else
    echo "  Site:         NOT CREATED"
fi

# Check apps
echo ""
echo "[Apps]"
for APP in orchestrator-crm orchestrator-hr orchestrator-helpdesk orchestrator-docs orchestrator-insights orchestrator-gameplan; do
    if [ -d "$BENCH_DIR/apps/$APP" ]; then
        echo "  $APP: installed"
    else
        echo "  $APP: NOT installed"
    fi
done

echo ""
echo "============================================================"
echo ""
echo "To start the server:"
echo "  wsl -d Ubuntu-22.04 -u frappe -- bash /mnt/c/workspace/frappe-orchestrator/scripts/start-dev.sh"
echo ""
echo "To open a WSL shell:"
echo "  wsl -d Ubuntu-22.04 -u frappe"
echo ""
