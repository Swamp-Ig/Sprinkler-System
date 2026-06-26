param()

# ── Git hooks ─────────────────────────────────────────────────────────────────
Write-Host "Configuring git hooks..."
git config core.hooksPath .githooks
Write-Host "  core.hooksPath -> .githooks"

# ── kicad-cli ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Checking for kicad-cli..."

$candidates = @(
    $env:KICAD_CLI,
    "kicad-cli",
    "C:\Program Files\KiCad\10.0\bin\kicad-cli.exe",
    "C:\Program Files\KiCad\9.0\bin\kicad-cli.exe",
    "C:\Program Files\KiCad\8.0\bin\kicad-cli.exe"
)

$found = $null
foreach ($c in $candidates) {
    if (-not $c) { continue }
    $cmd = Get-Command $c -ErrorAction SilentlyContinue
    if ($cmd) { $found = $cmd.Source; break }
    if (Test-Path $c) { $found = $c; break }
}

if ($found) {
    $ver = & $found --version 2>&1 | Select-Object -First 1
    Write-Host "  found: $found"
    Write-Host "  version: $ver"
} else {
    Write-Warning "kicad-cli not found on PATH or common install locations"
    Write-Host ""
    Write-Host "  The pre-commit hook will skip fabrication exports until kicad-cli"
    Write-Host "  is available. Fix by adding KiCad's bin\ dir to PATH, or set:"
    Write-Host ""
    Write-Host '    $env:KICAD_CLI = "C:\Program Files\KiCad\10.0\bin\kicad-cli.exe"'
    Write-Host ""
    Write-Host "  Add this to your PowerShell profile (\$PROFILE) for persistence."
}

Write-Host ""
Write-Host "Setup complete."
