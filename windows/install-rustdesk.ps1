[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$currentPrincipal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run the RustDesk installer from an elevated PowerShell session.'
}

# RustDesk is not currently in WinGet. Use the official stable release MSI,
# choosing the OS architecture even when running in an emulated shell.
$osArchitecture = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
$assetArchitecture = switch ($osArchitecture) {
    'AMD64' { 'x86_64' }
    'ARM64' { 'aarch64' }
    default { throw "No supported RustDesk MSI for Windows architecture '$osArchitecture'." }
}

$release = Invoke-RestMethod -Uri 'https://api.github.com/repos/rustdesk/rustdesk/releases/latest'
$releaseVersion = [version]($release.tag_name -replace '^v', '')
$assetName = "rustdesk-$($release.tag_name -replace '^v', '')-$assetArchitecture.msi"
$assets = @($release.assets | Where-Object { $_.name -eq $assetName })
if ($assets.Count -ne 1) {
    throw "Expected one '$assetName' asset in the official RustDesk release."
}
$asset = $assets[0]
if ($asset.digest -notmatch '^sha256:([a-fA-F0-9]{64})$') {
    throw "The official RustDesk release does not provide a SHA-256 digest for '$assetName'."
}
$expectedHash = $Matches[1]
if ($asset.browser_download_url -notlike 'https://github.com/rustdesk/rustdesk/releases/download/*') {
    throw 'Unexpected RustDesk release download URL.'
}

# Read uninstall records rather than Win32_Product, which can trigger repairs.
$uninstallPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$installed = @(Get-ItemProperty -Path $uninstallPaths -ErrorAction SilentlyContinue | Where-Object {
    $_.DisplayName -eq 'RustDesk'
})
foreach ($entry in $installed) {
    if ($entry.WindowsInstaller -ne 1) {
        Write-Warning 'An existing RustDesk EXE installation was preserved. Update it through RustDesk, or migrate manually to MSI; see docs/remote-access.md.'
        return
    }
    $installedVersion = $null
    if ([version]::TryParse($entry.DisplayVersion, [ref]$installedVersion) -and $installedVersion -ge $releaseVersion) {
        Write-Host "RustDesk $($entry.DisplayVersion) is already installed; preserving its configuration."
        return
    }
}

$installerPath = Join-Path ([IO.Path]::GetTempPath()) ("prompt-rustdesk-{0}.msi" -f [guid]::NewGuid())
try {
    Invoke-WebRequest -UseBasicParsing -Uri $asset.browser_download_url -OutFile $installerPath
    if ((Get-FileHash -LiteralPath $installerPath -Algorithm SHA256).Hash -ine $expectedHash) {
        throw 'RustDesk MSI checksum verification failed.'
    }

    # Keep MSI defaults and existing application settings. Never reboot setup's host.
    $installer = Start-Process -FilePath 'msiexec.exe' -ArgumentList @('/i', "`"$installerPath`"", '/qn', '/norestart') -Wait -PassThru
    if ($installer.ExitCode -notin @(0, 3010)) {
        throw "RustDesk installation failed (exit code $($installer.ExitCode))."
    }
    if ($installer.ExitCode -eq 3010) {
        Write-Warning 'RustDesk installation requires a restart. Restart Windows when convenient.'
    }
} finally {
    if (Test-Path -LiteralPath $installerPath) {
        Remove-Item -LiteralPath $installerPath -Force
    }
}

Write-Host 'RustDesk installed with standard defaults. Open the app to finish setup; see docs/remote-access.md.'
