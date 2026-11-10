# Windows build for omawrite (Qt 6 + MSVC). Usage: .\bin\build.ps1 [-QtDir C:\Qt\6.8.3\msvc2022_64]
param(
    [string]$QtDir = "C:\Qt\6.8.3\msvc2022_64"
)
$ErrorActionPreference = "Stop"

$root  = Split-Path -Parent $PSScriptRoot
$build = Join-Path $root "build"

$vcvars = Get-ChildItem "C:\Program Files*\Microsoft Visual Studio\2022\*\VC\Auxiliary\Build\vcvars64.bat" |
    Select-Object -First 1
if (-not $vcvars) { throw "vcvars64.bat not found; install the VS 2022 C++ build tools." }
if (-not (Test-Path "$QtDir\bin\qmake.exe")) { throw "qmake not found in $QtDir\bin" }

New-Item -ItemType Directory -Force $build | Out-Null

# Run qmake + nmake inside a vcvars-initialised cmd so cl/link are on PATH.
$cmd = "`"$($vcvars.FullName)`" && cd /d `"$build`" && `"$QtDir\bin\qmake.exe`" `"$root\omawrite.pro`" && nmake release"
cmd /c $cmd
if ($LASTEXITCODE -ne 0) { throw "Build failed ($LASTEXITCODE)" }

# Copy Qt runtime DLLs/plugins/QML modules next to the exe.
& "$QtDir\bin\windeployqt.exe" --release --qmldir "$root\src" "$build\release\omawrite.exe"
Write-Host "Built $build\release\omawrite.exe"
