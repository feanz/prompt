# Adapted from https://github.com/deja666/wezterm-dotfiles at commit
# dfce3719b07820141965d2a549dd1c7cd536d0f5. See THIRD_PARTY_NOTICES.md.

$theme = Join-Path $HOME '.config/oh-my-posh/theme.omp.json'

if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path $theme)) {
    oh-my-posh init pwsh --config $theme | Invoke-Expression
}

foreach ($module in @('posh-git', 'Terminal-Icons', 'z')) {
    if (Get-Module -ListAvailable -Name $module) {
        Import-Module $module -ErrorAction SilentlyContinue
    }
}

if ($Host.Name -eq 'ConsoleHost' -and (Get-Module -ListAvailable -Name PSReadLine)) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}
