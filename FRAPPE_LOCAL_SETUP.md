# Local Frappe Development Setup (No Docker)

## Quick Start
This guide sets up Frappe locally for development of the Orchestrator modules while Docker registry issues are resolved.

## Prerequisites

### Windows 10/11
- Python 3.11+ (download from https://www.python.org/downloads/)
- Git (download from https://git-scm.com/)
- Node.js 18+ (download from https://nodejs.org/)
- MariaDB 10.6+ (download from https://mariadb.org/download/) OR MySQL 8.0+
- Redis 7 (optional, for caching/jobs)

### Installation Steps

#### 1. Install Python 3.11
```powershell
# Download installer from https://www.python.org/downloads/
# Run installer with "Add Python to PATH" checked
python --version  # Should show 3.11.x
```

#### 2. Install Git
```powershell
# Download from https://git-scm.com/download/win
# Use default installation options
git --version  # Should show 2.x.x
```

#### 3. Install Node.js
```powershell
# Download from https://nodejs.org/ (LTS version)
# Use default installation options
node --version  # Should show v18.x.x or higher
npm --version   # Should show 8.x.x or higher
```

#### 4. Install MariaDB (or MySQL)
```powershell
# Download MariaDB 10.6 from: https://mariadb.org/download/
# Run installer:
#   - Choose "Install as service"
#   - Port: 3306
#   - Set root password: RootPassword123
#   - Enable UTF-8

# Verify installation:
mysql -u root -pRootPassword123 -e "SELECT VERSION();"
```

#### 5. Install Redis (Optional but recommended)
```powershell
# Download from: https://github.com/microsoftarchive/redis/releases
# Or use Windows Subsystem for Linux (WSL):
wsl
sudo apt-get update
sudo apt-get install redis-server
redis-server --version
```

## Setup Frappe Bench

### Step 1: Create Project Directory
```powershell
# Navigate to where you want Frappe installed
cd C:\frappe-dev
mkdir frappe-orchestrator
cd frappe-orchestrator
```

### Step 2: Install Frappe Bench
```powershell
# Install bench using pip
pip install frappe-bench

# Verify installation
bench --version  # Should show version 5.x or higher
```

### Step 3: Initialize Frappe
```powershell
# Create a new Frappe site
bench init frappe-orchestrator-bench --python C:\Users\<YourUsername>\AppData\Local\Programs\Python\Python311\python.exe

# Navigate into the bench directory
cd frappe-orchestrator-bench

# Create a new site
bench new-site frappe-orchestrator.local

# When prompted:
# Database: frappe
# MariaDB root password: RootPassword123
# Admin password: admin123
```

### Step 4: Install ERPNext (Optional)
```powershell
# Get the official ERPNext app
bench get-app erpnext https://github.com/frappe/erpnext.git

# Install on your site
bench install-app erpnext --site frappe-orchestrator.local

# Install other useful apps
bench get-app hrms https://github.com/frappe/crm.git
```

### Step 5: Install Our Orchestrator Modules
```powershell
# Clone the module repositories (or add as submodules)
cd apps
git clone <url-to-orchestrator-crm> orchestrator-crm
git clone <url-to-orchestrator-hr> orchestrator-hr
git clone <url-to-orchestrator-helpdesk> orchestrator-helpdesk
git clone <url-to-orchestrator-docs> orchestrator-docs
git clone <url-to-orchestrator-insights> orchestrator-insights
git clone <url-to-orchestrator-gameplan> orchestrator-gameplan

# Install each module on your site
cd ..
bench install-app orchestrator-crm --site frappe-orchestrator.local
bench install-app orchestrator-hr --site frappe-orchestrator.local
bench install-app orchestrator-helpdesk --site frappe-orchestrator.local
bench install-app orchestrator-docs --site frappe-orchestrator.local
bench install-app orchestrator-insights --site frappe-orchestrator.local
bench install-app orchestrator-gameplan --site frappe-orchestrator.local
```

## Running Frappe

### Start Development Server
```powershell
# From bench directory
bench start

# Or run specific processes
bench start --foreground

# Starts on http://localhost:8000
```

### Access Application
- URL: http://localhost:8000
- Username: Administrator
- Password: admin123

### Manage Services
```powershell
# Stop development server
# Press Ctrl+C in the terminal where bench start is running

# Start background worker/scheduler (optional)
bench worker
bench worker-short
bench schedule

# View logs
bench logs
```

## Database Access

### Direct Database Access
```powershell
# Connect to MariaDB
mysql -u root -pRootPassword123

# View Frappe database
SHOW DATABASES;
USE frappe;
SHOW TABLES;

# Sample query
SELECT name, title FROM `tabDocType` LIMIT 10;
```

### PHPMyAdmin (Optional)
```powershell
# Download and install PHPMyAdmin for GUI database management
# Or use VS Code extension: "MySQL" or "SQLTools"
```

## Development Workflow

### Create DocTypes
```powershell
# Use the Frappe UI:
# 1. Open http://localhost:8000
# 2. Search for "DocType"
# 3. Create new DocType
# 4. Define fields, permissions, validations

# Or use bench CLI:
bench make-migration create_doctype_name
```

### Create Custom Scripts
```powershell
# Create Python controllers
# Location: apps/orchestrator-crm/orchestrator_crm/doctype/lead/lead.py

# Create JavaScript snippets
# Location: apps/orchestrator-crm/orchestrator_crm/public/js/

# Use Frappe hooks for business logic
# File: apps/orchestrator-crm/orchestrator_crm/__init__.py
```

### Debugging
```powershell
# Enable debug mode
bench set-config developer_mode 1

# View console output
bench logs -f  # Follow logs in real-time

# Use Python debugger
# Add breakpoints in your code:
import pdb; pdb.set_trace()  # Python debugger
```

## Common Commands

```powershell
# Inside bench directory

# Database
bench migrate              # Run pending migrations
bench reset-db             # Reset database (careful!)

# Apps
bench get-app <app-name> <git-url>
bench install-app <app-name> --site <site-name>
bench uninstall-app <app-name> --site <site-name>

# Development
bench build                # Build assets
bench start                # Start dev server
bench console              # Python REPL with Frappe context

# Testing
bench test-runner          # Run tests
bench test-backend         # Run backend tests

# Utility
bench setup requirements   # Install Python/Node dependencies
bench clear-cache          # Clear Redis cache
bench backup                # Backup database and files
```

## Troubleshooting

### Port Already in Use
```powershell
# If port 8000 is busy, specify different port
bench start --port 8001
```

### Database Connection Error
```powershell
# Verify MariaDB is running:
mysql -u root -pRootPassword123 -e "SELECT VERSION();"

# Check Frappe site config:
cat sites/frappe-orchestrator.local/site_config.json
```

### Module Not Loading
```powershell
# Reinstall module:
bench uninstall-app orchestrator-crm --site frappe-orchestrator.local
bench install-app orchestrator-crm --site frappe-orchestrator.local

# Check module syntax:
python -m py_compile apps/orchestrator-crm/orchestrator_crm/__init__.py
```

### Permission Denied Error
```powershell
# Run PowerShell as Administrator for file permissions
# Or use WSL (Windows Subsystem for Linux) for better compatibility
```

## Next Steps

1. **Setup**: Follow steps 1-5 above (takes ~30-45 minutes)
2. **Verify**: Open http://localhost:8000 and login with admin/admin123
3. **Create DocTypes**: Use the Frappe UI or use `DATA_SCHEMA.md` for reference
4. **Develop Modules**: Add custom fields and business logic to each module
5. **Test**: Use the Frappe testing framework
6. **Document**: Update this guide as you discover more

## References

- [Frappe Official Docs](https://frappeframework.com/docs/v14)
- [Frappe Bench Documentation](https://frappeframework.com/docs/v14/user/manual/en/installation)
- [ERPNext Installation Guide](https://erpnext.com/docs/user/manual/en/setup/installation)
- [See FRAPPE_DEV_QUICK_GUIDE.md](../docs/FRAPPE_DEV_QUICK_GUIDE.md) for code examples

## Support

If setup fails:
1. Check that Python 3.11+ is properly installed
2. Verify MariaDB is running and accessible
3. Check firewall settings allowing localhost connections
4. Review Frappe logs: `bench logs -f`
5. Visit https://discuss.erpnext.com/ for community support
