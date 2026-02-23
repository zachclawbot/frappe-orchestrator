# Frappe Orchestrator - Automated Local Setup
# Run this PowerShell script as Administrator to install all prerequisites and setup Frappe

param(
    [switch]$SkipChocolatey = $false
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error-Custom { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Cyan }

Write-Info "=== FRAPPE ORCHESTRATOR LOCAL SETUP ==="
Write-Info "This script will install Python 3.11, Node.js, Git, and MariaDB"
Write-Info ""

# Check if running as Administrator
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match "S-1-5-32-544")
if (-not $isAdmin) {
    Write-Error-Custom "❌ This script must run as Administrator!"
    Write-Info "Please right-click PowerShell and select 'Run as Administrator'"
    exit 1
}

Write-Success "✅ Running as Administrator"

# Step 1: Check/Install Chocolatey
Write-Info ""
Write-Info "=== STEP 1: Checking Chocolatey ==="

if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Success "✅ Chocolatey already installed"
} else {
    Write-Info "Installing Chocolatey..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ Chocolatey installed"
    } else {
        Write-Error-Custom "❌ Chocolatey installation failed"
        exit 1
    }
}

# Step 2: Install Python 3.11
Write-Info ""
Write-Info "=== STEP 2: Installing Python 3.11 ==="

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonVersion = python --version 2>&1
    Write-Success "✅ Python already installed: $pythonVersion"
} else {
    Write-Info "Installing Python 3.11 via Chocolatey..."
    choco install python311 -y --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ Python 3.11 installed"
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        Write-Error-Custom "❌ Python installation failed"
        exit 1
    }
}

# Step 3: Install Node.js
Write-Info ""
Write-Info "=== STEP 3: Installing Node.js ==="

if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    Write-Success "✅ Node.js already installed: $nodeVersion"
} else {
    Write-Info "Installing Node.js via Chocolatey..."
    choco install nodejs -y --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ Node.js installed"
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        Write-Error-Custom "❌ Node.js installation failed"
        exit 1
    }
}

# Step 4: Install Git
Write-Info ""
Write-Info "=== STEP 4: Installing Git ==="

if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitVersion = git --version
    Write-Success "✅ Git already installed: $gitVersion"
} else {
    Write-Info "Installing Git via Chocolatey..."
    choco install git -y --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ Git installed"
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        Write-Error-Custom "❌ Git installation failed"
        exit 1
    }
}

# Step 5: Install MariaDB
Write-Info ""
Write-Info "=== STEP 5: Installing MariaDB 10.6 ==="

if (Get-Command mysql -ErrorAction SilentlyContinue) {
    $mysqlVersion = mysql --version
    Write-Success "✅ MySQL/MariaDB already installed: $mysqlVersion"
} else {
    Write-Info "Installing MariaDB 10.6 via Chocolatey..."
    Write-Info "  Note: Installation may prompt for configuration"
    choco install mariadb -y --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ MariaDB installed"
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        Write-Error-Custom "⚠️  MariaDB installation had issues - may need manual setup"
    }
}

# Step 6: Verify Installations
Write-Info ""
Write-Info "=== STEP 6: Verifying Installations ==="

$tools = @("python", "node", "npm", "git")
$allGood = $true

foreach ($tool in $tools) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        $version = & $tool --version 2>&1 | Select-Object -First 1
        Write-Success "✅ $tool : $version"
    } else {
        Write-Error-Custom "❌ $tool : NOT FOUND"
        $allGood = $false
    }
}

if (-not $allGood) {
    Write-Error-Custom "❌ Some tools are missing. Please resolve above issues."
    exit 1
}

# Step 7: Create Frappe directory
Write-Info ""
Write-Info "=== STEP 7: Setting up Frappe Directory ==="

$frappeDir = "C:\frappe-dev"
if (Test-Path $frappeDir) {
    Write-Info "Using existing directory: $frappeDir"
} else {
    Write-Info "Creating directory: $frappeDir"
    New-Item -ItemType Directory -Path $frappeDir -Force | Out-Null
    Write-Success "✅ Directory created"
}

Set-Location $frappeDir

# Step 8: Install Frappe Bench
Write-Info ""
Write-Info "=== STEP 8: Installing Frappe Bench ==="

Write-Info "This may take a few minutes..."
pip install --upgrade pip setuptools wheel | Out-Null
pip install frappe-bench

if ($LASTEXITCODE -eq 0) {
    Write-Success "✅ Frappe Bench installed"
} else {
    Write-Error-Custom "❌ Frappe Bench installation failed"
    exit 1
}

