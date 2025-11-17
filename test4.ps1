# ============================================
# Script d'installation de l'agent FusionInventory pour GLPI
# ============================================

# 1. Vérification des droits administrateur
# L'installation nécessite des privilèges admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Ce script doit être exécuté en tant qu'administrateur."
    exit 1
}

# 2. Définition des variables
# URL de téléchargement (HTTPS)
$installerUrl = "https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_windows-x64_2.6.exe"
# Chemin temporaire pour stocker l'installateur
$installerPath = "$env:TEMP\fusioninventory-agent_windows-x64_2.6.exe"
# URL de votre serveur GLPI (HTTPS)
$glpiServerUrl = "inventaire.kanoma.fr/glpi/plugins/fusioninventory/"

# 3. Vérifier si FusionInventory est déjà installé
if (Get-Command "fusioninventory-agent" -ErrorAction SilentlyContinue) {
    Write-Host "FusionInventory Agent est déjà installé. Fin du script."
    exit 
}

# 4. Téléchargement de l'installateur
try {
    Write-Host "Téléchargement de l'agent FusionInventory..."
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -ErrorAction Stop
    Write-Host "Téléchargement terminé avec succès."
} catch {
    Write-Error "Échec du téléchargement : $_"
    exit 1
}

# 5. Installation silencieuse avec configuration du serveur GLPI
# L'argument /S = installation silencieuse
# L'argument /server=URL permet de configurer directement le serveur GLPI
try {
    Write-Host "Installation de l'agent FusionInventory..."
    Start-Process -FilePath $installerPath -ArgumentList Set-Clipboard -Value $serveurGLPI -Wait -NoNewWindow
    Write-Host "Installation terminée avec succès."
} catch {
    Write-Error "Échec de l'installation : $_"
    exit 1
}

# 6. Configuration du service pour démarrage automatique
try {
    Set-Service -Name "FusionInventory-Agent" -StartupType Automatic
    Start-Service -Name "FusionInventory-Agent" -ErrorAction Stop
    Write-Host "Service FusionInventory configuré et démarré."
} catch {
    Write-Warning "Impossible de configurer ou démarrer le service : $_"
}
# 7. Vérifier si FusionInventory est bien installé
#if (Get-Command "fusioninventory-agent" -ErrorAction SilentlyContinue) {
#    Write-Host "FusionInventory Agent est déjà installé. Fin du script."
    
#} else {
#    Write-Error "Échec de l'installation de Fusion Inventory Agent !!!! "
    #exit 1
#}

# 8. Nettoyage du fichier téléchargé
#try {
#    Remove-Item -Path $installerPath -Force
#    Write-Host "Fichier d'installation supprimé."
#} catch {
#    Write-Warning "Impossible de supprimer le fichier : $_"
#}

Write-Host "Script terminé avec succès."






#### pk pas pour forcer le demarrage 
# Démarrage avec sc.exe (alternative)
#Write-Host "Tentative de démarrage avec sc.exe..."
#$scResult = sc.exe start FusionInventory-Agent
#Write-Host $scResult