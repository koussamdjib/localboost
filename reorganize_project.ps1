param(
    [ValidateSet('analyze', 'scaffold', 'move-docs', 'validate', 'report', 'all')]
    [string]$Phase = 'all',
    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$WhatIfPreference = -not $Apply.IsPresent

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$docFiles = @(
    'AI_RULES.md',
    'ARCHITECTURE_MIGRATION_PLAN.md',
    'MERCHANT_MVP_ARCHITECTURE.md',
    'NOTIFICATION_SYSTEM_DOCS.md'
)

$requiredDirs = @(
    'client/lib', 'client/android', 'client/ios', 'client/web', 'client/test',
    'merchant/lib', 'merchant/android', 'merchant/ios', 'merchant/web', 'merchant/test',
    'shared/lib', 'docs'
)

function Write-Phase([string]$title) {
    Write-Host "`n=== $title ===" -ForegroundColor Cyan
}

function Ensure-Directory([string]$path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force -WhatIf:$WhatIfPreference | Out-Null
        Write-Host "  Created: $path" -ForegroundColor Gray
    } else {
        Write-Host "  Exists:  $path" -ForegroundColor DarkGray
    }
}

function Move-DocIfPresent([string]$fileName) {
    $source = Join-Path $root $fileName
    $dest = Join-Path $root (Join-Path 'docs' $fileName)

    if (Test-Path $source) {
        Move-Item -Path $source -Destination $dest -Force -WhatIf:$WhatIfPreference
        Write-Host "  Moved: $fileName -> docs/" -ForegroundColor Gray
    } else {
        Write-Host "  Skip:  $fileName (not in repo root)" -ForegroundColor DarkGray
    }
}

function Run-FlutterValidation([string]$appPath) {
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        Write-Host "  flutter not found in PATH. Skipping $appPath validation." -ForegroundColor Yellow
        return
    }

    Push-Location $appPath
    try {
        Write-Host "  [$appPath] flutter pub get" -ForegroundColor Gray
        & flutter pub get

        Write-Host "  [$appPath] flutter analyze" -ForegroundColor Gray
        & flutter analyze

        if (Test-Path 'test') {
            Write-Host "  [$appPath] flutter test" -ForegroundColor Gray
            & flutter test
        } else {
            Write-Host "  [$appPath] test directory not found; skipping flutter test" -ForegroundColor Yellow
        }
    }
    finally {
        Pop-Location
    }
}

function Invoke-Analyze {
    Write-Phase 'Phase 1-2: Analyze And Migration Map'

    $legacyRoots = @('lib', 'android', 'ios', 'web', 'test', 'pubspec.yaml')
    foreach ($entry in $legacyRoots) {
        if (Test-Path $entry) {
            Write-Host "  Legacy root artifact still present: $entry" -ForegroundColor Yellow
        } else {
            Write-Host "  Legacy root artifact not present: $entry" -ForegroundColor Green
        }
    }

    Write-Host "  Proposed map (if legacy root exists):" -ForegroundColor White
    Write-Host "    client  <= lib/screens, lib/widgets, lib/main.dart" -ForegroundColor Gray
    Write-Host "    merchant<= lib/merchant/**" -ForegroundColor Gray
    Write-Host "    shared  <= lib/models, lib/services, lib/providers, lib/core" -ForegroundColor Gray
    Write-Host "    docs    <= root markdown docs listed in script" -ForegroundColor Gray
}

function Invoke-Scaffold {
    Write-Phase 'Phase 3: Ensure Workspace Structure'
    foreach ($dir in $requiredDirs) {
        Ensure-Directory $dir
    }
}

function Invoke-MoveDocs {
    Write-Phase 'Phase 7: Move Docs To /docs'
    foreach ($doc in $docFiles) {
        Move-DocIfPresent $doc
    }
}

function Invoke-Validate {
    Write-Phase 'Phase 8: Validate Packages'
    Run-FlutterValidation 'shared'
    Run-FlutterValidation 'client'
    Run-FlutterValidation 'merchant'
}

function Get-DartFileMetrics {
    $scanRoots = @('client/lib', 'merchant/lib', 'shared/lib')
    $rows = @()

    foreach ($scanRoot in $scanRoots) {
        if (-not (Test-Path $scanRoot)) {
            continue
        }

        $package = ($scanRoot -split '/')[0]
        $files = Get-ChildItem -Path $scanRoot -Recurse -Filter '*.dart' -File
        foreach ($file in $files) {
            $lineCount = (Get-Content -Path $file.FullName).Count
            $rows += [PSCustomObject]@{
                Package = $package
                Path = $file.FullName.Substring($root.Length + 1) -replace '\\', '/'
                Lines = $lineCount
            }
        }
    }

    return $rows | Sort-Object Lines -Descending
}