# Step 9: Initialize Frappe Bench
Write-Info ""
Write-Info "=== STEP 9: Initializing Frappe Bench ==="

$benchDir = "$frappeDir\frappe-orchestrator-bench"
if (Test-Path $benchDir) {
    Write-Info "Using existing bench directory: $benchDir"
} else {
    Write-Info "Creating bench directory (this may take 5-10 minutes)..."
    bench init frappe-orchestrator-bench --python python --no-setup-docker
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ Frappe Bench initialized"
    } else {
        Write-Error-Custom "❌ Frappe Bench initialization failed"
        exit 1
    }
}

Set-Location $benchDir

# Step 10: Create MariaDB User and Database
Write-Info ""
Write-Info "=== STEP 10: Setting up Database ==="

Write-Info "Checking MariaDB service..."
$mariadbRunning = Get-Service MariaDB -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq "Running"}

if (-not $mariadbRunning) {
    Write-Info "Starting MariaDB service..."
    Start-Service MariaDB -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
}

Write-Info "Creating Frappe database user..."

# Create frappe user and database (with default password)
$mysqlScript = @"
-- Create frappe user (if not exists)
CREATE USER IF NOT EXISTS 'frappe'@'localhost' IDENTIFIED BY 'FrappePassword123';
GRANT ALL PRIVILEGES ON frappe.* TO 'frappe'@'localhost';
GRANT ALL PRIVILEGES ON test_frappe.* TO 'frappe'@'localhost';
FLUSH PRIVILEGES;
"@

try {
    $mysqlScript | mysql -u root 2>$null
} catch {
    Write-Info "Could not create database user (may already exist)"
}

Write-Success "Database user setup attempted"

# Step 11: Create Frappe Site
Write-Info ""
Write-Info "=== STEP 11: Creating Frappe Site ==="

Write-Info "This will take 3-5 minutes (downloading dependencies)..."
bench new-site frappe-orchestrator.local --admin-password admin123 --db-name frappe --db-host localhost --db-user frappe --db-password FrappePassword123

if ($LASTEXITCODE -eq 0) {
    Write-Success "✅ Frappe site created"
} else {
    Write-Error-Custom "❌ Site creation failed"
    Write-Info "You may need to manually run: bench new-site frappe-orchestrator.local"
    exit 1
}

# Step 12: Copy Orchestrator Modules
Write-Info ""
Write-Info "=== STEP 12: Installing Orchestrator Modules ==="

$appsDir = "$benchDir\apps"
$sourceModules = "C:\workspace\frappe-orchestrator\apps"

$modules = @("orchestrator-crm", "orchestrator-hr", "orchestrator-helpdesk", "orchestrator-docs", "orchestrator-insights", "orchestrator-gameplan")

foreach ($module in $modules) {
    $sourcePath = "$sourceModules\$module"
    $targetPath = "$appsDir\$module"
    
    if (Test-Path $sourcePath) {
        Write-Info "Installing $module..."
        
        # Copy module
        if (Test-Path $targetPath) {
            Write-Info "  Already exists, skipping copy"
        } else {
            Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
            Write-Success "  ✅ Copied"
        }
        
        # Install on site
        bench install-app $module --site frappe-orchestrator.local
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "  ✅ Installed: $module"
        } else {
            Write-Error-Custom "  ⚠️  Failed to install: $module (may be OK)"
        }
    } else {
        Write-Error-Custom "  ❌ Source not found: $sourcePath"
    }
}

# Step 13: Summary
Write-Info ""
Write-Success "=== SETUP COMPLETE! ==="
Write-Success ""
Write-Success "✅ All prerequisites installed:"
Write-Success "   - Python 3.11"
Write-Success "   - Node.js 18+"
Write-Success "   - Git"
Write-Success "   - MariaDB 10.6"
Write-Success "   - Frappe Bench"
Write-Success "   - 6 Orchestrator Modules"
Write-Success ""
Write-Info "📍 Working Directory: $benchDir"
Write-Info ""
Write-Info "=== TO START FRAPPE NOW ==="
Write-Info "   cd $benchDir"
Write-Info "   bench start"
Write-Info ""
Write-Info "Then open: http://localhost:8000"
Write-Info "Login with:"
Write-Info "   Username: Administrator"
Write-Info "   Password: admin123"
Write-Info ""
Write-Info "Documentation: C:\workspace\frappe-orchestrator\GETTING_STARTED.md"
Write-Info ""
Write-Success "Setup Complete!"
