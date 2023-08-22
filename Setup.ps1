#Update this to be chocolatey meta package

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

choco install git
choco install powershell.portable
winget install JanDeDobbeleer.OhMyPosh
winget install vim.vim
winget install KDE.KDiff3
winget install Github.cli --source winget
choco install bat

Install-Module PSReadline 
Install-Module Terminal-Icons
Install-Module z

