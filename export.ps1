# Script PowerShell pour exporter tous les supports MARP en PDF et HTML
# Parcourt tous les modules et preserve l'arborescence
# Version avec verification automatique des plugins

param(
    [string]$OutputDir = "exports",
    [switch]$PDF = $true,
    [switch]$HTML = $true,
    [string]$Path = "",
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\export-all-pdf-html.ps1 [-OutputDir <dossier>] [-PDF] [-HTML] [-Path <chemin>] [-Help]" -ForegroundColor Green
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -OutputDir  Dossier de sortie (defaut: exports)" -ForegroundColor White
    Write-Host "  -PDF        Exporter en PDF (defaut: active)" -ForegroundColor White
    Write-Host "  -HTML       Exporter en HTML (defaut: active)" -ForegroundColor White
    Write-Host "  -Path       Chemin specifique (fichier ou dossier)" -ForegroundColor White
    Write-Host "  -Help       Afficher cette aide" -ForegroundColor White
    Write-Host ""
    Write-Host "Exemples:" -ForegroundColor Yellow
    Write-Host "  .\export-all-pdf-html.ps1" -ForegroundColor White
    Write-Host "  .\export-all-pdf-html.ps1 -Path modules/lot1/formation/formation_180min.md" -ForegroundColor White
    Write-Host "  .\export-all-pdf-html.ps1 -Path modules/lot1/formation/" -ForegroundColor White
    Write-Host "  .\export-all-pdf-html.ps1 -OutputDir pdf -PDF" -ForegroundColor White
    exit 0
}

# Verifier si MARP CLI est installe
$marpInstalled = $false
try {
    $null = marp --version
    $marpInstalled = $true
    Write-Host "MARP CLI detecte" -ForegroundColor Green
} catch {
    Write-Host "MARP CLI non detecte, installation..." -ForegroundColor Yellow
    try {
        npm install -g @marp-team/marp-cli
        Write-Host "MARP CLI installe avec succes" -ForegroundColor Green
        $marpInstalled = $true
    } catch {
        Write-Host "Erreur lors de l'installation de MARP CLI" -ForegroundColor Red
        exit 1
    }
}

# Verifier si md-to-pdf est disponible (via npx) sinon installer globalement
$mdToPdfAvailable = $false
try {
    $null = npx --yes md-to-pdf --version 2>$null
    if ($LASTEXITCODE -eq 0) { $mdToPdfAvailable = $true }
} catch {}
if (-not $mdToPdfAvailable) {
    Write-Host "md-to-pdf non detecte, installation..." -ForegroundColor Yellow
    try {
        npm install -g md-to-pdf
        Write-Host "md-to-pdf installe avec succes" -ForegroundColor Green
        $mdToPdfAvailable = $true
    } catch {
        Write-Host "Erreur lors de l'installation de md-to-pdf" -ForegroundColor Red
        exit 1
    }
}

if ($marpInstalled) {
    # Verifier les plugins MARP
    Write-Host "Verification des plugins MARP..." -ForegroundColor Cyan
    try {
        $null = npm list -g @marp-team/marpit
        Write-Host "  OK @marp-team/marpit (global)" -ForegroundColor Green
    } catch {
        Write-Host "  Installation @marp-team/marpit..." -ForegroundColor Yellow
        npm install -g @marp-team/marpit
    }
    
    try {
        $null = npm list -g @marp-team/marp-cli
        Write-Host "  OK @marp-team/marp-cli (global)" -ForegroundColor Green
    } catch {
        Write-Host "  Installation @marp-team/marp-cli..." -ForegroundColor Yellow
        npm install -g @marp-team/marp-cli
    }
    
    # Verifier les fichiers CSS locaux
    Write-Host "Verification des fichiers CSS locaux..." -ForegroundColor Blue
    $cssFiles = @("css/a4.css", "css/slides.css", "css/qcm.css")
    foreach ($cssFile in $cssFiles) {
        if (Test-Path $cssFile) {
            Write-Host "  OK $cssFile trouve" -ForegroundColor Green
        } else {
            Write-Host "  MANQUANT $cssFile" -ForegroundColor Red
        }
    }
}

# Creer le dossier de sortie
if (-not (Test-Path $OutputDir)) {
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Host "Dossier principal cree: $OutputDir" -ForegroundColor Green
}

