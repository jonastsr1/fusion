## Define the URL of the installer
#$installerUrl = "https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_windows-x64_2.6.exe"

## Define the local path where the installer will be downloaded
#$installerPath = "$env:TEMP\fusioninventory-agent_windows-x64_2.6.exe"

## Clean up the downloaded installer
#try {
#    Remove-Item -Path $installerPath -Force
#    Write-Host "Cleanup completed."
#} catch {
#    Write-Warning "Failed to clean up the installer file: $_"
#}
#Write-Host "Cleanup OK !!!"

# Arrêter le service
Stop-Service -Name "*FusionInventory*" -Force -ErrorAction SilentlyContinue

# Désinstaller
(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*FusionInventory*" }).PSChildName | ForEach-Object { Start-Process "msiexec.exe" -ArgumentList "/x $_ /quiet /norestart" -Wait }

# Supprimer les fichiers
Remove-Item "C:\Program Files*\FusionInventory-Agent" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:ProgramData\FusionInventory-Agent" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "FusionInventory supprimé!" -ForegroundColor Green