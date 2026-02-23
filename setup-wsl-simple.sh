#!/bin/bash
# Simplified Frappe Setup for WSL2 - Bypasses apt-pkg issues

set -e

echo "🚀 Frappe Orchestrator - Simplified WSL2 Setup"
echo "================================================"
echo ""

# Fix command-not-found issue
echo "📦 Fixing WSL package manager..."
sudo rm -f /var/lib/command-not-found/commands.db 2>/dev/null || true
export DEBIAN_FRONTEND=noninteractive

# Update without post-invoke hooks
echo "📦 Updating system (this may take 2-3 minutes)..."
sudo apt-get update -o APT::Update::Post-Invoke-Success::= 2>&1 | grep -v "command-not-found" || true

echo ""
echo "📦 Installing dependencies..."
sudo apt-get install -y \
    git python3-dev python3-pip python3-setuptools python3.10-venv \
    redis-server mariadb-server mariadb-client \
    software-properties-common libmysqlclient-dev curl \
    build-essential libssl-dev libffi-dev \
    2>&1 | grep -E "^(Reading|Building|Setting up|Processing)" || true

echo ""
echo "📦 Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - > /dev/null 2>&1
sudo apt-get install -y nodejs 2>&1 | grep -E "^(Setting up)" || true
sudo npm install -g yarn --silent

echo ""
echo "✅ Dependencies installed"
echo "   Python: $(python3 --version)"
echo "   Node.js: $(node --version)"
echo "   npm: $(npm --version)"
echo ""

# Start services
echo "🔧 Starting services..."
sudo service mariadb start
sudo service redis-server start

# Configure MariaDB
echo "🔧 Configuring MariaDB..."
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootPassword123';" 2>/dev/null || true

# Create Frappe config
sudo tee /etc/mysql/mariadb.conf.d/frappe.cnf > /dev/null <<EOF
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
EOF

sudo service mariadb restart

echo "✅ MariaDB configured"
echo ""

# Install frappe-bench
echo "📦 Installing frappe-bench..."
sudo pip3 install frappe-bench --quiet

echo "✅ frappe-bench installed: $(bench --version 2>/dev/null || echo 'installed')"
echo ""

# Create frappe user
echo "👤 Creating frappe user..."
if ! id "frappe" &>/dev/null; then
    sudo adduser frappe --disabled-password --gecos "" --quiet
    sudo usermod -aG sudo frappe
    echo "✅ User 'frappe' created"
else
    echo "✅ User 'frappe' already exists"
fi
echo ""

# Initialize bench as frappe user
echo "🔨 Initializing Frappe bench (this takes 5-10 minutes)..."
sudo -u frappe bash <<'FRAPPE_INIT'
cd ~
if [ ! -d "frappe-bench" ]; then
    bench init frappe-bench --frappe-branch version-15 --verbose
else
    echo "Bench already exists"
fi
FRAPPE_INIT

echo "✅ Bench initialized"
echo ""

# Create site
echo "🌐 Creating site: orchestrator.local..."
sudo -u frappe bash <<'SITE_CREATE'
cd ~/frappe-bench
if [ ! -d "sites/orchestrator.local" ]; then
    bench new-site orchestrator.local \
        --mariadb-root-password RootPassword123 \
        --admin-password admin123 \
        --no-mariadb-socket \
        --verbose
    bench use orchestrator.local
else
    echo "Site already exists"
fi
SITE_CREATE

echo "✅ Site created"
echo ""

# Copy modules
echo "📦 Copying orchestrator modules..."
MODULES="orchestrator-crm orchestrator-hr orchestrator-helpdesk orchestrator-docs orchestrator-insights orchestrator-gameplan"

for module in $MODULES; do
    source="/mnt/c/workspace/frappe-orchestrator/apps/$module"
    target="/home/frappe/frappe-bench/apps/$module"
    
    if [ -d "$source" ]; then
        sudo -u frappe cp -r "$source" "$target" 2>/dev/null || true
        echo "  ✓ Copied $module"
    fi
done

echo ""
echo "📦 Installing modules on site..."
sudo -u frappe bash <<'INSTALL_MODULES'
cd ~/frappe-bench

bench --site orchestrator.local install-app orchestrator-crm || echo "  ⚠ orchestrator-crm install failed"
bench --site orchestrator.local install-app orchestrator-hr || echo "  ⚠ orchestrator-hr install failed"
bench --site orchestrator.local install-app orchestrator-helpdesk || echo "  ⚠ orchestrator-helpdesk install failed"
bench --site orchestrator.local install-app orchestrator-docs || echo "  ⚠ orchestrator-docs install failed"
bench --site orchestrator.local install-app orchestrator-insights || echo "  ⚠ orchestrator-insights install failed"
bench --site orchestrator.local install-app orchestrator-gameplan || echo "  ⚠ orchestrator-gameplan install failed"

bench build --app frappe
bench migrate
bench clear-cache
INSTALL_MODULES

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup Complete!"
echo ""
echo "🚀 To start Frappe:"
echo "   1. wsl"
echo "   2. sudo -u frappe bash"
echo "   3. cd ~/frappe-bench"
echo "   4. bench start"
echo ""
echo "🌐 Access at:"
echo "   URL: http://localhost:8000"
echo "   User: Administrator"
echo "   Pass: admin123"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
