# Install-99EMU.ps1 - 99EMU v0.01
# Run this script from the drive where you want 99EMU installed.
$ErrorActionPreference = 'Stop'
$repo = 'https://raw.githubusercontent.com/reed-rosa/99EMU/main'
$drive = (Get-Location).Drive
if (-not $drive -or -not $drive.Root -or $drive.Root -notmatch '^[A-Za-z]:\\$') {
    throw 'Open PowerShell on a local Windows drive (for example, D:) and run the script there.'
}
$target = Join-Path $drive.Root '99EMU'
Write-Host "99EMU will be installed in $target"
if (Test-Path -LiteralPath $target) {
    $answer = Read-Host 'Directory exists. Overwrite matching files? (Y/N)'
    if ($answer -notmatch '^(y|yes)$') {
        Write-Host 'Cancelled. No files changed.'
        exit
    }
}
$stage = Join-Path ([System.IO.Path]::GetTempPath()) ('99emu-' + [guid]::NewGuid().ToString('N'))
$names = @('99emu.exe', 'SDL3.dll', 'Get-ROMs.ps1')
try {
    New-Item -ItemType Directory -Path $stage -Force | Out-Null
    foreach ($name in $names) {
        $url = "$repo/$name"
        Write-Host "Downloading $name..."
        Invoke-WebRequest -Uri $url -OutFile (Join-Path $stage $name) -UseBasicParsing
    }
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    foreach ($folder in @('roms', 'roms\parsec', 'roms\speech')) {
        New-Item -ItemType Directory -Path (Join-Path $target $folder) -Force | Out-Null
    }
    foreach ($name in $names) {
        Copy-Item -LiteralPath (Join-Path $stage $name) -Destination (Join-Path $target $name) -Force
    }
    Set-Location -LiteralPath $target
    Write-Host "Files installed in $target"
    Write-Host 'Starting ROM setup...'
    & (Join-Path $target 'Get-ROMs.ps1')
} finally {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
}