# Fonction pour lire les options d'export depuis l'en-tête YAML
function Get-ExportOptions {
    param([string]$FilePath)

    $result = [ordered]@{
        IsMarp = $null
        Html   = $null
        Pdf    = $null
    }

    try {
        $raw = Get-Content -Path $FilePath -Raw -Encoding UTF8
    } catch {
        return $result
    }

    # Extraire le front matter YAML entre les deux premiers '---'
    $fmStart = $raw.IndexOf("---")
    if ($fmStart -lt 0) { return $result }
    $afterStart = $fmStart + 3
    $fmEnd = $raw.IndexOf("---", $afterStart)
    if ($fmEnd -le $fmStart) { return $result }
    $yaml = $raw.Substring($afterStart, $fmEnd - $afterStart)

    # Normaliser lignes
    $lines = ($yaml -split "`r?`n").ForEach({ $_.Trim() })
    $inDocument = $false
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        if ($line -match "^marp:\s*(true|false|yes|no)$") {
            $val = $Matches[1].ToLower()
            $result.IsMarp = ($val -eq 'true' -or $val -eq 'yes')
            continue
        }

        if ($line -match "^document:\s*$") {
            $inDocument = $true
            continue
        }

        if ($inDocument) {
            if ($line -match "^(html|pdf):\s*(yes|no|true|false)$") {
                $k = $Matches[1].ToLower()
                $v = $Matches[2].ToLower()
                $bool = ($v -eq 'yes' -or $v -eq 'true')
                if ($k -eq 'html') { $result.Html = $bool }
                if ($k -eq 'pdf')  { $result.Pdf  = $bool }
            } elseif (-not ($line -match "^\s")) {
                # Fin de la section document si ligne non indentée
                $inDocument = $false
            }
        }
    }

    # Valeurs par défaut si non renseignées
    if ($null -eq $result.IsMarp) {
        $fileName = Split-Path $FilePath -Leaf
        $result.IsMarp = ($fileName -like "*slides*" -or $fileName -like "*presentation*")
    }
    if ($null -eq $result.Html) { $result.Html = $true }
    if ($null -eq $result.Pdf)  { $result.Pdf  = $true }

    return $result
}

