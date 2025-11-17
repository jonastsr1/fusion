# Script pour l'installation de l'agent FusionInventory pour l'inventaire GLPI


# L'URL qui permet d'installer l'agent Fuision inventory qui est sur GitHub
$installerUrl = "https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_windows-x64_2.6.exe"

# le nom de .exe qui va être installé
$installerPath = "$env:TEMP\fusioninventory-agent_windows-x64_2.6.exe"


###
$glpiServerUrl = '"https://inventaire.kanoma.fr/glpi/plugins/fusioninventory/"'

# Download the installer
try {
    Write-Host "Downloading FusionInventory Agent installer..."
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -ErrorAction Stop
    Write-Host "Download completed successfully."
} catch {
    Write-Error "Failed to download the installer: $_"
    exit 1
}

# Install the agent silently
# Assuming the installer supports /S for silent installation (common for NSIS installers)
try {
    Write-Host "Installing FusionInventory Agent..."
    Start-Process -FilePath $installerPath -ArgumentList " /S /server= $glpiServerUrl" -Wait -NoNewWindow
    Write-Host "Installation completed successfully."
} catch {
    Write-Error "Failed to install the agent: $_"
    exit 1
}

## suppression fusion inventory
#try {
#    Remove-Item -Path $installerPath -Force
#    Write-Host "Cleanup completed."
#} catch {
#    Write-Warning "Failed to clean up the installer file: $_"
#}

Write-Host "FusionInventory Agent installation script finished."

##### ajout pour test 
# Arrêter le service
Stop-Service -Name "*FusionInventory*" -Force -ErrorAction SilentlyContinue

# Désinstaller
(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*FusionInventory*" }).PSChildName | ForEach-Object { Start-Process "msiexec.exe" -ArgumentList "/x $_ /quiet /norestart" -Wait }

# Supprimer les fichiers
Remove-Item "C:\Program Files*\FusionInventory-Agent" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:ProgramData\FusionInventory-Agent" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "FusionInventory supprimé!" -ForegroundColor Green