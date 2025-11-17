# =========================================================================
# Script pour Installation de Fusion Inventory Agent Pour le park info GLPI 
# =========================================================================

#
# Ce script va permettre l'installation de l'agent FusioInventory pour permettre 
# le recensement du matériel informatique dans le parc informatique GLPI de Kanoma
#

## modifier ExecutionPolicy pour le premier script et qui pourra être exécuté juste sur cette session

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# vérification des droits admin pour exécuter le script PowerShell

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "pour exécuter le script, il faut le lancer en tant qu'administrateur !! " -ForegroundColor Red
    pause
    exit
}

# Initialisation des variables (où trouver l'agent où il va être installé et le lien pour relier le GLPI de Kanoma avec le plugin Fuision Inventory)

$url = "https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_windows-x64_2.6.exe"
$fichier = "$env:TEMP\fusioninventory-agent.exe"
$serveurGLPI = "https://inventaire.kanoma.fr/glpi/plugins/fusioninventory/"

Write-Host ""
Write-Host "=== l'installation de FusionInventory commence ===" 
Write-Host ""


# téléchargement de l'agent qui est sur GitHub et il est placé dans le fichier initialisé par $fichier

if (-not (Test-Path $fichier)) {
    Write-Host " Téléchargement " 
    Invoke-WebRequest -Uri $url -OutFile $fichier
    Write-Host " L'agent est bien téléchargé !! "
}


# pour que ce soit plus simple pendant la configuration, on copie l'URL du serveur, comme ça il sera rentré directement pendant la configuration

Set-Clipboard -Value $serveurGLPI


Write-Host "L'url du serveur vient d'être copiée, l'URL est le suivant : "
Write-Host ""
Write-Host "$serveurGLPI    "
Write-Host ""
pause 


# Lancement de l'installateur FusionInventory

Write-Host ""
Write-Host "L'installateur se lance " 
Write-Host ""
Start-Process -FilePath $fichier -Wait


# On procède à des vérifications pour savoir si le service est bien installé

Write-Host ""
Write-Host "Vérification en cour ..." 


# On donne un peu de temps pour que tout se lance bien

Start-Sleep -Seconds 3


# recuperation des infos service 

$service = Get-Service -Name "FusionInventory-Agent" -ErrorAction SilentlyContinue


# vérification du service pour savoir s'il est installé ou non

if ($service) {
    Write-Host ""
    Write-Host "Le Service est bien installé !! " 
    Write-Host ""
    
    # Démarrage automatique
    Set-Service -Name "FusionInventory-Agent" -StartupType Automatic
    
    # Démarrer si pas déjà démarré
    if ($service.Status -ne "Running") {
        Start-Service -Name "FusionInventory-Agent" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        $service.Refresh()
    }
    
    #Vérification de l'état du service 
    Write-Host "État : $($service.Status)" -ForegroundColor $(if($service.Status -eq "Running"){"Green"}else{"Yellow"})
    
    if ($service.Status -eq "Running") {
        Write-Host ""
        Write-Host " Installation réussie !! " 
    } else {
        Write-Host ""
        Write-Host " Redémarrez l'ordinateur pour finaliser" 
    }
} else {
    Write-Host "Service non trouvé il faut vérifiez l'installation" 
}

Write-Host ""
pause