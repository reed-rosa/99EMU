# Get-ROMs.ps1 - import firmware and game files already obtained by the user.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$files = @(
    @{ Relative = 'roms\rom.bin'; Name = 'rom.bin' },
    @{ Relative = 'roms\grom0.bin'; Name = 'grom0.bin' },
    @{ Relative = 'roms\grom1.bin'; Name = 'grom1.bin' },
    @{ Relative = 'roms\grom2.bin'; Name = 'grom2.bin' },
    @{ Relative = 'roms\parsec\phm3112c.bin'; Name = 'phm3112c.bin' },
    @{ Relative = 'roms\parsec\phm3112g3.bin'; Name = 'phm3112g3.bin' },
    @{ Relative = 'roms\parsec\phm3112g4.bin'; Name = 'phm3112g4.bin' },
    @{ Relative = 'roms\parsec\phm3112g5.bin'; Name = 'phm3112g5.bin' },
    @{ Relative = 'roms\speech\cd2325a.vsm'; Name = 'cd2325a.vsm' },
    @{ Relative = 'roms\speech\cd2326a.vsm'; Name = 'cd2326a.vsm' }
)
Write-Host '99EMU requires TI firmware, Parsec and speech files.'
Write-Host 'Automatic ROM downloads are not configured yet.'
Write-Host 'You can import files you already have permission to use.'
$source = Read-Host 'Folder containing your existing ROM files (Enter to skip)'
if ([string]::IsNullOrWhiteSpace($source)) {
    Write-Host 'Skipped ROM import.'
} elseif (-not (Test-Path -LiteralPath $source -PathType Container)) {
    Write-Warning "Folder not found: $source"
} else {
    foreach ($item in $files) {
        $destination = Join-Path $root $item.Relative
        $match = Get-ChildItem -LiteralPath $source -Recurse -File -ErrorAction Stop |
            Where-Object { $_.Name -ieq $item.Name } | Select-Object -First 1
        if ($null -eq $match) { continue }
        $folder = Split-Path -Parent $destination
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        if (Test-Path -LiteralPath $destination) {
            $answer = Read-Host "Overwrite $destination ? (Y/N)"
            if ($answer -notmatch '^(y|yes)$') { continue }
        }
        Copy-Item -LiteralPath $match.FullName -Destination $destination -Force
        Write-Host "Imported $($item.Relative)"
    }
}
$missing = @($files | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_.Relative) -PathType Leaf) })
if ($missing.Count -gt 0) {
    Write-Host 'Missing required files:'
    foreach ($item in $missing) { Write-Host "  $($item.Relative)" }
    Write-Host 'Run Get-ROMs.ps1 again after obtaining the missing files.'
} else {
    Write-Host 'All expected ROM filenames are present. Authenticity/content have not been verified.'
}
