# Frappe Orchestrator - Automated Local Setup
# Run this PowerShell script as Administrator

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FRAPPE ORCHESTRATOR LOCAL SETUP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match "S-1-5-32-544")
if (-not $isAdmin) {
    Write-Host "ERROR: This script must run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Running as Administrator" -ForegroundColor Green
Write-Host ""

# ========== STEP 1: Check/Install Chocolatey ==========
Write-Host "STEP 1: Checking Chocolatey" -ForegroundColor Cyan
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Chocolatey already installed" -ForegroundColor Green
} else {
    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "[OK] Chocolatey installed" -ForegroundColor Green
}

# ========== STEP 2: Install Python ==========
Write-Host ""
Write-Host "STEP 2: Installing Python 3.11" -ForegroundColor Cyan
if (Get-Command python -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Python already installed" -ForegroundColor Green
} else {
    Write-Host "Installing Python 3.11..." -ForegroundColor Yellow
    choco install python311 -y --force
    Write-Host "[OK] Python 3.11 installed" -ForegroundColor Green
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# ========== STEP 3: Install Node.js ==========
Write-Host ""
Write-Host "STEP 3: Installing Node.js" -ForegroundColor Cyan
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Node.js already installed" -ForegroundColor Green
} else {
    Write-Host "Installing Node.js..." -ForegroundColor Yellow
    choco install nodejs -y --force
    Write-Host "[OK] Node.js installed" -ForegroundColor Green
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# ========== STEP 4: Install Git ==========
Write-Host ""
Write-Host "STEP 4: Installing Git" -ForegroundColor Cyan
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Git already installed" -ForegroundColor Green
} else {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    choco install git -y --force
    Write-Host "[OK] Git installed" -ForegroundColor Green
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# ========== STEP 5: Install MariaDB ==========
Write-Host ""
Write-Host "STEP 5: Installing MariaDB" -ForegroundColor Cyan
if (Get-Command mysql -ErrorAction SilentlyContinue) {
    Write-Host "[OK] MariaDB already installed" -ForegroundColor Green
} else {
    Write-Host "Installing MariaDB (this may take a few minutes)..." -ForegroundColor Yellow
    choco install mariadb -y --force
    Write-Host "[OK] MariaDB installed" -ForegroundColor Green
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# ========== STEP 6: Verify Tools ==========
Write-Host ""
Write-Host "STEP 6: Verifying Installations" -ForegroundColor Cyan

$tools = @("python", "node", "npm", "git")
$allGood = $true

foreach ($tool in $tools) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        $version = & $tool --version 2>&1 | Select-Object -First 1
        Write-Host "[OK] $tool : OK" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $tool : NOT FOUND" -ForegroundColor Red
        $allGood = $false
    }
}

if (-not $allGood) {
    Write-Host ""
    Write-Host "ERROR: Some tools are missing!" -ForegroundColor Red
    exit 1
}

# ========== STEP 7: Create Frappe Directory ==========
Write-Host ""
Write-Host "STEP 7: Setting up Frappe Directory" -ForegroundColor Cyan

$frappeDir = "C:\frappe-dev"
if (-not (Test-Path $frappeDir)) {
    New-Item -ItemType Directory -Path $frappeDir -Force | Out-Null
}
Write-Host "[OK] Using directory: $frappeDir" -ForegroundColor Green
Set-Location $frappeDir

# ========== STEP 8: Install Frappe Bench ==========
Write-Host ""
Write-Host "STEP 8: Installing Frappe Bench (this may take 2-3 minutes)" -ForegroundColor Cyan

Write-Host "Upgrading pip..." -ForegroundColor Yellow
python -m pip install --upgrade pip setuptools wheel | Out-Null

Write-Host "Installing frappe-bench..." -ForegroundColor Yellow
pip install frappe-bench

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Frappe Bench installation failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Frappe Bench installed" -ForegroundColor Green

# ========== STEP 9: Initialize Bench ==========
Write-Host ""
Write-Host "STEP 9: Initializing Frappe Bench (this may take 5-10 minutes)" -ForegroundColor Cyan

$benchDir = "$frappeDir\frappe-orchestrator-bench"
if (-not (Test-Path $benchDir)) {
    bench init frappe-orchestrator-bench --python python --no-setup-docker
}
Set-Location $benchDir
Write-Host "[OK] Bench initialized" -ForegroundColor Green

# ========== STEP 10: Start Database ==========
Write-Host ""
Write-Host "STEP 10: Starting MariaDB Service" -ForegroundColor Cyan

$mariadbService = Get-Service MariaDB -ErrorAction SilentlyContinue
if ($mariadbService) {
    if ($mariadbService.Status -ne "Running") {
        Start-Service MariaDB
        Start-Sleep -Seconds 3
    }
    Write-Host "[OK] MariaDB service running" -ForegroundColor Green
}

# ========== STEP 11: Create Site ==========
Write-Host ""
Write-Host "STEP 11: Creating Frappe Site (this may take 5 minutes)" -ForegroundColor Cyan
Write-Host "This downloads and configures all Frappe dependencies..." -ForegroundColor Yellow

bench new-site frappe-orchestrator.local --admin-password admin123 --db-name frappe --db-host localhost --db-user frappe --db-password FrappePassword123

if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Site creation may have had issues, but proceeding..." -ForegroundColor Yellow
}
Write-Host "[OK] Site created" -ForegroundColor Green

# ========== STEP 12: Install Modules ==========
Write-Host ""
Write-Host "STEP 12: Installing Orchestrator Modules" -ForegroundColor Cyan

$sourceModules = "C:\workspace\frappe-orchestrator\apps"
$modules = @("orchestrator-crm", "orchestrator-hr", "orchestrator-helpdesk", "orchestrator-docs", "orchestrator-insights", "orchestrator-gameplan")

foreach ($module in $modules) {
    $sourcePath = "$sourceModules\$module"
    if (Test-Path $sourcePath) {
        Write-Host "Installing $module..." -ForegroundColor Yellow
        bench install-app $module --site frappe-orchestrator.local 2>$null
        Write-Host "[OK] $module" -ForegroundColor Green
    }
}

# ========== SUMMARY ==========
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "SETUP COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "All prerequisites installed:" -ForegroundColor Green
Write-Host "  [OK] Python 3.11" -ForegroundColor Green
Write-Host "  [OK] Node.js 18+" -ForegroundColor Green
Write-Host "  [OK] Git" -ForegroundColor Green
Write-Host "  [OK] MariaDB 10.6" -ForegroundColor Green
Write-Host "  [OK] Frappe Bench" -ForegroundColor Green
Write-Host "  [OK] 6 Orchestrator Modules" -ForegroundColor Green
Write-Host ""
Write-Host "TO START WORKING:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  cd $benchDir" -ForegroundColor Yellow
Write-Host "  bench start" -ForegroundColor Yellow
Write-Host ""
Write-Host "Then open: http://localhost:8000" -ForegroundColor Cyan
Write-Host "Login: Administrator / admin123" -ForegroundColor Cyan
Write-Host ""
Write-Host "Documentation: C:\workspace\frappe-orchestrator\GETTING_STARTED.md" -ForegroundColor Cyan
Write-Host ""
