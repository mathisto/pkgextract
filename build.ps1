# Builds a single-file win-x64 PkgTool.exe into ./dist
$ErrorActionPreference = 'Stop'
dotnet publish "$PSScriptRoot/PkgTool.Core/PkgTool.Core.csproj" -c Release -r win-x64 --self-contained `
  -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -o "$PSScriptRoot/dist"
Move-Item "$PSScriptRoot/dist/PkgTool.Core.exe" "$PSScriptRoot/dist/PkgTool.exe" -Force
Write-Host "Built dist/PkgTool.exe"
