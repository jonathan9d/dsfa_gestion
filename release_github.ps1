# ============================================================
#  Publication d'une release GitHub pour DSFA Gestion.
#
#  Prérequis : un jeton GitHub (scope « repo ») dans la variable
#  d'environnement GITHUB_TOKEN. Le jeton n'est jamais écrit sur le
#  disque ni versionné.
#
#    $env:GITHUB_TOKEN = "<votre jeton>"
#    powershell -ExecutionPolicy Bypass -File release_github.ps1
#
#  Le script crée (ou met à jour) la release du tag poussé puis y
#  dépose l'installateur Windows correspondant à la version.
# ============================================================

param(
    [string]$Tag = "",
    [string]$Notes = "",
    [switch]$Brouillon,
    [switch]$Preversion
)

$ErrorActionPreference = "Stop"

$racine = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $racine

if (-not $env:GITHUB_TOKEN) {
    Write-Host "GITHUB_TOKEN n'est pas défini." -ForegroundColor Red
    Write-Host "Créez un jeton (scope 'repo') sur https://github.com/settings/tokens"
    Write-Host 'puis : $env:GITHUB_TOKEN = "<votre jeton>"'
    exit 1
}

# --- Version lue depuis pubspec.yaml (source unique de vérité) -------------
$version = (Select-String -Path "pubspec.yaml" -Pattern '^version:\s*([0-9]+\.[0-9]+\.[0-9]+)' |
    Select-Object -First 1).Matches.Groups[1].Value
if (-not $version) {
    Write-Host "Impossible de lire la version dans pubspec.yaml." -ForegroundColor Red
    exit 1
}
if (-not $Tag) { $Tag = "v$version" }
if (-not $Notes) {
    $fichierNotes = "docs\RELEASE_$Tag.md"
    if (Test-Path $fichierNotes) {
        $Notes = Get-Content $fichierNotes -Raw
    } else {
        $Notes = "Version $version de DSFA Gestion."
    }
}

# --- Dépôt distant --------------------------------------------------------
$url = (git remote get-url origin).Trim()
$depot = [regex]::Match($url, 'github\.com[:/]+([^/]+)/([^/.]+)').Groups
$proprietaire = $depot[1].Value
$nom = $depot[2].Value
$api = "https://api.github.com/repos/$proprietaire/$nom"
$entetes = @{
    Authorization          = "Bearer $($env:GITHUB_TOKEN)"
    Accept                 = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent"           = "dsfa-gestion-release"
}

Write-Host "Dépôt : $proprietaire/$nom   tag : $Tag   version : $version"

# --- Création ou mise à jour de la release --------------------------------
$corps = @{
    tag_name         = $Tag
    name             = "DSFA Gestion $version"
    body             = $Notes
    draft            = [bool]$Brouillon
    prerelease       = [bool]$Preversion
    generate_release_notes = $false
} | ConvertTo-Json -Depth 5

try {
    $release = Invoke-RestMethod -Method Post -Uri "$api/releases" -Headers $entetes -Body $corps
    Write-Host "Release créée : $($release.html_url)" -ForegroundColor Green
} catch {
    # La release existe déjà : on récupère son identifiant.
    $existante = Invoke-RestMethod -Uri "$api/releases/tags/$Tag" -Headers $entetes
    $release = Invoke-RestMethod -Method Patch -Uri "$api/releases/$($existante.id)" `
        -Headers $entetes -Body $corps
    Write-Host "Release mise à jour : $($release.html_url)" -ForegroundColor Yellow
}

# --- Dépôt de l'installateur ---------------------------------------------
$installateur = "build\installer\DSFA_Gestion_Setup_$version.exe"
if (-not (Test-Path $installateur)) {
    Write-Host "Installateur introuvable : $installateur" -ForegroundColor Red
    Write-Host "Lancez d'abord : flutter build windows --release"
    Write-Host "puis : \"C:\Program Files (x86)\Inno Setup 6\ISCC.exe\" installer\dsfa_gestion.iss"
    exit 1
}

$nomFichier = Split-Path -Leaf $installateur
$dejaLa = $release.assets | Where-Object { $_.name -eq $nomFichier }
if ($dejaLa) {
    Invoke-RestMethod -Method Delete -Uri "$api/releases/assets/$($dejaLa.id)" -Headers $entetes
    Write-Host "Ancienne pièce jointe supprimée : $nomFichier"
}

$envoi = "https://uploads.github.com/repos/$proprietaire/$nom/releases/$($release.id)/assets?name=$nomFichier"
$octets = [System.IO.File]::ReadAllBytes((Resolve-Path $installateur))
Invoke-RestMethod -Method Post -Uri $envoi -Headers $entetes -Body $octets `
    -ContentType "application/octet-stream" | Out-Null

Write-Host "Installateur publié : $nomFichier" -ForegroundColor Green
Write-Host "Release : $($release.html_url)"
