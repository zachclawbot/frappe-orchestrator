@echo off
REM Frappe Orchestrator - Full Installation Using Windows Package Manager
REM This script installs Python, Node.js, Git, and MariaDB automatically

echo.
echo ========================================
echo  FRAPPE ORCHESTRATOR - FULL INSTALLATION
echo ========================================
echo.
echo Installing Python 3.11, Node.js, Git, and MariaDB...
echo This may take 15-30 minutes
echo.
echo DO NOT CLOSE THIS WINDOW
echo.

REM Install Python 3.11
echo [1/4] Installing Python 3.11...
winget install -e --id Python.Python.3.11 -h --accept-package-agreements --accept-source-agreements
if %errorlevel% equ 0 (
    echo SUCCESS: Python 3.11 installed
) else (
    echo WARNING: Python installation may have had issues
)
timeout /t 2 >nul

REM Install Node.js
echo.
echo [2/4] Installing Node.js...
winget install -e --id OpenJS.NodeJS -h --accept-package-agreements --accept-source-agreements
if %errorlevel% equ 0 (
    echo SUCCESS: Node.js installed
) else (
    echo WARNING: Node.js installation may have had issues
)
timeout /t 2 >nul

REM Install Git
echo.
echo [3/4] Installing Git...
winget install -e --id Git.Git -h --accept-package-agreements --accept-source-agreements
if %errorlevel% equ 0 (
    echo SUCCESS: Git installed
) else (
    echo WARNING: Git installation may have had issues
)
timeout /t 2 >nul

REM Install MariaDB
echo.
echo [4/4] Installing MariaDB...
winget install -e --id MariaDB.MariaDB -h --accept-package-agreements --accept-source-agreements
if %errorlevel% equ 0 (
    echo SUCCESS: MariaDB installed
) else (
    echo WARNING: MariaDB installation may have had issues
)
timeout /t 2 >nul

REM Refresh environment
echo.
echo ========================================
echo  Installation Complete!
echo ========================================
echo.
echo Next Steps:
echo 1. Close and reopen PowerShell
echo 2. Run these commands:
echo.
echo    cd C:\frappe-dev
echo    python -m pip install --upgrade pip setuptools wheel
echo    pip install frappe-bench
echo    bench init frappe-orchestrator-bench --python python --no-setup-docker
echo.
echo For detailed setup instructions, see:
echo C:\workspace\frappe-orchestrator\GETTING_STARTED.md
echo.
pause
