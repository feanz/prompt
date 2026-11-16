[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$dotnetupDir = Join-Path $HOME '.dotnetup'
$dotnetupPath = Join-Path $dotnetupDir 'dotnetup.exe'

if (-not (Test-Path -LiteralPath $dotnetupPath -PathType Leaf)) {
    $installerPath = Join-Path ([IO.Path]::GetTempPath()) ("prompt-dotnetup-install-{0}.ps1" -f [guid]::NewGuid())
    $shellName = if ($PSVersionTable.PSEdition -eq 'Core') { 'pwsh.exe' } else { 'powershell.exe' }
    try {
        Invoke-WebRequest -UseBasicParsing -Uri 'https://aka.ms/dotnetup/get-dotnetup.ps1' -OutFile $installerPath
        & (Join-Path $PSHOME $shellName) -NoProfile -ExecutionPolicy Bypass -File $installerPath
        if ($LASTEXITCODE -ne 0) {
            throw "dotnetup installation failed (exit code $LASTEXITCODE)."
        }
    } finally {
        if (Test-Path -LiteralPath $installerPath) {
            Remove-Item -LiteralPath $installerPath -Force
        }
    }
}

& $dotnetupPath --version
if ($LASTEXITCODE -ne 0) {
    throw "dotnetup verification failed (exit code $LASTEXITCODE)."
}

# Persist the tool's directory for this user, preserving all other entries.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$userHasDotnetup = @($userPath -split ';' | Where-Object {
    [Environment]::ExpandEnvironmentVariables($_.Trim().Trim('"')).TrimEnd('\') -ieq $dotnetupDir.TrimEnd('\')
}).Count -gt 0
if (-not $userHasDotnetup) {
    $updatedUserPath = (@($userPath, $dotnetupDir) | Where-Object { $_ }) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $updatedUserPath, 'User')
}

$processHasDotnetup = @($env:Path -split ';' | Where-Object {
    [Environment]::ExpandEnvironmentVariables($_.Trim().Trim('"')).TrimEnd('\') -ieq $dotnetupDir.TrimEnd('\')
}).Count -gt 0
if (-not $processHasDotnetup) {
    $env:Path = (@($env:Path, $dotnetupDir) | Where-Object { $_ }) -join ';'
}

Write-Host 'dotnetup is ready. Open a new terminal and run dotnetup init to choose SDKs and access mode.'
