Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

winget install JanDeDobbeleer.OhMyPosh
winget install vim.vim
winget install KDE.KDiff3
winget install Github.cli --source winget
choco install bat

Install-Module PSReadline -RequiredVersion 2.2.0-beta1 -AllowPrerelease -Repository PSGallery
Install-Module Terminal-Icons
Install-Module z

