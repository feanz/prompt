#Update this to be chocolatey meta package

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

choco feature enable -n allowGlobalConfirmation

choco install git
choco install powershell-core
choco install oh-my-posh
choco install vim
choco install kdiff3
choco install gh
choco install bat

Install-Module PSReadline 
Install-Module terminal-icons.powershell
Install-Module z

