[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$claudeBin = Join-Path $env:USERPROFILE '.local\bin'
$claudePath = Join-Path $claudeBin 'claude.exe'
$installerPath = Join-Path ([IO.Path]::GetTempPath()) ("prompt-claude-install-{0}.ps1" -f [guid]::NewGuid())
$shellName = if ($PSVersionTable.PSEdition -eq 'Core') { 'pwsh.exe' } else { 'powershell.exe' }

try {
    # Run the official installer in a child shell: its exit calls and preference
    # changes must not terminate setup or change the rest of the bootstrap.
    Invoke-WebRequest -UseBasicParsing -Uri 'https://claude.ai/install.ps1' -OutFile $installerPath
    & (Join-Path $PSHOME $shellName) -NoProfile -ExecutionPolicy Bypass -File $installerPath latest
    if ($LASTEXITCODE -ne 0) {
        throw "Claude Code native installation failed (exit code $LASTEXITCODE)."
    }
} finally {
    if (Test-Path -LiteralPath $installerPath) {
        Remove-Item -LiteralPath $installerPath -Force
    }
}

if (-not (Test-Path -LiteralPath $claudePath -PathType Leaf)) {
    throw "Claude Code installer completed but '$claudePath' could not be found."
}

& $claudePath --version
if ($LASTEXITCODE -ne 0) {
    throw "Claude Code verification failed (exit code $LASTEXITCODE)."
}

# The native installer can leave PATH configuration to the user. Persist only
# the user entry, preserving unrelated entries and avoiding duplicate paths.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$userHasClaudeBin = @($userPath -split ';' | Where-Object {
    [Environment]::ExpandEnvironmentVariables($_.Trim().Trim('"')).TrimEnd('\') -ieq $claudeBin.TrimEnd('\')
}).Count -gt 0
if (-not $userHasClaudeBin) {
    $updatedUserPath = (@($userPath, $claudeBin) | Where-Object { $_ }) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $updatedUserPath, 'User')
}

$processHasClaudeBin = @($env:Path -split ';' | Where-Object {
    [Environment]::ExpandEnvironmentVariables($_.Trim().Trim('"')).TrimEnd('\') -ieq $claudeBin.TrimEnd('\')
}).Count -gt 0
if (-not $processHasClaudeBin) {
    $env:Path = (@($env:Path, $claudeBin) | Where-Object { $_ }) -join ';'
}

$resolvedClaude = Get-Command claude -ErrorAction Stop
if ($resolvedClaude.Source -ine $claudePath) {
    Write-Warning "'claude' resolves to '$($resolvedClaude.Source)' instead of '$claudePath'. Remove the older installation using its original package manager, then restart your terminal."
}
