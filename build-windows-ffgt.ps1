# FFGT -- see LICENSE
# Builds ffgt.exe on Windows x64 and packs dist\ffgt-<version>-windows-x64.zip with the prebuilt GPU libraries
#   powershell -ExecutionPolicy Bypass -File build-windows-ffgt.ps1 [-Tag 0.2.0b3]     (the tag names the zip; default: the crate version)
param([string]$Tag = '')
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$ver = (Select-String -Path host\Cargo.toml -Pattern '^version = "(.+)"').Matches[0].Groups[1].Value
if (-not $Tag) { $Tag = $ver }
# no local paths (user name, folders) in the binary's panic messages
$env:RUSTFLAGS = "--remap-path-prefix=$env:USERPROFILE\.cargo=cargo --remap-path-prefix=$PSScriptRoot=ffgt --remap-path-prefix=$env:USERPROFILE\.rustup=rustup"
Push-Location host
cargo build --release
if ($LASTEXITCODE -ne 0) { throw "cargo build failed" }
Pop-Location
$lib = 'prebuilt\windows-x64'
$name = "ffgt-$Tag-windows-x64"
$stage = "dist\$name\ffgt"
Remove-Item -Recurse -Force "dist\$name" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $stage | Out-Null
Copy-Item host\target\release\ffgt.exe, "$lib\tinggpu.dll", "$lib\tinggpu_cl.dll", windows-ffgt\start.bat $stage
Copy-Item docs\README-ffgt.md "$stage\README.md"
Copy-Item docs\HIVEOS-ffgt.md, docs\RELEASE-NOTES-ffgt.md $stage -ErrorAction SilentlyContinue
Copy-Item docs\LICENSE-ffgt "$stage\LICENSE"
Copy-Item docs\NOTICE-ffgt "$stage\NOTICE"
$zip = "dist\$name.zip"
Remove-Item -Force $zip -ErrorAction SilentlyContinue
Compress-Archive -Path "dist\$name\ffgt" -DestinationPath $zip
$hash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLower()
"$hash  $name.zip" | Tee-Object "dist\$name.zip.sha256"
