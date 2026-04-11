$ErrorActionPreference = 'Stop'

function Get-ImgSrcs([string]$filePath) {
    $content = Get-Content -Raw -Path $filePath
    $out = New-Object System.Collections.Generic.List[string]

    $m1 = [regex]::Matches($content, '<img\b[^>]*\bsrc\s*=\s*"([^"]+)"[^>]*>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    foreach ($m in $m1) {
        $src = $m.Groups[1].Value.Trim()
        if ($src) { $out.Add($src) | Out-Null }
    }

    $m2 = [regex]::Matches($content, "<img\b[^>]*\bsrc\s*=\s*'([^']+)'[^>]*>", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    foreach ($m in $m2) {
        $src = $m.Groups[1].Value.Trim()
        if ($src) { $out.Add($src) | Out-Null }
    }

    return $out | Sort-Object -Unique
}

function Test-ImgSrc([string]$htmlFile, [string]$src) {
    if ($src -match '^(https?:|data:|//|#|javascript:|mailto:)') { return $true }
    if ($src -match '[<>"|*?]' -or $src.Contains('{') -or $src.Contains('}')) { return $true }
    $cleanSrc = $src.Split('?')[0].Split('#')[0]
    try {
        $resolved = [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $htmlFile) $cleanSrc))
        return (Test-Path -LiteralPath $resolved -PathType Leaf)
    } catch {
        return $false
    }
}

$targets = @('pipes-and-tubes.html', 'fittings-and-flanges.html')
foreach ($t in $targets) {
    $targetPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $t))
    Write-Output ("FILE: " + $t)
    $srcs = Get-ImgSrcs $targetPath
    foreach ($src in $srcs) {
        if (Test-ImgSrc $targetPath $src) { Write-Output ("  OK: " + $src) }
        else { Write-Output ("  MISSING: " + $src) }
    }
}

$all = Get-ChildItem -Recurse -File -Include *.html | Where-Object { $_.FullName -notmatch '\\assets\\' }
$broken = New-Object System.Collections.Generic.List[object]
foreach ($f in $all) {
    $srcs = Get-ImgSrcs $f.FullName
    foreach ($src in $srcs) {
        if (-not (Test-ImgSrc $f.FullName $src)) {
            $broken.Add([pscustomobject]@{ file=$f.FullName; src=$src }) | Out-Null
        }
    }
}

Write-Output ("Site pages scanned: " + $all.Count)
Write-Output ("Broken image refs: " + $broken.Count)
$broken | Select-Object file, src | Sort-Object file, src -Unique | Format-Table -AutoSize

$reportPath = Join-Path (Get-Location) 'broken-images-report.csv'
$broken | Select-Object file, src | Sort-Object file, src -Unique | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $reportPath
Write-Output ("Report: " + $reportPath)
