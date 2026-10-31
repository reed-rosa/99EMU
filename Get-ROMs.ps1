# Get-ROMs.ps1 - optional third-party asset download/import for 99EMU
# No ROMs are included in this repository.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$roms = Join-Path $root 'roms'
$expected = @(
    'roms\rom.bin','roms\grom0.bin','roms\grom1.bin','roms\grom2.bin',
    'roms\parsec\phm3112c.bin','roms\parsec\phm3112g3.bin',
    'roms\parsec\phm3112g4.bin','roms\parsec\phm3112g5.bin',
    'roms\speech\cd2325a.vsm','roms\speech\cd2326a.vsm'
)
function Confirm-Replace([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) { return $true }
    return ((Read-Host "Overwrite $path ? (Y/N)") -match '^(?i:y|yes)$')
}
function Copy-Asset([string]$source, [string]$relative) {
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        Write-Warning "Not found: $source"
        return
    }
    $destination = Join-Path $root $relative
    if (-not (Confirm-Replace $destination)) { return }
    New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination -Force
    Write-Host "Installed $relative"
}
function Find-Asset([string]$folder, [string[]]$names) {
    foreach ($name in $names) {
        $match = Get-ChildItem -LiteralPath $folder -File -Recurse |
            Where-Object { $_.Name -ieq $name } | Select-Object -First 1
        if ($null -ne $match) { return $match.FullName }
    }
    return $null
}
function Install-From-Folder([string]$folder) {
    $mapping = @(
        @{ Relative='roms\grom0.bin'; Names=@('grom0.bin','994a_grom0.u500') },
        @{ Relative='roms\grom1.bin'; Names=@('grom1.bin','994a_grom1.u501') },
        @{ Relative='roms\grom2.bin'; Names=@('grom2.bin','994a_grom2.u502') },
        @{ Relative='roms\parsec\phm3112c.bin'; Names=@('phm3112c.bin') },
        @{ Relative='roms\parsec\phm3112g3.bin'; Names=@('phm3112g3.bin') },
        @{ Relative='roms\parsec\phm3112g4.bin'; Names=@('phm3112g4.bin') },
        @{ Relative='roms\parsec\phm3112g5.bin'; Names=@('phm3112g5.bin') },
        @{ Relative='roms\speech\cd2325a.vsm'; Names=@('cd2325a.vsm','cd2325a.u2a') },
        @{ Relative='roms\speech\cd2326a.vsm'; Names=@('cd2326a.vsm','cd2326a.u2b') }
    )
    foreach ($item in $mapping) {
        $source = Find-Asset $folder $item.Names
        if ($source) { Copy-Asset $source $item.Relative }
    }
    $existingRom = Find-Asset $folder @('rom.bin')
    if ($existingRom) {
        Copy-Asset $existingRom 'roms\rom.bin'
    } else {
        $hiPath = Find-Asset $folder @('994a_rom_hb.u610')
        $loPath = Find-Asset $folder @('994a_rom_lb.u611')
        if ($hiPath -and $loPath) {
            $hi = [System.IO.File]::ReadAllBytes($hiPath)
            $lo = [System.IO.File]::ReadAllBytes($loPath)
            if ($hi.Length -ne 4096 -or $lo.Length -ne 4096) {
                Write-Warning 'Unexpected console ROM chip sizes; not generating rom.bin.'
            } else {
                $destination = Join-Path $roms 'rom.bin'
                if (Confirm-Replace $destination) {
                    $merged = New-Object byte[] 8192
                    for ($i = 0; $i -lt 4096; $i++) {
                        $merged[2*$i] = $hi[$i]
                        $merged[2*$i+1] = $lo[$i]
                    }
                    New-Item -ItemType Directory -Path $roms -Force | Out-Null
                    [System.IO.File]::WriteAllBytes($destination, $merged)
                    Write-Host 'Installed roms\rom.bin (interleaved high/low byte ROM chips)'
                }
            }
        }
    }
}
Write-Host '99EMU needs console ROM/GROMs, Parsec and speech assets.'
Write-Host 'These third-party files are NOT included in 99EMU.'
Write-Host 'Please obtain/use them only when you have the necessary rights.'
Write-Host ''
Write-Host 'Sources:'
Write-Host '  https://ftp.whtech.com/System%20ROMs/MAME/ti99_4a.zip'
Write-Host '  https://ftp.whtech.com/Cartridges/MAME/zip/parsec.zip'
Write-Host '  https://ftp.whtech.com/System%20ROMs/MAME/ti99_speech.zip'
$choice = Read-Host 'Download these three archives directly from WHTech? (Y/N)'
if ($choice -match '^(?i:y|yes)$') {
    $stage = Join-Path ([System.IO.Path]::GetTempPath()) ('99emu-roms-' + [guid]::NewGuid().ToString('N'))
    $archives = @(
        @{ Name='ti99_4a.zip'; Url='https://ftp.whtech.com/System%20ROMs/MAME/ti99_4a.zip' },
        @{ Name='parsec.zip'; Url='https://ftp.whtech.com/Cartridges/MAME/zip/parsec.zip' },
        @{ Name='ti99_speech.zip'; Url='https://ftp.whtech.com/System%20ROMs/MAME/ti99_speech.zip' }
    )
    try {
        New-Item -ItemType Directory -Path $stage -Force | Out-Null
        foreach ($archive in $archives) {
            $zip = Join-Path $stage $archive.Name
            $folder = Join-Path $stage ([System.IO.Path]::GetFileNameWithoutExtension($archive.Name))
            Write-Host "Downloading $($archive.Name)..."
            try {
                Invoke-WebRequest -Uri $archive.Url -OutFile $zip -UseBasicParsing
                Expand-Archive -LiteralPath $zip -DestinationPath $folder -Force
                Install-From-Folder $folder
            } catch {
                Write-Warning "Unable to install $($archive.Name): $($_.Exception.Message)"
            }
        }
    } finally {
        Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
    }
} else {
    $source = Read-Host 'Folder containing your own ROM files (Enter to skip)'
    if (-not [string]::IsNullOrWhiteSpace($source)) {
        if (Test-Path -LiteralPath $source -PathType Container) {
            Install-From-Folder $source
        } else {
            Write-Warning "Folder not found: $source"
        }
    }
}
$missing = @($expected | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_) -PathType Leaf) })
if ($missing.Count) {
    Write-Host 'Missing files:'
    foreach ($path in $missing) { Write-Host "  $path" }
    Write-Host 'Run Get-ROMs.ps1 again to retry or import files.'
} else {
    Write-Host 'All expected filenames are present (contents not independently verified).'
}
