# Frappe Orchestrator - Quick Start Guide

## ✅ What's Been Set Up

### GitHub Repository
**Repository:** https://github.com/zachclawbot/frappe-orchestrator
- ✓ All code pushed and version-controlled
- ✓ 6 custom Frappe modules (CRM, HR, Helpdesk, Documents, Insights, Gameplan)
- ✓ Complete Docker infrastructure
- ✓ Comprehensive documentation (8,200+ lines)
- ✓ Automated setup scripts

### Project Structure
```
frappe-orchestrator/
├── apps/                      # 6 Frappe modules
├── docker/                    # Docker configuration (ready for later)
├── docs/                      # Full documentation
├── scripts/                   # Utility scripts
├── setup-wsl-frappe.sh       # WSL2 automated setup (recommended)
├── setup-frappe-local.ps1    # Windows PowerShell setup (limited support)
└── README.md                  # Project overview
```

---

## 🚀 Getting Started - Two Options

### Option 1: WSL2 Setup (Recommended) ✅

**Why WSL2?** Frappe requires a Linux environment. WSL2 gives you native Linux on Windows.

**You already have:** WSL2 with Ubuntu 22.04 installed

**Steps:**

1. **Run the automated setup script:**
   ```powershell
   # From PowerShell/Windows Terminal
   wsl -e bash /mnt/c/workspace/frappe-orchestrator/setup-wsl-frappe.sh
   ```

   This script will:
   - Install all dependencies (Python, Node.js, MariaDB, Redis)
   - Configure MariaDB for Frappe
   - Create a `frappe` user
   - Initialize Frappe bench
   - Create the site `orchestrator.local`
   - Link all 6 orchestrator modules
   - Install modules and build assets

   **Time:** 15-20 minutes (depending on internet speed)

2. **Start Frappe:**
   ```powershell
   wsl
   sudo -u frappe bash
   cd ~/frappe-bench
   bench start
   ```

3. **Access the application:**
   - **URL:** http://localhost:8000
   - **Username:** Administrator
   - **Password:** admin123

---

### Option 2: Manual WSL Setup (If automated script fails)

```bash
# 1. Enter WSL
wsl

# 2. Update system
sudo apt-get update
sudo apt-get upgrade -y

# 3. Install dependencies
sudo apt-get install -y git python3-dev python3-pip python3-setuptools \
    redis-server mariadb-server libmysqlclient-dev curl nginx

# 4. Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g yarn

# 5. Install frappe-bench
sudo pip3 install frappe-bench

# 6. Create frappe user
sudo adduser frappe --disabled-password
sudo usermod -aG sudo frappe

# 7. Initialize bench (as frappe user)
sudo -u frappe bash
cd ~
bench init frappe-bench --frappe-branch version-15
cd frappe-bench

# 8. Configure MariaDB
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootPassword123';
FLUSH PRIVILEGES;
EXIT;

# Configure UTF-8
sudo nano /etc/mysql/mariadb.conf.d/frappe.cnf
# Add:
# [mysqld]
# character-set-server = utf8mb4
# collation-server = utf8mb4_unicode_ci
sudo service mariadb restart

# 9. Create site
bench new-site orchestrator.local \
    --mariadb-root-password RootPassword123 \
    --admin-password admin123

# 10. Copy orchestrator modules to apps/
cp -r /mnt/c/workspace/frappe-orchestrator/apps/* ~/frappe-bench/apps/

# 11. Install orchestrator apps
bench --site orchestrator.local install-app orchestrator-crm
bench --site orchestrator.local install-app orchestrator-hr
bench --site orchestrator.local install-app orchestrator-helpdesk
bench --site orchestrator.local install-app orchestrator-docs
bench --site orchestrator.local install-app orchestrator-insights
bench --site orchestrator.local install-app orchestrator-gameplan

# 12. Build and start
bench build
bench migrate
bench start
```

---

## 🔧 Common Commands

### Development
```bash
bench start              # Start development server
bench restart            # Restart all services
bench migrate            # Run database migrations
bench build              # Build frontend assets
bench clear-cache        # Clear all caches
bench console            # Interactive Frappe console
```

### App Management
```bash
bench new-app <name>                        # Create new app
bench get-app <repo-url>                   # Download app from GitHub
bench --site <site> install-app <app>      # Install app on site
bench --site <site> uninstall-app <app>    # Remove app from site
```

### Site Management
```bash
bench new-site <site-name>    # Create new site
bench use <site-name>         # Set default site
bench backup                  # Backup site database
bench restore <backup-file>   # Restore from backup
```

---

## 📁 Directory Structure (Inside WSL)

```
/home/frappe/frappe-bench/
├── apps/                           # Frappe applications
│   ├── frappe/                     # Core Frappe framework
│   ├── orchestrator-crm/           # Your CRM module
│   ├── orchestrator-hr/            # Your HR module
│   ├── orchestrator-helpdesk/      # Your Helpdesk module
│   ├── orchestrator-docs/          # Your Documents module
│   ├── orchestrator-insights/      # Your Insights module
│   └── orchestrator-gameplan/      # Your Gameplan module
├── sites/                          # Frappe sites
│   └── orchestrator.local/        # Your site
├── config/                         # Configuration files
└── env/                            # Python virtual environment
```

---

## 🐛 Troubleshooting

### WSL Issues

**Problem:** WSL command not found
```powershell
wsl --install
# Restart computer
```

**Problem:** Can't access http://localhost:8000
- Check if `bench start` is running without errors
- Verify MariaDB is running: `sudo service mariadb status`
- Check Redis: `sudo service redis-server status`

### Frappe Issues

**Problem:** Import errors when starting bench
```bash
cd ~/frappe-bench
bench migrate
bench build
bench restart
```

**Problem:** Database connection errors
```bash
sudo service mariadb start
mysql -u root -pRootPassword123 -e "SHOW DATABASES;"
```

**Problem:** Port 8000 already in use
```bash
# Find and kill the process
lsof -ti:8000 | xargs kill -9
# Or use a different port
bench serve --port 8001
```

---

## 🐳 Docker Setup (Later)

Once local development is working, you can containerize with Docker:

```powershell
cd C:\workspace\frappe-orchestrator\docker
docker-compose up -d
```

**Note:** Docker registry issue needs to be resolved first (see `DOCKER_REGISTRY_ISSUE.md`)

---

## 📚 Next Steps - Development Roadmap

### Phase 2: Build Out DocTypes
1. Create DocTypes for CRM module (Lead, Contact, Company)
2. Create DocTypes for HR module (Employee, Leave, Attendance)
3. Create DocTypes for Helpdesk (Issue, SLA)

### Phase 3: Implement Business Logic
1. Add validation rules
2. Create workflows
3. Build custom APIs
4. Design UI forms

### Phase 4: External Integrations
1. Kipu healthcare data sync
2. External API adapters
3. Webhooks

### Phase 5: Docker & Production
1. Fix Docker registry issue
2. Test docker-compose locally
3. Deploy to Google Cloud Run

---

## 🔗 Resources

- **GitHub:** https://github.com/zachclawbot/frappe-orchestrator
- **Frappe Docs:** https://frappeframework.com/docs
- **Frappe Forum:** https://discuss.frappe.io
- **ERPNext (reference):** https://erpnext.com

---

## 📞 Support

If you encounter issues:
1. Check `docs/TROUBLESHOOTING.md`
2. Review Frappe forum
3. Check GitHub issues
4. Ask me (Ronald) for help!

---

**Last Updated:** 2026-02-22  
**Setup Status:** WSL2 installation in progress
