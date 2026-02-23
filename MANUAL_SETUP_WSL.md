# Manual Frappe Setup for WSL2

This is a step-by-step manual installation if the automated script encounters issues.

## Prerequisites
- Windows 10/11 with WSL2 enabled
- Ubuntu 22.04 (or compatible Linux distro)

## Step-by-Step Installation

### 1. Enter WSL
```powershell
wsl
```

### 2. Fix APT if needed (optional)
```bash
sudo rm /var/lib/command-not-found/commands.db
sudo apt-get update
```

### 3. Install System Dependencies
```bash
sudo apt-get install -y \
    git python3-dev python3-pip python3-setuptools python3.10-venv \
    redis-server mariadb-server mariadb-client \
    software-properties-common libmysqlclient-dev \
    curl nginx build-essential libssl-dev
```

### 4. Install Node.js 18
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g yarn
```

### 5. Configure MariaDB
```bash
sudo service mariadb start

# Set root password
sudo mysql
```

In MySQL shell:
```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootPassword123';
FLUSH PRIVILEGES;
EXIT;
```

Create Frappe config:
```bash
sudo nano /etc/mysql/mariadb.conf.d/frappe.cnf
```

Add this content:
```ini
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
```

Restart MariaDB:
```bash
sudo service mariadb restart
```

### 6. Install Frappe Bench
```bash
sudo pip3 install frappe-bench
```

### 7. Create Frappe User
```bash
sudo adduser frappe --disabled-password --gecos ""
sudo usermod -aG sudo frappe
```

### 8. Initialize Bench (as frappe user)
```bash
sudo -u frappe bash
cd ~
bench init frappe-bench --frappe-branch version-15
cd frappe-bench
```

### 9. Create Site
```bash
bench new-site orchestrator.local \
    --mariadb-root-password RootPassword123 \
    --admin-password admin123

bench use orchestrator.local
```

### 10. Add Orchestrator Modules

Copy modules from Windows to WSL:
```bash
mkdir -p ~/frappe-bench/apps

cp -r /mnt/c/workspace/frappe-orchestrator/apps/orchestrator-crm ~/frappe-bench/apps/
cp -r /mnt/c/workspace/frappe-orchestrator/apps/orchestrator-hr ~/frappe-bench/apps/
cp -r /mnt/c/workspace/frappe-orchestrator/apps/orchestrator-helpdesk ~/frappe-bench/apps/
cp -r /mnt/c/workspace/frappe-orchestrator/apps/orchestrator-docs ~/frappe-bench/apps/
cp -r /mnt/c/workspace/frappe-orchestrator/apps/orchestrator-insights ~/frappe-bench/apps/
cp -r /mnt/c/workspace/frappe-orchestrator/apps/orchestrator-gameplan ~/frappe-bench/apps/
```

### 11. Install Apps
```bash
cd ~/frappe-bench

bench --site orchestrator.local install-app orchestrator-crm
bench --site orchestrator.local install-app orchestrator-hr
bench --site orchestrator.local install-app orchestrator-helpdesk
bench --site orchestrator.local install-app orchestrator-docs
bench --site orchestrator.local install-app orchestrator-insights
bench --site orchestrator.local install-app orchestrator-gameplan
```

### 12. Build Assets
```bash
bench build --app frappe
bench migrate
bench clear-cache
```

### 13. Start Development Server
```bash
bench start
```

## Access Your Application

- **URL:** http://localhost:8000
- **Username:** Administrator
- **Password:** admin123

## Troubleshooting

### MariaDB won't start
```bash
sudo service mariadb start
sudo service mariadb status
```

### Permission errors
Make sure you're running as the `frappe` user:
```bash
sudo -u frappe bash
cd ~/frappe-bench
```

### Module installation fails
```bash
cd ~/frappe-bench
bench migrate
bench build
bench clear-cache
```

### Port 8000 in use
```bash
bench serve --port 8001
```

## Next Steps

1. ✅ Access Frappe at http://localhost:8000
2. Create your first DocType (Client, Lead, etc.)
3. Customize modules with business logic
4. Build frontend forms
5. Test external API integrations

## Useful Commands

```bash
# Development
bench start                 # Start all services
bench restart              # Restart services
bench console              # Frappe Python console

# Database
bench migrate              # Run migrations
bench backup               # Backup database

# Frontend
bench build                # Build assets
bench watch                # Auto-rebuild on changes

# Debugging
bench --site orchestrator.local console    # Site console
bench --verbose start                       # Verbose logging
```

---

**Ready to develop!** 🎉
