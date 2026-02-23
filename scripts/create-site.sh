#!/bin/bash
# create-site.sh - Creates the Frappe site and installs apps
# Must be run as frappe user in WSL

export HOME=/home/frappe
export PATH=/home/frappe/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH
export GIT_PYTHON_REFRESH=quiet

BENCH_DIR=/home/frappe/frappe-bench
SITE_NAME=frappe-orchestrator.local

cd "$BENCH_DIR"

echo "=== Starting Redis ==="
redis-server /home/frappe/frappe-bench/config/redis_cache.conf --daemonize yes 2>/dev/null || true
redis-server /home/frappe/frappe-bench/config/redis_queue.conf --daemonize yes 2>/dev/null || true
sleep 2

echo "=== Starting MariaDB ==="
sudo service mariadb start 2>/dev/null || true
sleep 3

echo "=== Verifying MariaDB ==="
mysqladmin -u root -pRootPassword123 ping 2>&1 || echo "MariaDB ping failed"

echo "=== Creating Frappe Site ==="
if [ ! -d "$BENCH_DIR/sites/$SITE_NAME" ]; then
    bench new-site "$SITE_NAME" \
        --mariadb-root-password RootPassword123 \
        --admin-password admin123 \
        --db-name frappe_orchestrator 2>&1
    echo "Site created: $SITE_NAME"
else
    echo "Site already exists: $SITE_NAME"
fi

echo "=== Setting Default Site ==="
bench use "$SITE_NAME" 2>/dev/null || true

echo "=== Installing Orchestrator Apps ==="
APPS="orchestrator_crm orchestrator_hr orchestrator_helpdesk orchestrator_docs orchestrator_insights orchestrator_gameplan"
for APP in $APPS; do
    echo "Installing $APP..."
    bench --site "$SITE_NAME" install-app "$APP" 2>&1 || echo "WARNING: $APP install failed (may be OK)"
done

echo ""
echo "=== Site Setup Complete ==="
echo "Start server: cd $BENCH_DIR && bench start"
echo "Access: http://localhost:8000"
