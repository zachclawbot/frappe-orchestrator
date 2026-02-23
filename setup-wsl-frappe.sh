#!/bin/bash

# Frappe Orchestrator - WSL Setup Script
# Complete automated setup for Frappe on WSL2 Ubuntu

set -e  # Exit on any error

echo "🚀 Frappe Orchestrator - WSL2 Setup"
echo "===================================="
echo ""

# Configuration
FRAPPE_USER="frappe"
FRAPPE_DIR="/home/$FRAPPE_USER/frappe-bench"
SITE_NAME="orchestrator.local"
DB_ROOT_PASSWORD="RootPassword123"
ADMIN_PASSWORD="admin123"
ORCHESTRATOR_WIN_PATH="/mnt/c/workspace/frappe-orchestrator"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Step 1: Update System
print_status "Updating system packages..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
print_success "System updated"
echo ""

# Step 2: Install Dependencies
print_status "Installing dependencies..."
sudo apt-get install -y -qq \
    git \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3.10-venv \
    redis-server \
    mariadb-server \
    mariadb-client \
    software-properties-common \
    libmysqlclient-dev \
    curl \
    nginx \
    supervisor \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-wheel \
    python3-cffi \
    xvfb \
    libfontconfig \
    wkhtmltopdf

# Node.js 18.x
print_status "Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - > /dev/null 2>&1
sudo apt-get install -y -qq nodejs
print_success "Node.js installed: $(node --version)"

# Yarn
print_status "Installing Yarn..."
sudo npm install -g yarn -qq
print_success "Yarn installed: $(yarn --version)"

echo ""

# Step 3: Configure MariaDB
print_status "Configuring MariaDB..."
sudo service mariadb start

# Secure MariaDB installation (automated)
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';" 2>/dev/null || true
sudo mysql -u root -p$DB_ROOT_PASSWORD -e "DELETE FROM mysql.user WHERE User='';" 2>/dev/null || true
sudo mysql -u root -p$DB_ROOT_PASSWORD -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" 2>/dev/null || true
sudo mysql -u root -p$DB_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS test;" 2>/dev/null || true
sudo mysql -u root -p$DB_ROOT_PASSWORD -e "FLUSH PRIVILEGES;" 2>/dev/null || true

# Configure MariaDB for Frappe
sudo tee /etc/mysql/mariadb.conf.d/frappe.cnf > /dev/null <<EOF
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
EOF

sudo service mariadb restart
print_success "MariaDB configured"
echo ""

# Step 4: Create Frappe User
print_status "Creating frappe user..."
if id "$FRAPPE_USER" &>/dev/null; then
    print_warning "User 'frappe' already exists"
else
    sudo adduser --disabled-password --gecos "" $FRAPPE_USER
    sudo usermod -aG sudo $FRAPPE_USER
    print_success "User 'frappe' created"
fi
echo ""

# Step 5: Install Frappe Bench
print_status "Installing frappe-bench..."
sudo pip3 install --upgrade pip -qq
sudo pip3 install frappe-bench -qq
print_success "frappe-bench installed: $(bench --version)"
echo ""

# Step 6: Initialize Bench (as frappe user)
print_status "Initializing Frappe bench..."
sudo -u $FRAPPE_USER bash <<'FRAPPE_SETUP'
set -e
cd ~

# Initialize bench
if [ ! -d "frappe-bench" ]; then
    bench init frappe-bench --frappe-branch version-15
    cd frappe-bench
else
    cd frappe-bench
    echo "Bench already initialized"
fi
FRAPPE_SETUP

print_success "Bench initialized"
echo ""

# Step 7: Create Site
print_status "Creating site: $SITE_NAME..."
sudo -u $FRAPPE_USER bash <<SITE_SETUP
set -e
cd ~/frappe-bench

if [ ! -d "sites/$SITE_NAME" ]; then
    bench new-site $SITE_NAME \
        --mariadb-root-password $DB_ROOT_PASSWORD \
        --admin-password $ADMIN_PASSWORD \
        --verbose
    
    bench use $SITE_NAME
else
    echo "Site already exists"
fi
SITE_SETUP

print_success "Site created"
echo ""

# Step 8: Link Orchestrator Modules from Windows
print_status "Linking orchestrator modules from Windows directory..."

if [ -d "$ORCHESTRATOR_WIN_PATH/apps" ]; then
    for module in orchestrator-crm orchestrator-hr orchestrator-helpdesk \
                  orchestrator-docs orchestrator-insights orchestrator-gameplan; do
        
        source="$ORCHESTRATOR_WIN_PATH/apps/$module"
        target="/home/$FRAPPE_USER/frappe-bench/apps/$module"
        
        if [ -d "$source" ]; then
            sudo -u $FRAPPE_USER ln -sf "$source" "$target" 2>/dev/null || true
            print_success "Linked $module"
        else
            print_warning "Source not found: $source"
        fi
    done
else
    print_error "Orchestrator apps directory not found: $ORCHESTRATOR_WIN_PATH/apps"
    print_warning "You'll need to copy or clone the modules manually"
fi

echo ""

# Step 9: Install Orchestrator Apps
print_status "Installing orchestrator modules..."
sudo -u $FRAPPE_USER bash <<'INSTALL_APPS'
set -e
cd ~/frappe-bench

for module in orchestrator-crm orchestrator-hr orchestrator-helpdesk \
              orchestrator-docs orchestrator-insights orchestrator-gameplan; do
    if [ -d "apps/$module" ]; then
        echo "Installing $module..."
        bench --site orchestrator.local install-app $module || true
    fi
done

# Build assets
bench build --app frappe
INSTALL_APPS

print_success "Modules installed"
echo ""

# Step 10: Final Configuration
print_status "Finalizing setup..."
sudo -u $FRAPPE_USER bash <<'FINAL'
cd ~/frappe-bench
bench migrate
bench clear-cache
FINAL

print_success "Setup finalized"
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "✅ Frappe Orchestrator Setup Complete!"
echo ""
echo -e "${CYAN}📍 Getting Started:${NC}"
echo ""
echo "  1. Start Frappe:"
echo -e "     ${YELLOW}sudo -u frappe bash${NC}"
echo -e "     ${YELLOW}cd ~/frappe-bench${NC}"
echo -e "     ${YELLOW}bench start${NC}"
echo ""
echo "  2. Access Application:"
echo -e "     ${YELLOW}URL: http://localhost:8000${NC}"
echo -e "     ${YELLOW}Username: Administrator${NC}"
echo -e "     ${YELLOW}Password: $ADMIN_PASSWORD${NC}"
echo ""
echo -e "${CYAN}🔧 Useful Commands:${NC}"
echo "  bench migrate                     - Run migrations"
echo "  bench build                       - Build assets"
echo "  bench console                     - Frappe console"
echo "  bench new-app <app-name>          - Create new app"
echo "  bench --site <site> install-app   - Install app"
echo ""
echo -e "${CYAN}📂 Directories:${NC}"
echo "  Bench: /home/frappe/frappe-bench"
echo "  Site:  /home/frappe/frappe-bench/sites/$SITE_NAME"
echo "  Apps:  /home/frappe/frappe-bench/apps"
echo ""
echo -e "${CYAN}🔗 Resources:${NC}"
echo "  Frappe Docs: https://frappeframework.com/docs"
echo "  GitHub:      https://github.com/zachclawbot/frappe-orchestrator"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
