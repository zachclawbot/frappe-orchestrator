# Quick Reference - Essential Commands

## Docker Approach (Once Registry Fixes)

```powershell
# Navigate to docker directory
cd C:\workspace\frappe-orchestrator\docker

# Check docker and docker-compose status
docker ps
docker-compose ps

# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f
docker-compose logs -f frappe
docker-compose logs -f mariadb

# Access Frappe in container
docker-compose exec frappe bash

# Initialize Frappe (database, migrations)
docker-compose exec frappe bench init frappe-orchestrator
docker-compose exec frappe bench new-site frappe-orchestrator.local
docker-compose exec frappe bench install-app orchestrator-crm

# Access application
# Browser: http://localhost (or https://localhost with self-signed cert)
# Username: admin
# Password: admin123
```

## Local Development Approach (Currently Recommended)

```powershell
# Install dependencies (one-time)
pip install frappe-bench

# Create initial bench environment
bench init C:\frappe-dev\frappe-orchestrator-bench --python <python-path>
cd frappe-orchestrator-bench

# Create site
bench new-site frappe-orchestrator.local

# Start development server
bench start

# In another terminal, install modules from C:\workspace\frappe-orchestrator\apps
cd apps
git clone <module-url> orchestrator-crm
# Repeat for other modules
cd ..

# Install module on site
bench install-app orchestrator-crm --site frappe-orchestrator.local

# Run migrations
bench migrate --site frappe-orchestrator.local

# Access application
# Browser: http://localhost:8000
# Username: Administrator
# Password: admin123
```

## Module Development

```powershell
# Create new DocType via UI
# 1. Go to http://localhost:8000
# 2. Search "DocType" in search bar
# 3. Create new doctype with fields

# Create new DocType via command (Frappe v14)
bench make-doctype

# Create custom script
# File: apps/orchestrator-crm/orchestrator_crm/doctype/lead/lead.py
# File: apps/orchestrator-crm/orchestrator_crm/public/js/lead.js

# Test your code
bench test-runner orchestrator-crm

# View console/logs
bench logs -f

# Execute Python code in Frappe context
bench console
> from frappe import db
> docs = db.get_list('Lead', limit=5)
> docs
```

## Database Operations

```powershell
# Connect to database (local setup)
mysql -u frappe -pFrappePassword123 -h localhost frappe

# View tables
SHOW TABLES;

# Query DocType
SELECT name, title FROM `tabDocType` WHERE app = 'orchestrator_crm'\G

# Reset database (local - DESTRUCTIVE!)
bench reset-db --site frappe-orchestrator.local

# Backup database
bench backup --site frappe-orchestrator.local

# View Frappe site config
cat sites/frappe-orchestrator.local/site_config.json
```

## File Locations

### Project Root
```
C:\workspace\frappe-orchestrator\
├── apps\orchestrator-*\          # Module source code
├── docker\                        # Docker configuration
├── docs\                          # Documentation
└── README.md                      # Quick start
```

### Docker-based (Once Running)
```
http://localhost:8000             # Frappe dev server
http://localhost                  # Frappe production via Nginx
Database: localhost:3306
Redis Cache: localhost:6379
Redis Queue: localhost:6380
```

### Local-based
```
C:\frappe-dev\frappe-orchestrator-bench\
├── apps\                         # Installed apps (including our modules)
├── sites\
│   └── frappe-orchestrator.local\
│       ├── site_config.json      # Site configuration
│       └── database.db           # SQLite (or MariaDB)
├── env\                          # Python virtual environment
└── .env                          # Bench configuration
```

## Common Issues & Fixes

### Docker Registry Blocked
```powershell
# See: DOCKER_REGISTRY_ISSUE.md
# Quick fix: Use local Frappe setup instead
# File: FRAPPE_LOCAL_SETUP.md
```

### Port Already in Use
```powershell
# Docker: Change in docker-compose.yml
# Local: Change port in bench start command
bench start --port 8001
```

### Database Connection Failed
```powershell
# Check MariaDB is running
mysql -u root -p -e "SELECT VERSION();"

# Verify credentials in .env (Docker) or site_config.json (Local)

# Reset and reinitialize
bench new-site frappe-orchestrator.local --force
```

### Module Not Appearing
```powershell
# Clear cache
bench clear-cache --site frappe-orchestrator.local

# Reinstall module
bench uninstall-app orchestrator-crm --site frappe-orchestrator.local
bench install-app orchestrator-crm --site frappe-orchestrator.local

# Restart development server
# Ctrl+C to stop, then: bench start
```

## Development Workflow

```powershell
# 1. Make code changes in apps/orchestrator-*/ files

# 2. If you changed DocType definition:
bench migrate --site frappe-orchestrator.local

# 3. If you changed Python code:
# Just save file - Frappe auto-reloads in dev mode

# 4. If you changed CSS/JS:
bench build

# 5. Clear cache to see changes
bench clear-cache --site frappe-orchestrator.local

# 6. Test in browser at http://localhost:8000

# 7. View console for errors:
bench logs -f
```

## Testing

```powershell
# Run all tests for a module
bench test-runner orchestrator-crm

# Run specific test
bench test-runner orchestrator-crm.doctype.lead.test_lead

# Run with coverage
bench test-runner --coverage orchestrator-crm

# View test file
# Location: apps/orchestrator-crm/orchestrator_crm/doctype/lead/test_lead.py
```

## Documentation References

| Document | Purpose | Link |
|----------|---------|------|
| Setup | Installation guide | SETUP.md |
| Architecture | System design | docs/ARCHITECTURE.md |
| Schema | DocType definitions | docs/DATA_SCHEMA.md |
| API | REST endpoints | docs/API_REFERENCE.md |
| Dev Guide | Code examples | docs/FRAPPE_DEV_QUICK_GUIDE.md |
| Local Setup | Development without Docker | FRAPPE_LOCAL_SETUP.md |
| Status | Project progress | PROJECT_STATUS.md |
| Docker Issue | Registry problems | DOCKER_REGISTRY_ISSUE.md |
| Troubleshooting | Common fixes | docs/TROUBLESHOOTING.md |

## URLs

```
# Local Development
http://localhost:8000      # Frappe dev server
http://localhost:8000/app  # Module apps list

# Docker-based (when running)
http://localhost           # Nginx reverse proxy
https://localhost          # Secure (self-signed cert)

# Web Services
http://<host>:3306        # MariaDB
http://<host>:6379        # Redis Cache
http://<host>:6380        # Redis Queue
```

## Credentials

```
# Frappe Admin (initial user created by bench)
Username: Administrator
Password: admin123

# Database (MariaDB)
User: frappe
Password: FrappePassword123
Root: RootPassword123

# System (local setup)
Update in C:\frappe-dev\frappe-orchestrator-bench\sites\frappe-orchestrator.local\site_config.json
```

---

**Last Updated:** 2026-02-19  
**Recommended Reading Order:**
1. Start with: PROJECT_STATUS.md (overview)
2. Setup: FRAPPE_LOCAL_SETUP.md or SETUP.md
3. Architecture: docs/ARCHITECTURE.md
4. Development: docs/FRAPPE_DEV_QUICK_GUIDE.md
5. Reference: This file + docs/API_REFERENCE.md
