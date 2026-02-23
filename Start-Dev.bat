@echo off
echo ============================================================
echo   Frappe Orchestrator - Development Server
echo ============================================================
echo.
echo Starting Frappe in WSL...
echo Access at: http://localhost:8000
echo Login:     Administrator / admin123
echo.
echo Press Ctrl+C to stop the server.
echo.
wsl -d Ubuntu-22.04 -u frappe -- bash /mnt/c/workspace/frappe-orchestrator/scripts/start-dev.sh
pause
