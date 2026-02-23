# run-frappe-setup.ps1
# Runs the Frappe WSL setup and logs output to C:\Users\Public\frappe-setup.log
$logFile = "C:\Users\Public\frappe-setup.log"
"Starting Frappe setup at $(Get-Date)" | Out-File $logFile -Encoding UTF8

$scriptInWSL = "bash /mnt/c/workspace/frappe-orchestrator/scripts/wsl-setup.sh"

& wsl.exe -d Ubuntu-22.04 -u root -- bash -c $scriptInWSL *>&1 | Tee-Object -FilePath $logFile -Append

"Setup finished at $(Get-Date)" | Out-File $logFile -Append -Encoding UTF8
