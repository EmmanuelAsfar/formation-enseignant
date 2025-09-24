param(
    [string]$CsvPath = "tools/urls.csv",
    [string]$TargetRoot = "source"
)

if (-not (Test-Path -Path $CsvPath)) {
    Write-Error "CSV introuvable: $CsvPath"
    exit 1
}

$entries = Import-Csv -Path $CsvPath

foreach ($e in $entries) {
    $url = $e.url
    $cycle = $e.cycle # ex: cycle_2 | cycle_3
    $type = $e.type   # eduscol | canope | nouveaux
    $categorie = $e.categorie # ex: maths, emc, etc. (optionnel)
    $filename = $e.nom_fichier

    if (-not $url) { Write-Warning "Ligne sans URL, ignorée."; continue }
    if (-not $cycle) { Write-Warning "Cycle manquant pour $url, défaut cycle_2"; $cycle = "cycle_2" }

    if (-not $filename -or [string]::IsNullOrWhiteSpace($filename)) {
        $filename = Split-Path -Leaf $url
        if (-not $filename) { $filename = "document.pdf" }
        if (-not $filename.ToLower().EndsWith('.pdf')) { $filename = "$filename.pdf" }
    }

    switch ($type) {
        'eduscol'      { $subdir = 'programmes_officiels' }
        'nouveaux'     { $subdir = 'nouveaux_programmes' }
        'canope'       { $subdir = 'documentation_interne' }
        default        { $subdir = 'documentation_interne' }
    }

    $destDir = Join-Path $TargetRoot (Join-Path $subdir $cycle)
    if ($categorie) { $destDir = Join-Path $destDir $categorie }

    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    $destPath = Join-Path $destDir $filename

    try {
        Invoke-WebRequest -Uri $url -OutFile $destPath -UseBasicParsing -Headers @{ 'User-Agent' = 'Mozilla/5.0' }
        Write-Host "Téléchargé: $url -> $destPath"
    } catch {
        Write-Warning "Échec de téléchargement: $url -> $destPath. Erreur: $_"
    }
}