# Fonction pour exporter un fichier MARP
function Export-MarpFile {
    param(
        [string]$InputFile,
        [string]$RelativePath,
        [string]$BaseName,
        [string]$ModuleName
    )
    
    if (-not (Test-Path $InputFile)) {
        Write-Host "Fichier non trouve: $InputFile" -ForegroundColor Yellow
        return
    }
    
    # Creer la structure de dossiers dans exports
    $pdfPath = Join-Path $OutputDir "pdf"
    $pdfPath = Join-Path $pdfPath "modules"
    $pdfPath = Join-Path $pdfPath $ModuleName
    $pdfPath = Join-Path $pdfPath $RelativePath
    
    $htmlPath = Join-Path $OutputDir "html"
    $htmlPath = Join-Path $htmlPath "modules"
    $htmlPath = Join-Path $htmlPath $ModuleName
    $htmlPath = Join-Path $htmlPath $RelativePath
    
    if ($PDF) {
        New-Item -ItemType Directory -Path $pdfPath -Force | Out-Null
    }
    if ($HTML) {
        New-Item -ItemType Directory -Path $htmlPath -Force | Out-Null
    }
    
    Write-Host "Traitement: $RelativePath\$BaseName" -ForegroundColor Cyan
    
    # Déterminer les options d'export
    $opts = Get-ExportOptions -FilePath $InputFile
    Write-Host "  Options: marp=$($opts.IsMarp) html=$($opts.Html) pdf=$($opts.Pdf)" -ForegroundColor Yellow

    # Choisir la feuille de style
    $cssToUse = "css/a4.css"
    if ($InputFile -match "\\qcm\\") { $cssToUse = "css/qcm.css" }
    if ($opts.IsMarp) { $cssToUse = "css/slides.css" }

    # Résoudre un chemin CSS absolu (utile pour MARP et non‑MARP)
    $absCssResolved = $cssToUse
    try { $absCssResolved = (Resolve-Path $cssToUse).Path } catch {}

    # Pour les documents non-MARP, pretraiter: supprimer le front matter et utiliser des chemins absolus
    $sourceForDoc = $InputFile
    $absCss = $null
    if (-not $opts.IsMarp) {
        try {
            $absCss = (Resolve-Path $cssToUse).Path
        } catch {
            $absCss = $cssToUse
        }

        # Lire et retirer le front matter YAML si present
        try {
            $raw = Get-Content -Path $InputFile -Raw -Encoding UTF8
            $fmStart = $raw.IndexOf("---")
            if ($fmStart -ge 0) {
                $afterStart = $fmStart + 3
                $fmEnd = $raw.IndexOf("---", $afterStart)
                if ($fmEnd -gt $fmStart) {
                    $contentOnly = $raw.Substring($fmEnd + 3)
                } else {
                    $contentOnly = $raw
                }
            } else {
                $contentOnly = $raw
            }

            # Ecrire un fichier temporaire dans le meme dossier pour conserver les chemins relatifs des images
            $dir = Split-Path $InputFile -Parent
            $tempName = ".export_tmp_" + [System.IO.Path]::GetFileName($InputFile)
            $tempPath = Join-Path $dir $tempName
            Set-Content -Path $tempPath -Value $contentOnly -Encoding UTF8
            $sourceForDoc = $tempPath
        } catch {
            Write-Host "  Avertissement: pretraitement YAML echoue, utilisation du fichier original" -ForegroundColor DarkYellow
            $sourceForDoc = $InputFile
        }
    }
    
    if ($PDF -and $opts.Pdf) {
        try {
            $pdfFile = Join-Path $pdfPath "$BaseName.pdf"
            
            if ($opts.IsMarp) {
                # Exécuter MARP depuis le dossier du fichier pour résoudre media/
                $mdDir = Split-Path $InputFile -Parent
                Push-Location $mdDir
                try {
                    $marpInput = Split-Path $InputFile -Leaf
                    $marpOut = $pdfFile
                    $pdfCmd = "marp `"$marpInput`" --pdf --output `"$marpOut`" --allow-local-files --theme-set `"$absCssResolved`""
                    Invoke-Expression $pdfCmd
                } finally {
                    Pop-Location
                }
            } else {
                # Utiliser md-to-pdf (Chromium) pour les documents A4 (PDF)
                $dir = Split-Path $InputFile -Parent
                $cssArg = ""
                if ($absCss) { $cssArg = "--stylesheet `"$absCss`"" } else { $cssArg = "--stylesheet `"$cssToUse`"" }
                $tempOutPdf = Join-Path $dir (([System.IO.Path]::GetFileNameWithoutExtension($sourceForDoc)) + ".pdf")
                if (Test-Path $tempOutPdf) { Remove-Item $tempOutPdf -Force -ErrorAction SilentlyContinue }
                $pdfCmd = "npx --yes md-to-pdf `"$sourceForDoc`" --basedir `"$dir`" $cssArg"
                Invoke-Expression $pdfCmd
                if (Test-Path $tempOutPdf) { Move-Item -Force $tempOutPdf $pdfFile }
            }
            
            Write-Host "  PDF exporte: $pdfFile" -ForegroundColor Green
        } catch {
            Write-Host "  Erreur PDF: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($HTML -and $opts.Html) {
        try {
            $htmlFile = Join-Path $htmlPath "$BaseName.html"
            
            if ($opts.IsMarp) {
                # Exécuter MARP depuis le dossier du fichier pour résoudre media/
                $mdDir = Split-Path $InputFile -Parent
                Push-Location $mdDir
                try {
                    $marpInput = Split-Path $InputFile -Leaf
                    $marpOut = $htmlFile
                    $htmlCmd = "marp `"$marpInput`" --html --output `"$marpOut`" --allow-local-files --theme-set `"$absCssResolved`""
                    Invoke-Expression $htmlCmd
                } finally {
                    Pop-Location
                }
            } else {
                # Utiliser pandoc pour un HTML auto‑contenu (images + CSS embarquees)
                $dir = Split-Path $InputFile -Parent
                $absCssForPandoc = $absCss
                if (-not $absCssForPandoc) {
                    try { $absCssForPandoc = (Resolve-Path $cssToUse).Path } catch { $absCssForPandoc = $cssToUse }
                }
                $pandocCmd = "pandoc `"$sourceForDoc`" -o `"$htmlFile`" --standalone --self-contained -c `"$absCssForPandoc`""
                Invoke-Expression $pandocCmd
            }
            
            Write-Host "  HTML exporte: $htmlFile" -ForegroundColor Green
        } catch {
            Write-Host "  Erreur HTML: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Nettoyage du fichier temporaire si cree
    if (-not $opts.IsMarp -and $sourceForDoc -ne $InputFile) {
        try { Remove-Item -Path $sourceForDoc -Force -ErrorAction SilentlyContinue } catch {}
    }
}

# Traitement selon le parametre Path
if (-not [string]::IsNullOrEmpty($Path)) {
    # Traitement d'un chemin specifique
    if (Test-Path $Path) {
        $item = Get-Item $Path
        if ($item.PSIsContainer) {
            # C'est un dossier
            Write-Host "Traitement du dossier: $Path" -ForegroundColor Magenta
            $mdFiles = Get-ChildItem -Path $Path -Filter "*.md" -Recurse
            foreach ($file in $mdFiles) {
                # Determiner le module en fonction du chemin
                $moduleName = "custom"
                if ($file.FullName -like "*\modules\lot1\*") {
                    $moduleName = "lot1"
                } elseif ($file.FullName -like "*\modules\lot2\*") {
                    $moduleName = "lot2"
                } elseif ($file.FullName -like "*\modules\lot3\*") {
                    $moduleName = "lot3"
                } elseif ($file.FullName -like "*\docs\*") {
                    $moduleName = "docs"
                }
                
            # Calculer le chemin relatif depuis le module
            $modulePath = "modules\$moduleName"
            $relativePath = $file.DirectoryName.Replace((Get-Location).Path, "").Replace($modulePath, "").TrimStart("\")
            if ([string]::IsNullOrEmpty($relativePath)) {
                $relativePath = "."
            }
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                Export-MarpFile -InputFile $file.FullName -RelativePath $relativePath -BaseName $baseName -ModuleName $moduleName
            }
        } else {
            # C'est un fichier
            Write-Host "Traitement du fichier: $Path" -ForegroundColor Magenta
            
            # Determiner le module en fonction du chemin
            $moduleName = "custom"
            if ($item.FullName -like "*\modules\lot1\*") {
                $moduleName = "lot1"
            } elseif ($item.FullName -like "*\modules\lot2\*") {
                $moduleName = "lot2"
            } elseif ($item.FullName -like "*\modules\lot3\*") {
                $moduleName = "lot3"
            } elseif ($item.FullName -like "*\docs\*") {
                $moduleName = "docs"
            }
            
            # Calculer le chemin relatif depuis le module
            $modulePath = "modules\$moduleName"
            $relativePath = $item.DirectoryName.Replace((Get-Location).Path, "").Replace($modulePath, "").TrimStart("\")
            if ([string]::IsNullOrEmpty($relativePath)) {
                $relativePath = "."
            }
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($item.Name)
            Export-MarpFile -InputFile $item.FullName -RelativePath $relativePath -BaseName $baseName -ModuleName $moduleName
        }
    } else {
        Write-Host "Chemin non trouve: $Path" -ForegroundColor Red
        exit 1
    }
} else {
    # Traitement de tous les modules (comportement par defaut)
$modules = Get-ChildItem -Path "modules" -Directory

    Write-Host "Modules trouves:" -ForegroundColor Blue
foreach ($module in $modules) {
    Write-Host "  - $($module.Name)" -ForegroundColor White
}

Write-Host ""

# Exporter chaque module
foreach ($module in $modules) {
        Write-Host "Traitement du module: $($module.Name)" -ForegroundColor Magenta
    
    # Trouver tous les fichiers .md dans le module
    $mdFiles = Get-ChildItem -Path $module.FullName -Filter "*.md" -Recurse
    
    foreach ($file in $mdFiles) {
        # Calculer le chemin relatif depuis le module
        $relativePath = $file.DirectoryName.Replace($module.FullName, "").TrimStart("\")
        if ([string]::IsNullOrEmpty($relativePath)) {
            $relativePath = "."
        }
        
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            Export-MarpFile -InputFile $file.FullName -RelativePath $relativePath -BaseName $baseName -ModuleName $module.Name
    }
}

    # Parcourir aussi les docs si necessaire
$docsPath = "docs"
if (Test-Path $docsPath) {
        Write-Host "Traitement de la documentation" -ForegroundColor Magenta
    
    $mdFiles = Get-ChildItem -Path $docsPath -Filter "*.md" -Recurse
    
    foreach ($file in $mdFiles) {
        # Calculer le chemin relatif depuis docs
        $relativePath = $file.DirectoryName.Replace((Get-Location).Path, "").TrimStart("\")
        if ([string]::IsNullOrEmpty($relativePath)) {
            $relativePath = "docs"
        }
        
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            Export-MarpFile -InputFile $file.FullName -RelativePath $relativePath -BaseName $baseName -ModuleName "docs"
        }
    }
}

# Resume final
Write-Host ""
Write-Host "Resume de l'export:" -ForegroundColor Blue

if ($PDF) {
    $pdfCount = (Get-ChildItem -Path $OutputDir -Filter "*.pdf" -Recurse).Count
    Write-Host "  PDF: $pdfCount fichiers dans $OutputDir" -ForegroundColor Green
}

if ($HTML) {
    $htmlCount = (Get-ChildItem -Path $OutputDir -Filter "*.html" -Recurse).Count
    Write-Host "  HTML: $htmlCount fichiers dans $OutputDir" -ForegroundColor Green
}

# Afficher la structure creee
Write-Host ""
Write-Host "Structure creee:" -ForegroundColor Blue
Get-ChildItem -Path $OutputDir -Recurse -Directory | ForEach-Object {
    $indent = "  " * ($_.FullName.Split("\").Length - $OutputDir.Split("\").Length - 1)
    Write-Host "$indent$($_.Name)" -ForegroundColor White
}

Write-Host ""
Write-Host "Export termine!" -ForegroundColor Green
Write-Host "Consultez le dossier $OutputDir pour tous les fichiers exportes" -ForegroundColor Cyan
Write-Host "Consultez le dossier $OutputDir pour tous les fichiers exportes" -ForegroundColor Cyan