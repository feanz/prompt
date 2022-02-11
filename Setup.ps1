Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

winget install --id Git.Git -e --source winget
winget install --id Microsoft.Powershell --source winget
winget install JanDeDobbeleer.OhMyPosh
winget install vim.vim
winget install KDE.KDiff3
winget install Github.cli --source winget
choco install bat

Install-Module PSReadline 
Install-Module Terminal-Icons
Install-Module z

