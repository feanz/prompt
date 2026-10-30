[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$configRoot = Join-Path $HOME '.config\prompt'
$currentPrincipal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this setup from an elevated PowerShell session.'
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'WinGet is required. Install App Installer from the Microsoft Store and run this script again.'
}

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

$packagesPath = Join-Path $PSScriptRoot 'packages.json'
winget import --import-file $packagesPath --accept-package-agreements --accept-source-agreements --disable-interactivity
if ($LASTEXITCODE -notin @(0, [int]0x8A15002B)) {
    throw "WinGet failed while importing '$packagesPath' (exit code $LASTEXITCODE)."
}

$env:Path = @(
    [Environment]::GetEnvironmentVariable('Path', 'Machine')
    [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path
) -join ';'

New-Item -ItemType Directory -Path $configRoot -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $configRoot 'powershell') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $HOME '.config\wezterm') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $HOME '.config\oh-my-posh') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $HOME '.config\fastfetch') -Force | Out-Null

Copy-Item (Join-Path $repoRoot 'shared\wezterm\wezterm.lua') (Join-Path $HOME '.config\wezterm\wezterm.lua') -Force
Copy-Item (Join-Path $repoRoot 'shared\oh-my-posh\theme.omp.json') (Join-Path $HOME '.config\oh-my-posh\theme.omp.json') -Force
Copy-Item (Join-Path $repoRoot 'shared\powershell\profile.ps1') (Join-Path $configRoot 'powershell\profile.ps1') -Force
Copy-Item (Join-Path $repoRoot 'shared\fastfetch\config.jsonc') (Join-Path $HOME '.config\fastfetch\config.jsonc') -Force
Copy-Item (Join-Path $repoRoot 'shared\fastfetch\logo.txt') (Join-Path $HOME '.config\fastfetch\logo.txt') -Force
Copy-Item (Join-Path $repoRoot 'shared\git\gitconfig') (Join-Path $configRoot 'gitconfig') -Force
Copy-Item (Join-Path $repoRoot 'shared\git\git-aliases') (Join-Path $configRoot 'git-aliases') -Force
Copy-Item (Join-Path $PSScriptRoot 'git\gitconfig') (Join-Path $configRoot 'git-platform') -Force

$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $pwsh) {
    $pwshPath = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
    if (-not (Test-Path $pwshPath)) {
        throw 'PowerShell 7 was installed but could not be located. Open a new shell and run setup again.'
    }
} else {
    $pwshPath = $pwsh.Source
}

& $pwshPath -NoProfile -File (Join-Path $repoRoot 'shared\powershell\install-profile.ps1')
if ($LASTEXITCODE -ne 0) {
    throw "PowerShell profile setup failed (exit code $LASTEXITCODE)."
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

Write-Host 'Windows setup complete. Restart WezTerm to load the shared configuration.'
