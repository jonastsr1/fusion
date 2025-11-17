# ============================================
# Installation FusionInventory - VERSION SIMPLE
# ============================================

# Vérification admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ Lancez ce script en tant qu'administrateur !" -ForegroundColor Red
    pause
    exit
}

# Variables
$url = "https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_windows-x64_2.6.exe"
$fichier = "$env:TEMP\fusioninventory-agent.exe"
$serveurGLPI = "https://inventaire.kanoma.fr/glpi/plugins/fusioninventory/"

Write-Host ""
Write-Host "=== Installation FusionInventory ===" -ForegroundColor Cyan
Write-Host ""

# Téléchargement
if (-not (Test-Path $fichier)) {
    Write-Host "⏳ Téléchargement..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $url -OutFile $fichier
    Write-Host "✓ Téléchargé" -ForegroundColor Green
}

# Copier l'URL du serveur dans le presse-papier
Set-Clipboard -Value $serveurGLPI

# Instructions
Write-Host ""
Write-Host "📋 INSTRUCTIONS :" -ForegroundColor Yellow
Write-Host ""
Write-Host "Dans l'installateur qui va s'ouvrir :" -ForegroundColor White
Write-Host ""
Write-Host "  1. Collez l'URL du serveur (déjà copiée, faites CTRL+V) :" -ForegroundColor White
Write-Host "     → $serveurGLPI" -ForegroundColor Green
Write-Host ""
Write-Host "  2. Cochez ces options :" -ForegroundColor White
Write-Host "     ☑ Install as a service" -ForegroundColor Green
Write-Host "     ☑ Run inventory immediately" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
pause

# Lancer l'installateur
Write-Host "⏳ Lancement de l'installateur..." -ForegroundColor Yellow
Start-Process -FilePath $fichier -Wait

# Vérification
Write-Host ""
Write-Host "⏳ Vérification..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

$service = Get-Service -Name "FusionInventory-Agent" -ErrorAction SilentlyContinue

if ($service) {
    Write-Host "✓ Service installé" -ForegroundColor Green
    
    # Démarrage automatique
    Set-Service -Name "FusionInventory-Agent" -StartupType Automatic
    
    # Démarrer si pas déjà démarré
    if ($service.Status -ne "Running") {
        Start-Service -Name "FusionInventory-Agent" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        $service.Refresh()
    }
    
    Write-Host "État : $($service.Status)" -ForegroundColor $(if($service.Status -eq "Running"){"Green"}else{"Yellow"})
    
    if ($service.Status -eq "Running") {
        Write-Host ""
        Write-Host "🎉 Installation réussie !" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠️  Redémarrez l'ordinateur pour finaliser" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Service non trouvé - Vérifiez l'installation" -ForegroundColor Red
}

Write-Host ""
pause