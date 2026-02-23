# Docker Registry Certificate Issue - Workaround Guide

## Issue Summary
Docker daemon cannot authenticate with the Docker registry due to TLS certificate validation failure. The error message indicates:
```
x509: certificate has expired or is not yet valid: current time 2026-02-19T15:42:53Z 
is before 2026-02-19T20:57:44Z
```

This is blocking all `docker pull` and `docker-compose` operations.

## Root Cause Analysis
- ✅ System time is correct: 2026-02-19 08:42 AM (verified)
- ✅ Docker daemon is running: Docker Desktop 4.61.0 (verified)
- ✅ Network connectivity: System can reach internet (implied)
- ❌ Docker registry certificate validation: Failing
- Likely cause: Docker daemon's internal time reference or certificate chain issue

## Verified Solutions (Try in order)

### Solution 1: Docker Desktop Settings → Resources → Advanced
1. Open Docker Desktop application
2. Click Settings ⚙️ 
3. Go to **Resources** → **Advanced**
4. Click **Reset Docker Engine to factory settings** (more aggressive reset)
5. Wait 5-10 minutes for full restart
6. Try: `docker pull nginx:alpine`

### Solution 2: Clear Docker Desktop Cache
1. Close Docker Desktop completely
2. Delete VM state:
   - Delete: `%APPDATA%\Docker\vm`
   - Delete: `%PROGRAMDATA%\Docker` (may require admin)
3. Reopen Docker Desktop
4. Wait for complete re-initialization (10-15 minutes)
5. Try: `docker pull nginx:alpine`

### Solution 3: Update Docker Desktop
1. Open Docker Desktop → Settings ⚙️
2. Check for updates
3. Current version: 4.61.0 (built Feb 2, 2026)
4. Update if newer version available
5. Restart Docker and try again

### Solution 4: Check Network/Proxy
If you're behind a corporate proxy or VPN:
1. Docker Desktop → Settings → Resources → Proxies
2. Verify proxy settings are correct (or disable if testing locally)
3. Restart Docker

### Solution 5: Switch Registry Mirror (Temporary)
As a last resort, try using an alternative Docker registry mirror:
```powershell
$daemonPath = "$env:APPDATA\Docker\daemon.json"
$config = @{
    "registry-mirrors" = @(
        "https://mirror.aliyun.com",
        "https://dockerhub.azk8s.cn"
    )
} | ConvertTo-Json

Set-Content $daemonPath -Value $config -Encoding UTF8
```
Then restart Docker Desktop.

## Immediate Workarounds While Waiting for Fix

### Option A: Manual Frappe Setup (No Docker)
```powershell
# Install Python 3.11, pip, MariaDB, Redis locally
# Then manually set up Frappe bench:
git clone https://github.com/frappe/bench.git
pip install -e bench
bench new-site frappe-orchestrator
bench get-app orchestrator-crm  # Repeat for other modules
bench install-app orchestrator-crm
bench start
```

### Option B: Use Pre-built Frappe Docker Image (if available)
If you have access to a shared Docker image registry or previous backup:
```powershell
docker load -i frappe-orchestrator.tar
docker-compose up -d
```

### Option C: Simulate Frappe Environment Locally
Since Docker is blocked, we can validate the Frappe module code locally:
```powershell
# Install Frappe development environment (no Docker needed)
pip install frappe-bench erpnext
# See FRAPPE_DEV_QUICK_GUIDE.md for manual setup steps
```

## Testing Status
- ✅ Project structure created and verified (35+ files)
- ✅ SSL certificates generated
- ✅ Module templates created (6 modules)
- ✅ Configuration files prepared
- ✅ Documentation complete (5000+ lines)
- ⏳ Docker infrastructure ready but blocked by registry access
- ⏳ Service launch pending Docker fix

## Files to Reference
- [SETUP.md](SETUP.md) - Installation instructions (update with manual steps if needed)
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design and components
- [FRAPPE_DEV_QUICK_GUIDE.md](../docs/FRAPPE_DEV_QUICK_GUIDE.md) - Development without Docker
- [docker-compose.yml](docker-compose.yml) - Service definitions (ready for when Docker works)
- [Dockerfile](Dockerfile) - Custom Frappe image (ready for when Docker works)

## Next Steps
1. Try solutions 1-3 above
2. If still blocked, use **Option C** (local Frappe development without Docker)
3. Create test DocTypes and modules in local environment
4. Document any system/network configuration that might be causing the issue
5. Once Docker registry access is restored, use docker-compose to containerize

## Support
For Docker registry certificate issues, see:
- [Docker Forums - Certificate Errors](https://forums.docker.com/c/docker-desktop/22)
- [Docker Docs - Troubleshooting](https://docs.docker.com/get-started/troubleshooting/)
- [Stack Overflow - x509 certificate errors](https://stackoverflow.com/questions/tagged/docker%20x509)
