[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$modules = @('posh-git', 'PSReadLine', 'Terminal-Icons', 'z')

$gallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
if ($gallery -and $gallery.InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
    }
}

$managedProfile = '$HOME/.config/prompt/powershell/profile.ps1'
$profileLine = ". `"$managedProfile`""
$profilePath = $PROFILE.CurrentUserAllHosts

New-Item -ItemType Directory -Path (Split-Path -Parent $profilePath) -Force | Out-Null
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

if (-not (Select-String -Path $profilePath -SimpleMatch $profileLine -Quiet)) {
    Add-Content -Path $profilePath -Value "`n$profileLine"
}

Write-Host "Configured PowerShell profile: $profilePath"