function Invoke-Report {
    Write-Phase 'Phase 9: Generate Refactor Queue'

    $lineLimit = 150
    $metrics = Get-DartFileMetrics
    if (-not $metrics -or $metrics.Count -eq 0) {
        Write-Host '  No Dart files found under client/lib, merchant/lib, shared/lib.' -ForegroundColor Yellow
        return
    }

    $overLimit = @($metrics | Where-Object { $_.Lines -gt $lineLimit })
    $topOffenders = @($overLimit | Select-Object -First 25)

    Write-Host "  Dart files scanned: $($metrics.Count)" -ForegroundColor Gray
    Write-Host "  Files over ${lineLimit} lines: $($overLimit.Count)" -ForegroundColor Gray

    $packages = @('client', 'merchant', 'shared')
    $summaryRows = foreach ($pkg in $packages) {
        $pkgAll = @($metrics | Where-Object { $_.Package -eq $pkg })
        $pkgOver = @($overLimit | Where-Object { $_.Package -eq $pkg })
        $worst = if ($pkgAll.Count -gt 0) { $pkgAll[0] } else { $null }

        [PSCustomObject]@{
            Package = $pkg
            DartFiles = $pkgAll.Count
            OverLimit = $pkgOver.Count
            Worst = if ($null -eq $worst) { 'n/a' } else { "{0} ({1})" -f $worst.Path, $worst.Lines }
        }
    }

    $reportPath = Join-Path $root 'docs/FLUTTER_REFACTOR_QUEUE.md'
    $markdown = @(
        '# Flutter Refactor Queue',
        '',
        "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')",
        '',
        "Line limit: ${lineLimit}",
        '',
        '## Summary',
        '',
        '| Package | Dart Files | Files Over Limit | Worst File |',
        '|---|---:|---:|---|'
    )

    foreach ($row in $summaryRows) {
        $markdown += "| $($row.Package) | $($row.DartFiles) | $($row.OverLimit) | $($row.Worst) |"
    }

    $markdown += @(
        '',
        '## Top 25 Over-Limit Files',
        ''
    )

    if ($topOffenders.Count -eq 0) {
        $markdown += '- No files exceed the configured line limit.'
    } else {
        foreach ($item in $topOffenders) {
            $markdown += "- $($item.Path) ($($item.Lines) lines)"
        }
    }

    $markdown += @(
        '',
        '## Recommended Split Order (First 10)',
        ''
    )

    foreach ($item in ($topOffenders | Select-Object -First 10)) {
        $markdown += "- $($item.Path)"
    }

    $markdown += @(
        '',
        '## Notes',
        '',
        '- This report does not move or rewrite files.',
        '- Use this queue to refactor incrementally while preserving behavior.',
        '- Keep app-specific screens/widgets in their app package and shared logic in shared/lib only.'
    )

    if ($Apply.IsPresent) {
        Set-Content -Path $reportPath -Value $markdown -Encoding UTF8
        Write-Host "  Wrote refactor queue: $reportPath" -ForegroundColor Green
    } else {
        Write-Host "  Dry-run: would write refactor queue to $reportPath" -ForegroundColor Yellow
    }
}

switch ($Phase) {
    'analyze' { Invoke-Analyze }
    'scaffold' { Invoke-Scaffold }
    'move-docs' { Invoke-MoveDocs }
    'validate' { Invoke-Validate }
    'report' { Invoke-Report }
    'all' {
        Invoke-Analyze
        Invoke-Scaffold
        Invoke-MoveDocs
        Invoke-Validate
        Invoke-Report
    }
}

Write-Host "`nComplete. Dry-run is default." -ForegroundColor Green
Write-Host "Examples:" -ForegroundColor Green
Write-Host "  .\reorganize_project.ps1 -Phase analyze" -ForegroundColor DarkGray
Write-Host "  .\reorganize_project.ps1 -Phase scaffold -Apply" -ForegroundColor DarkGray
Write-Host "  .\reorganize_project.ps1 -Phase report -Apply" -ForegroundColor DarkGray
