# MANUAL FRAPPE INSTALLATION - Step by Step

This is the manual approach if you can't run the automated script as Administrator.

## Quick Check - Do You Have These Installed?

Run each command in PowerShell:
```powershell
python --version
node --version
npm --version
git --version
mysql --version
```

If any are missing, follow the installation steps below.

## Installation Steps

### 1. Python 3.11
Download from: https://www.python.org/downloads/
- Choose Python 3.11 Latest
- IMPORTANT: Check "Add Python to PATH" during installation
- Click Install

Verify:
```powershell
python --version
```

### 2. Node.js 18+ (LTS)
Download from: https://nodejs.org/
- Choose LTS version
- Run installer, use default options

Verify:
```powershell
node --version
npm --version
```

### 3. Git
Download from: https://git-scm.com/download/win
- Run installer, use default options

Verify:
```powershell
git --version
```

### 4. MariaDB 10.6
Download from: https://mariadb.org/download/
- Choose Windows MSI (.msi) installer
- Run installer
- When asked for port: Use 3306
- When asked for root password: RootPassword123
- Check "Enable UTF-8..."
- Check "Install as service"

Verify:
```powershell
mysql -u root -pRootPassword123 -e "SELECT VERSION();"
```

### 5. Upgrade pip (Windows PowerShell)
```powershell
python -m pip install --upgrade pip setuptools wheel
```

### 6. Install Frappe Bench
```powershell
pip install frappe-bench
bench --version
```

### 7. Setup Frappe Directory
```powershell
mkdir C:\frappe-dev
cd C:\frappe-dev
```

### 8. Initialize Frappe Bench
This takes 5-10 minutes
```powershell
bench init frappe-orchestrator-bench --python python --no-setup-docker
cd frappe-orchestrator-bench
```

### 9. Create Frappe Site
This takes 5-10 minutes (downloading dependencies)
```powershell
bench new-site frappe-orchestrator.local --admin-password admin123 --db-name frappe --db-host localhost --db-user frappe --db-password FrappePassword123
```

### 10. Install Orchestrator Modules
First, copy the modules:
```powershell
# Copy from your project into bench apps
Copy-Item -Path "C:\workspace\frappe-orchestrator\apps\orchestrator-*" -Destination "apps" -Recurse -Force
```

Then install each one:
```powershell
bench install-app orchestrator-crm --site frappe-orchestrator.local
bench install-app orchestrator-hr --site frappe-orchestrator.local
bench install-app orchestrator-helpdesk --site frappe-orchestrator.local
bench install-app orchestrator-docs --site frappe-orchestrator.local
bench install-app orchestrator-insights --site frappe-orchestrator.local
bench install-app orchestrator-gameplan --site frappe-orchestrator.local
```

## Start Working!

Once everything is installed:

```powershell
# Make sure you're in the bench directory
cd C:\frappe-dev\frappe-orchestrator-bench

# Start Frappe
bench start
```

Then open in browser:
- URL: http://localhost:8000
- Username: Administrator
- Password: admin123

## Troubleshooting Steps

### Python Not Found After Installation
- Close and reopen PowerShell
- Verify PATH: echo $env:Path (should include Python folder)

### Port 8000 Already in Use
```powershell
bench start --port 8001
```
Then access at http://localhost:8001

### Database Connection Failed
```powershell
# Make sure MariaDB is running and accessible
mysql -u frappe -pFrappePassword123 -h localhost -e "SELECT 1;"
```

### Can't Find bench Command
```powershell
# Make sure pip installed it globally
pip install --upgrade frappe-bench
```

### Need to Start Over
```powershell
# Reset Frappe site (destructive!)
bench reset-db --site frappe-orchestrator.local

# Or create fresh Frappe installation
rm -Recurse -Force C:\frappe-dev\frappe-orchestrator-bench
cd C:\frappe-dev
bench init frappe-orchestrator-bench --python python --no-setup-docker
```

## Important Files

- Working Directory: `C:\frappe-dev\frappe-orchestrator-bench`
- Configuration: `sites\frappe-orchestrator.local\site_config.json`
- Modules: `apps\orchestrator-*\`
- Documentation: `C:\workspace\frappe-orchestrator\GETTING_STARTED.md`

## Next Steps After Setup

1. Open http://localhost:8000
2. Login with admin/admin123
3. Search for "DocType" in the search bar
4. Create your first custom DocType following DATA_SCHEMA.md
5. Explore the CRM, HR, and other modules

Good luck!
