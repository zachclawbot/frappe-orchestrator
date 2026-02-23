#!/bin/bash
# =============================================================================
# Frappe Orchestrator - WSL2 Setup Script (Robust Version)
# =============================================================================

echo "============================================================"
echo "  Frappe Orchestrator - Development Environment Setup"
echo "============================================================"

export DEBIAN_FRONTEND=noninteractive

log_info()    { echo "[INFO] $1"; }
log_warn()    { echo "[WARN] $1"; }
log_section() { echo; echo "------- $1 -------"; }

wait_for_apt() {
    log_info "Waiting for APT lock..."
    for i in $(seq 1 20); do
        if fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; then
            LOCK_PID=$(fuser /var/lib/dpkg/lock-frontend 2>/dev/null | tr -d ' ')
            LOCK_CMD=$(ps -p "$LOCK_PID" -o comm= 2>/dev/null || echo "unknown")
            log_warn "APT lock held by PID $LOCK_PID ($LOCK_CMD) - ($i/20)"
            if echo "$LOCK_CMD" | grep -qE "unattended|apt"; then
                kill -9 "$LOCK_PID" 2>/dev/null || true
                sleep 3
                dpkg --configure -a 2>/dev/null || true
                break
            fi
            sleep 8
        else
            break
        fi
    done
    rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock 2>/dev/null || true
}

log_section "STEP 1: System Packages"
wait_for_apt
apt-get update -qq
wait_for_apt
apt-get install -y curl wget git ca-certificates gnupg lsb-release \
    software-properties-common apt-transport-https build-essential pkg-config \
    libssl-dev libffi-dev libmysqlclient-dev libxslt1-dev libjpeg-dev \
    libtiff5-dev xfonts-75dpi xfonts-base fontconfig sudo 2>&1 || true
log_info "Core packages done."

log_section "STEP 2: Python 3.11"
add-apt-repository -y ppa:deadsnakes/ppa 2>/dev/null || true
wait_for_apt
apt-get update -qq
wait_for_apt
apt-get install -y python3.11 python3.11-dev python3.11-venv python3-pip 2>&1
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 2>/dev/null || true
update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 2>/dev/null || true
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 2>/dev/null
python3.11 -m pip install --quiet --upgrade pip setuptools wheel
log_info "Python: $(python3.11 --version 2>&1)"

log_section "STEP 3: Node.js 18 & Yarn"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash - 2>/dev/null
wait_for_apt
apt-get install -y nodejs 2>&1
npm install -g yarn 2>/dev/null
log_info "Node: $(node --version 2>&1)"

log_section "STEP 4: MariaDB"
wait_for_apt
apt-get install -y mariadb-server mariadb-client 2>&1
cat > /etc/mysql/mariadb.conf.d/99-frappe.cnf << 'MARIADB_CONF'
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
max_allowed_packet = 64M
wait_timeout = 28800
[mysql]
default-character-set = utf8mb4
[client]
default-character-set = utf8mb4
MARIADB_CONF
service mariadb start 2>/dev/null || true
sleep 5
mysql -u root 2>/dev/null << 'MYSQL_SETUP'
UPDATE mysql.user SET authentication_string=PASSWORD('RootPassword123'), plugin='mysql_native_password' WHERE User='root' AND Host='localhost';
CREATE DATABASE IF NOT EXISTS `frappe_orchestrator` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'frappe'@'localhost' IDENTIFIED BY 'FrappePassword123';
GRANT ALL PRIVILEGES ON `frappe_orchestrator`.* TO 'frappe'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SETUP
log_info "MariaDB ready."

log_section "STEP 5: Redis"
wait_for_apt
apt-get install -y redis-server 2>&1
cat > /etc/redis/redis.conf.d/frappe.conf 2>/dev/null << 'REDISEOF'
save ""
REDISEOF
service redis-server start 2>/dev/null || redis-server --daemonize yes 2>/dev/null || true
sleep 2
log_info "Redis: $(redis-cli ping 2>/dev/null || echo started)"

log_section "STEP 6: Frappe User"
if ! id "frappe" &>/dev/null; then
    useradd -m -s /bin/bash frappe
    echo "frappe:frappe" | chpasswd
fi
echo "frappe ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/frappe
chmod 0440 /etc/sudoers.d/frappe
log_info "User frappe ready."

log_section "STEP 7: wkhtmltopdf"
wait_for_apt
apt-get install -y wkhtmltopdf 2>/dev/null || true

log_section "STEP 8: frappe-bench"
python3.11 -m pip install --quiet frappe-bench
export PATH="/usr/local/bin:$PATH"
log_info "bench: $(bench --version 2>&1 || echo installed)"

