#!/bin/bash
# start-dev.sh - Starts the Frappe development server
export HOME=/home/frappe
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
export PATH=$HOME/.nvm/versions/node/v18.20.8/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin
export GIT_PYTHON_REFRESH=quiet

BENCH_DIR=/home/frappe/frappe-bench
echo "============================================================"
echo "  Starting Frappe Development Server"
echo "============================================================"
echo "  Node: $(node --version 2>&1)  |  Python: $(python3.11 --version 2>&1)"

echo "[INFO] Starting MariaDB..."
sudo service mariadb start 2>/dev/null || true
sleep 3
MYSQL_UP=$(mysqladmin -u root -pRootPassword123 ping 2>/dev/null && echo "OK" || echo "FAILED")
echo "[INFO] MariaDB: $MYSQL_UP"
if [ "$MYSQL_UP" != "OK" ]; then
    sudo service mariadb restart 2>/dev/null || true
    sleep 5
fi

pkill -f "redis-server.*\.conf" 2>/dev/null || true
sleep 1

cd "$BENCH_DIR"
echo ""
echo "  Access: http://localhost:8000  |  Login: Administrator / admin123"
echo "  Ctrl+C to stop"
echo ""
bench start
