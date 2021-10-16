# Install git for windows https://git-scm.com/download/win
# Install the windows terminal from the windows store 
# Install and the latest version of powershell https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows
# Install nerd font https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

winget install JanDeDobbeleer.OhMyPosh
winget install vim.vim
winget install KDE.KDiff3
winget install Github.cli --source winget

Install-Module PSReadline -RequiredVersion 2.2.0-beta1 -AllowPrerelease -Repository PSGallery
Install-Module Terminal-Icons
Install-Module z