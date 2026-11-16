# Adapted from https://github.com/deja666/wezterm-dotfiles at commit
# dfce3719b07820141965d2a549dd1c7cd536d0f5. See THIRD_PARTY_NOTICES.md.

# The official dotnetup downloader leaves PATH configuration to the user.
$dotnetupDir = Join-Path $HOME '.dotnetup'
if ((Test-Path -LiteralPath $dotnetupDir -PathType Container) -and
    ($env:PATH -split [IO.Path]::PathSeparator) -notcontains $dotnetupDir) {
    $env:PATH = "$dotnetupDir$([IO.Path]::PathSeparator)$env:PATH"
}

$theme = Join-Path $HOME '.config/oh-my-posh/theme.omp.json'

if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path $theme)) {
    oh-my-posh init pwsh --config $theme | Invoke-Expression
}

foreach ($module in @('posh-git', 'Terminal-Icons', 'z')) {
    if (Get-Module -ListAvailable -Name $module) {
        Import-Module $module -ErrorAction SilentlyContinue
    }
}

# PowerShell on macOS leaves ls mapped to the native executable by default.
# Use PowerShell objects so Terminal-Icons can format directory listings.
Set-Alias -Name ls -Value Get-ChildItem

if ($Host.Name -eq 'ConsoleHost' -and (Get-Module -ListAvailable -Name PSReadLine)) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}
