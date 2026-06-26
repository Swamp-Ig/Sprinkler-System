param([Parameter(Mandatory)][string]$Version)

if (-not $Version) {
    Write-Error "usage: .\release.ps1 <version>  (e.g. .\release.ps1 v1.1.0)"
    exit 1
}

# ── Ensure working tree is clean ──────────────────────────────────────────────
$dirty = git status --porcelain
if ($dirty) {
    Write-Error "error: working tree has uncommitted changes — please commit or stash first"
    exit 1
}

$pcb   = "Sprinkler System.kicad_pcb"
$sch   = "Sprinkler System.kicad_sch"
$today = Get-Date -Format 'yyyy-MM-dd'
$utf8  = New-Object System.Text.UTF8Encoding $false   # UTF-8 without BOM

# ── Stamp title blocks ────────────────────────────────────────────────────────
Write-Host "Stamping title blocks with $Version ($today)..."
foreach ($file in $sch, $pcb) {
    $content = [System.IO.File]::ReadAllText($file)
    $content = $content -replace '\(rev "[^"]*"\)',  "(rev `"$Version`")"
    $content = $content -replace '\(date "[^"]*"\)', "(date `"$today`")"
    [System.IO.File]::WriteAllText($file, $content, $utf8)
}
git add $sch $pcb

# ── Commit and tag ────────────────────────────────────────────────────────────
# KICAD_RELEASE tells the pre-commit hook to skip re-stamping (we've already
# set the exact version above), while still running the fabrication exports.
Write-Host "Committing..."
$env:KICAD_RELEASE = '1'
git commit -m "Release $Version"
Remove-Item Env:KICAD_RELEASE -ErrorAction SilentlyContinue
git tag -f $Version

Write-Host ""
Write-Host "Tagged $Version. To publish:"
Write-Host "  git push && git push origin $Version --force"
