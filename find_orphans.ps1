param([string]$libPath)
$allDart = Get-ChildItem -Recurse -Filter "*.dart" $libPath
$allContents = @{}
foreach ($f in $allDart) { $allContents[$f.FullName] = Get-Content $f.FullName -Raw }
$orphans = @()
foreach ($f in $allDart) {
    $fn = $f.Name
    $c = $allContents[$f.FullName]
    if ($c -match '(?m)^part of') { continue }
    $found = $false
    foreach ($other in $allDart) {
        if ($other.FullName -eq $f.FullName) { continue }
        if ($allContents[$other.FullName] -match [regex]::Escape($fn)) { $found = $true; break }
    }
    if (-not $found) { $orphans += $fn }
}
Write-Host "=== ORPHANS ==="
$orphans | Sort-Object
