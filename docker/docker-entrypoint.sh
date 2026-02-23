#!/bin/bash
set -e

FRAPPE_HOME=/home/frappe/frappe-bench

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
until mysql -h ${FRAPPE_DB_HOST} -u ${FRAPPE_DB_USER} -p${FRAPPE_DB_PASSWORD} -e "SELECT 1" &>/dev/null; do
  sleep 1
done
echo "MariaDB is ready!"

# Change to bench directory
cd ${FRAPPE_HOME}

# Initialize bench if needed
if [ ! -d "sites" ]; then
  echo "Initializing Frappe Bench..."
  bench --version
fi

# Create site if it doesn't exist
if [ ! -d "sites/frappe-orchestrator.local" ]; then
  echo "Creating site: frappe-orchestrator.local"
  bench new-site frappe-orchestrator.local \
    --db-name ${FRAPPE_DB_NAME} \
    --db-user ${FRAPPE_DB_USER} \
    --db-password ${FRAPPE_DB_PASSWORD} \
    --db-host ${FRAPPE_DB_HOST} \
    --db-port ${FRAPPE_DB_PORT} \
    --admin-password admin123 \
    --no-mariadb-socket
fi

# Migrate database
echo "Running migrations..."
bench --site frappe-orchestrator.local migrate

# Install standard Frappe apps if not present
if ! bench --site frappe-orchestrator.local list-apps | grep -q "erpnext"; then
  echo "Installing ERPNext..."
  bench get-app erpnext --branch version-14
  bench --site frappe-orchestrator.local install-app erpnext
fi

# Execute the main command
exec "$@"
