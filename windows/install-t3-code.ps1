[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# WinGet's T3Tools.T3Code package tracks stable. Resolve the desktop nightly
# using upstream's channel pointer, then fetch that exact release's assets.
$channel = Invoke-RestMethod -Uri 'https://github.com/pingdotgg/t3code/releases/download/update-feed/nightly.json'
if ($channel.tag_name -notmatch '^v(\d+\.\d+\.\d+-nightly\.\d{8}\.\d+)$') {
    throw 'The official T3 Code nightly pointer returned an unexpected version.'
}
$nightlyVersion = $Matches[1]
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/pingdotgg/t3code/releases/tags/$($channel.tag_name)"
if ($release.draft -or $release.tag_name -ne $channel.tag_name) {
    throw 'The T3 Code release does not match the published nightly pointer.'
}

$osArchitecture = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
$assetArchitecture = switch ($osArchitecture) {
    'AMD64' { 'x64' }
    'ARM64' { 'arm64' }
    default { throw "No supported T3 Code nightly desktop installer for Windows architecture '$osArchitecture'." }
}
$assetName = "T3-Code-$nightlyVersion-$assetArchitecture.exe"
$assets = @($release.assets | Where-Object { $_.name -eq $assetName })
if ($assets.Count -ne 1) {
    throw "Expected one '$assetName' asset in the official T3 Code nightly release."
}
$asset = $assets[0]
if ($asset.digest -notmatch '^sha256:([a-fA-F0-9]{64})$') {
    throw "The official T3 Code nightly release does not provide a SHA-256 digest for '$assetName'."
}
$expectedHash = $Matches[1]
if ($asset.browser_download_url -notlike 'https://github.com/pingdotgg/t3code/releases/download/*') {
    throw 'Unexpected T3 Code nightly download URL.'
}

$installed = @(Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object {
    $_.DisplayName -eq "T3 Code (Nightly) $nightlyVersion" -and $_.DisplayVersion -eq $nightlyVersion
})
if ($installed.Count -gt 0) {
    Write-Host "T3 Code nightly $nightlyVersion is already installed."
    return
}

$installerPath = Join-Path ([IO.Path]::GetTempPath()) ("prompt-t3-code-nightly-{0}.exe" -f [guid]::NewGuid())
try {
    Invoke-WebRequest -UseBasicParsing -Uri $asset.browser_download_url -OutFile $installerPath
    if ((Get-FileHash -LiteralPath $installerPath -Algorithm SHA256).Hash -ine $expectedHash) {
        throw 'T3 Code nightly installer checksum verification failed.'
    }

    # Use NSIS silent installation for the current user; preserve application data.
    $installer = Start-Process -FilePath $installerPath -ArgumentList @('/S', '/currentuser') -Wait -PassThru
    if ($installer.ExitCode -ne 0) {
        throw "T3 Code nightly installation failed (exit code $($installer.ExitCode))."
    }
} finally {
    if (Test-Path -LiteralPath $installerPath) {
        Remove-Item -LiteralPath $installerPath -Force
    }
}

Write-Host "T3 Code nightly $nightlyVersion installed. Open T3 Code (Nightly) to configure providers."
