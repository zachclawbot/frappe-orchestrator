# Frappe Local Development Setup Script
# Automates complete Frappe installation with orchestrator modules

Write-Host "🚀 Frappe Orchestrator - Local Development Setup" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Add bench to PATH for this session
$env:PATH += ";C:\Users\zacha\AppData\Roaming\Python\Python314\Scripts"

# Configuration
$FRAPPE_DIR = "C:\frappe-dev"
$BENCH_NAME = "frappe-bench"
$SITE_NAME = "orchestrator.local"
$DB_ROOT_PASSWORD = "RootPassword123"
$ADMIN_PASSWORD = "admin123"
$ORCHESTRATOR_PATH = "C:\workspace\frappe-orchestrator"

# Step 1: Check Prerequisites
Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow
$python_version = python --version 2>&1
$node_version = node --version 2>&1
$npm_version = npm --version 2>&1

Write-Host "  ✓ Python: $python_version" -ForegroundColor Green
Write-Host "  ✓ Node.js: $node_version" -ForegroundColor Green
Write-Host "  ✓ npm: $npm_version" -ForegroundColor Green

# Check if MariaDB is running
$mariadb_service = Get-Service -Name "MariaDB*" -ErrorAction SilentlyContinue
if ($mariadb_service) {
    Write-Host "  ✓ MariaDB service found: $($mariadb_service.DisplayName)" -ForegroundColor Green
    if ($mariadb_service.Status -ne "Running") {
        Write-Host "  ⚠ Starting MariaDB..." -ForegroundColor Yellow
        Start-Service $mariadb_service.Name
    }
} else {
    Write-Host "  ⚠ MariaDB service not found (may still be installing)" -ForegroundColor Yellow
}

Write-Host ""

# Step 2: Create Frappe Directory
Write-Host "📁 Creating Frappe directory..." -ForegroundColor Yellow
if (-Not (Test-Path $FRAPPE_DIR)) {
    New-Item -ItemType Directory -Path $FRAPPE_DIR | Out-Null
    Write-Host "  ✓ Created $FRAPPE_DIR" -ForegroundColor Green
} else {
    Write-Host "  ✓ Directory already exists" -ForegroundColor Green
}

Set-Location $FRAPPE_DIR
Write-Host ""

# Step 3: Initialize Frappe Bench
Write-Host "🔨 Initializing Frappe bench..." -ForegroundColor Yellow
$bench_path = Join-Path $FRAPPE_DIR $BENCH_NAME

if (-Not (Test-Path $bench_path)) {
    Write-Host "  Running: bench init $BENCH_NAME --frappe-branch version-15" -ForegroundColor Cyan
    & C:\Users\zacha\AppData\Roaming\Python\Python314\Scripts\bench.exe init $BENCH_NAME --frappe-branch version-15
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Bench initialized successfully" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Bench initialization failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ✓ Bench already exists at $bench_path" -ForegroundColor Green
}

Set-Location $bench_path
Write-Host ""

# Step 4: Create New Site
Write-Host "🌐 Creating Frappe site: $SITE_NAME..." -ForegroundColor Yellow

$site_path = Join-Path $bench_path "sites\$SITE_NAME"

if (-Not (Test-Path $site_path)) {
    Write-Host "  Running: bench new-site $SITE_NAME --db-root-password $DB_ROOT_PASSWORD --admin-password $ADMIN_PASSWORD" -ForegroundColor Cyan
    
    # Create site
    & C:\Users\zacha\AppData\Roaming\Python\Python314\Scripts\bench.exe new-site $SITE_NAME --db-root-password $DB_ROOT_PASSWORD --admin-password $ADMIN_PASSWORD --no-mariadb-socket
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Site created successfully" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Site creation failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
        Write-Host "  💡 Tip: Make sure MariaDB is installed and running" -ForegroundColor Yellow
        Write-Host "  💡 You can run: Get-Service -Name 'MariaDB*' | Start-Service" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "  ✓ Site already exists at $site_path" -ForegroundColor Green
}

Write-Host ""

# Step 5: Link Orchestrator Modules
Write-Host "🔗 Linking orchestrator modules..." -ForegroundColor Yellow

$apps_dir = Join-Path $bench_path "apps"
$modules = @("orchestrator-crm", "orchestrator-hr", "orchestrator-helpdesk", 
             "orchestrator-docs", "orchestrator-insights", "orchestrator-gameplan")

foreach ($module in $modules) {
    $source = Join-Path $ORCHESTRATOR_PATH "apps\$module"
    $target = Join-Path $apps_dir $module
    
    if (Test-Path $source) {
        if (-Not (Test-Path $target)) {
            # Create symlink
            New-Item -ItemType SymbolicLink -Path $target -Target $source -Force | Out-Null
            Write-Host "  ✓ Linked $module" -ForegroundColor Green
        } else {
            Write-Host "  ✓ $module already linked" -ForegroundColor Green
        }
    } else {
        Write-Host "  ⚠ Source not found: $source" -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 6: Install Orchestrator Apps
Write-Host "📦 Installing orchestrator modules on site..." -ForegroundColor Yellow

foreach ($module in $modules) {
    Write-Host "  Installing $module..." -ForegroundColor Cyan
    & C:\Users\zacha\AppData\Roaming\Python\Python314\Scripts\bench.exe --site $SITE_NAME install-app $module
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ $module installed" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $module installation failed" -ForegroundColor Red
    }
}

Write-Host ""

# Step 7: Final Instructions
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Navigate to bench directory:"
Write-Host "     cd $bench_path" -ForegroundColor Yellow
Write-Host ""
Write-Host "  2. Start development server:"
Write-Host "     C:\Users\zacha\AppData\Roaming\Python\Python314\Scripts\bench.exe start" -ForegroundColor Yellow
Write-Host ""
Write-Host "  3. Access Frappe:"
Write-Host "     URL: http://localhost:8000" -ForegroundColor Yellow
Write-Host "     Username: Administrator" -ForegroundColor Yellow
Write-Host "     Password: $ADMIN_PASSWORD" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Useful Commands:" -ForegroundColor Cyan
Write-Host "  bench migrate         - Run database migrations"
Write-Host "  bench build           - Build frontend assets"
Write-Host "  bench console         - Open Frappe console"
Write-Host "  bench clear-cache     - Clear all caches"
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "  Project: $ORCHESTRATOR_PATH\README.md"
Write-Host "  Frappe Docs: https://frappeframework.com/docs"
Write-Host ""
