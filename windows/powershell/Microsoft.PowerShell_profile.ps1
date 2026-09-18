$theme = Join-Path $HOME '.config\prompt\theme.omp.json'

if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path $theme)) {
    oh-my-posh init pwsh --config $theme | Invoke-Expression
}

foreach ($module in @('Terminal-Icons', 'z')) {
    if (Get-Module -ListAvailable -Name $module) {
        Import-Module $module
    }
}
