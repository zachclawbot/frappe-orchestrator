# Docker TLS Certificate Verification Issue

## Problem
Docker daemon is failing to pull images due to TLS certificate validation:
```
x509: certificate has expired or is not yet valid: current time 2026-02-19T15:37:17Z is before 2026-02-19T20:57:44Z
```

**Note:** System time (2026-02-19 08:27:05 AM) is correct. The issue is with Docker's internal certificate validation.

## Solutions (in order of preference)

### Solution 1: Restart Docker Desktop
**Windows 10/11:**
1. Open Task Manager (Ctrl+Shift+Esc)
2. Find "Docker Desktop" process
3. Right-click → End Task
4. Wait 10 seconds
5. Open Docker Desktop application again
6. Wait for "Docker is running" notification
7. Retry: `docker-compose up -d`

### Solution 2: Reset Docker Engine
**Windows 10/11 (Docker Desktop):**
1. Open Settings (Gear icon in Docker Desktop)
2. Go to Resources → Advanced
3. Click "Reset Docker Engine to factory settings"
4. Confirm and wait for restart
5. Retry: `docker-compose up -d`

### Solution 3: Update Docker Desktop
Check if Docker Desktop has available updates:
```powershell
# Docker Desktop → Check for updates
# Current version: 29.2.1
# Update to latest stable release
```

### Solution 4: Configure Insecure Registries (Temporary)
**WARNING: Not recommended for production**
1. Edit Docker Desktop daemon.json:
   - File location: `C:\Users\[USERNAME]\AppData\Roaming\Docker\daemon.json`
2. Add:
   ```json
   {
     "insecure-registries": ["docker.io", "registry-1.docker.io"]
   }
   ```
3. Restart Docker Desktop
4. Retry: `docker-compose up -d`

## Fallback: Manual Image Pre-download
If above solutions don't work, manually download images on a different system or use cached images:

```powershell
# Check available Docker images
docker images

# If needed, save/load images from tar files
docker save mariadb:10.6 -o mariadb.tar
docker save redis:7-alpine -o redis.tar
docker save nginx:alpine -o nginx.tar
```

## Testing
After fix, verify connectivity:
```powershell
cd C:\workspace\frappe-orchestrator\docker
docker pull nginx:alpine
docker-compose up -d
docker-compose ps
```

## Documentation
- Docker Desktop for Windows: https://docs.docker.com/docker-for-windows/
- Docker Registry Certificate Issues: https://docs.docker.com/docker-desktop/troubleshoot/topics/#certificate-errors
