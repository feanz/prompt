[CmdletBinding()]
param(
    [switch]$InstallTerminalSettings
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$configRoot = Join-Path $HOME '.config\prompt'
$currentPrincipal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this setup from an elevated PowerShell session.'
}

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    throw 'Chocolatey is required. Install it from https://chocolatey.org/install and run this script again.'
}

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
choco feature enable -n allowGlobalConfirmation

$packages = @(
    'git'
    'nerd-fonts-cascadiacode'
    'microsoft-windows-terminal'
    'powershell-core'
    'oh-my-posh'
    'vim'
    'kdiff3'
    'gh'
    'bat'
    'azure-cli'
    'chatgpt'
    'awscli'
    'kubernetes-cli'
)

foreach ($package in $packages) {
    choco upgrade $package --yes --no-progress
    if ($LASTEXITCODE -notin @(0, 1641, 3010)) {
        throw "Chocolatey failed while installing or upgrading '$package' (exit code $LASTEXITCODE)."
    }
}

foreach ($module in @('Terminal-Icons', 'z')) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
    }
}

New-Item -ItemType Directory -Path $configRoot -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $configRoot 'powershell') -Force | Out-Null

Copy-Item (Join-Path $repoRoot 'shared\oh-my-posh\theme.omp.json') (Join-Path $configRoot 'theme.omp.json') -Force
Copy-Item (Join-Path $repoRoot 'shared\git\gitconfig') (Join-Path $configRoot 'gitconfig') -Force
Copy-Item (Join-Path $repoRoot 'shared\git\git-aliases') (Join-Path $configRoot 'git-aliases') -Force
Copy-Item (Join-Path $PSScriptRoot 'git\gitconfig') (Join-Path $configRoot 'git-platform') -Force
Copy-Item (Join-Path $PSScriptRoot 'powershell\Microsoft.PowerShell_profile.ps1') (Join-Path $configRoot 'powershell\Microsoft.PowerShell_profile.ps1') -Force

$managedProfile = '$HOME/.config/prompt/powershell/Microsoft.PowerShell_profile.ps1'
$profileLine = ". `"$managedProfile`""
$profilePath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\profile.ps1'
New-Item -ItemType Directory -Path (Split-Path -Parent $profilePath) -Force | Out-Null

if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

if (-not (Select-String -Path $profilePath -SimpleMatch $profileLine -Quiet)) {
    Add-Content -Path $profilePath -Value "`n$profileLine"
}

$gitConfigPath = Join-Path $configRoot 'gitconfig'
if (Get-Command git -ErrorAction SilentlyContinue) {
    $includes = @(git config --global --get-all include.path 2>$null)
    if ($includes -notcontains $gitConfigPath) {
        git config --global --add include.path $gitConfigPath
    }
} else {
    Write-Warning 'Git was installed, but it is not visible in this process yet. Open a new shell and run this setup again to register the shared Git configuration.'
}

. (Join-Path $PSScriptRoot 'explorer\Set-WindowsExplorerOptions.ps1')
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions -EnableShowProtectedOSFiles

if ($InstallTerminalSettings) {
    $terminalSettings = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    $terminalSettingsDirectory = Split-Path -Parent $terminalSettings

    if (-not (Test-Path $terminalSettingsDirectory)) {
        throw 'Windows Terminal settings directory was not found. Launch Windows Terminal once, then run setup again.'
    }

    if (Test-Path $terminalSettings) {
        $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
        Copy-Item $terminalSettings "$terminalSettings.backup.$timestamp"
    }

    Copy-Item (Join-Path $PSScriptRoot 'terminal\settings.json') $terminalSettings -Force
}

Write-Host 'Windows setup complete. Open a new PowerShell session to load the prompt.'