log_section "STEP 9: bench init"
BENCH_DIR="/home/frappe/frappe-bench"
if [ ! -d "$BENCH_DIR" ]; then
    log_info "Running bench init (15-30 min)..."
    sudo -u frappe -H bash -c "
        export HOME=/home/frappe
        export PATH=/home/frappe/.local/bin:/usr/local/bin:\$PATH
        cd /home/frappe
        bench init frappe-bench --python python3.11 --frappe-branch version-15
    " 2>&1
    log_info "Bench initialized."
else
    log_info "Bench already exists."
fi
chown -R frappe:frappe "$BENCH_DIR" 2>/dev/null || true

log_section "STEP 10: Configure Bench"
sudo -u frappe -H bash -c "
    export HOME=/home/frappe
    export PATH=/home/frappe/.local/bin:/usr/local/bin:\$PATH
    cd $BENCH_DIR
    bench set-config -g developer_mode 1
    bench set-config -g redis_cache 'redis://127.0.0.1:6379'
    bench set-config -g redis_queue 'redis://127.0.0.1:6379'
    bench set-config -g redis_socketio 'redis://127.0.0.1:6379'
" 2>&1 || true

log_section "STEP 11: Create Site"
SITE_NAME="frappe-orchestrator.local"
if [ ! -d "$BENCH_DIR/sites/$SITE_NAME" ]; then
    log_info "Creating site $SITE_NAME ..."
    sudo -u frappe -H bash -c "
        export HOME=/home/frappe
        export PATH=/home/frappe/.local/bin:/usr/local/bin:\$PATH
        cd $BENCH_DIR
        bench new-site $SITE_NAME \
            --mariadb-root-password RootPassword123 \
            --admin-password admin123 \
            --db-name frappe_orchestrator
    " 2>&1
    log_info "Site created."
else
    log_info "Site already exists."
fi
sudo -u frappe -H bash -c "
    export HOME=/home/frappe; export PATH=/home/frappe/.local/bin:/usr/local/bin:\$PATH
    cd $BENCH_DIR && bench use $SITE_NAME
" 2>/dev/null || true

log_section "STEP 12: Orchestrator Apps"
WORKSPACE_APPS="/mnt/c/workspace/frappe-orchestrator/apps"
declare -A APP_NAMES
APP_NAMES["orchestrator-crm"]="orchestrator_crm"
APP_NAMES["orchestrator-hr"]="orchestrator_hr"
APP_NAMES["orchestrator-helpdesk"]="orchestrator_helpdesk"
APP_NAMES["orchestrator-docs"]="orchestrator_docs"
APP_NAMES["orchestrator-insights"]="orchestrator_insights"
APP_NAMES["orchestrator-gameplan"]="orchestrator_gameplan"
for APP_DIR in "${!APP_NAMES[@]}"; do
    PKG="${APP_NAMES[$APP_DIR]}"
    SRC="$WORKSPACE_APPS/$APP_DIR"
    DEST="$BENCH_DIR/apps/$APP_DIR"
    if [ -d "$SRC" ] && [ ! -d "$DEST" ]; then
        cp -r "$SRC" "$DEST"
        chown -R frappe:frappe "$DEST"
    fi
    if [ -d "$DEST" ]; then
        sudo -u frappe -H bash -c "
            cd $BENCH_DIR && env/bin/pip install --quiet -e apps/$APP_DIR
        " 2>&1 || log_warn "$APP_DIR pip install failed"
        sudo -u frappe -H bash -c "
            export HOME=/home/frappe; export PATH=/home/frappe/.local/bin:/usr/local/bin:\$PATH
            cd $BENCH_DIR && bench --site $SITE_NAME install-app $PKG
        " 2>&1 || log_warn "$PKG site install failed (OK if no DocTypes yet)"
    fi
done

log_section "STEP 13: Hosts"
grep -q "frappe-orchestrator.local" /etc/hosts || echo "127.0.0.1 frappe-orchestrator.local" >> /etc/hosts
WIN_HOSTS="/mnt/c/Windows/System32/drivers/etc/hosts"
[ -f "$WIN_HOSTS" ] && ! grep -q "frappe-orchestrator" "$WIN_HOSTS" && echo "127.0.0.1 frappe-orchestrator.local" >> "$WIN_HOSTS" 2>/dev/null || true

echo ""
echo "============================================================"
echo "  SETUP COMPLETE!"
echo "============================================================"
echo ""
echo "To START: wsl -d Ubuntu-22.04 -u frappe -- bash -c 'cd ~/frappe-bench && bench start'"
echo "Access:   http://localhost:8000"
echo "Login:    Administrator / admin123"
echo "============================================================"
